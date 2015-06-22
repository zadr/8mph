#import "CLPlacemarkAdditions.h"

@implementation CLPlacemark (Additions)
- (NSString *) mph_readableAddressString {
	NSMutableString *addressString = [NSMutableString string];
	if (self.thoroughfare.length) {
		[addressString appendString:self.thoroughfare];
		[addressString appendString:@", "];
	}
	if (self.locality.length) {
		[addressString appendString:self.locality];
		[addressString appendString:@", "];
	}
	if (self.administrativeArea.length) {
		[addressString appendString:self.administrativeArea];
		[addressString appendString:@" "];
	}
	if (self.postalCode.length) {
		[addressString appendString:self.postalCode];
		[addressString appendString:@" "];
	}
	if (self.country.length) {
		[addressString appendString:self.country];
		[addressString appendString:@" "];
	}
	return [addressString copy];
}
@end
