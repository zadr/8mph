#import "MPHSoundAlertViewController.h"

NSString *const MPHSoundAlertPopUpDisplayNameKey = @"popup-display-name";
  NSString *const MPHSoundAlertPopUpValuesKey = @"popup-all-values"; // array
  NSString *const MPHSoundAlertPopUpSelectedValuesKey = @"popup-selected-values"; // array
  NSString *const MPHSoundAlertPopUpReturnDictionaryKeyKey = @"popup-return-key";
NSString *const MPHSoundAlertSliderDisplayNameKey = @"slider-display-name";
  NSString *const MPHSoundAlertSliderValueKey = @"slider-value"; // nsnumber
  NSString *const MPHSoundAlertSliderReturnDictionaryKeyKey = @"slider-return-key";
NSString *const MPHSoundAlertCheckboxDisplayNameKey = @"checkbox-display-name";
  NSString *const MPHSoundAlertCheckboxStateKey = @"ckeckbox-state"; // NSNumber
  NSString *const MPHSoundAlertCheckboxReturnDictionaryKeyKey = @"checkbox-return-key";

@implementation MPHSoundAlertViewController {
	NSString *_filePath;
	NSDictionary *_keys;
	NSDictionary *_dictionary;
}

- (id) init {
	return (self = [super initWithNibName:@"MPHSoundAlertView" bundle:nil]);
}

- (void) selectFile {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = YES;
	openPanel.resolvesAliases = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = @[@"public.audio"];

	[openPanel runModal];

	_filePath = [((NSURL *)openPanel.URLs[0]).path copy];
}

- (void) awakeFromNib {
	[super awakeFromNib];

	_keys = @{
		MPHSoundAlertPopUpReturnDictionaryKeyKey: _dictionary[MPHSoundAlertPopUpReturnDictionaryKeyKey],
		MPHSoundAlertSliderReturnDictionaryKeyKey: _dictionary[MPHSoundAlertSliderReturnDictionaryKeyKey],
		MPHSoundAlertCheckboxReturnDictionaryKeyKey: _dictionary[MPHSoundAlertCheckboxReturnDictionaryKeyKey]
	};

	[_popupButton removeAllItems];

	_popupButtonLabel.stringValue = _dictionary[MPHSoundAlertPopUpDisplayNameKey];
	[_popupButton addItemsWithTitles:_dictionary[MPHSoundAlertPopUpValuesKey]];

	for (NSString *string in _dictionary[MPHSoundAlertPopUpSelectedValuesKey])
		[_popupButton selectItemWithTitle:string];

	_sliderLabel.stringValue = _dictionary[MPHSoundAlertSliderDisplayNameKey];
	_slider.minValue = 0.;
	_slider.maxValue = 1.;
	_slider.doubleValue = [_dictionary[MPHSoundAlertSliderValueKey] doubleValue];

	_checkboxButton.title = _dictionary[MPHSoundAlertCheckboxDisplayNameKey];
	_checkboxButton.state = [_dictionary[MPHSoundAlertCheckboxStateKey] intValue];
}

- (void) setValuesWithDictionary:(NSDictionary *) dictionary {
	_dictionary = dictionary;
}

- (NSDictionary *) dictionaryValue {
	return @{
		_keys[MPHSoundAlertPopUpReturnDictionaryKeyKey]: _popupButton.titleOfSelectedItem,
		_keys[MPHSoundAlertSliderReturnDictionaryKeyKey]: @(_slider.doubleValue),
		_keys[MPHSoundAlertCheckboxReturnDictionaryKeyKey]: @(_checkboxButton.state),
		MPHAlertTypeKey: _dictionary[MPHAlertTypeKey]
	};
}
@end
