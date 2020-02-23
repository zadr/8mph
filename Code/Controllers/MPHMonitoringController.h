#import <Foundation/Foundation.h>

@protocol MPHRoute;

@interface MPHMonitoringController : NSObject
+ (instancetype) monitoringController;

- (void) beginMonitoringRoute:(id <MPHRoute>) route;
- (void) endMonitoringRoute:(id <MPHRoute>) route;
@end
