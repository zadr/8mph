#import <Foundation/Foundation.h>

// Eventually, this will support more than Caltrain.

#import "MPHAmalgamation.h"

@interface MPH511Amalgamation : NSObject <MPHAmalgamation>
@end

@interface MPHCaltrainAmalgamation : MPH511Amalgamation
@end

@interface MPHACTransitAmalgamation : MPH511Amalgamation
@end

@interface MPHDumbartonAmalgamation : MPH511Amalgamation
@end

@interface MPH511MUNIAmalgamation : MPH511Amalgamation
@end

@interface MPHSamTransAmalgamation : MPH511Amalgamation
@end

@interface MPHVTAAmalgamation : MPH511Amalgamation
@end

@interface MPHWestcatAmalgamation : MPH511Amalgamation
@end
