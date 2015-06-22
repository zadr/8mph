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

#pragma mark -

+ (UIColor *) MUNIColor {
	return [UIColor colorWithRed:(168. / 255.) green:(48. / 255.) blue:(1. / 255.) alpha:1.];
}

+ (UIColor *) MUNIFColor {
	return [UIColor colorWithRed:(0xE8 / 255.) green:(0x83 / 255.) blue:(0x8e / 255.) alpha:1.];
}

+ (UIColor *) MUNIJColor {
	return [UIColor colorWithRed:(0xFA / 255.) green:(0xA6 / 255.) blue:(0x34 / 255.) alpha:1.];
}

+ (UIColor *) MUNIKColor {
	return [UIColor colorWithRed:(0x56 / 255.) green:(0x9B / 255.) blue:(0xBE / 255.) alpha:1.];
}

+ (UIColor *) MUNILColor {
	return [UIColor colorWithRed:(0x92 / 255.) green:(0x27 / 255.) blue:(0x8F / 255.) alpha:1.];
}

+ (UIColor *) MUNIMColor {
	return [UIColor colorWithRed:(0x00 / 255.) green:(0x87 / 255.) blue:(0x52 / 255.) alpha:1.];
}

+ (UIColor *) MUNINColor {
	return [UIColor colorWithRed:(0x00 / 255.) green:(0x53 / 255.) blue:(0x9B / 255.) alpha:1.];
}

+ (UIColor *) MUNISColor {
	return [UIColor colorWithRed:(0xFF / 255.) green:(0xCC / 255.) blue:(0x00 / 255.) alpha:1.];
}

+ (UIColor *) MUNITColor {
	return [UIColor colorWithRed:(0xD3 / 255.) green:(0x12 / 255.) blue:(0x45 / 255.) alpha:1.];
}

#pragma mark -

// 1, 2, 3, 5, 5L, 6, 21, 31, 38, 38L, 71, 71L
+ (UIColor *) MUNIGreenColor {
	return [UIColor colorWithRed:(14. / 255.) green:(178. / 255.) blue:(75. / 255.) alpha:1.];
}

// 1ax, 1bx, 8x, 8ax, 8bx, 16x, 30x, 31ax, 31bx, 38ax, 38bx, 81x, 82x, 83x, 88, 108, nx
+ (UIColor *) MUNIPinkColor {
	return [UIColor colorWithRed:(243. / 255.) green:(134. / 255.) blue:(168. / 255.) alpha:1.];
}

// 9, 9L, 10, 12, 14, 14L, 27, 30, 41, 45, 76X,
+ (UIColor *) MUNIVioletColor {
	return [UIColor colorWithRed:(125. / 255.) green:(128. / 255.) blue:(189. / 255.) alpha:1.];
}

// 17, 35, 36, 37, 39, 52, 56, 66, 67
+ (UIColor *) MUNIAquaColor {
	return [UIColor colorWithRed:0. green:(174. / 255.) blue:(230. / 255.) alpha:1.];
}

// 18, 19, 22, 24, 28, 29, 33, 44, 49
+ (UIColor *) MUNIOrangeColor {
	return [UIColor colorWithRed:(236. / 255.) green:(125. / 255.) blue:(31. / 255.) alpha:1.];
}

// 23, 28L, 43, 47, 54
+ (UIColor *) MUNIPaleOrangeColor {
	return [UIColor colorWithRed:(238. / 255.) green:(143. / 255.) blue:(49. / 255.) alpha:1.];
}

#pragma mark -

+ (UIColor *) MUNIPowellMasonColor {
	return [UIColor colorWithRed:(104. / 255.) green:(168. / 255.) blue:(188. / 255.) alpha:1.];
}

+ (UIColor *) MUNIPowellHydeColor {
	return [UIColor colorWithRed:(68. / 255.) green:(173. / 255.) blue:(165. / 255.) alpha:1.];
}

+ (UIColor *) MUNICaliforniaColor {
	return [UIColor colorWithRed:(131. / 255.) green:(174. / 255.) blue:(190. / 255.) alpha:1.];
}

// F, J, K, L, M, N, T, Cali, PM, PH, 1, 5, 6, 8x, 9, 14, 22, 24, 28, 29, 30, 31, 38, 43, 44, 47, 49, 71, nx,
+ (UIColor *) MUNIGrayOutlineColor {
	return [UIColor colorWithRed:(125. / 255.) green:(111. / 255.) blue:(108. / 255.) alpha:1.];
}

#pragma mark -

+ (UIColor *) BARTColor {
   return [UIColor colorWithRed:0. green:(156. / 255.) blue:(219. / 255.) alpha:1.];
}

#pragma mark -

+ (UIColor *) caltrainColor {
	return [UIColor colorWithRed:(224. / 255.) green:(61. / 255.) blue:(63. / 255.) alpha:1.];
}

#pragma mark -

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
@end
