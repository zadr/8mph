@class MPHAlertTypeSelectionViewController;

@protocol MPHAlertTypeSelectionDelegate <NSObject>
@required
- (void) alertTypeSelectionViewController:(MPHAlertTypeSelectionViewController *) rulesTimeSelectionViewController didAddAlert:(NSDictionary *) alert;
- (void) alertTypeSelectionViewController:(MPHAlertTypeSelectionViewController *) rulesTimeSelectionViewController didRemoveAlertOfType:(NSString *) alertType;
@end

@interface MPHAlertTypeSelectionViewController : NSViewController
@property (nonatomic, readonly) NSArray *alerts;
@end
