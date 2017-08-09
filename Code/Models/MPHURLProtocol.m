#import "MPHURLProtocol.h"

@implementation MPHURLProtocol
+ (BOOL) canInitWithRequest:(NSURLRequest *) request {
	NSLog(@"%@ %@", request.HTTPMethod, request.URL);
	return NO;
}
@end
