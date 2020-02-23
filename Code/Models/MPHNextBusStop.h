#import <Foundation/Foundation.h>

#import "MPHStop.h"

@interface MPHNextBusStop : NSObject <MPHStop>
@property NSInteger tag;
@property NSUInteger identifier;
@property (copy) NSString *title;
@property CLLocationCoordinate2D coordinate;
@property NSInteger rowID;

@property (copy) NSString *routeTag;
@end
