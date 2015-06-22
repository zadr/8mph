#import "NSArrayAdditions.h"

@implementation NSArray (Additions)
- (NSInteger) signedCount {
	NSUInteger count = self.count;
	if (count > INT_MAX)
		return INT_MAX;
	return (NSInteger)count;
}

- (id) objectAtSignedIndex:(NSInteger) index {
	if (index > self.signedCount || 0 > index)
		return nil;

	return self[(NSUInteger)index];
}
@end
