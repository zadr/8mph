#import "MPHRoute.h"

@interface MPHBARTRoute : NSObject <MPHRoute>
@property MPHService service;

@property (copy) NSString *name;
@property (copy) NSString *abbreviation;
@property (copy) NSString *routeIdentifier;
@property NSInteger number;
@property (copy) NSArray *stops;

#if TARGET_OS_IPHONE
@property (retain) UIColor *color;
#endif

@property NSInteger rowID;
@end
