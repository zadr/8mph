@class MPHServiceSelectionViewController;

@protocol MPHServiceSelectionDelegate <NSObject>
@required
- (void) serviceSelectionViewController:(MPHServiceSelectionViewController *) serviceSelectionViewController didSelectService:(MPHService) service;
@end

@interface MPHServiceSelectionViewController : NSViewController
@property (nonatomic, weak) id <MPHServiceSelectionDelegate> delegate;

- (IBAction) selectService:(id) sender;
@end
