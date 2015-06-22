#import "MPHAlertEditing.h"

@interface MPHRunScriptAlertViewController : NSViewController <MPHAlertEditing, NSTextFieldDelegate> {
	IBOutlet NSTextField *_scriptPathTextField;
	IBOutlet NSButton *_environmentVariablesCheckboxButton;
	IBOutlet NSTextField *_commandOutputLabel;
}

- (IBAction) selectScript:(id) sender;
@end
