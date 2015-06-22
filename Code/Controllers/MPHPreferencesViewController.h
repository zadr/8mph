@interface MPHPreferencesViewController : NSWindowController {
@private
	IBOutlet NSPopUpButton *_statusItemPopUp;
	IBOutlet NSPopUpButton *_dockIconPopUp;
	IBOutlet NSButton *_endAlertStatusItemButton;
	IBOutlet NSButton *_endAlertDockIconButton;
	IBOutlet NSButton *_endAlertKeyComboButton;
}
@end
