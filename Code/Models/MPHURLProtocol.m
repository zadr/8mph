#import "MPHURLProtocol.h"

#import <zlib.h>

@interface NSData (compression)
@end

@implementation NSData (compression)
- (NSData *) mph_gzipInflate {
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[self bytes];
    strm.avail_in = (uInt)[self length];

    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15 + 16), 8, Z_DEFAULT_STRATEGY) != Z_OK)
		return nil;

    NSMutableData *compressed = [NSMutableData data];
    do {
        if (strm.total_out >= compressed.length)
            [compressed increaseLengthBy:16384];

        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)(compressed.length - strm.total_out);

        deflate(&strm, Z_FINISH);
    } while (strm.avail_out == 0);

    deflateEnd(&strm);

	compressed.length = strm.total_out;

    return [compressed copy];
}
@end

@implementation MPHURLProtocol
+ (BOOL) canInitWithRequest:(NSURLRequest *) request {
	NSLog(@"%@ %@", request.HTTPMethod, request.URL);
//
//	if (request.allHTTPHeaderFields.allValues.count)
//		NSLog(@"%@", request.allHTTPHeaderFields);
//
//	if (request.HTTPBody.length) {
//		NSString *string = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
//		if (string.length)
//			NSLog(@"%@", string);
//		else { // try gzip inflating
//			string = [[NSString alloc] initWithData:request.HTTPBody.mph_gzipInflate encoding:NSUTF8StringEncoding];
//			if (string.length)
//				NSLog(@"%@", string);
//			else { // try zlib
//				char *bytes = (char *)request.HTTPBody.bytes;
//				printf("raw:\n");
//				for (NSUInteger i = 0; bytes && i < request.HTTPBody.length; i++)
//					printf("%c", bytes[i]);
//				printf("\n");
//
//				bytes = (char *)request.HTTPBody.mph_gzipInflate.bytes;
//				printf("gzip:\n");
//				for (NSUInteger i = 0; bytes && i < request.HTTPBody.mph_gzipInflate.length; i++)
//					printf("%c", bytes[i]);
//				printf("\n");
//			}
//		}
//	}
//
//	if (request.HTTPBodyStream)
//		NSLog(@"%@", request.HTTPBodyStream);
//
//	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
//	if (cookies.count)
//		NSLog(@"%@", cookies);
//
	return NO;
}
@end
