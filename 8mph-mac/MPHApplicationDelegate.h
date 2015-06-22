@class MPHMenuController;
@class MPHRulesTableWindowController;

@interface MPHApplicationDelegate : NSObject <NSApplicationDelegate> {
@private
	MPHMenuController *_menuController;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction) showPreferences:(id) sender;

@property (nonatomic, readonly) MPHRulesTableWindowController *rulesTableWindowController;
@end
