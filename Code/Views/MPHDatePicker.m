#import "MPHDatePicker.h"

@implementation MPHDatePicker {
	NSString *_lastEnteredCharacter;
}

+ (NSRange) hoursRange {
	return NSMakeRange(0, 2);
}

+ (NSRange) minutesRange {
	return NSMakeRange(3, 2);
}

+ (NSRange) amPMRange {
	if ([NSDateFormatter mph_isAMPM])
		return NSMakeRange(5, 2);
	return NSMakeRange(NSNotFound, 0);
}

#pragma mark -

- (NSString *) hours {
	return [self.string substringWithRange:[MPHDatePicker hoursRange]];
}

- (void) setHours:(NSString *) hours {
	self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker hoursRange] withString:hours];
}

- (NSString *) minutes {
	return [self.string substringWithRange:[MPHDatePicker minutesRange]];
}

- (void) setMinutes:(NSString *) minutes {
	self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker minutesRange] withString:minutes];
}

- (NSString *) amPM {
	if ([MPHDatePicker amPMRange].location != NSNotFound)
		return [self.string substringWithRange:[MPHDatePicker amPMRange]];
	return nil;
}

- (void) setAmPM:(NSString *)amPM {
	self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker amPMRange] withString:amPM];
}

- (void) setHidesAMPM:(BOOL) hidesAMPM {
	if (_hidesAMPM == hidesAMPM)
		return;

	if (hidesAMPM) {
		_hidesAMPM = YES;

		self.string = [self.string stringByAppendingString:@"am"];
	} else {
		_hidesAMPM = NO;

		self.string = [self.string substringFromIndex:[MPHDatePicker amPMRange].location];
	}
}

#pragma mark -

- (void) mouseDown:(NSEvent *) event {
	NSRange selectedRange = self.selectedRange;

	[super mouseDown:event];

	if (self.selectedRange.location != selectedRange.location)
		_lastEnteredCharacter = nil;
}

- (void) moveLeft:(id)sender {
	[self _advanceToPreviousComponentWrapping:YES];
}

- (void) moveRight:(id) sender {
	[self _advanceToNextComponentWrapping:YES];
}

- (void) moveUp:(id) sender {
	[self _incrementCurrentComponent];
}

- (void) moveDown:(id) sender {
	[self _decrementCurrentComponent];
}

#pragma mark -

- (void) _setSelectedRange:(NSRange) range {
	if (range.location != self.selectedRange.location)
		[super setSelectedRange:range];
}

- (void) setSelectedRange:(NSRange) charRange {
	return;
}

#pragma mark -

- (NSString *) _replaceSpacesInRange:(NSRange) range {
	static NSCharacterSet *spaceCharacterSet = nil;
	if (!spaceCharacterSet)
		spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];

	NSString *string = [self.string substringWithRange:range];
	NSRange badCharacterRange = [string rangeOfCharacterFromSet:spaceCharacterSet];
	if (badCharacterRange.length)
		return [string stringByReplacingCharactersInRange:badCharacterRange withString:@"0"];
	return string;
}

- (void) _replaceSpacesWithZeros {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_replaceSpacesWithZeros) object:nil];

	_lastEnteredCharacter = nil;

	self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker hoursRange] withString:[self _replaceSpacesInRange:[MPHDatePicker hoursRange]]];
	self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker minutesRange] withString:[self _replaceSpacesInRange:[MPHDatePicker minutesRange]]];
	if ([NSDateFormatter mph_isAMPM])
		self.string = [self.string stringByReplacingCharactersInRange:[MPHDatePicker amPMRange] withString:[self _replaceSpacesInRange:[MPHDatePicker amPMRange]]];
}

- (NSRange) _timeRangeInterceptingRange:(NSRange) range {
	if (NSLocationInRange(range.location, [MPHDatePicker hoursRange]))
		return [MPHDatePicker hoursRange];
	if (NSLocationInRange(range.location, [MPHDatePicker minutesRange]))
		return [MPHDatePicker minutesRange];
	if (NSLocationInRange(range.location, [MPHDatePicker amPMRange]) || range.location == 7)
		return [MPHDatePicker amPMRange];
	return NSMakeRange(NSNotFound, 0);
}

