#import "MPHPrediction.h"

@interface MPHNextBusPrediction : NSObject <MPHPrediction>
// Set from prediction data
@property NSTimeInterval epochTime;
@property NSTimeInterval seconds;
@property NSTimeInterval minutes;
@property (copy) NSString *vehicle;
@property (copy) NSString *stopTag;
@property (copy) NSString *direction;
@property (copy) NSString *trip;
@property (copy) NSString *routeTitle;
@property (copy) NSString *stopTitle;
@end
