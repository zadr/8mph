#import <UIKit/UIKit.h>

@interface UIColor (Hex)
+ (UIColor *) mph_colorFromHexString:(NSString *) string;
@end

@interface UIColor (MUNIV1)
+ (UIColor *) MUNIColorV1;
+ (UIColor *) MUNIFColorV1;
+ (UIColor *) MUNIJColorV1;
+ (UIColor *) MUNIKColorV1;
+ (UIColor *) MUNILColorV1;
+ (UIColor *) MUNIMColorV1;
+ (UIColor *) MUNINColorV1;
+ (UIColor *) MUNISColorV1;
+ (UIColor *) MUNITColorV1;

+ (UIColor *) MUNIGreenColorV1;
+ (UIColor *) MUNIPinkColorV1;
+ (UIColor *) MUNIVioletColorV1;
+ (UIColor *) MUNIAquaColorV1;
+ (UIColor *) MUNIOrangeColorV1;
+ (UIColor *) MUNIPaleOrangeColorV1;

+ (UIColor *) MUNIPowellMasonColorV1;
+ (UIColor *) MUNIPowellHydeColorV1;
+ (UIColor *) MUNICaliforniaColorV1;
@end

@interface UIColor (MUNIV2)
+ (UIColor *) MUNIEColor;
+ (UIColor *) MUNIFColor;
+ (UIColor *) MUNIJColor;
+ (UIColor *) MUNIKColor;
+ (UIColor *) MUNILColor;
+ (UIColor *) MUNILOwlColor;
+ (UIColor *) MUNIOwlColor;
+ (UIColor *) MUNIMColor;
+ (UIColor *) MUNINColor; // N, N Owl
+ (UIColor *) MUNISColor;
+ (UIColor *) MUNITColor;
+ (UIColor *) MUNIPowellMasonCableCarColor;
+ (UIColor *) MUNIPowellHydeCableCarColor;
+ (UIColor *) MUNICaliforniaCableCarColor;
+ (UIColor *) MUNIPinkColor; // 1AX, 1BX, 31AX, 31BX, 38AX, 38BX, 7X, 81X, 83X
+ (UIColor *) MUNIPinkAltColor; // 30X, 82X, 88, NX
+ (UIColor *) MUNIPinkAlt2Color; // 8AX, 8BX
+ (UIColor *) MUNISalmonColor; // J Bus, KT Bus, L Bus, M Bus, N Bus
+ (UIColor *) MUNIOrangeColor; // 18, 19, 22, 24, 28R, 29, 33, 44, 47, 49, 55
+ (UIColor *) MUNIOrangeAltColor; // 28, 48
+ (UIColor *) MUNIGreenColor; // 1, 2, 21, 3, 31, 38, 38R, 6, 7
+ (UIColor *) MUNIGreenAltColor; // 5
+ (UIColor *) MUNINCSBlueAltColor; // 5R
+ (UIColor *) MUNINCSBlueColor; // 35, 36, 37, 39, 52, 54, 56, 57, 66, 67
+ (UIColor *) MUNINavyBlueAltColor; // 45
+ (UIColor *) MUNINavyBlueColor; // 714, 78X, 79X
+ (UIColor *) MUNICrayolaBlue; // 43
+ (UIColor *) MUNIMunsellBlueColor; // 23
+ (UIColor *) MUNIPompAndPowerPurpleColor; // 90, 91
+ (UIColor *) MUNIPurpleNavyColor; // 10, 12, 14, 14R, 14X, 25, 30, 41, 76X, 9, 9R
+ (UIColor *) MUNIPurpleNavyAltColor; // 27, 8
@end

@interface UIColor (BART)
+ (UIColor *) BARTColor;
@end

@interface UIColor (Caltrain)
+ (UIColor *) caltrainColor;
@end

@interface UIColor (Additions)
- (NSComparisonResult) mph_compare:(UIColor *) color;

- (UIColor *) mph_lightenedColor;
- (UIColor *) mph_darkenedColor;
@end
