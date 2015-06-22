#import "MPHMapViewController.h"

@protocol MPHRouteController;

@interface MPHRouteMapViewController : MPHMapViewController
- (id) initWithRouteController:(id <MPHRouteController>) routeController;
@end
