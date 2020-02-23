#import <Foundation/Foundation.h>

#import "MPHStopsController.h"

@interface MPHMUNIStopsController : MPHStopsController <MPHStopsController>
@property (atomic, copy) NSArray *stops;
@end
