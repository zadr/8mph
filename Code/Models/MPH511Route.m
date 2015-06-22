#import "MPH511Route.h"

@implementation MPH511Route
- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (BOOL) isEqual:(id) object {
	if (![object isKindOfClass:[self class]])
		return NO;

	return [_routeCode isEqual:[(MPH511Route *)object routeCode]];
}

#pragma mark -

- (NSString *) tag {
	return _routeCode;
}

- (NSString *) name {
	return _routeName;
}

- (MPHService) service {
	return MPHServiceCaltrain;
}
@end
