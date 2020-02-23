#import <TargetConditionals.h>

#import "MPHBARTRoute.h"

@implementation MPHBARTRoute
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" %@, abbreviation: %@, routeIdentifier: %@, number: %zd, stops: %@, color: %@", _name, _abbreviation, _routeIdentifier, _number, _stops,
#if TARGET_OS_IPHONE
	 _color
#else
	 @"<not available>"
#endif
	 ];

	return description;
}

- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (NSString *) tag {
	return [NSString stringWithFormat:@"%zd", _number];
}
@end
