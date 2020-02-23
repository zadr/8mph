#import "NSStringAdditions.h"

@implementation NSString (MPHAdditions)
- (NSString *) mph_stringByPercentEncodingString {
	NSMutableString *result = [NSMutableString stringWithCapacity:self.length];
	const char *p = [self UTF8String];
	char c;

	for(; (c = *p); p++) {
		switch(c) {
		case '0'...'9':
		case 'A'...'Z':
		case 'a'...'z':
		case '.':
		case '-':
		case '~':
		case '_':
			[result appendFormat:@"%c", c];
			break;
		default:
			[result appendFormat:@"%%%02X", c];
		}
	}

	return result;
}

- (BOOL) mph_isCaseInsensitiveEqualToString:(NSString *) string {
	return ![self caseInsensitiveCompare:string];
}

- (BOOL) mph_hasCaseInsensitiveSubstring:(NSString *) prefix {
	return [self rangeOfString:prefix options:(NSStringCompareOptions)(NSCaseInsensitiveSearch) range:NSMakeRange(0, self.length)].location != NSNotFound;
}

- (BOOL) mph_hasCaseInsensitivePrefix:(NSString *) prefix {
	return [self rangeOfString:prefix options:(NSStringCompareOptions)(NSCaseInsensitiveSearch | NSAnchoredSearch) range:NSMakeRange(0, self.length)].location != NSNotFound;
}

- (NSString *) mph_stringByReplacingStrings:(NSArray *) strings withStrings:(NSArray *) replacements {
	NSMutableString *string = [self mutableCopy];

	for (NSUInteger i = 0; i < strings.count; i++) {
		NSString *search = strings[i];
		NSString *replacement = replacements[i];
		[string replaceOccurrencesOfString:search
								withString:replacement
								   options:NSCaseInsensitiveSearch
									 range:NSMakeRange(0, string.length)];
	}

	return [string copy];
}

+ (NSURLRequest *)mph_requestWithFormat:(NSString *)format, ...  {
	va_list args;
	va_start(args, format);
	NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	NSURL *URL = [NSURL URLWithString:string];
	return [NSURLRequest requestWithURL:URL];
}
@end