- (void) _advanceToPreviousComponentWrapping:(BOOL) wrapping {
	[self _replaceSpacesWithZeros];

	if ([NSDateFormatter mph_isAMPM]) {
		if (wrapping && self.selectedRange.location == [MPHDatePicker hoursRange].location)
			[self _setSelectedRange:[MPHDatePicker amPMRange]];
		else if (self.selectedRange.location == [MPHDatePicker minutesRange].location)
			[self _setSelectedRange:[MPHDatePicker hoursRange]];
		else if (wrapping && self.selectedRange.location == [MPHDatePicker amPMRange].location)
			[self _setSelectedRange:[MPHDatePicker minutesRange]];
	} else {
		if (wrapping && self.selectedRange.location == [MPHDatePicker hoursRange].location)
			[self _setSelectedRange:[MPHDatePicker minutesRange]];
		else if (self.selectedRange.location == [MPHDatePicker minutesRange].location)
			[self _setSelectedRange:[MPHDatePicker hoursRange]];
			
	}
}

- (void) _advanceToNextComponentWrapping:(BOOL) wrapping {
	[self _replaceSpacesWithZeros];

	if ([NSDateFormatter mph_isAMPM]) {
		if (self.selectedRange.location == [MPHDatePicker hoursRange].location)
			[self _setSelectedRange:[MPHDatePicker minutesRange]];
		else if (self.selectedRange.location == [MPHDatePicker minutesRange].location)
			[self _setSelectedRange:[MPHDatePicker amPMRange]];
		else if (wrapping && self.selectedRange.location == [MPHDatePicker amPMRange].location)
			[self _setSelectedRange:[MPHDatePicker hoursRange]];
	} else {
		if (self.selectedRange.location == [MPHDatePicker hoursRange].location)
			[self _setSelectedRange:[MPHDatePicker minutesRange]];
		else if (wrapping && self.selectedRange.location == [MPHDatePicker minutesRange].location)
			[self _setSelectedRange:[MPHDatePicker hoursRange]];
	}
}

- (void) _incrementCurrentComponent {
	[self _replaceSpacesWithZeros];

	BOOL rolledAroundMinutes = NO;
	if (self.selectedRange.location == [MPHDatePicker minutesRange].location) {
		NSUInteger newValue = ([[self.string substringWithRange:[MPHDatePicker minutesRange]] integerValue] + 1);
		if (newValue >= 60) {
			newValue -= 60;
			rolledAroundMinutes = YES;
		}
		[super replaceCharactersInRange:[MPHDatePicker minutesRange] withString:[NSString stringWithFormat:@"%02ld", newValue]];
	}

	BOOL rolledAroundHours = NO;
	if (rolledAroundMinutes || self.selectedRange.location == [MPHDatePicker hoursRange].location) {
		NSUInteger newValue = ([[self.string substringWithRange:[MPHDatePicker hoursRange]] integerValue] + 1);
		if ([NSDateFormatter mph_isAMPM] && newValue > 12) {
			newValue -= 12;
			rolledAroundHours = YES;
		} else if ([NSDateFormatter mph_isAMPM] && newValue > 23) {
			newValue -= 24;
		}
		[super replaceCharactersInRange:[MPHDatePicker hoursRange] withString:[NSString stringWithFormat:@"%02ld", newValue]];
	}

	if (rolledAroundHours || self.selectedRange.location == [MPHDatePicker amPMRange].location) {
		if ([[self.string substringWithRange:[MPHDatePicker amPMRange]] mph_isCaseInsensitiveEqualToString:@"am"])
			[super replaceCharactersInRange:[MPHDatePicker amPMRange] withString:@"pm"];
		else [super replaceCharactersInRange:[MPHDatePicker amPMRange] withString:@"am"];
	}
}

- (void) _decrementCurrentComponent {
	[self _replaceSpacesWithZeros];

	BOOL rolledAroundMinutes = NO;
	if (self.selectedRange.location == [MPHDatePicker minutesRange].location) {
		NSInteger newValue = ([[self.string substringWithRange:[MPHDatePicker minutesRange]] integerValue] - 1);
		if (newValue == -1) {
			rolledAroundMinutes = YES;
			newValue = 59;
		}
		[super replaceCharactersInRange:[MPHDatePicker minutesRange] withString:[NSString stringWithFormat:@"%02ld", newValue]];
	}

	BOOL rolledAroundHours = NO;
	if (rolledAroundMinutes || self.selectedRange.location == [MPHDatePicker hoursRange].location) {
		NSInteger newValue = ([[self.string substringWithRange:[MPHDatePicker hoursRange]] integerValue] - 1);
		if ([NSDateFormatter mph_isAMPM] && newValue == 0) {
			rolledAroundHours = YES;
			newValue = 12;
		} else if ([NSDateFormatter mph_isAMPM] && newValue == -1) {
			newValue = 23;
		}
		[super replaceCharactersInRange:[MPHDatePicker hoursRange] withString:[NSString stringWithFormat:@"%02ld", newValue]];
	}

	if (rolledAroundHours || self.selectedRange.location == [MPHDatePicker amPMRange].location) {
		if ([[self.string substringWithRange:[MPHDatePicker amPMRange]] mph_isCaseInsensitiveEqualToString:@"am"])
			[super replaceCharactersInRange:[MPHDatePicker amPMRange] withString:@"pm"];
		else [super replaceCharactersInRange:[MPHDatePicker amPMRange] withString:@"am"];
	}
}

