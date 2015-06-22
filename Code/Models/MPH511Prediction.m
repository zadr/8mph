#import "MPH511Prediction.h"

@implementation MPH511Prediction
@synthesize service = _service;
@synthesize updatedAt = _updatedAt;

- (id) init {
	if (!(self = [super init]))
		return nil;

	_updatedAt = [NSDate timeIntervalSinceReferenceDate];

	return self;
}

- (id) uniqueIdentifier {
	return [NSString stringWithFormat:@"%@%@%@%@", _routeName, _routeCode, _stopName, _stopCode];
}

- (NSString *) route {
	return _routeName;
}

- (NSString *) stop {
	return _stopName;
}

- (NSInteger) minutesETA {
	return _minutes;
}
@end
