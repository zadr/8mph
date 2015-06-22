#import "MPHRouteController.h"

#import "MPH511RouteController.h"
#import "MPHBARTRouteController.h"
#import "MPHMUNIRouteController.h"

@implementation MPHRouteController
+ (id <MPHRouteController>) routeControllerForRoute:(id <MPHRoute>) route onService:(MPHService) service {
	switch (service) {
	case MPHServiceBART:
		return [[MPHBARTRouteController alloc] initWithRoute:route];
	case MPHServiceCaltrain:
	case MPHServiceACTransit:
	case MPHServiceDumbartonExpress:
	case MPHServiceSamTrans:
	case MPHServiceVTA:
	case MPHServiceWestCat:
		return [[MPH511RouteController alloc] initWithRoute:route];
	case MPHServiceMUNI:
		return [[MPHMUNIRouteController alloc] initWithRoute:route];
	case MPHServiceNone:
		return nil;
	}
}
@end
