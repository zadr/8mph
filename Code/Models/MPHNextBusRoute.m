#import <TargetConditionals.h>

#import "MPHNextBusRoute.h"

#import "NSStringAdditions.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "UIColorAdditions.h"
#endif

@implementation MPHNextBusRoute
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" tag: \"%@\", title: \"%@\", inbound routes: \"%@\", outbound routes: \"%@\",", _tag, _title, _inboundRoutes, _outboundRoutes];

	return description;
}

- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (BOOL) isEqual:(id) object {
	if (![object isKindOfClass:[self class]])
		return NO;

	return [_tag isEqual:[(MPHNextBusRoute *)object tag]];
}

- (NSUInteger) hash {
	return _tag.hash;
}

- (NSString *) name {
	return [_title copy];
}

#pragma mark -

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
+ (UIColor *) colorFromRouteTag:(NSString *) tag {
	// Late 2010's colors
	if ([tag mph_hasCaseInsensitivePrefix:@"E-"])
		return [UIColor MUNIEColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"F-"])
		return [UIColor MUNIFColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"J-"])
		return [UIColor MUNIJColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"JBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"TBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"KBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"KTBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"KTBU-"] || [tag mph_hasCaseInsensitivePrefix:@"LBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"MBUS-"] || [tag mph_hasCaseInsensitivePrefix:@"NBUS-"])
		return [UIColor MUNISalmonColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"K-"] || [tag mph_hasCaseInsensitivePrefix:@"KT-"])
		return [UIColor MUNIKColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"L-"])
		return [UIColor MUNIKColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"L-"])
		return [UIColor MUNILColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"M-"])
		return [UIColor MUNIMColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"N-"])
		return [UIColor MUNIMColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"S-"])
		return [UIColor MUNISColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"T-"])
		return [UIColor MUNITColor];

	if ([tag mph_hasCaseInsensitivePrefix:@"KLM-"])
		return [UIColor MUNISalmonColor];

	if ([tag mph_hasCaseInsensitivePrefix:@"PM-"])
		return [UIColor MUNIPowellMasonCableCarColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"PH-"])
		return [UIColor MUNIPowellHydeCableCarColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"C-"])
		return [UIColor MUNICaliforniaCableCarColor];
 // 42 91 144
	if ([tag mph_hasCaseInsensitivePrefix:@"1AX-"] || [tag mph_hasCaseInsensitivePrefix:@"1BX-"] || [tag mph_hasCaseInsensitivePrefix:@"31AX-"] || [tag mph_hasCaseInsensitivePrefix:@"31BX-"] || [tag mph_hasCaseInsensitivePrefix:@"38AX-"] || [tag mph_hasCaseInsensitivePrefix:@"38BX-"] || [tag mph_hasCaseInsensitivePrefix:@"7X-"] || [tag mph_hasCaseInsensitivePrefix:@"81X-"] || [tag mph_hasCaseInsensitivePrefix:@"83X-"])
		return [UIColor MUNIPinkColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"30X-"] || [tag mph_hasCaseInsensitivePrefix:@"82X-"] || [tag mph_hasCaseInsensitivePrefix:@"88-"] || [tag mph_hasCaseInsensitivePrefix:@"NX-"])
		return [UIColor MUNIPinkAltColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"8AX-"] || [tag mph_hasCaseInsensitivePrefix:@"8BX-"])
		return [UIColor MUNIPinkAlt2Color];
	if ([tag mph_hasCaseInsensitivePrefix:@"J Bus-"] || [tag mph_hasCaseInsensitivePrefix:@"KT Bus-"] || [tag mph_hasCaseInsensitivePrefix:@"L Bus-"] || [tag mph_hasCaseInsensitivePrefix:@"M Bus-"])
		return [UIColor MUNISalmonColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"15-"])
		return [UIColor colorWithRed:(42.0 / 255.0) green:(91.0 / 255.0) blue:(144.0 / 255.0) alpha:1.0];
	if ([tag mph_hasCaseInsensitivePrefix:@"18-"] || [tag mph_hasCaseInsensitivePrefix:@"19-"] || [tag mph_hasCaseInsensitivePrefix:@"22-"] || [tag mph_hasCaseInsensitivePrefix:@"24-"] || [tag mph_hasCaseInsensitivePrefix:@"28R-"] || [tag mph_hasCaseInsensitivePrefix:@"29-"] || [tag mph_hasCaseInsensitivePrefix:@"33-"] || [tag mph_hasCaseInsensitivePrefix:@"44-"] || [tag mph_hasCaseInsensitivePrefix:@"47-"] || [tag mph_hasCaseInsensitivePrefix:@"49-"] || [tag mph_hasCaseInsensitivePrefix:@"55-"])
		return [UIColor MUNIOrangeColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"28-"] || [tag mph_hasCaseInsensitivePrefix:@"48-"])
		return [UIColor MUNIOrangeAltColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"1-"] || [tag mph_hasCaseInsensitivePrefix:@"2-"] || [tag mph_hasCaseInsensitivePrefix:@"21-"] || [tag mph_hasCaseInsensitivePrefix:@"3-"] || [tag mph_hasCaseInsensitivePrefix:@"31-"] || [tag mph_hasCaseInsensitivePrefix:@"38-"] || [tag mph_hasCaseInsensitivePrefix:@"38R-"] || [tag mph_hasCaseInsensitivePrefix:@"6-"] || [tag mph_hasCaseInsensitivePrefix:@"7-"])
		return [UIColor MUNIGreenColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"5-"])
		return [UIColor MUNIGreenAltColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"5R-"])
		return [UIColor MUNINCSBlueAltColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"35-"] || [tag mph_hasCaseInsensitivePrefix:@"36-"] || [tag mph_hasCaseInsensitivePrefix:@"37-"] || [tag mph_hasCaseInsensitivePrefix:@"39-"] || [tag mph_hasCaseInsensitivePrefix:@"52-"] || [tag mph_hasCaseInsensitivePrefix:@"54-"] || [tag mph_hasCaseInsensitivePrefix:@"56-"] || [tag mph_hasCaseInsensitivePrefix:@"57-"] || [tag mph_hasCaseInsensitivePrefix:@"66-"] || [tag mph_hasCaseInsensitivePrefix:@"67-"])
		return [UIColor MUNINCSBlueColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"45-"])
		return [UIColor MUNINavyBlueAltColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"714-"] || [tag mph_hasCaseInsensitivePrefix:@"78X-"] || [tag mph_hasCaseInsensitivePrefix:@"79X-"])
		return [UIColor MUNINavyBlueColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"43-"])
		return [UIColor MUNICrayolaBlue];
	if ([tag mph_hasCaseInsensitivePrefix:@"23-"])
		return [UIColor MUNIMunsellBlueColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"90-"] || [tag mph_hasCaseInsensitivePrefix:@"91-"])
		return [UIColor MUNIPompAndPowerPurpleColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"10-"] || [tag mph_hasCaseInsensitivePrefix:@"12-"] || [tag mph_hasCaseInsensitivePrefix:@"14-"] || [tag mph_hasCaseInsensitivePrefix:@"14R-"] || [tag mph_hasCaseInsensitivePrefix:@"14X-"] || [tag mph_hasCaseInsensitivePrefix:@"25-"] || [tag mph_hasCaseInsensitivePrefix:@"30-"] || [tag mph_hasCaseInsensitivePrefix:@"41-"] || [tag mph_hasCaseInsensitivePrefix:@"76X-"] || [tag mph_hasCaseInsensitivePrefix:@"9-"] || [tag mph_hasCaseInsensitivePrefix:@"9R-"])
		return [UIColor MUNIPurpleNavyColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"27-"] || [tag mph_hasCaseInsensitivePrefix:@"8-"])
		return [UIColor MUNIPurpleNavyAltColor];

	// Mid-2010's colors
