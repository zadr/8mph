#import "MPHNextBusStop.h"

@implementation MPHNextBusStop
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" tag: \"%zd\", identifier: \"%zd\", title: \"%@\", coordinate: \"%@\"", _tag, _identifier, _title, NSStringFromCLLocationCoordinate2D(_coordinate)];

	return description;
}

- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (NSString *) name {
	return _title;
}

- (BOOL) isEqual:(id) object {
	if (![object isKindOfClass:[self class]])
		return NO;

	MPHNextBusStop *stop = (MPHNextBusStop *)object;
	return _identifier == stop.identifier;
}

- (NSUInteger) hash {
	return _identifier;
}

- (id) link {
	return @(_identifier);
}
@end
