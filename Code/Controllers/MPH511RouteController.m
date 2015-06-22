#import "MPH511RouteController.h"

#import "MPHMUNIRouteController.h"

#import "MPHRouteController.h"

#import "MPHAmalgamation.h"
#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPH511Route.h"

#import "MPHPredictions.h"

#import "DDXML.h"

#import "UIColorAdditions.h"

@implementation MPH511RouteController {
	NSArray *_inboundStops;
	NSArray *_outboundStops;

	MPH511Route *_route;

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
	_route = route;

	__weak typeof(self) weakSelf = self;
	[_queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
		__strong typeof(weakSelf) strongSelf = weakSelf;
		__strong typeof(strongSelf->_delegate) strongDelegate = strongSelf->_delegate;

		strongSelf->_inboundStops = [[[MPHAmalgamator amalgamator] stopsForRoute:strongSelf->_route inDirection:MPHDirectionInbound] copy];

		[strongSelf reloadStopTimesForDirection:MPHDirectionInbound];

		if (strongDelegate && [strongDelegate respondsToSelector:@selector(routeController:didLoadRoutesForDirection:)])
			[strongDelegate routeController:strongSelf didLoadRoutesForDirection:MPHDirectionInbound];
	}]];

	[_queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
		__strong typeof(weakSelf) strongSelf = weakSelf;
		__strong typeof(strongSelf->_delegate) strongDelegate = strongSelf->_delegate;

		strongSelf->_outboundStops = [[[MPHAmalgamator amalgamator] stopsForRoute:strongSelf->_route inDirection:MPHDirectionOutbound] copy];

		[strongSelf reloadStopTimesForDirection:MPHDirectionOutbound];

		if (strongDelegate && [strongDelegate respondsToSelector:@selector(routeController:didLoadRoutesForDirection:)])
			[strongDelegate routeController:strongSelf didLoadRoutesForDirection:MPHDirectionOutbound];
	}]];

	return self;
}

#pragma mark -

- (void) reloadStopTimesForDirection:(MPHDirection) direction {
	NSArray *stops = [self stopsForDirection:direction];

	__weak id <MPHRouteControllerDelegate> weakDelegate = _delegate;
	__weak id weakSelf = self;
	__strong id <MPHRouteControllerDelegate> strongDelegate = weakDelegate;
	__strong id strongSelf = weakSelf;

	NSURLRequest *request = [NSURLRequest nextBusPredictionsForStops:stops onRoute:_route];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//		NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:request.responseData options:NSXMLDocumentXMLKind error:nil];
//		for (NSXMLElement *predictionsElement in [document.rootElement elementsForName:@"predictions"]) {
//			NSMutableArray *predictions = [NSMutableArray array];
//
//			for (NSXMLElement *predictionElement in [[[predictionsElement elementsForName:@"direction"] lastObject] elementsForName:@"prediction"])
//				[predictions addObject:[MPHHTTPRequest predictionFromXMLElement:predictionElement onRoute:_route withPredictionsElement:predictionsElement]];
//
//			_predictions[[predictionsElement attributeForName:@"stopTag"].stringValue] = predictions;
//		}

		dispatch_async(dispatch_get_main_queue(), ^{
			if (strongDelegate && [strongDelegate respondsToSelector:@selector(routeController:didLoadPredictionsForDirection:)])
				[strongDelegate routeController:strongSelf didLoadPredictionsForDirection:direction];
		});
	}] resume];
}

- (void) reloadStopTimes {
	[self reloadStopTimesForDirection:MPHDirectionInbound];
	[self reloadStopTimesForDirection:MPHDirectionOutbound];
}

#pragma mark -

- (id <MPHStop>) nearestStopForDirection:(MPHDirection) direction {
	NSArray *workingStops = nil;

	if (direction == MPHDirectionInbound)
		workingStops = _inboundStops;
	else if (direction == MPHDirectionOutbound)
		workingStops = _outboundStops;

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

- (NSArray *) messagesForStop:(id <MPHStop>) stop {
	return [[MPHAmalgamator amalgamator] messagesForStop:stop ofService:_route.service];
}

- (NSArray *) predictionsForStop:(id <MPHStop>) stop {
	return _predictions[[NSString stringWithFormat:@"%zd", stop.tag]];
}

- (NSArray *) stopsForDirection:(MPHDirection) direction {
	if (direction == MPHDirectionInbound)
		return _inboundStops;
	return _outboundStops;
}

- (NSArray *) pathsForMap {
	return [[MPHAmalgamator amalgamator] pathsForRoute:_route];
}

#pragma mark -

- (UIColor *) color {
	if (_route.service == MPHServiceCaltrain)
		return [UIColor caltrainColor];
	return nil;
}
@end
