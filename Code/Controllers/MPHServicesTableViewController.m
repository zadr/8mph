#import "MPHServicesTableViewController.h"

#import "MPHTripPlannerViewController.h"
#import "MPHNearbyStopsViewController.h"

#import "MPHRoutesViewController.h"
#import "MPHStopsViewController.h"

#import "MPHUtilities.h"

typedef NS_ENUM(NSInteger, MPHSection) {
	MPHSectionPlanATrip,
	MPHSectionServices,
	MPHSectionFavoriteStops,
	MPHSectionCount // must stay at the bottom
};

typedef NS_ENUM(NSInteger, MPHServiceRow) {
	MPHServiceRowMUNI,
	MPHServiceRowBART,
//	MPHServiceRowCaltrain,
	MPHServiceRowCount,

	MPHServiceRowACTransit,
	MPHServiceRowDumbartonExpress,
	MPHServiceRowSamTrans,
	MPHServiceRowVTA,
	MPHServiceRowWestCat,
//	MPHServiceRowCount
};

typedef NS_ENUM(NSInteger, MPHTripPlanningSection) {
#if defined(MPH_ENABLE_TRIP_PLANNING)
	MPHTripPlanningSectionPlan,
#endif
	MPHTripPlanningSectionNearby
};

@implementation MPHServicesTableViewController {
	BOOL _hasPresentedService;
}

- (id) init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	self.navigationController.hidesBarsOnSwipe = NO;
	self.navigationController.hidesBarsOnTap = NO;
	self.navigationController.hidesBarsWhenVerticallyCompact = NO;
}

#pragma mark -

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

	if (indexPath.section == MPHSectionServices) {
		cell.textLabel.text = NSStringFromMPHService((MPHService)(indexPath.row + 1));

		if (indexPath.row == MPHServiceRowMUNI)
			cell.imageView.image = [[UIImage imageNamed:@"bus-4"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		else if (indexPath.row == MPHServiceRowBART)
			cell.imageView.image = [[UIImage imageNamed:@"train-3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//		else if (indexPath.row == MPHServiceRowCaltrain)
//			cell.imageView.image = [[UIImage imageNamed:@"train-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	} else if (indexPath.section == MPHSectionPlanATrip) {
#if defined(MPH_ENABLE_TRIP_PLANNING)
		if (indexPath.row == MPHTripPlanningSectionPlan) {
			cell.textLabel.text = NSLocalizedString(@"Plan A Trip", @"Plan A Trip row title");
			cell.imageView.image = [[UIImage imageNamed:@"directions-3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		} else
#endif
		if (indexPath.row == MPHTripPlanningSectionNearby) {
			cell.textLabel.text = NSLocalizedString(@"Nearby", @"Nearby row title");
			cell.imageView.image = [[UIImage imageNamed:@"nearby-3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
	}

	cell.imageView.frame = CGRectMake(0., 0., 28., 28.);
	cell.imageView.contentMode = UIViewContentModeCenter;

	return cell;
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	if (section == MPHSectionServices)
		return NSLocalizedString(@"Find Times", @"Find Times");
	if (section == MPHSectionFavoriteStops)
		return NSLocalizedString(@"Favorite Stops", @"Favorite Stops section title");
	return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
	return MPHSectionCount;
}

#pragma mark -

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if (section == MPHSectionServices) 
		return MPHServiceRowCount;
#if defined(MPH_ENABLE_TRIP_PLANNING)
	if (section == MPHSectionPlanATrip)
		return 2;
#else
	if (section == MPHSectionPlanATrip)
		return 1;
#endif
	return 0;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	UIViewController *viewController = nil;

	if (indexPath.section == MPHSectionPlanATrip) {
#if defined(MPH_ENABLE_TRIP_PLANNING)
		if (indexPath.row == MPHTripPlanningSectionPlan)
			viewController = [[MPHTripPlannerViewController alloc] init];
#endif
		if (indexPath.row == MPHTripPlanningSectionNearby)
			viewController = [[MPHNearbyStopsViewController alloc] init];
	}

	if (indexPath.section == MPHSectionServices) {
		if (indexPath.row == MPHServiceRowMUNI)
			viewController = [[MPHRoutesViewController alloc] initWithService:MPHServiceMUNI];
		if (indexPath.row == MPHServiceRowBART)
			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceBART];
//		if (indexPath.row == MPHServiceRowCaltrain)
//			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceCaltrain];
		if (indexPath.row == MPHServiceRowACTransit)
			viewController = [[MPHRoutesViewController alloc] initWithService:MPHServiceACTransit];
		if (indexPath.row == MPHServiceRowDumbartonExpress)
			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceDumbartonExpress];
		if (indexPath.row == MPHServiceRowSamTrans)
			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceSamTrans];
		if (indexPath.row == MPHServiceRowVTA)
			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceVTA];
		if (indexPath.row == MPHServiceRowWestCat)
			viewController = [[MPHStopsViewController alloc] initWithService:MPHServiceWestCat];
	}

	[self.navigationController pushViewController:viewController animated:_hasPresentedService];

	_hasPresentedService = YES;
}
@end
