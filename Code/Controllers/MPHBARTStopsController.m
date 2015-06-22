#import "MPHBARTStopsController.h"

#import "MPHPredictions.h"

#import "MPHBARTPrediction.h"
#import "MPHBARTStation.h"

#import "MPHAmalgamator.h"

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

- (void) fetchPredictionsForStop:(id <MPHStop>) aStop {
	MPHBARTStation *stop = (MPHBARTStation *)aStop;
	NSArray *predictionRequests = [NSURLRequest BARTPredictionsForStops:@[stop.abbreviation]];
	for (NSURLRequest *request in predictionRequests) {
		__weak id weakSelf = self;
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			__strong MPHBARTStopsController *strongSelf = weakSelf;
			strongSelf->_predictions = [NSMutableDictionary dictionary];

			NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentXMLKind error:nil];
			NSXMLElement *stationElement = [[document.rootElement elementsForName:@"station"] lastObject];
			for (NSXMLElement *etdElement in [stationElement elementsForName:@"etd"]) {
				for (NSXMLElement *estimateElement in [etdElement elementsForName:@"estimate"]) {
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
