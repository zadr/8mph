#import "MPHBARTRouteController.h"

#import "MPHRouteController.h"

#import "MPHAmalgamation.h"
#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPHNextBusPrediction.h"
#import "MPHNextBusRoute.h"
#import "MPHNextBusStop.h"

#import "MPHBARTRoute.h"
#import "MPHBARTPrediction.h"

#import "MPHPredictions.h"

#import "CLLocationAdditions.h"

#import "DDXMLDocument.h"

@implementation MPHBARTRouteController {
	NSArray *_stops;
	NSArray *_inboundStops;
	NSArray *_outboundStops;

	MPHBARTRoute *_route;

	NSMutableDictionary *_predictions;

	NSOperationQueue *_queue;
}

@synthesize delegate = _delegate;
@synthesize predictionLoadedDate = _predictionLoadedDate;
@synthesize route = _route;

- (id) initWithRoute:(id <MPHRoute>) route {
	if (!(self = [super init]))
		return nil;

	_predictions = [NSMutableDictionary dictionary];
	_queue = [[NSOperationQueue alloc] init];
	_queue.maxConcurrentOperationCount = 1;
	_route = route;

	__weak typeof(self) weakSelf = self;
	[_queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
		__strong typeof(weakSelf) strongSelf = weakSelf;
		__strong typeof(strongSelf->_delegate) strongDelegate = strongSelf->_delegate;

		strongSelf->_stops = [[[MPHAmalgamator amalgamator] stopsForRoute:strongSelf->_route inDirection:MPHDirectionIgnored] copy];

		[strongSelf reloadStopTimesForDirection:MPHDirectionIgnored];

		if (strongDelegate && [strongDelegate respondsToSelector:@selector(routeController:didLoadRoutesForDirection:)])
			[strongDelegate routeController:strongSelf didLoadRoutesForDirection:MPHDirectionIgnored];
	}]];

	return self;
}

#pragma mark -

- (void) reloadStopTimesForDirection:(MPHDirection) direction {
	__weak id <MPHRouteControllerDelegate> weakDelegate = _delegate;
	__weak id weakSelf = self;
	MPHBARTRoute *route = (MPHBARTRoute *)_route;
	NSArray *predictionRequests = [NSURLRequest BARTPredictionsForStops:route.stops];

	for (NSURLRequest *request in predictionRequests) {
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			__strong id <MPHRouteControllerDelegate> strongDelegate = weakDelegate;
			__strong MPHBARTRouteController *strongSelf = weakSelf;

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
				if (strongDelegate && [strongDelegate respondsToSelector:@selector(routeController:didLoadPredictionsForDirection:)])
					[strongDelegate routeController:strongSelf didLoadPredictionsForDirection:direction];
			});
		}] resume];
	}
}

- (void) reloadStopTimes {
	[self reloadStopTimesForDirection:MPHDirectionInbound];
	[self reloadStopTimesForDirection:MPHDirectionOutbound];
	[self reloadStopTimesForDirection:MPHDirectionIgnored];
}

#pragma mark -

- (id <MPHStop>) nearestStopForDirection:(MPHDirection) direction {
	NSArray *workingStops = nil;

	if (direction == MPHDirectionInbound)
		workingStops = _inboundStops;
	else if (direction == MPHDirectionOutbound)
		workingStops = _outboundStops;
	else if (direction == MPHDirectionIgnored)
		workingStops = _stops;

	CGFloat previousNearestDistance = 0.;
	id <MPHStop> nearestStop = nil;
	if ([MPHLocationCenter locationCenter].currentLocation) {
		for (id <MPHStop> stop in workingStops) {
			CGFloat distance = distanceBetweenCoordinates(stop.coordinate, [MPHLocationCenter locationCenter].currentLocation.coordinate);

			if (!nearestStop) {
				nearestStop = stop;
				previousNearestDistance = distance;
			}

			if (distance < previousNearestDistance) {
				nearestStop = stop;
				previousNearestDistance = distance;
			}
		}
	} else return nil;

	return nearestStop;
}

#pragma mark -

- (NSArray *) routesForStop:(id <MPHStop>) stop {
	return [[MPHAmalgamator amalgamator] routesForStop:stop onService:_route.service];
}

- (NSArray *) messagesForStop:(id <MPHStop>) stop {
	return [[MPHAmalgamator amalgamator] messagesForStop:stop ofService:_route.service];
}

- (NSArray *) predictionsForStop:(id <MPHStop>) stop {
	return _predictions[[NSString stringWithFormat:@"%zd", stop.tag]];
}

- (NSArray *) stopsForDirection:(MPHDirection) direction {
	return _stops;
}

- (NSArray *) pathsForMap {
	return [[MPHAmalgamator amalgamator] pathsForRoute:_route];
}

- (NSArray *) directionTitles {
	return @[
		[_route.name componentsSeparatedByString:@" - "][0],
		[_route.name componentsSeparatedByString:@" - "][1]
	];
}

#pragma mark -

- (UIColor *) color {
	return _route.color;
}
@end
