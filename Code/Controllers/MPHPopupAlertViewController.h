#import <AppKit/AppKit.h>

#import "MPHAlertEditing.h"

extern NSString *const MPHPopupAlertDisplayNameKey;
  extern NSString *const MPHPopupAlertStateKey; // NSNumber
  extern NSString *const MPHPopupAlertReturnDictionaryKeyKey;

@interface MPHPopupAlertViewController : NSViewController <MPHAlertEditing> {
@private
	IBOutlet NSButton *_checkboxButton;
}
@end
