#import <UIKit/UIKit.h>

@interface UIColor (Hex)
+ (UIColor *) mph_colorFromHexString:(NSString *) string;

+ (UIColor *) MUNIColor;
+ (UIColor *) MUNIFColor;
+ (UIColor *) MUNIJColor;
+ (UIColor *) MUNIKColor;
+ (UIColor *) MUNILColor;
+ (UIColor *) MUNIMColor;
+ (UIColor *) MUNINColor;
+ (UIColor *) MUNISColor;
+ (UIColor *) MUNITColor;

+ (UIColor *) MUNIGreenColor;
+ (UIColor *) MUNIPinkColor;
+ (UIColor *) MUNIVioletColor;
+ (UIColor *) MUNIAquaColor;
+ (UIColor *) MUNIOrangeColor;
+ (UIColor *) MUNIPaleOrangeColor;

+ (UIColor *) MUNIPowellMasonColor;
+ (UIColor *) MUNIPowellHydeColor;
+ (UIColor *) MUNICaliforniaColor;

+ (UIColor *) BARTColor;

+ (UIColor *) caltrainColor;

- (NSComparisonResult) mph_compare:(UIColor *) color;

- (UIColor *) mph_darkenedColor;
@end
