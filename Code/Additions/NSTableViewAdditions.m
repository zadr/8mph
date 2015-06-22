#import "NSTableViewAdditions.h"

@implementation NSTableView (Additions)
- (NSInteger) mph_chosenRow {
	if (self.selectedRow == -1)
		return self.clickedRow;
	return self.selectedRow;
}
@end
