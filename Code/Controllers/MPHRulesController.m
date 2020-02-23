#import "MPHRulesController.h"

#import "MPHAlertGenerator.h"

#import "MPHRule.h"
#import "MPHDateRange.h"

#import "MPHPrediction.h"
#import "MPHRoute.h"
#import "MPHStop.h"

#import "MPHPredictions.h"

@implementation MPHRulesController {
	NSMutableArray *_rules;
	NSTimer *_rulesTimer;

	NSMutableDictionary *_predictionData;
	NSMutableSet *_predictedPredictions;
}

+ (instancetype) rulesController {
	static MPHRulesController *rulesController;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		rulesController = [[MPHRulesController alloc] init];
	});
	return rulesController;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_predictionData = [NSMutableDictionary dictionary];
	_predictedPredictions = [NSMutableSet set];

	_rules = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.rulesPath] mutableCopy];
	if (!_rules)
		_rules = [NSMutableArray array];

	_rulesTimer = [NSTimer timerWithTimeInterval:15. target:self selector:@selector(checkTimes:) userInfo:nil repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:_rulesTimer forMode:NSRunLoopCommonModes];

	[_rulesTimer fire];

	return self;
}

#pragma mark -

- (void) checkTimes:(NSTimer *) timer {
	NSMutableDictionary *routesStopsMapping = [NSMutableDictionary dictionary];

	for (MPHRule *rule in _rules) {
		for (id <MPHRoute> route in rule.routes) {
			NSMutableSet *stops = routesStopsMapping[route.tag];
			if (!stops) {
				stops = [NSMutableSet setWithArray:[rule stopsForRoute:route]];

				routesStopsMapping[route.tag] = stops;
			} else [stops addObjectsFromArray:[rule stopsForRoute:route]];
		}
	}

	MPHHTTPRequest *request = [MPHHTTPRequest nextBusPredictionsWithStopsAndRoutes:routesStopsMapping];
	__weak typeof(self) weakSelf = self;

	request.successBlock = ^(MPHHTTPRequest *completedRequest, MPHHTTPResponse *response) {
		__strong typeof(self) strongSelf = weakSelf;
		if (!response.responseData.length)
			return;

		DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:response.responseData options:DDXMLDocumentXMLKind error:nil];
		id <MPHRoute> route = [[[strongSelf->_rules lastObject] routes] lastObject];

		[strongSelf->_predictionData removeAllObjects];

		for (DDXMLElement *predictionsElement in [document.rootElement elementsForName:@"predictions"]) {
			for (DDXMLElement *directionElement in [predictionsElement elementsForName:@"direction"]) {
				for (DDXMLElement *predictionElement in [directionElement elementsForName:@"prediction"]) {
					id <MPHPrediction> prediction = [MPHHTTPRequest predictionFromXMLElement:predictionElement onRoute:route withPredictionsElement:predictionsElement];
					strongSelf->_predictionData[prediction.uniqueIdentifier] = prediction;
				}
			}
		}

		[strongSelf checkRules:nil];
	};

	[_queue addOperation:request];
}

- (NSArray *) predictionsForRule:(MPHRule *) rule {
	NSMutableArray *predictions = [NSMutableArray array];

	for (id <MPHPrediction> prediction in _predictionData) {
		for (id <MPHStop> stop in rule.stops) {
			// TODO: make sure we're on the right route
			if ([prediction.stop isEqualToString:[NSString stringWithFormat:@"%d", stop.tag]])
				[predictions addObject:prediction];
		}
	}

	return [predictions copy];
}

#pragma mark -

- (void) addRule:(MPHRule *) rule {
	if (![_rules containsObject:rule])
		[_rules addObject:rule];

	[self saveRules];
}

- (void) removeRuleAtIndex:(NSUInteger) index {
	[_rules removeObjectAtIndex:index];

	[self saveRules];
}

#pragma mark-

