#import "MPH511StopsController.h"

#import "MPHPredictions.h"

#import "MPH511Prediction.h"
#import "MPH511Stop.h"

#import "MPHAmalgamator.h"
#import "MPHUtilities.h"

#import "DDXMLDocument.h"
#import "DDXMLElement.h"

@implementation MPH511StopsController {
	NSMutableDictionary *_predictions;

	MPHService _service;
}

@synthesize delegate;

- (id) initWithService:(MPHService) service {
	if (!(self = [super init]))
		return nil;

	_service = service;
	_stops = [[MPHAmalgamator amalgamator] stopsForService:service inRegion:MKCoordinateRegionForMapRect(MKMapRectWorld)];

	return self;
}

- (NSArray *) stopsSortedByType:(MPHStopsSortType) sortType {
	if (sortType == MPHStopsSortTypeAlphabetical)
		return [self.stops sortedArrayUsingComparator:compareStopsByTitle];
	if (sortType == MPHStopsSortTypeDistanceFromDistance)
		return [self.stops sortedArrayUsingComparator:compareStopsByDistance];

	MPHUnreachable
}

- (NSArray *) stopsForRoutes:(NSArray *) routes {
	return nil;
}

- (void) fetchPredictions {
	// do nothing
}

- (void) fetchPredictionsForStop:(id <MPHStop>) aStop {
	_predictions = nil;

	MPH511Stop *stop = (MPH511Stop *)aStop;
	NSArray *predictionRequests = [NSURLRequest VIIPredictionsForStops:stop.stopCodes];
	for (NSURLRequest *request in predictionRequests) {
		__weak id weakSelf = self;
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			__strong MPH511StopsController *strongSelf = weakSelf;
			if (!strongSelf->_predictions)
				strongSelf->_predictions = [NSMutableDictionary dictionary];

			DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:nil];
			DDXMLElement *agencyListElement = [document.rootElement elementsForName:@"AgencyList"].lastObject;
			DDXMLElement *agencyElement = [agencyListElement elementsForName:@"Agency"].lastObject;
			DDXMLElement *routeListElement = [agencyElement elementsForName:@"RouteList"].lastObject;
			for (DDXMLElement *routeElement in [routeListElement elementsForName:@"Route"]) {
				for (DDXMLElement *routeDirectionListElement in [routeElement elementsForName:@"RouteDirectionList"]) {
					for (DDXMLElement *routeDirectionElement in [routeDirectionListElement elementsForName:@"RouteDirection"]) {
						for (DDXMLElement *stopListElement in [routeDirectionElement elementsForName:@"StopList"]) {
							for (DDXMLElement *stopElement in [stopListElement elementsForName:@"Stop"]) {
								for (DDXMLElement *departureTimeListElement in [stopElement elementsForName:@"DepartureTimeList"]) {
									for (DDXMLElement *departureTimeElement in [departureTimeListElement elementsForName:@"DepartureTime"]) {
										MPH511Prediction *prediction = [NSURLRequest predictionFromDepartureTimeElement:departureTimeElement inRouteDirectionElement:routeDirectionElement];

										NSMutableDictionary *stopsPredictions = strongSelf->_predictions[stop.name] ?: [NSMutableDictionary dictionary];
										strongSelf->_predictions[stop.name] = stopsPredictions;

										NSMutableArray *predictions = stopsPredictions[prediction.stopCode] ?: [NSMutableArray array];
										stopsPredictions[prediction.stopCode] = predictions;
										[predictions addObject:prediction];
									}
								}
							}
						}
					}
				}
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				__strong id <MPHStopsControllerDelegate> strongDelegate = strongSelf.delegate;
				if ([strongDelegate respondsToSelector:@selector(stopsController:didLoadPredictionsForStop:)])
					[strongDelegate stopsController:strongSelf didLoadPredictionsForStop:stop];
			});
		}] resume];
	}
}

- (NSDictionary *) predictionsForStop:(id <MPHStop>) stop {
	return _predictions[stop.name];
}

- (NSAttributedString *) predictionStringForStop:(id <MPHStop>) stop {
	NSDictionary *predictions = [self predictionsForStop:stop];
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];

	NSString *groupingSeparator = [NSString stringWithFormat:@"%@ ", [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];;

	[predictions enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stopIteration) {
		id <MPHPrediction> anyPrediction = [object lastObject];
		NSString *stationString = [NSString stringWithFormat:@"\n • %@: ", anyPrediction.route.capitalizedString];
		UIFont *footnoteFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		UIFontDescriptor *footnoteFontDescriptors = footnoteFont.fontDescriptor;
		footnoteFontDescriptors = [footnoteFontDescriptors fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
		footnoteFont = [UIFont fontWithDescriptor:footnoteFontDescriptors size:footnoteFont.pointSize] ?: footnoteFont;
		NSAttributedString *station = [[NSAttributedString alloc] initWithString:stationString attributes:@{
			NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
			NSFontAttributeName: footnoteFont
		}];
		[text appendAttributedString:station];
		object = [object sortedArrayUsingComparator:^NSComparisonResult(id one, id two) {
			return [@([one minutesETA]) compare:@([two minutesETA])];
		}];

		for (id <MPHPrediction> prediction in object) {
			if (prediction.minutesETA < 0.)
				continue;

			NSDictionary *attributes;
			if (prediction.minutesETA < 5) {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor colorWithRed:(0. / 255.) green:(102. / 255.) blue:(0. / 255.) alpha:1.],
					NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
				};
			} else {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
					NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
				};
			}
			if (prediction.minutesETA) {
				NSString *string = [NSString stringWithFormat:@"%zdm%@ ", prediction.minutesETA, groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			} else {
				NSString *string = [NSString stringWithFormat:@"now%@ ", groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			}
		}

		if (text.length)
			[text deleteCharactersInRange:NSMakeRange(text.length - (groupingSeparator.length + 1), (groupingSeparator.length + 1))];
	}];

	if (text.length)
		[text deleteCharactersInRange:NSMakeRange(0, 1)];
	else {
		text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"No trains", @"No trains text") attributes:@{
			NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
			NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
		}];
	}

	return text;
}

- (MPHService) service {
	return _service;
}
@end
