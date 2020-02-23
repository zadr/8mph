#import <TargetConditionals.h>

#import "MPHBARTPrediction.h"

#if TARGET_OS_IPHONE
#import "UIColorAdditions.h"
#endif

@implementation MPHBARTPrediction {
	MPHService _service;
}

@synthesize service = _service;
@synthesize updatedAt = _updatedAt;
@synthesize uniqueIdentifier = _uniqueIdentifier;
@synthesize route = _route;
@synthesize stop = _stop;

- (id) init {
	if (!(self = [super init]))
		return nil;

	_updatedAt = [NSDate timeIntervalSinceReferenceDate];

	return self;
}

#if TARGET_OS_IPHONE
- (void) setColorFromHexString:(NSString *) hexString {
	_color = [UIColor mph_colorFromHexString:hexString];
}
#endif

- (NSInteger) minutesETA {
	return _minutes;
}
@end
