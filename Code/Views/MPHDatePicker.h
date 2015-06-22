@class MPHDatePicker;

@protocol MPHDatePickerDelegate <NSObject>
@optional
- (void) timeTextViewDidEndEditing:(MPHDatePicker *) timeTextView;
@end

@interface MPHDatePicker : NSTextView <NSTextViewDelegate>
@property (nonatomic, weak) id <MPHDatePickerDelegate> timeDelegate;

@property (nonatomic, copy) NSString *hours;
@property (nonatomic, copy) NSString *minutes;
@property (nonatomic, copy) NSString *amPM;
@property (nonatomic) BOOL hidesAMPM;
@end
