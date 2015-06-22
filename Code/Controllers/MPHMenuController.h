@class MPHRule;

@interface MPHMenuController : NSObject
- (void) addStatusBarItem;
- (void) removeStatusBarItem;

- (void) refreshStatusBarItem;

- (void) prepareStatusItemForRule:(MPHRule *) rule; // passing in `nil` will go back to the default

@property (nonatomic, readonly) NSMenu *menu;
@end
