#import "MPHRoute.h"

@class MPHRouteController;

@interface MPHPolylineController : NSObject
+ (MPHPolylineController *) polylineControllerForService:(MPHService) service;

- (NSArray *) polylinesForRoute:(id <MPHRoute>) route;
- (MKPolylineRenderer *) polylineViewForOverlay:(id <MKOverlay>) overlay;
@end
