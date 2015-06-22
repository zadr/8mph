#import "MPH511Stop.h"

@implementation MPH511Stop
- (id) copyWithZone:(NSZone *) zone {
	return self;
}

#pragma mark -

- (NSString *) name {
	return _stopName;
}

- (NSInteger) tag {
	return [_stopCodes.lastObject integerValue];
}

- (id) link {
	return _stopCodes.lastObject;
}

- (NSString *) routeTag {
	return _routeCode;
}
@end