//	if ([tag mph_hasCaseInsensitivePrefix:@"F-"])
//		return [UIColor MUNIFColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"J-"])
//		return [UIColor MUNIJColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"K-"])
//		return [UIColor MUNIKColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"L-"])
//		return [UIColor MUNILColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"M-"])
//		return [UIColor MUNIMColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"N-"])
//		return [UIColor MUNINColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"S-"])
//		return [UIColor MUNISColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"T-"] || [tag mph_hasCaseInsensitivePrefix:@"KT-"])
//		return [UIColor MUNITColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"1-"] || [tag mph_hasCaseInsensitivePrefix:@"2-"] || [tag mph_hasCaseInsensitivePrefix:@"3-"] || [tag mph_hasCaseInsensitivePrefix:@"5-"] || [tag mph_hasCaseInsensitivePrefix:@"5R-"] || [tag mph_hasCaseInsensitivePrefix:@"6-"] || [tag mph_hasCaseInsensitivePrefix:@"21-"] || [tag mph_hasCaseInsensitivePrefix:@"31-"] || [tag mph_hasCaseInsensitivePrefix:@"38-"] || [tag mph_hasCaseInsensitivePrefix:@"38X-"] || [tag mph_hasCaseInsensitivePrefix:@"7-"] || [tag mph_hasCaseInsensitivePrefix:@"7L-"])
//		return [UIColor MUNIGreenColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"1ax-"] || [tag mph_hasCaseInsensitivePrefix:@"1bx-"] || [tag mph_hasCaseInsensitivePrefix:@"8-"] || [tag mph_hasCaseInsensitivePrefix:@"8x-"] || [tag mph_hasCaseInsensitivePrefix:@"8ax-"] || [tag mph_hasCaseInsensitivePrefix:@"8bx-"] || [tag mph_hasCaseInsensitivePrefix:@"16x-"] || [tag mph_hasCaseInsensitivePrefix:@"30x-"] || [tag mph_hasCaseInsensitivePrefix:@"31ax-"] || [tag mph_hasCaseInsensitivePrefix:@"31bx-"] || [tag mph_hasCaseInsensitivePrefix:@"38ax-"] || [tag mph_hasCaseInsensitivePrefix:@"38bx-"] || [tag mph_hasCaseInsensitivePrefix:@"81x-"] || [tag mph_hasCaseInsensitivePrefix:@"82x-"] || [tag mph_hasCaseInsensitivePrefix:@"83x-"] || [tag mph_hasCaseInsensitivePrefix:@"88-"] || [tag mph_hasCaseInsensitivePrefix:@"108-"] || [tag mph_hasCaseInsensitivePrefix:@"nx-"])
//		return [UIColor MUNIPinkColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"9-"] || [tag mph_hasCaseInsensitivePrefix:@"9R-"] || [tag mph_hasCaseInsensitivePrefix:@"10-"] || [tag mph_hasCaseInsensitivePrefix:@"12-"] || [tag mph_hasCaseInsensitivePrefix:@"14-"] || [tag mph_hasCaseInsensitivePrefix:@"14R-"] || [tag mph_hasCaseInsensitivePrefix:@"14X-"] || [tag mph_hasCaseInsensitivePrefix:@"27-"] || [tag mph_hasCaseInsensitivePrefix:@"30-"] || [tag mph_hasCaseInsensitivePrefix:@"41-"] || [tag mph_hasCaseInsensitivePrefix:@"45-"] || [tag mph_hasCaseInsensitivePrefix:@"76X-"])
//		return [UIColor MUNIVioletColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"17-"] || [tag mph_hasCaseInsensitivePrefix:@"35-"] || [tag mph_hasCaseInsensitivePrefix:@"36-"] || [tag mph_hasCaseInsensitivePrefix:@"37-"] || [tag mph_hasCaseInsensitivePrefix:@"39-"] || [tag mph_hasCaseInsensitivePrefix:@"52-"] || [tag mph_hasCaseInsensitivePrefix:@"56-"] || [tag mph_hasCaseInsensitivePrefix:@"66-"] || [tag mph_hasCaseInsensitivePrefix:@"67-"])
//		return [UIColor MUNIAquaColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"18-"] || [tag mph_hasCaseInsensitivePrefix:@"19-"] || [tag mph_hasCaseInsensitivePrefix:@"22-"] || [tag mph_hasCaseInsensitivePrefix:@"24-"] || [tag mph_hasCaseInsensitivePrefix:@"28-"] || [tag mph_hasCaseInsensitivePrefix:@"29-"] || [tag mph_hasCaseInsensitivePrefix:@"33-"] || [tag mph_hasCaseInsensitivePrefix:@"44-"] || [tag mph_hasCaseInsensitivePrefix:@"49-"])
//		return [UIColor MUNIOrangeColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"23-"] || [tag mph_hasCaseInsensitivePrefix:@"28R-"] || [tag mph_hasCaseInsensitivePrefix:@"43-"] || [tag mph_hasCaseInsensitivePrefix:@"47-"] || [tag mph_hasCaseInsensitivePrefix:@"54-"])
//		return [UIColor MUNIPaleOrangeColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"PM-Powell/Mason"])
//		return [UIColor MUNIPowellMasonColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"PH-Powell/Hyde"])
//		return [UIColor MUNIPowellHydeColorV1];
//	if ([tag mph_hasCaseInsensitivePrefix:@"C-California"])
//		return [UIColor MUNICaliforniaColorV1];
	NSLog(@":( %@", tag);
	return [UIColor MUNIColorV1];

}

- (UIColor *) color {
	return [MPHNextBusRoute colorFromRouteTag:_title];
}
#endif
@end
