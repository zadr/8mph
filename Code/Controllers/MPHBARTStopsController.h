#import <Foundation/Foundation.h>

#import "MPHStopsController.h"

@interface MPHBARTStopsController : MPHStopsController <MPHStopsController>
@property (atomic, copy) NSArray *stops;
@end
