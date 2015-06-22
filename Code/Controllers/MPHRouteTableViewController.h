#import "MPHTableViewController.h"

@protocol MPHRouteController;

@interface MPHRouteTableViewController : MPHTableViewController
- (id) initWithRouteController:(id <MPHRouteController>) routeController;

- (void) directionSelected:(MPHDirection) direction;
@end
