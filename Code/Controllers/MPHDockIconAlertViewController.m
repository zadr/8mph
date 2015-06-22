#import "MPHDockIconAlertViewController.h"

NSString *const MPHDockIconBouncesKey = @"dock-bounces";
  NSString *const MPHDockIconBouncesRepeatedlyKey = @"dock-bounces-repeatedly";
NSString *const MPHDockIconBadgesKey = @"dock-badge";
  NSString *const MPHDockIconBadgeLineKey = @"dock-badge-shows-line";
  NSString *const MPHDockIconBadgeServiceKey = @"dock-badge-shows-service";
  NSString *const MPHDockIconBadgeETAKey = @"dock-badge-shows-eta";

@implementation MPHDockIconAlertViewController {
	NSDictionary *_dictionary;
}

- (id) init {
	return (self = [super initWithNibName:@"MPHDockIconAlertView" bundle:nil]);
}

#pragma mark -

- (void) awakeFromNib {
	[super awakeFromNib];

	_bouncesCheckbox.state = [_dictionary[MPHDockIconBouncesKey] intValue];
	_repeatedlyCheckbox.state = [_dictionary[MPHDockIconBouncesRepeatedlyKey] intValue];
	_badgeCheckbox.state = [_dictionary[MPHDockIconBadgesKey] intValue];
	_badgeLineCheckbox.state = [_dictionary[MPHDockIconBadgeLineKey] intValue];
	_badgeServiceCheckbox.state = [_dictionary[MPHDockIconBadgeServiceKey] intValue];
	_badgeETACheckbox.state = [_dictionary[MPHDockIconBadgeETAKey] intValue];
}

#pragma mark -

- (void) setValuesWithDictionary:(NSDictionary *) dictionary {
	_dictionary = dictionary;
}

- (NSDictionary *) dictionaryValue {
	return @{
		MPHDockIconBouncesKey: @(_bouncesCheckbox.state),
			MPHDockIconBouncesRepeatedlyKey: @(_repeatedlyCheckbox.state),
		MPHDockIconBadgesKey: @(_badgeCheckbox.state),
			MPHDockIconBadgeLineKey: @(_badgeLineCheckbox.state),
			MPHDockIconBadgeServiceKey: @(_badgeServiceCheckbox.state),
			MPHDockIconBadgeETAKey: @(_badgeETACheckbox.state),
		MPHAlertTypeKey: MPHDockAlertTypeKey
	};
}

#pragma mark -

- (IBAction) toggleBounce:(id) sender {
	BOOL enabled = (_badgeCheckbox.state == NSOnState);
	[_repeatedlyCheckbox setEnabled:enabled];
}

- (IBAction) toggleBadge:(id) sender {
	BOOL enabled = (_badgeCheckbox.state == NSOnState);
	[_badgeETACheckbox setEnabled:enabled];
	[_badgeLineCheckbox setEnabled:enabled];
	[_badgeServiceCheckbox setEnabled:enabled];
}
@end
