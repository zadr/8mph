#import <Foundation/Foundation.h>

@interface NSURLRequest (MPHAdditions)
@property (nonatomic, readonly) NSString *mph_cURLCommand;
@end

@interface NSHTTPURLResponse (MPHAdditions)
@property (readonly) BOOL mph_isValidResponse; // YES if 2xx, NO otherwise
@end

@interface NSCachedURLResponse (MPHAdditions)
@property (readonly) BOOL mph_isValidResponse; // YES if 2xx, NO otherwise
@end
