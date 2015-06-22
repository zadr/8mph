#import "MPHAlertEditing.h"

extern NSString *const MPHDockIconBouncesKey;
  extern NSString *const MPHDockIconBouncesRepeatedlyKey;
extern NSString *const MPHDockIconBadgesKey;
  extern NSString *const MPHDockIconBadgeLineKey;
  extern NSString *const MPHDockIconBadgeServiceKey;
  extern NSString *const MPHDockIconBadgeETAKey;

@interface MPHDockIconAlertViewController : NSViewController <MPHAlertEditing> {
@private
	IBOutlet NSButton *_bouncesCheckbox;
	IBOutlet NSButton *_repeatedlyCheckbox;
	IBOutlet NSButton *_badgeCheckbox;
	IBOutlet NSButton *_badgeLineCheckbox;
	IBOutlet NSButton *_badgeServiceCheckbox;
	IBOutlet NSButton *_badgeETACheckbox;
}

- (IBAction) toggleBounce:(id) sender;
- (IBAction) toggleBadge:(id) sender;
@end
