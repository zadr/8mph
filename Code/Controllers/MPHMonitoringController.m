#import "MPHMonitoringController.h"

@implementation MPHMonitoringController
+ (instancetype) monitoringController {
	static MPHMonitoringController *monitoringController = nil;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		monitoringController = [[MPHMonitoringController alloc] init];
	});

	return monitoringController;
}

- (void) beginMonitoringRoute:(id <MPHRoute>) route {
	//
}

- (void) endMonitoringRoute:(id <MPHRoute>) route {
	//
}
@end
