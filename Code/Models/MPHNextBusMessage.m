#import <TargetConditionals.h>

#import "MPHNextBusMessage.h"

#import "MPHAmalgamator.h"

#import "MPHNextBusRoute.h"

#import "MPHUtilities.h"

#import "NSStringAdditions.h"

@implementation MPHNextBusMessage {
	NSArray *_sortedAffectedLines;
	NSString *_text;
	BOOL _hasDetails;
	BOOL _hasCheckedForDetails;
}

- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" lines: %@, stops: %@", self.affectedLines, self.affectedStops];

	return description;
}

- (NSArray *) affectedLines {
	if (_sortedAffectedLines)
		return _sortedAffectedLines;

	_sortedAffectedLines = [[super affectedLines] sortedArrayUsingComparator:compareMUNIRoutesWithTitles];

	return _sortedAffectedLines;
}

- (BOOL) messageWithoutAffectedLinesIsSystemMessage {
	return YES;
}

- (NSString *) text {
	if (_text)
		return _text;

	_text = [self.message capitalizedStringWithLocale:[NSLocale currentLocale]];
	_text = [_text mph_stringByReplacingStrings:@[
		@" @ ",  @"&", @"\n", @",", @"(", @"Bwt ", @"Btwn ", @"thru", @".", @"dtr", @"Eff.", @"-Feet", @"-Foot",
		@"ax", @"bx", @"Embar.", @" Wp ", @"Bp", @"Bal Pk", @"muni ", @"SFMTA_Muni", @"sfmta.com", @"th", @" and ", @" or ", @" of ", @" at ", @" on ", @" to ", @" for ", @" a ", @" in ", @" is ", @"3 1 1", @" pd ", @" ok ", @"ft", @"Dtwn",
		@"wkdy", @"wknd", @"sat.", @"sun.", @"mon.", @"mon-", @"tues.", @"wed.", @"thurs.", @"fri.", @" St ", @"at&t", @"sta.", @" Ave ", @"pm ", @" am ",
		@"Clsd", @"svc", @"Temp. ", @"temp ", @" ob ", @" ib ", @"ib ", @"min.", @"srv", @"sfmta", @" At SFMTA", @"xfer", @"Ferry Pl,",
		@"Ggp", @"Mcallister", @"SVan", @"Vn.", @"Vn/", @"/Vn", @" vn ", @" vn", @"vn ", @"Vanness", @"Batt.", @"Mont.", @"O'farrell", @"Ply.", @" Sj/", @"Elcamino", @"Pac. ", @"Wash.", @"Stktn", @"Mrkt", @"Mkt",
		@"@SFMTA. Com",
		@"st ", @"st;", @"st.", @"nd ", @"nd;", @"nd/", @"rd ", @"rd/", @"rd;", @"th ", @"th;",
		@"/", @"\n"
	] withStrings:@[
		@" At ", @" and ", @" ", @", ", @" (", @"Between ", @"Between ", @"Through", @". ", @"Detour", @"Effective", @" Feet", @" Foot",
		@"AX", @"BX", @"Embarcadero", @" West Portal ", @"Ballpark", @"Ballpark", @"MUNI ", @"SFMTA_MUNI", @"SFMTA.com", @"th", @" and ", @" or ", @" of ", @" at ", @" on ", @" to ", @" for ", @" a ", @" in ", @" is ", @"311", @" Police Department ", @" OK ", @"Feet", @"Downtown",
		@"Weekday", @"Weekend", @"Saturday", @"Sunday", @"Monday", @"Monday-", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @" Street ", @"AT&T", @"Station", @" Avenue ", @"PM ", @" AM ",
		@"Closed", @"Service", @"Temporarily ", @"Temporary ", @" Outbound ", @" Inbound ", @"Inbound ", @"Minutes", @"Service", @"SFMTA", @" @SFMTA", @"Transfer", @"Ferry Plaza,",
		@"Golden Gate Park", @"McAllister", @"South Van", @"Van Ness", @"Van Ness/", @"Van Ness/", @" Van Ness ", @" Van Ness", @"Van Ness", @"Van Ness", @"Battery", @"Montgomery", @"O'Farrell", @"Plymouth", @" San Jose/", @"El Camino", @"Pacific", @"Washington", @"Stockton", @"Market", @"Market",
		@"SFMTA.com",
		@"st ", @"st;", @"st.", @"nd ", @"nd;", @"nd/", @"rd ", @"rd/", @"rd;", @"th ", @"th;",
		@" and ", @" "
	]];

	_text = [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	while ([_text containsString:@"  "]) {
		_text = [_text mph_stringByReplacingStrings:@[ @"  " ] withStrings:@[ @" " ]];
	}

	if (![NSCharacterSet.punctuationCharacterSet characterIsMember:[_text characterAtIndex:_text.length - 1]])
		_text = [_text stringByAppendingString:@"."];

	return _text;
}

- (BOOL) hasDetails {
	if (!_hasCheckedForDetails) {
		_hasCheckedForDetails = YES;
		[self.affectedLines enumerateObjectsUsingBlock:^(id route, NSUInteger index, BOOL *stop) {
			self->_hasDetails = ([[MPHAmalgamator amalgamator] stopsForMessage:self onRouteTag:route].count > 0);
			*stop = self->_hasDetails;
		}];
	}
	return _hasDetails;
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (UIColor *) colorForAffectedLine:(NSString *) line {
	return [MPHNextBusRoute colorFromRouteTag:[line stringByAppendingString:@"-"]];
}
#endif
@end
