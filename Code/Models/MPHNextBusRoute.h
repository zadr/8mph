#import <Foundation/Foundation.h>

#import "MPHRoute.h"

@interface MPHNextBusRoute : NSObject <MPHRoute>
@property (copy) NSString *tag;
@property (copy) NSString *title;
@property (copy) NSArray *inboundRoutes;
@property (copy) NSArray *outboundRoutes;
@property MPHService service;
@property NSInteger rowID;
@end
