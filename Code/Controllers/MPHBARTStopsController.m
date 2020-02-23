#import "MPHBARTStopsController.h"

#import "MPHPredictions.h"

#import "MPHBARTPrediction.h"
#import "MPHBARTStation.h"

#import "MPHAmalgamator.h"
#import "MPHUtilities.h"

#import "DDXMLDocument.h"

@implementation MPHBARTStopsController {
	NSMutableDictionary *_predictions;
}

@synthesize delegate;

- (id) init {
	if (!(self = [super init]))
		return nil;

	_stops = [[MPHAmalgamator amalgamator] stopsForService:MPHServiceBART inRegion:MKCoordinateRegionForMapRect(MKMapRectWorld)];

	return self;
}

- (NSArray *) stopsSortedByType:(MPHStopsSortType) sortType {
	NSArray *stops = [[MPHAmalgamator amalgamator] stopsForService:MPHServiceBART inRegion:MKCoordinateRegionForMapRect(MKMapRectWorld)];

	if (sortType == MPHStopsSortTypeAlphabetical)
		return [stops sortedArrayUsingComparator:compareStopsByTitle];
	if (sortType == MPHStopsSortTypeDistanceFromDistance)
		return [stops sortedArrayUsingComparator:compareStopsByDistance];

	MPHUnreachable
}

- (NSArray *) stopsForRoutes:(NSArray *) routes {
	return nil;
}

#pragma mark -

- (void) fetchPredictions {
	// do nothing
}

- (NSDictionary *) predictionsForStop:(id <MPHStop>) stop {
	return _predictions;
}

- (NSAttributedString *) predictionStringForStop:(id <MPHStop>) stop {
	NSDictionary *predictions = [self predictionsForStop:stop];
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
	NSArray *keys = [predictions.allKeys sortedArrayUsingComparator:^NSComparisonResult(id one, id two) {
		id <MPHPrediction> predictionOne = [predictions[one] lastObject];
		id <MPHPrediction> predictionTwo = [predictions[two] lastObject];

		return [predictionOne.route compare:predictionTwo.route];
	}];

	NSString *groupingSeparator = [NSString stringWithFormat:@"%@ ", [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];;
	for (id key in keys) {
		id object = predictions[key];

		NSDictionary *attributes = @{
			NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
			NSFontAttributeName: [UIFont boldSystemFontOfSize:13.]
		};

		id <MPHPrediction> anyPrediction = [object lastObject];
		NSAttributedString *prefix = [[NSAttributedString alloc] initWithString:@"\n " attributes:attributes];
		[text appendAttributedString:prefix];

		NSMutableDictionary *dotAttributes = [attributes mutableCopy];
		dotAttributes[NSForegroundColorAttributeName] = anyPrediction.color;

		NSAttributedString *dotString = [[NSAttributedString alloc] initWithString:@"•" attributes:dotAttributes];
		[text appendAttributedString:dotString];

		NSString *stationString = [NSString stringWithFormat:@" %@: ", key];
		NSAttributedString *station = [[NSAttributedString alloc] initWithString:stationString attributes:attributes];
		[text appendAttributedString:station];
  
		attributes = @{
			NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
			NSFontAttributeName: [UIFont systemFontOfSize:13.]
		};

		for (id <MPHPrediction> prediction in object) {
			if (prediction.minutesETA < 0.)
				continue;

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
	}

	if (text.length)
		[text deleteCharactersInRange:NSMakeRange(0, 1)];
	else {
		text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"No trains", @"No trains text") attributes:@{
			NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
			NSFontAttributeName: [UIFont systemFontOfSize:13.]
		}];
	}

	return text;
}

- (void) fetchPredictionsForStop:(id <MPHStop>) aStop {
	MPHBARTStation *stop = (MPHBARTStation *)aStop;
	NSArray *predictionRequests = [NSURLRequest BARTPredictionsForStops:@[stop.abbreviation]];
	for (NSURLRequest *request in predictionRequests) {
		__weak id weakSelf = self;
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			__strong MPHBARTStopsController *strongSelf = weakSelf;
			strongSelf->_predictions = [NSMutableDictionary dictionary];

			DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:nil];
			DDXMLElement *stationElement = [[document.rootElement elementsForName:@"station"] lastObject];
			for (DDXMLElement *etdElement in [stationElement elementsForName:@"etd"]) {
				for (DDXMLElement *estimateElement in [etdElement elementsForName:@"estimate"]) {
					MPHBARTPrediction *prediction = [NSURLRequest predictionFromETDElement:etdElement estimateElement:estimateElement atStation:nil];

					NSMutableArray *predictions = strongSelf->_predictions[prediction.destination] ?: [NSMutableArray array];
					strongSelf->_predictions[prediction.destination] = predictions;

					[predictions addObject:prediction];
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

- (MPHService) service {
	return MPHServiceBART;
}
@end
