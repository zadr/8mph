#import "MPHPrediction.h"

@interface MPHBARTPrediction : NSObject <MPHPrediction>
@property (copy) NSString *destination;
@property (copy) NSString *abbreviation;

@property NSInteger minutes;
@property NSUInteger platform;
@property NSUInteger carLength;
@property BOOL bikesAvailable;
@property MPHBARTDirection direction;

#if TARGET_OS_IPHONE
@property (copy) UIColor *color;
- (void) setColorFromHexString:(NSString *) hexString;
#endif
@end
