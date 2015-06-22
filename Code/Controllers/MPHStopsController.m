#import "MPHStopsController.h"

#import "MPH511StopsController.h"
#import "MPHBARTStopsController.h"
#import "MPHMUNIStopsController.h"

@implementation MPHStopsController
+ (id <MPHStopsController>) stopsControllerForService:(MPHService) service {
	switch (service) {
	case MPHServiceBART:
		return [[MPHBARTStopsController alloc] init];
	case MPHServiceCaltrain:
	case MPHServiceACTransit:
	case MPHServiceDumbartonExpress:
	case MPHServiceSamTrans:
	case MPHServiceVTA:
	case MPHServiceWestCat:
		return [[MPH511StopsController alloc] initWithService:service];
	case MPHServiceMUNI:
		return [[MPHMUNIStopsController alloc] init];
	case MPHServiceNone:
		return nil;
	}
}

+ (id <MPHStopsController>) stopsControllerForService:(MPHService) service withStops:(NSArray *) stops {
	id <MPHStopsController> stopsController = [self stopsControllerForService:service];
	stopsController.stops = stops;

	return stopsController;
}
@end
