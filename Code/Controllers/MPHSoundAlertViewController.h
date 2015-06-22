#import "MPHAlertEditing.h"

extern NSString *const MPHSoundAlertPopUpDisplayNameKey;
  extern NSString *const MPHSoundAlertPopUpValuesKey; // array
  extern NSString *const MPHSoundAlertPopUpSelectedValuesKey; // array
  extern NSString *const MPHSoundAlertPopUpReturnDictionaryKeyKey;
extern NSString *const MPHSoundAlertSliderDisplayNameKey;
  extern NSString *const MPHSoundAlertSliderValueKey; // nsnumber
extern NSString *const MPHSoundAlertSliderReturnDictionaryKeyKey;
extern NSString *const MPHSoundAlertCheckboxDisplayNameKey;
  extern NSString *const MPHSoundAlertCheckboxStateKey; // NSNumber
extern NSString *const MPHSoundAlertCheckboxReturnDictionaryKeyKey;

@interface MPHSoundAlertViewController : NSViewController <MPHAlertEditing> {
	IBOutlet NSTextField *_popupButtonLabel;
	IBOutlet NSPopUpButton *_popupButton;
	IBOutlet NSTextField *_sliderLabel;
	IBOutlet NSSlider *_slider;
	IBOutlet NSButton *_checkboxButton;
}
@end
