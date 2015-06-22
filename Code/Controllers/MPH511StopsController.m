#import "MPH511StopsController.h"

#import "MPHPredictions.h"

#import "MPH511Prediction.h"
#import "MPH511Stop.h"

#import "MPHAmalgamator.h"

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

			NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentXMLKind error:nil];
			NSXMLElement *agencyListElement = [document.rootElement elementsForName:@"AgencyList"].lastObject;
			NSXMLElement *agencyElement = [agencyListElement elementsForName:@"Agency"].lastObject;
			NSXMLElement *routeListElement = [agencyElement elementsForName:@"RouteList"].lastObject;
			for (NSXMLElement *routeElement in [routeListElement elementsForName:@"Route"]) {
				for (NSXMLElement *routeDirectionListElement in [routeElement elementsForName:@"RouteDirectionList"]) {
					for (NSXMLElement *routeDirectionElement in [routeDirectionListElement elementsForName:@"RouteDirection"]) {
						for (NSXMLElement *stopListElement in [routeDirectionElement elementsForName:@"StopList"]) {
							for (NSXMLElement *stopElement in [stopListElement elementsForName:@"Stop"]) {
								for (NSXMLElement *departureTimeListElement in [stopElement elementsForName:@"DepartureTimeList"]) {
									for (NSXMLElement *departureTimeElement in [departureTimeListElement elementsForName:@"DepartureTime"]) {
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


- (MPHService) service {
	return _service;
}
@end
