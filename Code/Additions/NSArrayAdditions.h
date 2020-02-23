#import <Foundation/Foundation.h>

@interface NSArray (Additions)
@property (readonly) NSInteger signedCount;

- (id) objectAtSignedIndex:(NSInteger) index;
@end
