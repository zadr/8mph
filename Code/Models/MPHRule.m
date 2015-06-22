#import "MPHRule.h"

#import "MPHDateRange.h"

#import "MPHAmalgamator.h"

#import "MPHStop.h"
#import "MPHRoute.h"

@implementation MPHRule {
	NSMutableDictionary *_stopsToRoutes; // arguello and fulton: [5, 33]
	NSMutableDictionary *_routesToStops; // 5: 6th and fulton, 31: 6th and balboa
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_enabled = YES;
	_alerts = [NSMutableArray array];
	_range = [[MPHDateRange alloc] init];
	_stopsToRoutes = [NSMutableDictionary dictionary];
	_routesToStops = [NSMutableDictionary dictionary];
	_warningInterval = 2000;

	return self;
}

- (id) initWithCoder:(NSCoder *) coder {
	if (!(self = [self init]))
		return nil;

	_service = [coder decodeIntForKey:@"service"];
	_warningInterval = [coder decodeDoubleForKey:@"warning-interval"];
	_range = [coder decodeObjectForKey:@"ranges"];
	_enabled = [coder decodeBoolForKey:@"enabled"];
	_alerts = [[coder decodeObjectForKey:@"alerts"] mutableCopy];

	NSDictionary *mapping = [coder decodeObjectForKey:@"stops-to-routes"];
	[mapping enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		_stopsToRoutes[key] = [NSMutableArray array];

		for (id tag in value) {
			id <MPHRoute> route = [[MPHAmalgamator amalgamator] routeWithTag:tag onService:_service];
			if (route)
				[_stopsToRoutes[key] addObject:route];
			else NSLog(@"Failed to add %@ to %@", tag, self);
		}
	}];

	mapping = [coder decodeObjectForKey:@"routes-to-stops"];
	[mapping enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		_routesToStops[key] = [NSMutableArray array];

		for (id tag in value) {
			id <MPHStop> stop = [[MPHAmalgamator amalgamator] stopWithTag:tag onRoute:[[MPHAmalgamator amalgamator] routeWithTag:key onService:_service] onService:MPHServiceMUNI inDirection:MPHDirectionInbound];
			if (!stop)
				stop = [[MPHAmalgamator amalgamator] stopWithTag:tag onRoute:[[MPHAmalgamator amalgamator] routeWithTag:key onService:_service] onService:MPHServiceMUNI inDirection:MPHDirectionOutbound];

			if (stop)
				[_routesToStops[key] addObject:stop];
			else NSLog(@"Failed to add %@ to %@", tag, self);
		}
	}];

	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder {
	[coder encodeInt:_service forKey:@"service"];
	[coder encodeDouble:_warningInterval forKey:@"warning-interval"];
	[coder encodeObject:_range forKey:@"ranges"];
	[coder encodeBool:_enabled forKey:@"enabled"];
	[coder encodeObject:_alerts forKey:@"alerts"];

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (id key in _stopsToRoutes) {
		NSMutableArray *valueIdentifiers = [NSMutableArray array];
		for (id <MPHRoute> value in _stopsToRoutes[key])
			[valueIdentifiers addObject:value.tag];
		dictionary[key] = valueIdentifiers;
	}

	[coder encodeObject:dictionary forKey:@"stops-to-routes"];

	dictionary = [NSMutableDictionary dictionary];
	for (id key in _routesToStops) {
		NSMutableArray *valueIdentifiers = [NSMutableArray array];
		for (id <MPHStop> value in _routesToStops[key])
			[valueIdentifiers addObject:value.link];
		dictionary[key] = valueIdentifiers;
	}
	[coder encodeObject:dictionary forKey:@"routes-to-stops"];
}

#pragma mark -

- (NSArray *) stops {
	NSMutableSet *stops = [NSMutableSet set];
	for (NSArray *array in _routesToStops.allValues)
		[stops addObjectsFromArray:array];
	return stops.allObjects;
}

- (NSArray *) routes {
	NSMutableSet *routes = [NSMutableSet set];
	for (NSArray *array in _stopsToRoutes.allValues)
		[routes addObjectsFromArray:array];
	return routes.allObjects;
}

#pragma mark -

- (void) addStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route {
	NSMutableArray *routes = _stopsToRoutes[stop.link];
	if (!routes) {
		routes = [NSMutableArray array];
		_stopsToRoutes[stop.link] = routes;
	}
	[routes addObject:route];

	NSMutableArray *stops = _routesToStops[route.tag];
	if (!stops) {
		stops = [NSMutableArray array];
		_routesToStops[route.tag] = stops;
	}
	[stops addObject:stop];
}

- (void) removeStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route {
	[_stopsToRoutes[stop.link] removeObject:route];
	[_routesToStops[route.tag] removeObject:stop];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route {
	return [_routesToStops[route.tag] copy];
}

- (NSArray *) routesForStop:(id <MPHStop>) stop {
	return [_stopsToRoutes[stop.link] copy];
}

#pragma mark -

- (NSDictionary *) alertOfType:(NSString *) type {
	for (NSDictionary *alert in _alerts) {
		if ([alert[MPHAlertTypeKey] isEqualToString:type])
			return [alert copy];
	}

	return nil;
}
@end