#pragma mark -

- (NSRange) textView:(NSTextView *) aTextView willChangeSelectionFromCharacterRange:(NSRange) oldSelectedCharRange toCharacterRange:(NSRange) newSelectedCharRange {
	NSRange newRange = [self _timeRangeInterceptingRange:newSelectedCharRange];
	if (newRange.location == NSNotFound)
		return oldSelectedCharRange;
	return newRange;
}

- (BOOL) textView:(NSTextView *) textView shouldChangeTextInRange:(NSRange) range replacementString:(NSString *) string {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_replaceSpacesWithZeros) object:nil];

	static NSCharacterSet *notAllowedCharacters = nil;
	if (!notAllowedCharacters)
		notAllowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789aApP"] invertedSet];

	if ([string isEqualToString:@":"]) {
		[self _advanceToNextComponentWrapping:NO];

		return NO;
	}

	if ([string rangeOfCharacterFromSet:notAllowedCharacters].location != NSNotFound)
		return NO;

	if (range.length && !string.length) { // deleting
		[super replaceCharactersInRange:range withString:[@"" stringByPaddingToLength:range.length withString:@" " startingAtIndex:0]];

		_lastEnteredCharacter = nil;
	} else if (_lastEnteredCharacter.length) { // second character being entered
		if (([_lastEnteredCharacter isEqualToString:@"0"] || [_lastEnteredCharacter isEqualToString:@"1"] || (![NSDateFormatter mph_isAMPM] && [_lastEnteredCharacter isEqualToString:@"2"])) && NSLocationInRange(range.location, [MPHDatePicker hoursRange])) {
			[super replaceCharactersInRange:[self _timeRangeInterceptingRange:range] withString:[[_lastEnteredCharacter lowercaseString] stringByAppendingString:string]];

			_lastEnteredCharacter = nil;
		} else if (([_lastEnteredCharacter isEqualToString:@"a"] || [_lastEnteredCharacter isEqualToString:@"p"]) && NSLocationInRange(range.location, [MPHDatePicker amPMRange])) {
			if ([string mph_isCaseInsensitiveEqualToString:@"m"])
				[super replaceCharactersInRange:[self _timeRangeInterceptingRange:range] withString:[_lastEnteredCharacter stringByAppendingString:@"m"]];

			_lastEnteredCharacter = nil;
		} else if (([_lastEnteredCharacter isEqualToString:@"0"] || [_lastEnteredCharacter isEqualToString:@"1"] || [_lastEnteredCharacter isEqualToString:@"2"] || [_lastEnteredCharacter isEqualToString:@"3"] || [_lastEnteredCharacter isEqualToString:@"4"] || [_lastEnteredCharacter isEqualToString:@"5"]) && NSLocationInRange(range.location, [MPHDatePicker minutesRange])) {
			[super replaceCharactersInRange:[self _timeRangeInterceptingRange:range] withString:[[_lastEnteredCharacter lowercaseString] stringByAppendingString:string]];

			_lastEnteredCharacter = nil;
		} else {
			_lastEnteredCharacter = [string copy];
		 }
	} else { // first character being entered
		if (([string mph_isCaseInsensitiveEqualToString:@"a"] || [string mph_isCaseInsensitiveEqualToString:@"p"]) && NSLocationInRange(range.location, [MPHDatePicker amPMRange])) {
			[super replaceCharactersInRange:[self _timeRangeInterceptingRange:range] withString:[[string lowercaseString] stringByAppendingString:@"m"]];
		} else {
			[super replaceCharactersInRange:[self _timeRangeInterceptingRange:range] withString:[@" " stringByAppendingString:string]];
			_lastEnteredCharacter = [string copy];
		}
	}

	[self performSelector:@selector(_replaceSpacesWithZeros) withObject:nil afterDelay:.5];

	return NO;
}

- (void) textDidEndEditing:(NSNotification *) notification {
	MPHDatePicker *textView = notification.object;

	[textView _setSelectedRange:NSMakeRange(0, 0)];

	__strong typeof(_timeDelegate) strongDelegate = _timeDelegate;
	if ([strongDelegate respondsToSelector:@selector(timeTextViewDidEndEditing:)])
		[strongDelegate timeTextViewDidEndEditing:self];
}
@end
