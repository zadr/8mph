 #import "MPHRouteViewController.h"

#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPHRouteMapViewController.h"
#import "MPHRouteTableViewController.h"

#import "MPHRoute.h"

#define MPHDefaultSegmentForRoute(route) \
	[NSString stringWithFormat:@"MPHDefaultSegmentForRoute-%@", route]

#define MPHDefaultViewForRoute(route) \
	[NSString stringWithFormat:@"MPHDefaultViewForRoute-%@", route]

typedef NS_ENUM(NSInteger, MPHView) {
	MPHViewList,
	MPHViewMap
};

@implementation MPHRouteViewController {
	id <MPHRouteController> _routeController;
	MPHRouteMapViewController *_mapViewContrller;
	MPHRouteTableViewController *_tableViewController;

	id <MPHRoute> _route;

	UISegmentedControl *_segmentedView;
}

- (id) initWithRoute:(id <MPHRoute>) route onService:(MPHService) service {
	if (!(self = [super init]))
		return nil;

	_route = route;

	_routeController = [MPHRouteController routeControllerForRoute:route onService:service];
	_routeController.delegate = self;

	_tableViewController = [[MPHRouteTableViewController alloc] initWithRouteController:_routeController];
	_mapViewContrller = [[MPHRouteMapViewController alloc] initWithRouteController:_routeController];

	MPHDirection selectedDirection = (MPHDirection)[[NSUserDefaults standardUserDefaults] integerForKey:MPHDefaultSegmentForRoute(_route.tag)];
	[_tableViewController directionSelected:selectedDirection];

	return self;
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.navigationController.navigationBar.barTintColor = _routeController.color.mph_darkenedColor;
	self.navigationController.toolbar.tintColor = _routeController.color.mph_darkenedColor;
	self.navigationController.toolbar.barTintColor = [UIColor lightTextColor];

	self.title = _route.name;

	_segmentedView = [[UISegmentedControl alloc] initWithItems:_routeController.directionTitles];
	_segmentedView.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:MPHDefaultSegmentForRoute(_route.tag)];

	[_segmentedView addTarget:self action:@selector(directionSegmentSelected:) forControlEvents:UIControlEventValueChanged];

	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_segmentedView];

	[self setToolbarItems:@[item] animated:NO];

	[self addChildViewController:_mapViewContrller];
	[self addChildViewController:_tableViewController];

	_tableViewController.edgesForExtendedLayout = (UIRectEdgeTop | UIRectEdgeBottom);

	switch ([[NSUserDefaults standardUserDefaults] integerForKey:MPHDefaultViewForRoute(_route.tag)]) {
	case MPHViewList:
		[self.navigationController setToolbarHidden:NO animated:YES];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(flipViewsAround:)];

		[self.view addSubview:_tableViewController.tableView];

		_tableViewController.tableView.frame = self.view.bounds;
		break;
	case MPHViewMap:
		[self.navigationController setToolbarHidden:YES animated:YES];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Times" style:UIBarButtonItemStylePlain target:self action:@selector(flipViewsAround:)];

		_mapViewContrller.mapView.centerCoordinate = [MPHLocationCenter locationCenter].currentLocation.coordinate;
		_mapViewContrller.mapView.region = MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(0.03125, 0.03125));
		_mapViewContrller.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
		_mapViewContrller.mapView.frame = self.view.bounds;

		[self.view addSubview:_mapViewContrller.mapView];
		break;
	}
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void) viewWillLayoutSubviews {
	CGRect frame = CGRectZero;
	frame.size.width = CGRectGetWidth(self.view.frame) - 30.;
	if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
		frame.size.height = 32.;
	else frame.size.height = 24.;
	_segmentedView.frame = frame;
}

- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

- (void) viewWillTransitionToSize:(CGSize) size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>) coordinator {
	[coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
		CGRect frame = _tableViewController.view.frame;
		frame.size = size;
		_tableViewController.view.frame = frame;
		_mapViewContrller.view.frame = frame;
	} completion:nil];
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
	return YES;
}

- (UIViewController *) childViewControllerForStatusBarStyle {
	if (_tableViewController.tableView.superview)
		return _tableViewController;
	return nil;
}

- (UIViewController *) childViewControllerForStatusBarHidden {
	if (_tableViewController.tableView.superview)
		return _tableViewController;
	return nil;
}


#pragma mark -

- (void) routeController:(id <MPHRouteController>) routeController didLoadPredictionsForDirection:(MPHDirection) direction {
	BOOL updateForInbound = (direction == MPHDirectionInbound && _segmentedView.selectedSegmentIndex == 0);
	BOOL updateForOutbound = (direction == MPHDirectionOutbound && _segmentedView.selectedSegmentIndex == 1);
	BOOL update = direction == MPHDirectionIgnored;

	if (updateForInbound || updateForOutbound || update)
		dispatch_async(dispatch_get_main_queue(), ^{
			[_tableViewController.tableView reloadData];
		});
}
// the display of data about a route, ,  from an
- (void) routeControllerDidLoadVehicleLocations:(id <MPHRouteController>) routeController {
	
}

#pragma mark -

- (void) directionSegmentSelected:(id) sender {
	MPHDirection direction = (MPHDirection)_segmentedView.selectedSegmentIndex;
	[_tableViewController directionSelected:direction];

	[[NSUserDefaults standardUserDefaults] setInteger:_segmentedView.selectedSegmentIndex forKey:MPHDefaultSegmentForRoute(_route.tag)];
}

- (void) flipViewsAround:(id) sender {
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];

	if (_tableViewController.tableView.superview) {
		[self.navigationController setToolbarHidden:YES animated:YES];
		self.navigationItem.rightBarButtonItem.title = @"Times";

		[[NSUserDefaults standardUserDefaults] setInteger:MPHViewMap forKey:MPHDefaultViewForRoute(_route.tag)];

		_mapViewContrller.mapView.centerCoordinate = [MPHLocationCenter locationCenter].currentLocation.coordinate;
		_mapViewContrller.mapView.region = MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(0.03125, 0.03125));

        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];

		_mapViewContrller.mapView.frame = _tableViewController.tableView.frame;

		[_tableViewController.tableView removeFromSuperview];

		[self.view addSubview:_mapViewContrller.mapView];
	} else if (_mapViewContrller.mapView.superview) {
		[self.navigationController setToolbarHidden:NO animated:YES];
		self.navigationItem.rightBarButtonItem.title = @"Map";

		[[NSUserDefaults standardUserDefaults] setInteger:MPHViewList forKey:MPHDefaultViewForRoute(_route.tag)];

        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];

		_tableViewController.tableView.frame = _mapViewContrller.mapView.frame;

		[_mapViewContrller.mapView removeFromSuperview];

		[self.view addSubview:_tableViewController.tableView];
	}

	[UIView commitAnimations];
}
@end
