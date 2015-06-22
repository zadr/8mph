#import "MPHStopsController.h"

@interface MPH511StopsController : MPHStopsController <MPHStopsController>
- (id) initWithService:(MPHService) service;
@property (atomic, copy) NSArray *stops;
@end
