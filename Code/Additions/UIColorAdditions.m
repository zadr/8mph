#import "UIColorAdditions.h"

@implementation UIColor (Hex)
+ (UIColor *) mph_colorFromHexString:(NSString *) string {
	if (string.length != 7 && string.length != 6) {
		NSLog(@"Unable to create a color from invalid input: '%@'", string);

		return nil;
	}

	NSUInteger index = [string hasPrefix:@"#"] ? 1 : 0;

	unsigned int redColor = 0;
	unsigned int greenColor = 0;
	unsigned int blueColor = 0;
	NSScanner *redScanner = [NSScanner scannerWithString:[string substringWithRange:NSMakeRange(index, 2)]];
	[redScanner scanHexInt:&redColor];

	NSScanner *greenScanner = [NSScanner scannerWithString:[string substringWithRange:NSMakeRange(index + 2, 2)]];
	[greenScanner scanHexInt:&greenColor];

	NSScanner *blueScanner = [NSScanner scannerWithString:[string substringWithRange:NSMakeRange(index + 4, 2)]];
	[blueScanner scanHexInt:&blueColor];

	return [UIColor colorWithRed:(redColor / 255.) green:(greenColor / 255.) blue:(blueColor / 255.) alpha:1.];
}
@end

@implementation UIColor (MUNIV1)

+ (UIColor *) MUNIColorV1 {
	return [UIColor colorWithRed:(168. / 255.) green:(48. / 255.) blue:(1. / 255.) alpha:1.];
}

+ (UIColor *) MUNIFColorV1 {
	return [UIColor colorWithRed:(0xE8 / 255.) green:(0x83 / 255.) blue:(0x8e / 255.) alpha:1.];
}

+ (UIColor *) MUNIJColorV1 {
	return [UIColor colorWithRed:(0xFA / 255.) green:(0xA6 / 255.) blue:(0x34 / 255.) alpha:1.];
}

+ (UIColor *) MUNIKColorV1 {
	return [UIColor colorWithRed:(0x56 / 255.) green:(0x9B / 255.) blue:(0xBE / 255.) alpha:1.];
}

+ (UIColor *) MUNILColorV1 {
	return [UIColor colorWithRed:(0x92 / 255.) green:(0x27 / 255.) blue:(0x8F / 255.) alpha:1.];
}

+ (UIColor *) MUNIMColorV1 {
	return [UIColor colorWithRed:(0x00 / 255.) green:(0x87 / 255.) blue:(0x52 / 255.) alpha:1.];
}

+ (UIColor *) MUNINColorV1 {
	return [UIColor colorWithRed:(0x00 / 255.) green:(0x53 / 255.) blue:(0x9B / 255.) alpha:1.];
}

+ (UIColor *) MUNISColorV1 {
	return [UIColor colorWithRed:(0xFF / 255.) green:(0xCC / 255.) blue:(0x00 / 255.) alpha:1.];
}

+ (UIColor *) MUNITColorV1 {
	return [UIColor colorWithRed:(0xD3 / 255.) green:(0x12 / 255.) blue:(0x45 / 255.) alpha:1.];
}

#pragma mark -

// 1, 2, 3, 5, 5L, 6, 21, 31, 38, 38L, 71, 71L
+ (UIColor *) MUNIGreenColorV1 {
	return [UIColor colorWithRed:(14. / 255.) green:(178. / 255.) blue:(75. / 255.) alpha:1.];
}

// 1ax, 1bx, 8x, 8ax, 8bx, 16x, 30x, 31ax, 31bx, 38ax, 38bx, 81x, 82x, 83x, 88, 108, nx
+ (UIColor *) MUNIPinkColorV1 {
	return [UIColor colorWithRed:(243. / 255.) green:(134. / 255.) blue:(168. / 255.) alpha:1.];
}

// 9, 9L, 10, 12, 14, 14L, 27, 30, 41, 45, 76X,
+ (UIColor *) MUNIVioletColorV1 {
	return [UIColor colorWithRed:(125. / 255.) green:(128. / 255.) blue:(189. / 255.) alpha:1.];
}

// 17, 35, 36, 37, 39, 52, 56, 66, 67
+ (UIColor *) MUNIAquaColorV1 {
	return [UIColor colorWithRed:0. green:(174. / 255.) blue:(230. / 255.) alpha:1.];
}

