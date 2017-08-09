#import "MPHUtilities.h"

#import "MPHNextBusRoute.h"

#import "MPHStop.h"

#import "MPHLocationCenter.h"

NSString *NSStringFromMPHService(MPHService service) {
	if (service == MPHServiceMUNI)
		return @"MUNI";

	if (service == MPHServiceBART)
		return @"BART";

	if (service == MPHServiceCaltrain)
		return @"Caltrain";

	if (service == MPHServiceACTransit)
		return @"AC Transit";

	if (service == MPHServiceDumbartonExpress)
		return @"Dumbarton Express";

	if (service == MPHServiceSamTrans)
		return @"SamTrans";

	if (service == MPHServiceVTA)
		return @"VTA";

	if (service == MPHServiceWestCat)
		return @"WestCAT";

	if (service == MPHServiceNone)
		return @"None";

	MPHUnreachable
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
UIColor *UIColorForMPHService(MPHService service) {
	if (service == MPHServiceMUNI)
		return [UIColor MUNIColor];

	if (service == MPHServiceBART)
		return [UIColor BARTColor];

	if (service == MPHServiceCaltrain)
		return [UIColor caltrainColor];

	return nil;
}
#endif

NSComparisonResult (^compareMUNIRoutes)(id, id) = ^(id one, id two) {
	MPHNextBusRoute *routeOne = one;
	MPHNextBusRoute *routeTwo = two;
	return compareMUNIRoutesWithTitles(routeOne.title, routeTwo.title);
};

NSComparisonResult (^compareMUNIRoutesWithTitles)(id, id) = ^(id one, id two) {
	NSString *lineOne = [(NSString *)one uppercaseString];
	NSString *lineTwo = [(NSString *)two uppercaseString];

	NSRange oneCharacterRange = [lineOne rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
	NSRange twoCharacterRange = [lineTwo rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];

	BOOL oneContainsCharacter = oneCharacterRange.location != NSNotFound;
	BOOL twoContainsCharacter = twoCharacterRange.location != NSNotFound;

	BOOL oneIsCharacter = oneContainsCharacter && oneCharacterRange.location == 0;
	BOOL twoIsCharacter = twoContainsCharacter && twoCharacterRange.location == 0;

	BOOL oneIsCableCar = [one mph_hasCaseInsensitiveSubstring:@"Cable Car"];
	BOOL twoIsCableCar = [two mph_hasCaseInsensitiveSubstring:@"Cable Car"];

	BOOL oneIsOwl = [one mph_hasCaseInsensitiveSubstring:@"Owl"];
	BOOL twoIsOwl = [two mph_hasCaseInsensitiveSubstring:@"Owl"];

	NSComparisonResult (^inline_compare)(NSInteger, NSInteger) = ^(NSInteger three, NSInteger four) {
		if (three > four)
			return NSOrderedDescending;
		if (three < four)
			return NSOrderedAscending;
		return NSOrderedSame;
	};

	// if both lines are cable cars, sort by the first word
	if (oneIsCableCar && twoIsCableCar)
		return [[one substringToIndex:[one rangeOfString:@" "].location] caseInsensitiveCompare:[two substringToIndex:[two rangeOfString:@" "].location]];

	// otherwise if one line is a cable car line and the other is not, we want to move the cablecar lines to the bottom of the list (eg: California Cable Car vs N)
	if (oneIsCableCar && !twoIsCableCar)
		return NSOrderedDescending;
	if (!oneIsCableCar && twoIsCableCar)
		return NSOrderedAscending;

	// if both lines are character lines, just return the result of the comparison (eg: N, J)
	if (oneIsCharacter && twoIsCharacter && !oneIsOwl && !twoIsOwl)
		return inline_compare([lineOne characterAtIndex:0], [lineTwo characterAtIndex:0]);

	// TODO: sort letter owl character lines below number character lines
	if (oneIsOwl && !twoIsOwl)
		return NSOrderedDescending;
	if (!oneIsOwl && twoIsOwl)
		return NSOrderedAscending;

	// otherwise if one line is a character line and the other a number line, we want to move the character lines to the top of the list (eg: N, 71)
	if (oneIsCharacter && !twoIsCharacter)
		return NSOrderedAscending;
	if (!oneIsCharacter && twoIsCharacter)
		return NSOrderedDescending;

	// if both lines are number lines that don't have qualifiers, just return the result of the comparison (eg 6, 71)
	if (!oneContainsCharacter && !twoContainsCharacter)
		return inline_compare([lineOne integerValue], [lineTwo integerValue]);

	// if one line contains a character and the other doesnt, we just want to comapre the numbers directly (eg: 6, 71L)
	if (oneContainsCharacter && !twoContainsCharacter)
		return inline_compare([[lineOne substringToIndex:oneCharacterRange.location] integerValue], [lineTwo integerValue]);
	if (!oneContainsCharacter && twoContainsCharacter)
		return inline_compare([lineOne integerValue], [[lineTwo substringToIndex:twoCharacterRange.location] integerValue]);

	// At this point, we only have numbers with qualifiers left, so, compare the numbers of the lines alone. if they're different, return the result of the comparison (eg: 71L vs 1AX)
	NSComparisonResult result = inline_compare([[lineOne substringToIndex:oneCharacterRange.location] integerValue], [[lineTwo substringToIndex:twoCharacterRange.location] integerValue]);
	if (result != NSOrderedSame)
		return result;

	// otherwise, we want to sort by length (8X vs 8BX)
	if (lineOne.length > lineTwo.length)
		return NSOrderedDescending;
	if (lineOne.length < lineTwo.length)
		return NSOrderedAscending;

	// and if the length is the same, sort by the characters english values (8AX vs 8BX)
	return [[lineOne substringFromIndex:oneCharacterRange.location] caseInsensitiveCompare:[lineTwo substringFromIndex:twoCharacterRange.location]];
};

#pragma mark -

NSComparisonResult (^compareStopsByTitle)(id <MPHStop>, id <MPHStop>) = ^(id <MPHStop> one, id <MPHStop> two) {
	return [one.name caseInsensitiveCompare:two.name];
};

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
NSComparisonResult (^compareStopsByDistance)(id <MPHStop>, id <MPHStop>) = ^(id <MPHStop> one, id <MPHStop> two) {
	CLLocationDistance distanceOne = distanceBetweenCoordinates(one.coordinate, [MPHLocationCenter locationCenter].currentLocation.coordinate);
	CLLocationDistance distanceTwo = distanceBetweenCoordinates(two.coordinate, [MPHLocationCenter locationCenter].currentLocation.coordinate);

	if (distanceOne > distanceTwo)
		return NSOrderedDescending;
	if (distanceTwo > distanceOne)
		return NSOrderedAscending;
	return NSOrderedSame;
};
#endif
