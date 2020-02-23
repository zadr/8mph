#import "MPHBARTStation.h"

#import "CLLocationAdditions.h"

@implementation MPHBARTStation
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" %@, abbreviation: %@, location: %@, address: %@, %@, %zd, %@, %@, north routes: %@, south routes: %@, north platforms: %@, south platforms: %@", _name, _abbreviation, NSStringFromCLLocationCoordinate2D(_location), _address, _city, _zipCode, _county, _state, _northRoutes, _southRoutes, _northPlatforms, _southPlatforms];
	[description appendFormat:@", %@", _stationData];

	return description;
}

- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (CLLocationCoordinate2D) coordinate {
	return _location;
}

- (NSInteger) tag {
	return ((NSInteger)self.hash);
}

- (NSUInteger) hash {
	return _abbreviation.hash;
}

- (BOOL) isEqual:(id) object {
	if (![object isKindOfClass:[self class]])
		return NO;
	return [_abbreviation isEqual:[object abbreviation]];
}

- (id) link {
	return _abbreviation;
}

- (NSString *) routeTag {
	return nil;
}

- (MPHService) service {
	return MPHServiceBART;
}

@end
