#import <Foundation/Foundation.h>

@interface NSDateFormatter (Additions)
+ (BOOL) mph_isAMPM;

+ (NSDateFormatter *) cachedDateFormatter;
@end
