#import "MPHTripPlannerViewController.h"

#import "MPHLocationCenter.h"

#import "MPHAnnotation.h"
#import "MPHWaypointEntryControl.h"

#import "MPHOTPPlanning.h"
#import "MPHOTPPlan.h"

#if defined(MPH_ENABLE_TRIP_PLANNING)
@interface MPHTripPlannerViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, MKMapViewDelegate>
@property (strong) MPHWaypointEntryControl *entryControl;

@property (strong) MKMapView *mapView;

@property (strong) MPHMapItemAnnotation *tappedAnnotation;
@property (strong) MPHMapItemAnnotation *fromAnnotation;
@property (strong) MPHMapItemAnnotation *toAnnotation;
@property (strong) NSMutableArray *annotationsToRemove;

@property (strong) CLGeocoder *geocoder;
@property (strong) MKLocalSearch *locationSearch;

@property (strong) UISearchDisplayController *tripSearchDisplayController;
@property (strong) NSArray *locationSearchMapItems;

@property BOOL isPickingDepartureLocation;

@property (nonatomic, strong) MPHOTPPlan *plan;
@property (strong) NSURLSessionTask *planTask;
@end

#pragma mark -

@implementation MPHTripPlannerViewController
- (id) init {
	if (!(self = [super init]))
		return nil;

	_entryControl = [[MPHWaypointEntryControl alloc] initWithFrame:CGRectZero];
	_mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
	_mapView.delegate = self;
	_tripSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_entryControl.searchBar contentsController:self];
	_tripSearchDisplayController.searchResultsDataSource = self;
	_tripSearchDisplayController.searchResultsDelegate = self;
	_tripSearchDisplayController.delegate = self;
	_annotationsToRemove = [NSMutableArray array];
	_isPickingDepartureLocation = YES;

	_geocoder = [[CLGeocoder alloc] init];

	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"New Trip", @"New Trip");

	[self.view addSubview:_mapView];
	[self.view addSubview:_entryControl];

	self.navigationController.navigationBarHidden = YES;

	UILongPressGestureRecognizer *startRequestingLocationDataGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startRequestingLocationData:)];
	startRequestingLocationDataGestureRecognizer.minimumPressDuration = .35;
	startRequestingLocationDataGestureRecognizer.delegate = self;
	[self.mapView addGestureRecognizer:startRequestingLocationDataGestureRecognizer];

	UILongPressGestureRecognizer *showPinForPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPinForPress:)];
	showPinForPressGestureRecognizer.minimumPressDuration = 1.;
	showPinForPressGestureRecognizer.delegate = self;
	[self.mapView addGestureRecognizer:showPinForPressGestureRecognizer];

//	if ([MPHLocationCenter locationCenter].currentLocation) {
//		self.mapView.centerCoordinate = [MPHLocationCenter locationCenter].currentLocation.coordinate;
//		self.mapView.region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(0.03125, 0.03125));
//	}
}

- (void) viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	self.mapView.frame = self.view.frame;

	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
		self.entryControl.frame = CGRectMake(0., 0., self.view.frame.size.width, 64.);
	else self.entryControl.frame = CGRectMake(0., 0., self.view.frame.size.width, 52.);
}

#pragma mark -

- (void) setPlan:(MPHOTPPlan *) plan {
	_plan = plan;

	[self.entryControl showWaypointSelectorFromPlan:_plan];
}
 
#pragma mark -

- (void) startRequestingLocationData:(UILongPressGestureRecognizer *) longPressGestureRecognizer {
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

    CGPoint locationInMapView = [longPressGestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D locationInMap = [self.mapView convertPoint:locationInMapView toCoordinateFromView:self.mapView];
	CLLocation *location = [[CLLocation alloc] initWithLatitude:locationInMap.latitude longitude:locationInMap.longitude];

	[self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		MKMapItem *mapItem = nil;

		if (!placemarks.count) {
			MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:locationInMap addressDictionary:nil];
			mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
		} else {
			MKPlacemark *newPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemarks.firstObject];
			mapItem = [[MKMapItem alloc] initWithPlacemark:newPlacemark];
		}

		MPHMapItemAnnotation *mapItemAnnotation = [MPHMapItemAnnotation annotationWithMapItem:mapItem];
		mapItemAnnotation.isDroppedPin = YES;

		if (self.tappedAnnotation)
			[self.annotationsToRemove addObject:self.tappedAnnotation];

		self.tappedAnnotation = mapItemAnnotation;
	}];
}

- (void) showPinForPress:(UILongPressGestureRecognizer *) longPressGestureRecognizer {
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

	[self.mapView removeAnnotations:self.annotationsToRemove];
	[self.mapView addAnnotation:self.tappedAnnotation];
	[self.mapView selectAnnotation:self.tappedAnnotation animated:YES];

	[self.annotationsToRemove removeAllObjects];
}

