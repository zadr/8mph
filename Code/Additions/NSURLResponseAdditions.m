#import "NSURLResponseAdditions.h"

@implementation NSURLRequest (MPHAdditions)
- (NSString *) mph_cURLCommand {
	NSMutableString *cURLCommand = [@"curl -i -L " mutableCopy];

	[cURLCommand appendFormat:@"-X %@ ", self.HTTPMethod];

	if ([self.HTTPMethod isEqualToString:@"PUT"] || [self.HTTPMethod isEqualToString:@"POST"]) {
		NSString *HTTPBody = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
		[cURLCommand appendFormat:@"--data \"%@\" ", HTTPBody];
	}

	if (self.HTTPShouldHandleCookies) {
		NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.URL];
		if (cookies.count) {
			[cURLCommand appendString:@"--cookie \""];
		}

		for (NSHTTPCookie *cookie in cookies) {
			[cURLCommand appendFormat:@"%@=%@; ", cookie.name, cookie.value];
		}

		[cURLCommand replaceCharactersInRange:NSMakeRange(cURLCommand.length - 2, 1) withString:@"\""];
	} else {
		[cURLCommand appendString:@"--cookie-jar /dev/null"];
	}

	[self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[cURLCommand appendFormat:@"--header \"%@: %@\" ", key, object];
	}];

	[cURLCommand appendString:self.URL.absoluteString];

	return [cURLCommand copy];
}
@end

@implementation NSHTTPURLResponse (MPHAdditions)
- (BOOL) mph_isValidResponse {
	return ((self.statusCode / 100) == 2);
}
@end

@implementation NSCachedURLResponse (MPHAdditions)
- (BOOL) mph_isValidResponse {
	return (((NSHTTPURLResponse *)self.response).mph_isValidResponse);
}
@end
