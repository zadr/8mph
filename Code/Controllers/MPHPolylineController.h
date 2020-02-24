#import <Foundation/Foundation.h>

#import "MPHRoute.h"

@class MPHRouteController;
@class MKPolylineRenderer;
@protocol MKOverlay;

@interface MPHPolylineController : NSObject
+ (MPHPolylineController *) polylineControllerForService:(MPHService) service;

- (NSArray *) polylinesForRoute:(id <MPHRoute>) route;
- (MKOverlayPathRenderer *) polylineViewForOverlay:(id <MKOverlay>) overlay;
@end
