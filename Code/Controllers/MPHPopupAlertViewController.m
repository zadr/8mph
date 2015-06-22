#import "MPHPopupAlertViewController.h"

NSString *const MPHPopupAlertDisplayNameKey = @"display-name";
NSString *const MPHPopupAlertStateKey = @"state";
NSString *const MPHPopupAlertReturnDictionaryKeyKey = @"return-key";

@implementation MPHPopupAlertViewController {
	id _keyName;
	NSString *_type;

	NSDictionary *_dictionary;
}

- (id) init {
	return (self = [super initWithNibName:@"MPHPopupAlertView" bundle:nil]);
}

- (void) awakeFromNib {
	[super awakeFromNib];

	_checkboxButton.title = _dictionary[MPHPopupAlertDisplayNameKey];
	_checkboxButton.state = [_dictionary[MPHPopupAlertStateKey] intValue];
	_keyName = [_dictionary[MPHPopupAlertReturnDictionaryKeyKey] copy];
	_type = [_dictionary[MPHAlertTypeKey] copy];
}

- (void) setValuesWithDictionary:(NSDictionary *) dictionary {
	_dictionary = dictionary;
}

- (NSDictionary *) dictionaryValue {
	return @{ _keyName: @(_checkboxButton.state), MPHAlertTypeKey: _type };
}
@end
