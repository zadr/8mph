#import "NSDictionaryAdditions.h"
#import "NSStringAdditions.h"

@implementation NSDictionary (Additions)
- (NSArray *) mph_alphabeticallyOrderedKeys {
	return [self keysSortedByValueUsingSelector:@selector(compare:)];
}

- (NSString *) mph_queryRepresentation {
	NSMutableString *string = [[NSMutableString alloc] init];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[string appendFormat:@"%@=%@&", [key mph_stringByPercentEncodingString], [object mph_stringByPercentEncodingString]];
	}];

	if (string.length)
		[string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
	return [string copy];
}
@end
