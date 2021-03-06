#import "MPHRoutesViewController.h"

#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"
#import "MPHRouteViewController.h"

#import "MPHImageGenerator.h"

#import "MPHAlertsTableViewController.h"

#import "MPHRoute.h"

#import "UIColorAdditions.h"

@implementation MPHRoutesViewController {
	MPHService _service;

	NSArray *_routes;
	NSArray *_nearbyRoutes;

	NSMutableDictionary *_cachedRouteImages;
	MPHImageGenerator *_imageGenerator;
}

- (id) initWithService:(MPHService) service {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_service = service;
	_routes = [[[MPHAmalgamator amalgamator] routesForService:service sorted:YES] copy];
	_imageGenerator = [[MPHImageGenerator alloc] init];

	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	self.tableView.rowHeight = 46.;

	[self detectNearbyRoutes];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Alerts" style:UIBarButtonItemStylePlain target:self action:@selector(showAlerts:)];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:MPHLocationDidUpdateNotification object:nil];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPHLocationDidUpdateNotification object:nil];
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	self.title = NSStringFromMPHService(_service);
	self.navigationController.navigationBar.barTintColor = UIColorForMPHService(_service);
	self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.barTintColor;
	self.navigationController.toolbar.barTintColor = [UIColor lightTextColor];
}

#pragma mark -

- (void) locationDidUpdate:(NSNotification *) notification {
	[self detectNearbyRoutes];
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
	if (_nearbyRoutes.signedCount)
		return 2;
	return 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if ([self _sectionIsNearbyStops:section])
		return _nearbyRoutes.signedCount;
	return _routes.signedCount;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}

	id <MPHRoute> route = nil;
	if ([self _sectionIsNearbyStops:indexPath.section])
		route = [_nearbyRoutes objectAtSignedIndex:indexPath.row];
	else route = [_routes objectAtSignedIndex:indexPath.row];

	NSRange dashRange = [route.name rangeOfString:@"-"];
	if (dashRange.location != NSNotFound)
		cell.textLabel.text = [route.name substringFromIndex:dashRange.location + dashRange.length];
	else cell.textLabel.text = route.name;
	cell.imageView.image = _cachedRouteImages[route.name];

	if (!cell.imageView.image) {
		NSString *text = dashRange.location != NSNotFound ? [route.name substringToIndex:dashRange.location] : route.tag;
		UIImage *image = [_imageGenerator generateImageWithParameters:@{
			MPHImageFillColor: route.color,
			MPHImageText: text,
			MPHImageFont: text.length <= 3 ? (text.length == 3 ? [UIFont systemFontOfSize:24] : [UIFont systemFontOfSize:28]) : [UIFont systemFontOfSize:22],
			MPHImageRadius: @(35)
		}];
		_cachedRouteImages[route.name] = image;

		cell.imageView.contentMode = UIViewContentModeCenter;
		cell.imageView.image = image;
		cell.imageView.transform = CGAffineTransformMakeScale(.5, .5);
	}

	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	id route = nil;
	if ([self _sectionIsNearbyStops:indexPath.section])
		route = [_nearbyRoutes objectAtSignedIndex:indexPath.row];
	else route = [_routes objectAtSignedIndex:indexPath.row];

	MPHRouteViewController *routeViewController = [[MPHRouteViewController alloc] initWithRoute:route onService:_service];

	[self.navigationController pushViewController:routeViewController animated:YES];
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	if ([self numberOfSectionsInTableView:tableView] == 2) {
		if (section == 0)
			return NSLocalizedString(@"Nearby Lines", @"Nearby Lines");
		return NSLocalizedString(@"All Lines", @"All Lines");
	}
	return nil;
}

#pragma mark -

- (void) detectNearbyRoutes {
	if (![MPHLocationCenter locationCenter].currentLocation)
		return;

	MKCoordinateRegion region = MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(MPHNearbyDefaultDistance, MPHNearbyDefaultDistance));

	_nearbyRoutes = [[MPHAmalgamator amalgamator] routesForService:_service inRegion:region];

	[self.tableView reloadData];
}

- (void) showAlerts:(id) sender {
	MPHAlertsTableViewController *alertsTableViewController = [[MPHAlertsTableViewController alloc] initWithAlerts:[[MPHAmalgamator amalgamator] messagesForService:_service]];

	[self.navigationController pushViewController:alertsTableViewController animated:YES];
}

#pragma mark -

- (BOOL) _sectionIsNearbyStops:(NSInteger) section {
	return (section == 0) && (_nearbyRoutes.count != 0);
}
@end
