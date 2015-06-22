#import "MPHTableViewController.h"

#import "MPHRouteController.h"

#import "MPHRoute.h"

@interface MPHRouteViewController : UIViewController <MPHRouteControllerDelegate>
- (id) initWithRoute:(id <MPHRoute>) route onService:(MPHService) service;
@end
