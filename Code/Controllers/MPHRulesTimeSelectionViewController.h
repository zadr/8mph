#import "MPHDateRange.h"

@class MPHRulesTimeSelectionViewController;

@protocol MPHRoute;

@protocol MPHRulesTimeSelectionDelegate <NSObject>
@required
- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectDay:(MPHRuleDays) day;
- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didDeselectDay:(MPHRuleDays) day;

- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectStartTimeWithHours:(NSTimeInterval) hours minutes:(NSTimeInterval) minutes pm:(BOOL) amOrPM;
- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectEndTimeWithHours:(NSTimeInterval) hours minutes:(NSTimeInterval) minutes pm:(BOOL) amOrPM;
@end

@interface MPHRulesTimeSelectionViewController : NSViewController <NSTextFieldDelegate>
@property (nonatomic, weak) id <MPHRulesTimeSelectionDelegate> delegate;

- (IBAction) didSelectDay:(id) sender;
@end