- (void) requestPlanFromMapItem:(MKMapItem *)fromItem toMapItem:(MKMapItem *)toItem {
	[self.planTask cancel];

	NSURLRequest *request = [NSURLRequest planTripWithParameters:@{
		MPHParameterPlanFromPlaceKey: [NSString stringWithFormat:@"%f,%f", fromItem.placemark.coordinate.latitude, fromItem.placemark.coordinate.longitude],
		MPHParameterPlanToPlaceKey: [NSString stringWithFormat:@"%f,%f", toItem.placemark.coordinate.latitude, toItem.placemark.coordinate.longitude],
	}];

	__weak __typeof__((self.planTask)) currentTask = self.planTask;
	__weak __typeof__((self)) weakSelf = self;
	self.planTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		__strong __typeof__((weakSelf)) strongSelf = weakSelf;
		__strong __typeof__((currentTask)) strongTask = currentTask;

		if (strongSelf.planTask != strongTask)
			return;

		strongSelf.plan = [MPHOTPPlan planFromData:data];
	}];
	[self.planTask resume];
}

#pragma mark -

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *) otherGestureRecognizer {
	return YES;
}

#pragma mark -

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
	if (!pinAnnotationView)
		pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
	pinAnnotationView.animatesDrop = YES;
	pinAnnotationView.canShowCallout = YES;
	pinAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	pinAnnotationView.rightCalloutAccessoryView.tintColor = [UIColor colorWithRed:(63. / 255.) green:(102. / 255.) blue:(246. / 255.) alpha:1.];

	if (annotation == self.tappedAnnotation)
		pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
	if (annotation == self.fromAnnotation)
		pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
	if (annotation == self.toAnnotation)
		pinAnnotationView.pinColor = MKPinAnnotationColorRed;

	return pinAnnotationView;
}

- (void) mapView:(MKMapView *) mapView annotationView:(MKAnnotationView *) view calloutAccessoryControlTapped:(UIControl *) control {

}

#pragma mark -

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	return self.locationSearchMapItems.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	MKMapItem *item = self.locationSearchMapItems[indexPath.row];
	NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:item.name attributes:nil];

	[title setAttributes:@{
		NSFontAttributeName: [UIFont boldSystemFontOfSize:17.]
	} range:[title.string rangeOfString:self.entryControl.searchBar.text options:(NSStringCompareOptions)(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch)]];

	cell.textLabel.attributedText = title;
	cell.detailTextLabel.text = item.placemark.mph_readableAddressString;
	cell.backgroundColor = [UIColor clearColor];

	return cell;
}

- (NSIndexPath *) tableView:(UITableView *) tableView willSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	MKMapItem *fromItem = self.isPickingDepartureLocation ? self.locationSearchMapItems[indexPath.row] : self.fromAnnotation.mapItem;
	MKMapItem *toItem = !self.isPickingDepartureLocation ? self.locationSearchMapItems[indexPath.row] : self.toAnnotation.mapItem;

	if (!fromItem || !toItem)
		return indexPath;

	[self requestPlanFromMapItem:fromItem toMapItem:toItem];

	return indexPath;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHMapItemAnnotation *oldAnnotation = nil;
	MPHMapItemAnnotation *newAnnotation = nil;
	MKMapItem *mapItem = self.locationSearchMapItems[indexPath.row];

	if (self.isPickingDepartureLocation) {
		self.isPickingDepartureLocation = NO;

		oldAnnotation = self.fromAnnotation;
		newAnnotation = [MPHMapItemAnnotation annotationWithMapItem:mapItem];

		self.fromAnnotation = newAnnotation;

		[self.entryControl slideFromDirection:MPHWaypointSlideDirectionPushFromRight simultaneouslyPerformingActions:^{
			self.entryControl.searchBar.text = nil;
			self.entryControl.searchBar.placeholder = NSLocalizedString(@"To…", @"To… search text");
		} completionHandler:NULL];
	} else {
		oldAnnotation = self.toAnnotation;
		newAnnotation = [MPHMapItemAnnotation annotationWithMapItem:mapItem];
		self.toAnnotation = newAnnotation;
	}

	[self.mapView removeAnnotation:oldAnnotation];
	[self.mapView addAnnotation:newAnnotation];

	[self.tripSearchDisplayController setActive:NO animated:YES];

	// dismiss search display control
	// swipe
}

#pragma mark -

- (void) searchDisplayController:(UISearchDisplayController *) controller didLoadSearchResultsTableView:(UITableView *) tableView {
	tableView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.7];
	tableView.separatorColor = [UIColor colorWithWhite:.2 alpha:.95];
	tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *) controller {
	self.entryControl.showingSearchController = YES;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *) controller {
	[UIView beginAnimations:nil context:NULL]; // animate in the current context and duration
	self.entryControl.showingSearchController = NO;
	[UIView commitAnimations];

	self.locationSearchMapItems = nil;

	[controller.searchResultsTableView reloadData];
}

- (BOOL) searchDisplayController:(UISearchDisplayController *) controller shouldReloadTableForSearchString:(NSString *) searchString {
	if (self.locationSearch.searching)
		[self.locationSearch cancel];

	MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
	searchRequest.naturalLanguageQuery = searchString;
	searchRequest.region = MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(0.125, 0.125));

	self.locationSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
	[self.locationSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
		self.locationSearchMapItems = response.mapItems;
		[controller.searchResultsTableView reloadData];
	}];

	return YES;
}
@end
#endif
