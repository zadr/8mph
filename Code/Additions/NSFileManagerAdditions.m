#import "NSFileManagerAdditions.h"

@implementation NSFileManager (Additions)
- (NSString *) documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
@end
