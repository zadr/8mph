@interface MPHRulesTableController : NSView <NSTableViewDataSource, NSTableViewDelegate>
@property (assign) IBOutlet NSTableView *tableView;

- (IBAction) pauseAlert:(id) sender;
- (IBAction) deleteAlert:(id) sender;
@end

@interface MPHRulesTableViewController : NSViewController
- (MPHRulesTableController *) rulesTableController;
@end

@interface MPHRulesTableWindowController : NSWindowController <NSToolbarDelegate, NSWindowDelegate> {
@private
	IBOutlet NSToolbar *_toolbar;
	IBOutlet MPHRulesTableViewController *_rulesTableViewController;
}

- (IBAction) addAlert:(id) sender;
- (IBAction) editAlert:(id) sender;

- (IBAction) showRules:(id) sender;
@end
