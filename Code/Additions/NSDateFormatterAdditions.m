#import "NSDateFormatterAdditions.h"

@implementation NSDateFormatter (Additions)
static BOOL cached = NO;

+ (void) initialize {
	static dispatch_once_t pred;
	dispatch_once(&pred, ^{
		(void)[self mph_isAMPM];
	});
}

+ (BOOL) mph_isAMPM {
	static BOOL result = NO;

	if (cached)
		return result;

	cached = YES;

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.locale = [NSLocale currentLocale];
	formatter.dateStyle = NSDateFormatterNoStyle;
	formatter.timeStyle = NSDateFormatterShortStyle;

	NSString *timeString = [formatter stringFromDate:[NSDate date]];
	NSRange AMRange = [timeString rangeOfString:formatter.AMSymbol];
	NSRange PMRange = [timeString rangeOfString:formatter.PMSymbol];

	result = (AMRange.location != NSNotFound || PMRange.location != NSNotFound);

	static dispatch_once_t pred;
	dispatch_once(&pred, ^{
		[[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			cached = NO;
		}];
	});

	return result;
}

+ (NSDateFormatter *) cachedDateFormatter {
	NSDateFormatter *dateFormatter = [NSThread currentThread].threadDictionary[@"date-formatter"];
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];

		[NSThread currentThread].threadDictionary[@"date-formatter"] = dateFormatter;
	}

	return dateFormatter;
}
@end
