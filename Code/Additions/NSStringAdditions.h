#import <Foundation/Foundation.h>

@interface NSString (MPHAdditions)
- (NSString *) mph_stringByPercentEncodingString;

- (BOOL) mph_isCaseInsensitiveEqualToString:(NSString *) string;
- (BOOL) mph_hasCaseInsensitivePrefix:(NSString *) prefix;
- (BOOL) mph_hasCaseInsensitiveSubstring:(NSString *) prefix;

- (NSString *) mph_stringByReplacingStrings:(NSArray *) strings withStrings:(NSArray *) replacements;

+ (NSURLRequest *)mph_requestWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
@end
