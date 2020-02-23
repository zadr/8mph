#import <Foundation/Foundation.h>

#import "MPHPrediction.h"

@interface MPH511Prediction : NSObject <MPHPrediction>
@property (copy) NSString *routeName;
@property (copy) NSString *routeCode;

@property (copy) NSString *stopName;
@property (copy) NSString *stopCode;

@property NSInteger minutes;
@end