// 18, 19, 22, 24, 28, 29, 33, 44, 49
+ (UIColor *) MUNIOrangeColorV1 {
	return [UIColor colorWithRed:(236. / 255.) green:(125. / 255.) blue:(31. / 255.) alpha:1.];
}

// 23, 28L, 43, 47, 54
+ (UIColor *) MUNIPaleOrangeColorV1 {
	return [UIColor colorWithRed:(238. / 255.) green:(143. / 255.) blue:(49. / 255.) alpha:1.];
}

#pragma mark -

+ (UIColor *) MUNIPowellMasonColorV1 {
	return [UIColor colorWithRed:(104. / 255.) green:(168. / 255.) blue:(188. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPowellHydeColorV1 {
	return [UIColor colorWithRed:(68. / 255.) green:(173. / 255.) blue:(165. / 255.) alpha:1.];
}

+ (UIColor *) MUNICaliforniaColorV1 {
	return [UIColor colorWithRed:(131. / 255.) green:(174. / 255.) blue:(190. / 255.) alpha:1.];
}

// F, J, K, L, M, N, T, Cali, PM, PH, 1, 5, 6, 8x, 9, 14, 22, 24, 28, 29, 30, 31, 38, 43, 44, 47, 49, 71, nx,
+ (UIColor *) MUNIGrayOutlineColor {
	return [UIColor colorWithRed:(125. / 255.) green:(111. / 255.) blue:(108. / 255.) alpha:1.];
}
@end

@implementation UIColor (MUNIV2)
+ (UIColor *) MUNIEColor {
	return [UIColor colorWithRed:(66. / 255.) green:(141. / 255.) blue:(138. / 255.) alpha:1.];
}

+ (UIColor *) MUNIFColor {
	return [UIColor colorWithRed:(207. / 255.) green:(128. / 255.) blue:(133. / 255.) alpha:1.];
}

+ (UIColor *) MUNIJColor {
	return [UIColor colorWithRed:(187. / 255.) green:(111. / 255.) blue:(55. / 255.) alpha:1.];
}

+ (UIColor *) MUNIKColor {
	return [UIColor colorWithRed:(112. / 255.) green:(181. / 255.) blue:(185. / 255.) alpha:1.];
}

+ (UIColor *) MUNILColor {
	return [UIColor colorWithRed:(119. / 255.) green:(52. / 255.) blue:(120. / 255.) alpha:1.];
}

+ (UIColor *) MUNILOwlColor {
	return [UIColor colorWithRed:(119. / 255.) green:(52. / 255.) blue:(120. / 255.) alpha:1.];
}

+ (UIColor *) MUNIOwlColor {
	return [UIColor colorWithRed:(131. / 255.) green:(120. / 255.) blue:(114. / 255.) alpha:1.];
}

+ (UIColor *) MUNIMColor {
	return [UIColor colorWithRed:(0. / 255.) green:(138. / 255.) blue:(91. / 255.) alpha:1.];
}

+ (UIColor *) MUNINColor { // N, N Owl
	return [UIColor colorWithRed:(64. / 255.) green:(116. / 255.) blue:(165. / 255.) alpha:1.];
}

+ (UIColor *) MUNISColor {
	return [UIColor colorWithRed:(212. / 255.) green:(161. / 255.) blue:(71. / 255.) alpha:1.];
}

+ (UIColor *) MUNITColor {
	return [UIColor colorWithRed:(192. / 255.) green:(53. / 255.) blue:(62. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPowellMasonCableCarColor {
	return [UIColor colorWithRed:(115. / 255.) green:(158. / 255.) blue:(172. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPowellHydeCableCarColor {
	return [UIColor colorWithRed:(118. / 255.) green:(169. / 255.) blue:(153. / 255.) alpha:1.];
}

+ (UIColor *) MUNICaliforniaCableCarColor {
	return [UIColor colorWithRed:(134. / 255.) green:(165. / 255.) blue:(174. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPinkColor { // 1AX, 1BX, 31AX, 31BX, 38AX, 38BX, 7X, 81X, 83X
	return [UIColor colorWithRed:(218. / 255.) green:(132. / 255.) blue:(155. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPinkAltColor { // 30X, 82X, 88, NX
	return [UIColor colorWithRed:(213. / 255.) green:(114. / 255.) blue:(145. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPinkAlt2Color { // 8AX, 8BX
	return [UIColor colorWithRed:(226. / 255.) green:(122. / 255.) blue:(157. / 255.) alpha:1.];
}

+ (UIColor *) MUNISalmonColor { // J Bus, KT Bus, L Bus, M Bus
	return [UIColor colorWithRed:(213. / 255.) green:(124. / 255.) blue:(97. / 255.) alpha:1.];
}

+ (UIColor *) MUNIOrangeColor { // 18, 19, 22, 24, 28R, 29, 33, 44, 47, 49, 55
	return [UIColor colorWithRed:(206. / 255.) green:(107. / 255.) blue:(58. / 255.) alpha:1.];
}

+ (UIColor *) MUNIOrangeAltColor { // 28, 48
	return [UIColor colorWithRed:(219. / 255.) green:(114. / 255.) blue:(55. / 255.) alpha:1.];
}

+ (UIColor *) MUNIGreenColor { // 1, 2, 21, 3, 31, 38, 38R, 6, 7
	return [UIColor colorWithRed:(77. / 255.) green:(163. / 255.) blue:(84. / 255.) alpha:1.];
}

+ (UIColor *) MUNIGreenAltColor { // 5
	return [UIColor colorWithRed:(115. / 255.) green:(175. / 255.) blue:(84. / 255.) alpha:1.];
}

+ (UIColor *) MUNINCSBlueAltColor { // 5R
	return [UIColor colorWithRed:(97. / 255.) green:(185. / 255.) blue:(213. / 255.) alpha:1.];
}

+ (UIColor *) MUNINCSBlueColor { // 35, 36, 37, 39, 52, 54, 56, 57, 66, 67
	return [UIColor colorWithRed:(66. / 255.) green:(163. / 255.) blue:(206. / 255.) alpha:1.];
}

+ (UIColor *) MUNINavyBlueAltColor { // 45
	return [UIColor colorWithRed:(56. / 255.) green:(117. / 255.) blue:(168. / 255.) alpha:1.];
}

+ (UIColor *) MUNINavyBlueColor { // 714, 78X, 79X
	return [UIColor colorWithRed:(42. / 255.) green:(87. / 255.) blue:(139. / 255.) alpha:1.];
}

+ (UIColor *) MUNICrayolaBlue { // 43
	return [UIColor colorWithRed:(52. / 255.) green:(128. / 255.) blue:(188. / 255.) alpha:1.];
}

+ (UIColor *) MUNIMunsellBlueColor { // 23
	return [UIColor colorWithRed:(100. / 255.) green:(145. / 255.) blue:(169. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPompAndPowerPurpleColor { // 90, 91
	return [UIColor colorWithRed:(122. / 255.) green:(81. / 255.) blue:(138. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPurpleNavyColor { // 10, 12, 14, 14R, 14X, 25, 30, 41, 76X, 9, 9R
	return [UIColor colorWithRed:(117. / 255.) green:(119. / 255.) blue:(166. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPurpleNavyAltColor { // 27, 8
	return [UIColor colorWithRed:(125. / 255.) green:(129. / 255.) blue:(184. / 255.) alpha:1.];
}
@end

@implementation UIColor (BART)
+ (UIColor *) BARTColor {
   return [UIColor colorWithRed:0. green:(156. / 255.) blue:(219. / 255.) alpha:1.];
}
@end

@implementation UIColor (Caltrain)
+ (UIColor *) caltrainColor {
	return [UIColor colorWithRed:(224. / 255.) green:(61. / 255.) blue:(63. / 255.) alpha:1.];
}
@end

@implementation UIColor (Additions)
- (NSComparisonResult) mph_compare:(UIColor *) color {
    CGFloat hue, saturation, brightness, otherHue, otherSaturation, otherBrightness;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    [color getHue:&otherHue saturation:&otherSaturation brightness:&otherBrightness alpha:NULL];

	// check hue
	if (hue < otherHue)
		return NSOrderedDescending;
	if (hue > otherHue)
		return NSOrderedAscending;

	// check saturation
	if (saturation < otherSaturation)
		return NSOrderedDescending;
	if (saturation > otherSaturation)
		return NSOrderedAscending;

	// check brightness
	if (brightness < otherBrightness)
		return NSOrderedDescending;
	if (brightness > otherBrightness)
		return NSOrderedAscending;

	return NSOrderedSame;
}

#pragma mark -

- (UIColor *) mph_darkenedColor {
	CGFloat hue, saturation, brightness, alpha = 0.;
	[self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness * .80 alpha:alpha];
}

- (UIColor *) mph_lightenedColor {
	CGFloat hue, saturation, brightness, alpha = 0.;
	[self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness * 1.20 alpha:alpha];
}
@end
