@class MPHRule;

@interface MPHRulesCreationViewController : NSWindowController <NSPageControllerDelegate> {
	IBOutlet NSPageViewController *_pageController;
	IBOutlet NSButton *_backButton;
	IBOutlet NSButton *_forwardButton;
}

@property (nonatomic, strong) MPHRule *rule;

- (IBAction) navigateForward:(id) sender;
- (IBAction) navigateBackward:(id) sender;
@end
