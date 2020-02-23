#import <Foundation/Foundation.h>

#import "MPHAmalgamation.h"

// Note on paths:
// NextBus data doesn't give us paths/points per direction, or enough information to be able to grab the data from MUNI instead
// -pointsForRoute: returns an array of arrays, where each array has a bunch of points in it.

@interface MPHMUNIAmalgamation : NSObject <MPHAmalgamation>
@end
