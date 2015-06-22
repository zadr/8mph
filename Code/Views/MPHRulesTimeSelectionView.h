@class MPHDatePicker;

@interface MPHRulesTimeSelectionView : NSView
@property (nonatomic, strong) IBOutlet NSButton *mondayButton;
@property (nonatomic, strong) IBOutlet NSButton *tuesdayButton;
@property (nonatomic, strong) IBOutlet NSButton *wednesdayButton;
@property (nonatomic, strong) IBOutlet NSButton *thursdayButton;
@property (nonatomic, strong) IBOutlet NSButton *fridayButton;
@property (nonatomic, strong) IBOutlet NSButton *saturdayButton;
@property (nonatomic, strong) IBOutlet NSButton *sundayButton;

@property (nonatomic, strong) IBOutlet MPHDatePicker *fromTextView;
@property (nonatomic, strong) IBOutlet MPHDatePicker *toTextView;

@property (nonatomic, strong) IBOutlet NSTextField *informationLabel;
@end
