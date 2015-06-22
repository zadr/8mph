#import "FMResultSetMPHAdditions.h"

#import "FMDatabaseAdditions.h"

@implementation FMResultSet (MPHAdditions)
- (NSArray *) arrayForColumn:(NSString *) column {
	return [[self stringForColumn:column] componentsSeparatedByString:@"`"];
}
@end

@implementation FMDatabase (MPHAdditions)
- (NSArray *) arrayForQuery:(NSString *) query {
	return [[self stringForQuery:query] componentsSeparatedByString:@"`"];
}
@end

