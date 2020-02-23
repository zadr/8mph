#import "MPHNextBusPrediction.h"

#import "MPHDefines.h"
#import "MPHUtilities.h"

@implementation MPHNextBusPrediction {
	MPHService _service;
	NSTimeInterval _updatedAt;
}

@synthesize service = _service;
@synthesize updatedAt = _updatedAt;

- (id) init {
	if (!(self = [super init]))
		return nil;

	_updatedAt = [NSDate timeIntervalSinceReferenceDate];

	return self;
}

#pragma mark -

- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" on: %@, epoch: %f, seconds: %f, minutes: %f, stop: %@, direction: %@, minutes ETA: %zd, updated at: %f", NSStringFromMPHService(_service), _epochTime, _seconds, _minutes, _stopTag, _direction, self.minutesETA, _updatedAt];

	return description;
}

#pragma mark -

- (id) uniqueIdentifier {
	return _trip;
}

- (NSString *) route {
	return _routeTitle;
}

- (NSString *) stop {
	return _stopTitle;
}

- (NSInteger) minutesETA {
	return ((NSInteger)((_seconds - ([NSDate timeIntervalSinceReferenceDate] - _updatedAt)) / 60.));
}
@end
