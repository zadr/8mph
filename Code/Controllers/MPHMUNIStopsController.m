#import "MPHMUNIStopsController.h"

#import "MPHAmalgamator.h"

#import "MPHNextBusPrediction.h"
#import "MPHNextBusRoute.h"
#import "MPHNextBusStop.h"

#import "MPHPredictions.h"

#import "MPHUtilities.h"

#import "DDXMLDocument.h"
#import "DDXMLElement.h"

@implementation MPHMUNIStopsController {
	NSMutableDictionary *_predictions;
	NSDate *_lastRequestedPredictionTime;
	BOOL _reloadingStops;
	NSOperationQueue *_queue;
}

@synthesize delegate;

- (id) init {
	if (!(self = [super init]))
		return nil;

	_predictions = [NSMutableDictionary dictionary];

	_queue = [[NSOperationQueue alloc] init];
	_queue.maxConcurrentOperationCount = 1;

	return self;
}

- (void) dealloc {
	[_queue cancelAllOperations];
}

- (NSArray *) stopsSortedByType:(MPHStopsSortType) sortType {
	if (sortType == MPHStopsSortTypeAlphabetical)
		return [self.stops sortedArrayUsingComparator:compareStopsByTitle];
	if (sortType == MPHStopsSortTypeDistanceFromDistance)
		return [self.stops sortedArrayUsingComparator:compareStopsByDistance];

	MPHUnreachable
}

- (id) predictionsForStop:(id <MPHStop>) stop {
	return _predictions[[NSString stringWithFormat:@"%zd", stop.tag]];
}

- (NSArray *) stopsForRoutes:(NSArray *) routes {
	return nil;
}

- (void) fetchPredictionsForStop:(id <MPHStop>) aStop {
    // ...
}

- (NSAttributedString *) predictionStringForStop:(id <MPHStop>) stop {
	return nil;
}

- (void) fetchPredictions {
	NSDate *lastRequestedDate = _lastRequestedPredictionTime;
	if (lastRequestedDate && [[NSDate date] timeIntervalSinceDate:lastRequestedDate] < 30)
		return;

	if (_reloadingStops)
		return;

	_reloadingStops = YES;
	_lastRequestedPredictionTime = [NSDate date];

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (id <MPHStop> stop in self.stops) {
		if (![stop isKindOfClass:MPHNextBusStop.class]) {
			continue;
		}

		NSMutableArray *array = dictionary[stop.routeTag];
		if (!array) {
			array = [NSMutableArray array];
			dictionary[stop.routeTag] = array;
		}

        [array addObject:stop];

        NSArray *routes = [[MPHAmalgamator amalgamator] routesForStop:stop onService:MPHServiceMUNI];
        for (id <MPHRoute> route in routes) {
            NSMutableArray *cachedRoutes = dictionary[route.tag];
            if (!cachedRoutes) {
                cachedRoutes = [NSMutableArray array];
                dictionary[route.tag] = cachedRoutes;
            }

            [cachedRoutes addObject:stop];
        }
    }

    __weak id <MPHStopsControllerDelegate> weakDelegate = self.delegate;
    __weak id weakSelf = self;

    NSURLRequest *request = [NSURLRequest nextBusPredictionsWithStopsAndRoutes:dictionary];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong id <MPHStopsControllerDelegate> strongDelegate = weakDelegate;
			__strong MPHMUNIStopsController *strongSelf = weakSelf;
			if (!strongSelf)
				return;

			DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:nil];
			for (DDXMLElement *predictionsElement in [document.rootElement elementsForName:@"predictions"]) {
				NSMutableArray *predictions = [NSMutableArray array];

				for (DDXMLElement *directionElement in [predictionsElement elementsForName:@"direction"]) {
					for (DDXMLElement *predictionElement in [directionElement elementsForName:@"prediction"]) {
						NSString *directionTag = [predictionElement attributeForName:@"dirTag"].stringValue;

						id <MPHRoute> route = [[MPHAmalgamator amalgamator] routeForDirectionTag:directionTag onService:MPHServiceMUNI];
						[predictions addObject:[NSURLRequest predictionFromXMLElement:predictionElement onRoute:route withPredictionsElement:predictionsElement]];
					}
				}

				strongSelf->_predictions[[predictionsElement attributeForName:@"stopTag"].stringValue] = predictions;
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				__strong MPHMUNIStopsController *strongAsyncSelf = weakSelf;
				if (!strongSelf)
					return;

				if (strongDelegate && [strongDelegate respondsToSelector:@selector(stopsControllerDidLoadPredictionsForStop:)])
					[strongDelegate stopsControllerDidLoadPredictionsForStop:self];

				strongAsyncSelf->_reloadingStops = NO;
			});
		});
	}] resume];
}

- (MPHService) service {
	return MPHServiceMUNI;
}
@end
