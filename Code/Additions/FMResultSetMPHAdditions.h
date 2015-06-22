#import "FMResultSet.h"
#import "FMDatabase.h"

@interface FMResultSet (MPHAdditions)
- (NSArray *) arrayForColumn:(NSString *) column;
@end

@interface FMDatabase (MPHAdditions)
- (NSArray *) arrayForQuery:(NSString *) query;
@end
