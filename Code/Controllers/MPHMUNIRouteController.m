#import "MPHMUNIRouteController.h"

#import "MPHRouteController.h"
#import "MPHStopsController.h"

#import "MPHAmalgamation.h"
#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"
#import "MPHVehicleLocation.h"

#import "CLLocationAdditions.h"

#import "UIColorAdditions.h"

#import "DDXMLDocument.h"

@interface MPHMUNIRouteController () <MPHStopsControllerDelegate>
@end

@implementation MPHMUNIRouteController {
	NSMutableDictionary *_stopsControllers;

	NSMutableDictionary *_vehicleLocations;
	NSUInteger _lastVehicleLocationTime; // intentionally not a NSTimeInterval because NextBus works with integers, not floats
}

@synthesize delegate = _delegate;
@synthesize predictionLoadedDate = _predictionLoadedDate;
@synthesize route = _route;

- (id) initWithRoute:(id <MPHRoute>) route {
	if (!(self = [super init]))
		return nil;

	_route = route;
	_stopsControllers = [NSMutableDictionary dictionary];

	NSArray *inboundStops = [[MPHAmalgamator amalgamator] stopsForRoute:_route inDirection:MPHDirectionInbound];
	_stopsControllers[@(MPHDirectionInbound)] = [MPHStopsController stopsControllerForService:MPHServiceMUNI withStops:inboundStops];

	NSArray *outboundStops = [[MPHAmalgamator amalgamator] stopsForRoute:_route inDirection:MPHDirectionOutbound];
	_stopsControllers[@(MPHDirectionOutbound)] = [MPHStopsController stopsControllerForService:MPHServiceMUNI withStops:outboundStops];

	for (id <MPHStopsController> stopsController in _stopsControllers.allValues) {
		stopsController.delegate = self;
		[stopsController fetchPredictions];
	}

	_vehicleLocations = [NSMutableDictionary dictionary];

	return self;
}

- (void) stopsControllerDidLoadPredictionsForStop:(id <MPHStopsController>) stopsController {
	__strong id <MPHRouteControllerDelegate> delegate = self.delegate;
	if (stopsController == _stopsControllers[@(MPHDirectionInbound)])
		[delegate routeController:self didLoadPredictionsForDirection:MPHDirectionInbound];
	else if (stopsController == _stopsControllers[@(MPHDirectionOutbound)])
		[delegate routeController:self didLoadPredictionsForDirection:MPHDirectionOutbound];
}

#pragma mark -

- (void) reloadStopTimesForDirection:(MPHDirection) direction {
	[_stopsControllers[@(direction)] fetchPredictions]; // reloadStopTimesForDirection:direction
}

- (void) reloadStopTimes {
	[self reloadStopTimesForDirection:MPHDirectionInbound];
	[self reloadStopTimesForDirection:MPHDirectionOutbound];
}

- (void) reloadVehicleLocations {
	__weak __typeof__((self)) weakSelf = self;
	NSString *URLString = [NSString stringWithFormat:@"https://retro.umoiq.com/service/publicXMLFeed?command=vehicleLocations&a=sfmta-cis&r=%@&t=%zd", self.route.tag, _lastVehicleLocationTime];
	NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	[URLRequest addValue:@"https://retro.umoiq.com/" forHTTPHeaderField:@"Referer"];

	[[[NSURLSession sharedSession] dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSError *xmlError = nil;
		DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:&xmlError];
		if (!document) {
			NSLog(@"Error making a DDXMLDocument from vehicle location data: %@, %@", xmlError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			return;
		}

		__strong __typeof__((weakSelf)) strongSelf = weakSelf;
		if (!strongSelf)
			return;

		for (DDXMLElement *vehicleElement in [document.rootElement elementsForName:@"vehicle"]) {
			MPHVehicleLocation *vehicleLocation = [[MPHVehicleLocation alloc] init];
			vehicleLocation.vehicleIdentifier = [vehicleElement attributeForName:@"id"].stringValue;
			vehicleLocation.routeTag = [vehicleElement attributeForName:@"routeTag"].stringValue;
			vehicleLocation.directionTag = [vehicleElement attributeForName:@"dirTag"].stringValue;
			vehicleLocation.coordinate = CLLocationCoordinate2DMake([vehicleElement attributeForName:@"lat"].stringValue.doubleValue, [vehicleElement attributeForName:@"lon"].stringValue.doubleValue);
			vehicleLocation.secondsSinceLastReport = [vehicleElement attributeForName:@"secsSinceReport"].stringValue.doubleValue;
			vehicleLocation.predictable = [vehicleElement attributeForName:@"predictable"].stringValue.boolValue;
			vehicleLocation.heading = [vehicleElement attributeForName:@"heading"].stringValue.doubleValue;
			vehicleLocation.speed = [vehicleElement attributeForName:@"speedKmHr"].stringValue.doubleValue * 100; // NextBus gives it to us in km/h, and we want m/h

			strongSelf->_vehicleLocations[vehicleLocation.vehicleIdentifier] = vehicleLocation;
		}

		DDXMLElement *lastTimeElement = [document.rootElement elementsForName:@"lastTime"].lastObject;
		strongSelf->_lastVehicleLocationTime = [lastTimeElement attributeForName:@"time"].stringValue.doubleValue;

		__strong __typeof__((strongSelf.delegate)) strongDelegate = strongSelf.delegate;
		[strongDelegate routeControllerDidLoadVehicleLocations:strongSelf];
	}] resume];
}

#pragma mark -

- (id <MPHStop>) nearestStopForDirection:(MPHDirection) direction {
	NSArray *workingStops = [self stopsForDirection:direction];

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
	NSArray *predictions = nil;
	for (id <MPHStopsController> stopsController in _stopsControllers.allValues) {
		predictions = [stopsController predictionsForStop:stop];
		if (predictions)
			break;
	}
	return predictions;
}

- (NSArray *) stopsForDirection:(MPHDirection) direction {
	if (direction == MPHDirectionInbound)
		return [_stopsControllers[@(MPHDirectionInbound)] stops];
	return [_stopsControllers[@(MPHDirectionOutbound)] stops];
}

- (NSArray *) pathsForMap {
	return [[MPHAmalgamator amalgamator] pathsForRoute:_route];
}

- (NSArray *) directionTitles {
	return @[
		NSLocalizedString(@"Inbound", @"Inbound segment item"),
		NSLocalizedString(@"Outbound", @"Outbound segment item")
	];
}

#pragma mark -

- (UIColor *) color {
	return _route.color;
}
@end
