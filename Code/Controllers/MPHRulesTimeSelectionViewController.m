#import "MPHRulesTimeSelectionViewController.h"

#import "MPHRulesTimeSelectionView.h"
#import "MPHDatePicker.h"

#import "MPHRule.h"
#import "MPHDateRange.h"

#import "NSStringAdditions.h"

enum {
	MPHRuleTimeRowDayOfTheWeek,
	MPHRuleTimeRowStartTime,
	MPHRuleTimeRowDuration,
	MPHRuleTimeRowCount
};

@interface MPHRulesTimeSelectionViewController () <MPHDatePickerDelegate>
@end

@implementation MPHRulesTimeSelectionViewController {
	MPHRule *_rule;
}

- (id) init {
	return (self = [super initWithNibName:@"MPHRulesTimeSelectionView" bundle:nil]);
}

- (void) awakeFromNib {
	[super awakeFromNib];

	MPHRulesTimeSelectionView *selectionView = (MPHRulesTimeSelectionView *)self.view;
	selectionView.fromTextView.timeDelegate = self;
	selectionView.toTextView.timeDelegate = self;

	if (![NSDateFormatter mph_isAMPM]) {
		selectionView.fromTextView.hidesAMPM = YES;
		selectionView.toTextView.hidesAMPM = YES;
	}
}

#pragma mark -

- (void) setRepresentedObject:(id) representedObject {
	_rule = representedObject;

	MPHRulesTimeSelectionView *selectionView = (MPHRulesTimeSelectionView *)self.view;
	selectionView.mondayButton.state = (_rule.range.days & MPHRuleDayMonday);
	selectionView.tuesdayButton.state = (_rule.range.days & MPHRuleDayTuesday);
	selectionView.wednesdayButton.state = (_rule.range.days & MPHRuleDayWednesday);
	selectionView.thursdayButton.state = (_rule.range.days & MPHRuleDayThursday);
	selectionView.fridayButton.state = (_rule.range.days & MPHRuleDayFriday);
	selectionView.saturdayButton.state = (_rule.range.days & MPHRuleDaySaturday);
	selectionView.sundayButton.state = (_rule.range.days & MPHRuleDaySunday);

	if (_rule.range.duration > 1.) {
		selectionView.fromTextView.hours = [NSString stringWithFormat:@"%02ld", _rule.range.hours];
		selectionView.fromTextView.minutes = [NSString stringWithFormat:@"%02ld", _rule.range.minutes];

		NSInteger hours = (_rule.range.duration / 3600);
		NSInteger minutes = (_rule.range.duration - (hours * 3600)) / 60.;
		selectionView.toTextView.hours = [NSString stringWithFormat:@"%02ld", (_rule.range.hours + hours)];
		selectionView.toTextView.minutes = [NSString stringWithFormat:@"%02ld", (_rule.range.minutes + minutes)];
	}
}

#pragma mark -

- (IBAction) didSelectDay:(id) sender {
	__strong typeof(_delegate) strongDelegate = _delegate;

	MPHRuleDays day = (MPHRuleDays)[sender tag];
	if (_rule.range.days & day)
		[strongDelegate rulesTimeSelectionViewController:self didDeselectDay:day];
	else [strongDelegate rulesTimeSelectionViewController:self didSelectDay:day];
}

#pragma mark -

- (void) _getHours:(NSTimeInterval *) hours minutes:(NSTimeInterval *) minutes pm:(BOOL *) amPM fromTextView:(NSTextView *) textView {
	NSScanner *scanner = [NSScanner scannerWithString:textView.string];
	NSString *hoursString = nil;
	[scanner scanUpToString:@":" intoString:&hoursString];

	scanner.scanLocation += 1;

	NSString *minutesString = nil;
	[scanner scanUpToString:@":" intoString:&minutesString];

	static NSCharacterSet *characterSet = nil;
	if (!characterSet)
		characterSet = [NSCharacterSet characterSetWithCharactersInString:@"aApP"];

	NSRange amPMRange = [textView.string rangeOfCharacterFromSet:characterSet];
	NSString *amPMString = nil;
	if (amPMRange.location != NSNotFound)
		amPMString = [textView.string substringFromIndex:amPMRange.location];

	*hours = hoursString.doubleValue;
	*minutes = minutesString.doubleValue;
	*amPM = [amPMString mph_hasCaseInsensitivePrefix:@"pm"];
}

#pragma mark -

- (void) timeTextViewDidEndEditing:(MPHDatePicker *) timeTextView {
	NSTimeInterval hours = -1;
	NSTimeInterval minutes = -1;
	BOOL amPM = NO;

	[self _getHours:&hours minutes:&minutes pm:&amPM fromTextView:timeTextView];

	MPHRulesTimeSelectionView *selectionView = (MPHRulesTimeSelectionView *)self.view;

	__strong typeof(_delegate) strongDelegate = _delegate;
	if (timeTextView == selectionView.fromTextView)
		[strongDelegate rulesTimeSelectionViewController:self didSelectStartTimeWithHours:hours minutes:minutes pm:amPM];
	else if (timeTextView == selectionView.toTextView)
		[strongDelegate rulesTimeSelectionViewController:self didSelectEndTimeWithHours:hours minutes:minutes pm:amPM];
}
@end
