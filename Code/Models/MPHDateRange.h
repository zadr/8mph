typedef NS_ENUM(NSInteger, MPHRuleDay) {
	MPHRuleDayMonday = 1,
	MPHRuleDayTuesday = 2,
	MPHRuleDayWednesday = 4,
	MPHRuleDayThursday = 8,
	MPHRuleDayFriday = 16,
	MPHRuleDaySaturday = 32,
	MPHRuleDaySunday = 64,

	MPHRuleWeekday = (MPHRuleDayMonday | MPHRuleDayTuesday | MPHRuleDayWednesday | MPHRuleDayThursday | MPHRuleDayFriday),
	MPHRuleWeekend = (MPHRuleDaySaturday | MPHRuleDaySunday),
	MPHRuleDaily = (MPHRuleWeekday | MPHRuleWeekend)
};

//
// NSDateFormatterFullStyle = Monday
// NSDateFormatterMediumStyle = Mon
// NSDateFormatterShortStyle = M
// NSDateFormatterNoStyle = ""
NSString *NSStringFromRuleDays(MPHRuleDays days, NSDateFormatterStyle style);

@interface MPHDateRange : NSObject <NSCoding>
@property (nonatomic) MPHRuleDays days;

// start
@property (nonatomic) NSInteger hours; // 0-23
@property (nonatomic) NSInteger minutes; // 0-59

@property (nonatomic) NSTimeInterval duration; // in seconds, nonnegative
@end
