#import "MPHStop.h"

@interface MPH511Stop : NSObject <MPHStop>
@property (copy) NSString *stopName;
@property (copy) NSArray *stopCodes;
@property (copy) NSString *routeCode;
@property (copy) NSString *directionCode;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property NSInteger rowID;
@end
