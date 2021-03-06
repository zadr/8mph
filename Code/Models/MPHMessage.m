#import "MPHMessage.h"

@implementation MPHMessage
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" %@ from %@ to %@: %@", _identifier, _startDate, _endDate, self.text];

	return description;
}

- (NSString *) text {
	return _message;
}

- (BOOL) messageWithoutAffectedLinesIsSystemMessage {
	return NO;
}

- (NSDate *) effectiveUntil {
	return _endDate;
}

- (BOOL) hasDetails {
	return YES;
}

#if TARGET_OS_IPHONE
- (UIColor *) colorForAffectedLine:(NSString *) line {
	NSParameterAssert([self.affectedLines containsObject:line]);

	return UIColorForMPHService(_service);
}
#endif
@end
