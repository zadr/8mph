#import "MPHNextBusMessage.h"

#import "MPHAmalgamator.h"

#import "MPHUtilities.h"

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

- (NSString *) text {
	if (_text)
		return _text;

	_text = [self.message capitalizedStringWithLocale:[NSLocale currentLocale]];
	_text = [_text mph_stringByReplacingStrings:@[@" @ ", @"&", @"\n", @",", @"(", @"Bwt", @"Btwn", @"Mkt", @"thru", @".", @"dtr", @"  "] withStrings:@[@" At ", @" and ", @" ", @", ", @" (", @"Between", @"Between", @"Market", @"Through", @". ", @"Detour", @" "]];
	_text = [_text mph_stringByReplacingStrings:@[@"ax", @"bx", @"muni ", @"SFMTA_Muni", @"sfmta.com", @"th", @" and ", @" or ", @" of ", @" at ", @" on ", @" to ", @" for ", @" a ", @" in ", @" is ", @"3 1 1", @" pd ", @" ok " ] withStrings:@[@"AX", @"BX", @"MUNI ", @"SFMTA_MUNI", @"SFMTA.com", @"th", @" and ", @" or ", @" of ", @" at ", @" on ", @" to ", @" for ", @" a ", @" in ", @" is ", @"311", @" Police Department ", @" OK "]];
	_text = [_text mph_stringByReplacingStrings:@[@"sat.", @"sun.", @"mon.", @"mon-", @"tues.", @"wed.", @"thurs.", @"fri.", @" St ", @"at&t", @"sta.", @" Ave "] withStrings:@[@"Saturday", @"Sunday", @"Monday", @"Monday-", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @" Street ", @"AT&T", @"Station", @" Avenue "]];
	_text = [_text mph_stringByReplacingStrings:@[@"ob", @"ib", @"pm", @" am ", @"min.", @"srv", @"sfmta", @" At SFMTA", @"xfer"] withStrings:@[@"Outbound", @"Inbound", @"PM", @" AM ", @"Minutes", @"Service", @"SFMTA", @" @SFMTA", @"Transfer"]];
	_text = [_text mph_stringByReplacingStrings:@[@"Mcallister", @"Vn.", @"Vanness", @"Batt.", @"Mont.", @"O'farrell", @"Ply.", @" Sj/", @"Elcamino"] withStrings:@[@"McAllister", @"Van Ness", @"Van Ness", @"Battery", @"Montgomery", @"O'Farrell", @"Plymouth", @" San Jose/", @"El Camino"]];
	_text = [_text mph_stringByReplacingStrings:@[@"@SFMTA. Com"] withStrings:@[@"SFMTA.com"]];
	_text = [_text mph_stringByReplacingStrings:@[ @"  ", @"st ", @"st;", @"nd ", @"nd;", @"rd ", @"rd;", @"th ", @"th;" ] withStrings:@[ @" ", @"st ", @"st;", @"nd ", @"nd;", @"rd ", @"rd;", @"th ", @"th;" ]];

	_text = [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (![_text hasSuffix:@"."])
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
@end
