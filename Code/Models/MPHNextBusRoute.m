#import "MPHNextBusRoute.h"

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

- (BOOL) bordered {
	return ([_title mph_hasCaseInsensitivePrefix:@"F-"] || [_title mph_hasCaseInsensitivePrefix:@"J-"] || [_title mph_hasCaseInsensitivePrefix:@"K-"] || [_title mph_hasCaseInsensitivePrefix:@"L-"] || [_title mph_hasCaseInsensitivePrefix:@"M-"] || [_title mph_hasCaseInsensitivePrefix:@"N-"] || [_title mph_hasCaseInsensitivePrefix:@"NX-"] || [_title mph_hasCaseInsensitivePrefix:@"T-"] || [_title mph_hasCaseInsensitivePrefix:@"Cali-"] || [_title mph_hasCaseInsensitivePrefix:@"PM-"] || [_title mph_hasCaseInsensitivePrefix:@"PH-"] || [_title mph_hasCaseInsensitivePrefix:@"1-"] || [_title mph_hasCaseInsensitivePrefix:@"5-"] || [_title mph_hasCaseInsensitivePrefix:@"6-"] || [_title mph_hasCaseInsensitivePrefix:@"8x-"] || [_title mph_hasCaseInsensitivePrefix:@"9-"] || [_title mph_hasCaseInsensitivePrefix:@"14-"] || [_title mph_hasCaseInsensitivePrefix:@"22-"] || [_title mph_hasCaseInsensitivePrefix:@"24-"] || [_title mph_hasCaseInsensitivePrefix:@"28-"] || [_title mph_hasCaseInsensitivePrefix:@"29-"] || [_title mph_hasCaseInsensitivePrefix:@"30-"] || [_title mph_hasCaseInsensitivePrefix:@"31-"] || [_title mph_hasCaseInsensitivePrefix:@"38-"] || [_title mph_hasCaseInsensitivePrefix:@"43-"] || [_title mph_hasCaseInsensitivePrefix:@"44-"] || [_title mph_hasCaseInsensitivePrefix:@"47-"] || [_title mph_hasCaseInsensitivePrefix:@"49-"] || [_title mph_hasCaseInsensitivePrefix:@"71-"]);
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
+ (UIColor *) colorFromRouteTag:(NSString *) tag {
	if ([tag mph_hasCaseInsensitivePrefix:@"F-"])
		return [UIColor MUNIFColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"J-"])
		return [UIColor MUNIJColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"K-"])
		return [UIColor MUNIKColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"L-"])
		return [UIColor MUNILColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"M-"])
		return [UIColor MUNIMColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"N-"])
		return [UIColor MUNINColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"S-"])
		return [UIColor MUNISColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"T-"] || [tag mph_hasCaseInsensitivePrefix:@"KT-"])
		return [UIColor MUNITColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"1-"] || [tag mph_hasCaseInsensitivePrefix:@"2-"] || [tag mph_hasCaseInsensitivePrefix:@"3-"] || [tag mph_hasCaseInsensitivePrefix:@"5-"] || [tag mph_hasCaseInsensitivePrefix:@"5L-"] || [tag mph_hasCaseInsensitivePrefix:@"6-"] || [tag mph_hasCaseInsensitivePrefix:@"21-"] || [tag mph_hasCaseInsensitivePrefix:@"31-"] || [tag mph_hasCaseInsensitivePrefix:@"38-"] || [tag mph_hasCaseInsensitivePrefix:@"38L-"] || [tag mph_hasCaseInsensitivePrefix:@"71-"] || [tag mph_hasCaseInsensitivePrefix:@"71L-"])
		return [UIColor MUNIGreenColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"1ax-"] || [tag mph_hasCaseInsensitivePrefix:@"1bx-"] || [tag mph_hasCaseInsensitivePrefix:@"8x-"] || [tag mph_hasCaseInsensitivePrefix:@"8ax-"] || [tag mph_hasCaseInsensitivePrefix:@"8bx-"] || [tag mph_hasCaseInsensitivePrefix:@"16x-"] || [tag mph_hasCaseInsensitivePrefix:@"30x-"] || [tag mph_hasCaseInsensitivePrefix:@"31ax-"] || [tag mph_hasCaseInsensitivePrefix:@"31bx-"] || [tag mph_hasCaseInsensitivePrefix:@"38ax-"] || [tag mph_hasCaseInsensitivePrefix:@"38bx-"] || [tag mph_hasCaseInsensitivePrefix:@"81x-"] || [tag mph_hasCaseInsensitivePrefix:@"82x-"] || [tag mph_hasCaseInsensitivePrefix:@"83x-"] || [tag mph_hasCaseInsensitivePrefix:@"88-"] || [tag mph_hasCaseInsensitivePrefix:@"108-"] || [tag mph_hasCaseInsensitivePrefix:@"nx-"])
		return [UIColor MUNIPinkColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"9-"] || [tag mph_hasCaseInsensitivePrefix:@"9L-"] || [tag mph_hasCaseInsensitivePrefix:@"10-"] || [tag mph_hasCaseInsensitivePrefix:@"12-"] || [tag mph_hasCaseInsensitivePrefix:@"14-"] || [tag mph_hasCaseInsensitivePrefix:@"14L-"] || [tag mph_hasCaseInsensitivePrefix:@"27-"] || [tag mph_hasCaseInsensitivePrefix:@"30-"] || [tag mph_hasCaseInsensitivePrefix:@"41-"] || [tag mph_hasCaseInsensitivePrefix:@"45-"] || [tag mph_hasCaseInsensitivePrefix:@"76X-"])
		return [UIColor MUNIVioletColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"17-"] || [tag mph_hasCaseInsensitivePrefix:@"35-"] || [tag mph_hasCaseInsensitivePrefix:@"36-"] || [tag mph_hasCaseInsensitivePrefix:@"37-"] || [tag mph_hasCaseInsensitivePrefix:@"39-"] || [tag mph_hasCaseInsensitivePrefix:@"52-"] || [tag mph_hasCaseInsensitivePrefix:@"56-"] || [tag mph_hasCaseInsensitivePrefix:@"66-"] || [tag mph_hasCaseInsensitivePrefix:@"67-"])
		return [UIColor MUNIAquaColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"18-"] || [tag mph_hasCaseInsensitivePrefix:@"19-"] || [tag mph_hasCaseInsensitivePrefix:@"22-"] || [tag mph_hasCaseInsensitivePrefix:@"24-"] || [tag mph_hasCaseInsensitivePrefix:@"28-"] || [tag mph_hasCaseInsensitivePrefix:@"29-"] || [tag mph_hasCaseInsensitivePrefix:@"33-"] || [tag mph_hasCaseInsensitivePrefix:@"44-"] || [tag mph_hasCaseInsensitivePrefix:@"49-"])
		return [UIColor MUNIOrangeColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"23-"] || [tag mph_hasCaseInsensitivePrefix:@"28L-"] || [tag mph_hasCaseInsensitivePrefix:@"43-"] || [tag mph_hasCaseInsensitivePrefix:@"47-"] || [tag mph_hasCaseInsensitivePrefix:@"54-"])
		return [UIColor MUNIPaleOrangeColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"Powell/Mason"])
		return [UIColor MUNIPowellMasonColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"Powell/Hyde"])
		return [UIColor MUNIPowellHydeColor];
	if ([tag mph_hasCaseInsensitivePrefix:@"California"])
		return [UIColor MUNICaliforniaColor];
	return [UIColor MUNIColor];

}

- (UIColor *) color {
	return [MPHNextBusRoute colorFromRouteTag:_title];
}
#endif
@end