- (void) checkRules:(NSTimer *) timer {
	static NSDateFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterNoStyle;
		formatter.timeStyle = NSDateFormatterShortStyle;
	}

	NSDateComponents *currentDateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:(NSWeekdayCalendarUnit | NSCalendarCalendarUnit | NSTimeZoneCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:[NSDate date]];

	for (MPHRule *rule in _rules) {
		if (!rule.enabled)
			continue;

		NSDateComponents *components = [currentDateComponents copy];
		components.hour = rule.range.hours;
		components.minute = rule.range.minutes;

		NSMutableSet *matchedPredictions = [NSMutableSet set];

		// then look at all the routes
		for (id <MPHRoute> route in rule.routes) {
			// and all all the stops for each route
			for (id <MPHStop> stop in [rule stopsForRoute:route]) {
				// and check the predictions
				for (id <MPHPrediction> prediction in _predictionData.allValues) {
					// TODO: make sure we're on the right route
					// if we're at the wrong stop
					if (![prediction.stop isEqualToString:[NSString stringWithFormat:@"%ld", stop.tag]])
						continue;

					// and if we haven't shown it yet
					if ([_predictedPredictions containsObject:prediction.uniqueIdentifier])
						continue;

					// and its within the warning interval
					if (prediction.minutesETA > (int)(rule.warningInterval / 60.))
						continue;

					// then save it
					[_predictedPredictions addObject:[prediction.uniqueIdentifier copy]];
					[matchedPredictions addObject:prediction];
				}
			}
		}

		NSDate *startDate = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
		NSDate *endDate = [startDate dateByAddingTimeInterval:rule.range.duration];
		NSDate *currentDate = [NSDate date];

		// if we're in the right time
		if ([startDate laterDate:currentDate] == currentDate && [currentDate laterDate:endDate] == endDate)  {
			for (id <MPHPrediction> prediction in matchedPredictions) {
				[self fireRule:rule withPrediction:prediction];
			}
		}
	}
}

- (void) fireRule:(MPHRule *) rule withPrediction:(id <MPHPrediction> ) prediction {
	for (NSDictionary *alert in rule.alerts) {

		NSMutableDictionary *workingAlert = [alert mutableCopy];
		MPHService service = [[rule.routes lastObject] service];
		workingAlert[MPHAlertTitleKey] = [NSString stringWithFormat:NSLocalizedString(@"%@ Alert", @"#{transit system} alert"), NSStringFromMPHService(service)];
		workingAlert[MPHAlertMessageKey] = [NSString stringWithFormat:NSLocalizedString(@"A %@ will be at %@ in %d minutes", @"A #{bus} will be at #{stop} in #{number} minutes)"), prediction.route, prediction.stop, prediction.minutesETA];

		if (alert[MPHAlertTypeKey] == MPHPopoverAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] popupAlertWithInformation:workingAlert];
		} else if (alert[MPHAlertTypeKey] == MPHAudioAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] audioAlertWithInformation:workingAlert];
		} else if (alert[MPHAlertTypeKey] == MPHVoiceoverAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] voiceoverAlertWithInformation:workingAlert];
		} else if (alert[MPHAlertTypeKey] == MPHNotificationAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] notificationAlertWithInformation:workingAlert];
		} else if (alert[MPHAlertTypeKey] == MPHScriptAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] scriptAlertWithInformation:workingAlert];
		} else if (alert[MPHAlertTypeKey] == MPHDockAlertTypeKey) {
			[[MPHAlertGenerator sharedInstance] dockAlertWithInformation:workingAlert];
		}
	}
}

- (void) unpauseRule:(MPHRule *) rule {
	rule.enabled = YES;
}

- (void) pauseRule:(MPHRule *) rule {
	rule.enabled = NO;
}

#pragma mark -

- (void) saveRules {
	if (_rules.count)
		[NSKeyedArchiver archiveRootObject:_rules toFile:self.rulesPath];
	else [[NSFileManager defaultManager] removeItemAtPath:self.rulesPath error:NULL];
}

#pragma mark -

- (NSString *) rulesPath {
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
	path = [path stringByAppendingPathComponent:@"8mph"];

	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];

	return [path stringByAppendingPathComponent:@"rules.plist"];
}
@end
