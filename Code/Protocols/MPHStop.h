#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "MPHDefines.h"

@protocol MPHStop <NSObject, NSCopying>
@required
- (NSString *) name;
- (CLLocationCoordinate2D) coordinate;
- (NSInteger) tag;

- (NSInteger) rowID;

- (id) link;

- (NSString *) routeTag;

- (MPHService)service;
@end
