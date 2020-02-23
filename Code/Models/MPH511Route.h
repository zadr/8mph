#import <Foundation/Foundation.h>

#import "MPHRoute.h"

@interface MPH511Route : NSObject <MPHRoute>
@property (copy) NSString *routeName;
@property (copy) NSString *routeCode;
@property (copy) NSString *directionName;
@property (copy) NSString *directionCode;
@property NSInteger rowID;
@end
