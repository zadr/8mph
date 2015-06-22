#import "MPHDateRange.h"

NSString *NSStringFromRuleDays(MPHRuleDays days, NSDateFormatterStyle style) {
	if (!days || style == NSDateFormatterNoStyle)
		return @"";

	NSMutableString *stringValue = [NSMutableString string];
	NSString *separator = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleGroupingSeparator];

	BOOL singularDay = (days == MPHRuleDaySaturday || days == MPHRuleDaySunday || days == MPHRuleDayMonday || days == MPHRuleDayTuesday || days == MPHRuleDayWednesday || days == MPHRuleDayThursday || days == MPHRuleDayFriday);
	SEL selector = NULL;
	if (singularDay) {
		if (style == NSDateFormatterFullStyle)
			selector = @selector(standaloneWeekdaySymbols);
		else if (style == NSDateFormatterMediumStyle)
			selector = @selector(shortStandaloneWeekdaySymbols);
		else if (style == NSDateFormatterShortStyle)
			selector = @selector(veryShortStandaloneWeekdaySymbols);
	} else {
		if (style == NSDateFormatterFullStyle)
			selector = @selector(weekdaySymbols);
		else if (style == NSDateFormatterMediumStyle)
			selector = @selector(shortWeekdaySymbols);
		else if (style == NSDateFormatterShortStyle)
			selector = @selector(veryShortWeekdaySymbols);
	}

	BOOL checkWeekends = YES;
	BOOL checkWeekdays = YES;

	if ((days & MPHRuleDaily) == MPHRuleDaily) {
		[stringValue appendFormat:NSLocalizedString(@"Daily%@ ", @"Daily#{separator} string"), separator];

		checkWeekdays = NO;
		checkWeekends = NO;
	} else if ((days & MPHRuleWeekday) == MPHRuleWeekday) {
		[stringValue appendFormat:NSLocalizedString(@"Weekdays%@ ", @"Weekdays#{separator} string"), separator];

		checkWeekdays = NO;
	} else if ((days & MPHRuleWeekend) == MPHRuleWeekend) {
		[stringValue appendFormat:NSLocalizedString(@"Weekends%@ ", @"Weekends#{separator} string"), separator];

		checkWeekends = NO;
	}

	if (checkWeekends) {
		if ((days & MPHRuleDaySaturday) == MPHRuleDaySaturday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][6], separator];
		if ((days & MPHRuleDaySunday) == MPHRuleDaySunday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][0], separator];
	}

	if (checkWeekdays) {
		if ((days & MPHRuleDayMonday) == MPHRuleDayMonday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][1], separator];
		if ((days & MPHRuleDayTuesday) == MPHRuleDayTuesday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][2], separator];
		if ((days & MPHRuleDayWednesday) == MPHRuleDayWednesday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][3], separator];
		if ((days & MPHRuleDayThursday) == MPHRuleDayThursday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][4], separator];
		if ((days & MPHRuleDayFriday) == MPHRuleDayFriday)
			[stringValue appendFormat:@"%@%@ ", [[NSDateFormatter cachedDateFormatter] performSelector:selector][5], separator];
	}
	[stringValue deleteCharactersInRange:NSMakeRange(stringValue.length - 2, 2)];

	return [stringValue copy];
}

@implementation MPHDateRange
- (id) initWithCoder:(NSCoder *) coder {
	if (!(self = [super init]))
		return nil;

	_days = [coder decodeIntForKey:@"days"];
	_hours = [coder decodeInt64ForKey:@"hours"];
	_minutes = [coder decodeInt64ForKey:@"minutes"];
	_duration = [coder decodeFloatForKey:@"duration"];

	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder {
	if (!coder.allowsKeyedCoding)
		[NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];

	[coder encodeInt:_days forKey:@"days"];
	[coder encodeInt64:_hours forKey:@"hours"];
	[coder encodeInt64:_minutes forKey:@"minutes"];
	[coder encodeFloat:_duration forKey:@"duration"];
}
@end
