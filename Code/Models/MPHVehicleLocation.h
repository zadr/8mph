#import "MPHRoute.h"

@interface MPHVehicleLocation : NSObject

@property (atomic, copy) NSString *vehicleIdentifier;
@property (atomic, copy) NSString *routeTag;
@property (atomic, copy) NSString *directionTag;
@property (atomic, assign) CLLocationCoordinate2D coordinate;
@property (atomic, assign) NSTimeInterval secondsSinceLastReport;
@property (atomic, assign) BOOL predictable;
@property (atomic, assign) CLLocationDegrees heading;
@property (atomic, assign) CLLocationSpeed speed;

@end
