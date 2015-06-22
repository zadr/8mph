#import "MPHBARTAmalgamation.h"

#import "MPHBARTRoute.h"
#import "MPHBARTStation.h"
#import "MPHBARTStationData.h"
#import "MPHMessage.h"

#import "MPHKeyedDictionary.h"

#import "MPHDefines.h"

#import "NSDictionaryAdditions.h"
#import "NSFileManagerAdditions.h"

#import "FMDatabase.h"
#import "FMResultSetMPHAdditions.h"

#import "DDXML.h"

@implementation MPHBARTAmalgamation {
	dispatch_queue_t _queue;
	FMDatabase *_database;
	NSMutableDictionary *_messages;
	NSMutableDictionary *_affectedLinesForMessage;
	MPHKeyedDictionary *_affectedStopsPerLine;
	NSMutableDictionary *_messagesForStops;
}

+ (instancetype) amalgamation {
	static MPHBARTAmalgamation *dataImporter = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		dataImporter = [[self alloc] init];
	});

	return dataImporter;
}

#pragma mark -

- (instancetype) init {
	if (!(self = [super init]))
		return nil;

	_queue = dispatch_queue_create([[NSString stringWithFormat:@"%@-%p", NSStringFromClass([self class]), self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);

	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSFileManager defaultManager].documentsDirectory error:nil];
	for (NSString *file in files) {
		if ([file mph_hasCaseInsensitivePrefix:@"BART"]) {
			NSString *path = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:file];

			_database = [FMDatabase databaseWithPath:path];
		}

		if (_database)
			break;
	}

	if (!_database) {
		NSString *defaultBARTPath = [[NSBundle mainBundle] pathForResource:@"bart" ofType:@"db"];
		_database = [FMDatabase databaseWithPath:defaultBARTPath];

		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *newBARTPath = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:@"bart.db"];

			[[NSFileManager defaultManager] copyItemAtPath:defaultBARTPath toPath:newBARTPath error:nil];
		});
	}

	[_database openWithFlags:SQLITE_OPEN_READONLY];
	_database.crashOnErrors = YES;

	_messages = [[NSMutableDictionary alloc] init];
	_messagesForStops = [[NSMutableDictionary alloc] init];
	_affectedLinesForMessage = [[NSMutableDictionary alloc] init];
	_affectedStopsPerLine = [[MPHKeyedDictionary alloc] init];

	return self;
}

#pragma mark -

- (NSURLRequest *) BARTAPIReqestWithURLString:(NSString *) URLString parameters:(NSDictionary *) parameters {
	NSMutableDictionary *workingParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
	workingParameters[@"key"] = MPHBARTAPIKey;

	URLString = [URLString stringByAppendingFormat:@"?%@", workingParameters.mph_queryRepresentation];

	return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
}

#pragma mark -

- (NSString *) routeDataVersion {
	return nil;
}

- (void) slurpRouteDataVersion:(NSString *) version {
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *path  = nil;
	if (!version.length)
		path = [fileManager.documentsDirectory stringByAppendingPathComponent:@"bart.db"];
	else path = [fileManager.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bart-%@.db", version]];
	[fileManager removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];

	FMDatabase *newDatabase = [FMDatabase databaseWithPath:path];

	dispatch_sync(_queue, ^{
		[newDatabase open];
		[newDatabase executeUpdate:@"CREATE TABLE routes (name STRING, abbreviation STRING, routeIdentifier STRING, number INTEGER, color STRING, stops STRING, PRIMARY KEY(routeIdentifier, abbreviation));"];
		[newDatabase executeUpdate:@"CREATE TABLE stations (name STRING, abbreviation STRING, latitude REAL, longitude REAL, address STRING, city STRING, county STRING, state STRING, zipcode INTEGER, north_routes STRING, south_routes STRING, north_platforms INTEGER, south_platforms INTEGER, PRIMARY KEY(latitude, longitude, abbreviation));"];
		[newDatabase executeUpdate:@"CREATE TABLE station_data (platform_info STRING, introduction STRING, abbreviation STRING, cross_street STRING, food STRING, shopping STRING, attraction STRING, entering STRING, exiting STRING, parking STRING, parking_flag INTEGER, locker_flag INTEGER, car_share INTEGER, fill_time STRING, lockers STRING, bike_station STRING, bike_flag INTEGER, bike_station_flag INTEGER, PRIMARY KEY(abbreviation));"];
	});

	NSURLRequest *routeListRequest = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/route.aspx" parameters:@{ @"cmd": @"routes" }];
	[[[NSURLSession sharedSession] dataTaskWithRequest:routeListRequest completionHandler:^(NSData *completedRouteListRequestData, NSURLResponse *completedRouteListRequestResponse, NSError *completedRouteListRequestError) {
		NSXMLDocument *routesDocument = [[NSXMLDocument alloc] initWithData:completedRouteListRequestData options:NSXMLDocumentXMLKind error:nil];
		NSXMLElement *routesElement = [[routesDocument.rootElement elementsForName:@"routes"] lastObject];

		for (NSXMLElement *routeElement in [routesElement elementsForName:@"route"]) {
			NSString *number = [[[routeElement elementsForName:@"number"] lastObject] stringValue];
			NSString *routeIdentifier = [[[routeElement elementsForName:@"routeID"] lastObject] stringValue];
			NSString *update = [NSString stringWithFormat:@"INSERT INTO routes (name, abbreviation, routeIdentifier, number, color) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\");", [[[routeElement elementsForName:@"name"] lastObject] stringValue], [[[routeElement elementsForName:@"abbr"] lastObject] stringValue], routeIdentifier, number, [[[routeElement elementsForName:@"color"] lastObject] stringValue]];
			dispatch_sync(self->_queue, ^{
				[newDatabase executeUpdate:update];
			});

			NSURLRequest *routeInformationRequest = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/route.aspx" parameters:@{ @"cmd": @"routeInfo", @"route": number }];
			[[[NSURLSession sharedSession] dataTaskWithRequest:routeInformationRequest completionHandler:^(NSData *completedRouteInformationRequestData, NSURLResponse *completedRouteInformationRequestResponse, NSError *completedRouteInformationRequestError) {
				NSXMLDocument *routeInformationDocument = [[NSXMLDocument alloc] initWithData:completedRouteInformationRequestData options:NSXMLDocumentXMLKind error:nil];
				NSXMLElement *routesInformationElement = [[routeInformationDocument.rootElement elementsForName:@"routes"] lastObject];
				NSXMLElement *routeInformationElement = [[routesInformationElement elementsForName:@"route"] lastObject];
				NSXMLElement *configElement = [[routeInformationElement elementsForName:@"config"] lastObject];

				NSMutableString *stations = [NSMutableString string];
				for (NSXMLElement *stationElement in [configElement elementsForName:@"station"])
					[stations appendFormat:@"%@`", stationElement.stringValue];
				[stations deleteCharactersInRange:NSMakeRange(stations.length - 1, 1)];

				NSString *completedRouteInformationUpdate = [NSString stringWithFormat:@"UPDATE routes SET stops = \"%@\" WHERE routeIdentifier = \"%@\";", stations, routeIdentifier];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:completedRouteInformationUpdate];
				});
			}] resume];
		}
	}] resume];

	NSURLRequest *stationsRequest = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/stn.aspx" parameters:@{ @"cmd": @"stns" }];
	[[[NSURLSession sharedSession] dataTaskWithRequest:stationsRequest completionHandler:^(NSData *completedStationsRequestData, NSURLResponse *completedStationsRequestResponse, NSError *completedStationsRequestError) {
		NSXMLDocument *stationsDocument = [[NSXMLDocument alloc] initWithData:completedStationsRequestData options:NSXMLDocumentXMLKind error:nil];
		NSXMLElement *stationsElement = [[stationsDocument.rootElement elementsForName:@"stations"] lastObject];
		for (NSXMLElement *stationElement in [stationsElement elementsForName:@"station"]) {
			NSString *abbreviation = [[[stationElement elementsForName:@"abbr"] lastObject] stringValue];
			NSString *update = [NSString stringWithFormat:@"INSERT INTO stations (name, abbreviation, latitude, longitude, address, city, county, state, zipcode) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\");", [[[stationElement elementsForName:@"name"] lastObject] stringValue], abbreviation, [[[stationElement elementsForName:@"gtfs_latitude"] lastObject] stringValue], [[[stationElement elementsForName:@"gtfs_longitude"] lastObject] stringValue], [[[stationElement elementsForName:@"address"] lastObject] stringValue], [[[stationElement elementsForName:@"city"] lastObject] stringValue], [[[stationElement elementsForName:@"county"] lastObject] stringValue], [[[stationElement elementsForName:@"state"] lastObject] stringValue], [[[stationElement elementsForName:@"zipcode"] lastObject] stringValue]];
			dispatch_sync(self->_queue, ^{
				[newDatabase executeUpdate:update];
			});

			NSURLRequest *stationInformationRequest = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/stn.aspx" parameters:@{ @"cmd": @"stninfo", @"orig": abbreviation }];
			[[[NSURLSession sharedSession] dataTaskWithRequest:stationInformationRequest completionHandler:^(NSData *completedStationInformationRequestData, NSURLResponse *completedStationInformationRequestResponse, NSError *completedStationInformationRequestError) {
				NSXMLDocument *stationDocument = [[NSXMLDocument alloc] initWithData:completedStationInformationRequestData options:NSXMLDocumentXMLKind error:nil];
				NSXMLElement *stationsInformationElement = [[stationDocument.rootElement elementsForName:@"stations"] lastObject];
				NSXMLElement *stationInformationElement = [[stationsInformationElement elementsForName:@"station"] lastObject];

				NSString *stationInformationElementAbbreviation = [[[stationInformationElement elementsForName:@"abbr"] lastObject] stringValue];
				NSMutableString *northRoutes = [NSMutableString string];
				for (NSXMLElement *routeElement in [stationInformationElement elementsForName:@"north_routes"])
					[northRoutes appendFormat:@"%@`", routeElement.stringValue];
				[northRoutes deleteCharactersInRange:NSMakeRange(northRoutes.length - 1, 1)];

				NSMutableString *southRoutes = [NSMutableString string];
				for (NSXMLElement *routeElement in [stationInformationElement elementsForName:@"south_routes"])
					[southRoutes appendFormat:@"%@`", routeElement.stringValue];
				[southRoutes deleteCharactersInRange:NSMakeRange(southRoutes.length - 1, 1)];

				NSMutableString *northPlatforms = [NSMutableString string];
				for (NSXMLElement *platformElement in [stationInformationElement elementsForName:@"north_platforms"])
					[northPlatforms appendFormat:@"%@`", platformElement.stringValue];
				[northPlatforms deleteCharactersInRange:NSMakeRange(northPlatforms.length - 1, 1)];

				NSMutableString *southPlatforms = [NSMutableString string];
				for (NSXMLElement *platformElement in [stationInformationElement elementsForName:@"south_platforms"])
					[southPlatforms appendFormat:@"%@`", platformElement.stringValue];
				[southPlatforms deleteCharactersInRange:NSMakeRange(southPlatforms.length - 1, 1)];

				NSString *completedStationInformationUpdate = [NSString stringWithFormat:@"UPDATE stations SET north_routes = \"%@\", south_routes = \"%@\", north_platforms = \"%@\", south_platforms = \"%@\" WHERE abbreviation = \"%@\";", northRoutes, southRoutes, northPlatforms, southPlatforms, stationInformationElementAbbreviation];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:completedStationInformationUpdate];
				});

				NSString *platformInfo =[[[[stationElement elementsForName:@"platform_info"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *info = [[[[stationElement elementsForName:@"intro"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *food = [[[[stationElement elementsForName:@"food"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *shopping = [[[[stationElement elementsForName:@"shopping"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *attraction = [[[[stationElement elementsForName:@"attraction"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];

				completedStationInformationUpdate = [NSString stringWithFormat:@"INSERT INTO station_data (abbreviation, platform_info, introduction, cross_street, food, shopping, attraction) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\");", stationInformationElementAbbreviation, platformInfo, info, [[[stationElement elementsForName:@"cross_street"] lastObject] stringValue], food, shopping, attraction];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:completedStationInformationUpdate];
				});
			}] resume];

			NSURLRequest *stationAccessRequest = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/stn.aspx" parameters:@{ @"cmd": @"stnaccess", @"orig": abbreviation, @"l": @"0" }];
			[[[NSURLSession sharedSession] dataTaskWithRequest:stationAccessRequest completionHandler:^(NSData *completedStationAccessRequestData, NSURLResponse *completedStationAccessRequestResponse, NSError *completedStationAccessRequestError) {
				NSXMLDocument *stationDocument = [[NSXMLDocument alloc] initWithData:completedStationAccessRequestData options:NSXMLDocumentXMLKind error:nil];
				NSXMLElement *stationsAccessElement = [[stationDocument.rootElement elementsForName:@"stations"] lastObject];
				NSXMLElement *stationAccessElement = [[stationsAccessElement elementsForName:@"station"] lastObject];

				NSString *accessUpdate = [NSString stringWithFormat:@"UPDATE station_data SET parking_flag = \"%@\", bike_flag = \"%@\", bike_station_flag = \"%@\", locker_flag = \"%@\" WHERE abbreviation = \"%@\";", [stationAccessElement attributeForName:@"parking_flag"].stringValue, [stationAccessElement attributeForName:@"bike_flag"].stringValue, [stationAccessElement attributeForName:@"bike_station_flag"].stringValue, [stationAccessElement attributeForName:@"locker_flag"].stringValue, abbreviation];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:accessUpdate];
				});

				NSString *entering = [[[[stationElement elementsForName:@"entering"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *exiting = [[[[stationElement elementsForName:@"exiting"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *parking = [[[[stationElement elementsForName:@"parking"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *fillTime = [[[[stationElement elementsForName:@"fill_time"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *carShare = [[[[stationElement elementsForName:@"car_share"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *lockers = [[[[stationElement elementsForName:@"lockers"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
				NSString *bikeStationInfo = [[[[stationElement elementsForName:@"bike_station_text"] lastObject] stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];

				accessUpdate = [NSString stringWithFormat:@"UPDATE station_data SET entering = \"%@\", exiting = \"%@\", parking = \"%@\", fill_time = \"%@\", car_share = \"%@\", lockers = \"%@\", bike_station = \"%@\"", entering, exiting, parking, fillTime, carShare, lockers, bikeStationInfo];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:accessUpdate];
				});
			}] resume];
		}
	}] resume];
}

#pragma mark -

- (NSArray *) routes {
	NSMutableArray *routes = [NSMutableArray array];
	__block FMResultSet *results = nil;

	dispatch_sync(_queue, ^{
		results = [self->_database executeQuery:@"SELECT * FROM routes;"];
	});

	while ([results next]) {
		MPHBARTRoute *route = [[MPHBARTRoute alloc] init];

		route.service = MPHServiceBART;
		route.name = [results stringForColumn:@"name"];
		route.number = [results intForColumn:@"number"];
		route.abbreviation = [results stringForColumn:@"abbreviation"];
		route.routeIdentifier = [results stringForColumn:@"routeIdentifier"];
		route.stops = [results arrayForColumn:@"stops"];

#if TARGET_OS_IPHONE
		// color!
#endif

		[routes addObject:route];
	}

	return routes;
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction {
	if (direction != MPHDirectionIgnored)
		return nil;

	NSMutableArray *stops = [NSMutableArray array];

	MPHBARTRoute *bartRoute = (MPHBARTRoute *)route;
	NSString *query = [NSString stringWithFormat:@"SELECT stops FROM routes WHERE number = \"%zd\"", bartRoute.number];
	__block NSArray *results = nil;

	dispatch_sync(_queue, ^{
		results = [self->_database arrayForQuery:query];
	});

	NSString *stopQuery = [NSString stringWithFormat:@"SELECT * FROM stations WHERE"];
	for (NSString *abbreviation in results) {
		NSString *abbreviationQuery = [stopQuery stringByAppendingFormat:@" abbreviation = \"%@\";", abbreviation];

		FMResultSet *resultSet = [_database executeQuery:abbreviationQuery];

		while ([resultSet next]) {
			MPHBARTStation *station = [[MPHBARTStation alloc] init];
			station.name = [resultSet stringForColumn:@"name"];
			station.abbreviation = [resultSet stringForColumn:@"abbreviation"];
			station.address = [resultSet stringForColumn:@"address"];
			station.city = [resultSet stringForColumn:@"city"];
			station.county = [resultSet stringForColumn:@"county"];
			station.state = [resultSet stringForColumn:@"state"];
			station.zipCode = [resultSet intForColumn:@"zipcode"];
			station.northRoutes = [resultSet arrayForColumn:@"north_routes"];
			station.southRoutes = [resultSet arrayForColumn:@"south_routes"];
			station.northPlatforms = [resultSet arrayForColumn:@"north_platforms"];
			station.southPlatforms = [resultSet arrayForColumn:@"south_platforms"];
			station.location = CLLocationCoordinate2DMake([resultSet doubleForColumn:@"latitude"], [resultSet doubleForColumn:@"longitude"]);
			[stops addObject:station];
		}
	}

	return stops;
}

- (NSArray *) pathsForRoute:(id <MPHRoute>) route {
	NSMutableArray *paths = [NSMutableArray array];
	for (MPHBARTStation *station in [self stopsForRoute:route inDirection:MPHDirectionIgnored])
		[paths addObject:[NSValue valueWithLocationCoordinate2D:station.location]];

	return @[ paths ];
}

- (id <MPHRoute>) routeWithTag:(id) tag {
	return nil;
}

#pragma mark -

- (NSArray *) messages {
	return [_messages.allValues copy];
}

- (NSArray *) routesForMessage:(MPHMessage *) message {
	return _affectedLinesForMessage[message.identifier];
}

- (id <MPHRoute>) routeForStop:(id <MPHStop>) stop {
	return nil;
}

- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag {
	return nil;
}

- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag {
	return [_affectedStopsPerLine objectForKey:message.identifier key:tag];
}

- (NSArray *) messagesForStop:(id <MPHStop>) stop {
	return [_messagesForStops[[NSString stringWithFormat:@"%zd", stop.tag]] allValues];
}

- (void) fetchMessages {
	__weak typeof(self) weakSelf = self;

	NSURLRequest *request = [self BARTAPIReqestWithURLString:@"http://api.bart.gov/api/bsa.aspx" parameters:@{ @"cmd": @"bsa", @"date": @"today", @"orig": @"all" }];

	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentXMLKind error:nil];

			static NSDateFormatter *dateFormatter = nil;
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				dateFormatter = [[NSDateFormatter alloc] init];
				dateFormatter.dateFormat = @"EEE MMM dd yyyy hh:mm a zzz";
			});

			for (NSXMLElement *bsaElement in [document.rootElement elementsForName:@"bsa"]) {
				NSString *identifier = [bsaElement attributeForName:@"id"].stringValue;
				if (!identifier.length)
					identifier = @"null"; // no delays reported

				MPHMessage *message = strongSelf->_messages[identifier];
				if (!message) {
					message = [[MPHMessage alloc] init];
					message.service = MPHServiceBART;
					message.identifier = identifier;
					message.startDate = [dateFormatter dateFromString:[[[bsaElement elementsForName:@"posted"] lastObject] stringValue]];
					message.endDate = [dateFormatter dateFromString:[[[bsaElement elementsForName:@"expires"] lastObject] stringValue]];
					message.message = [[[bsaElement elementsForName:@"description"] lastObject] stringValue];

					strongSelf->_messages[identifier] = message;
				}
			}
		});
	}] resume];
}

#pragma mark -

- (NSArray *) stopsInRegion:(MKCoordinateRegion) region {
	NSMutableArray *stops = [NSMutableArray array];

	CLLocationCoordinate2D coordinate = region.center;
	CGFloat halfLatitude = region.span.latitudeDelta / 2.;
	CGFloat halfLongitude = region.span.longitudeDelta / 2.;
	NSString *query = [NSString stringWithFormat:@"SELECT * from stations WHERE latitude > \"%f\" AND latitude < \"%f\" AND longitude > \"%f\" AND longitude < \"%f\";", coordinate.latitude - halfLatitude, coordinate.latitude + halfLatitude, coordinate.longitude - halfLongitude, coordinate.longitude + halfLongitude];

	__block FMResultSet *resultSet = nil;

	dispatch_sync(_queue, ^{
		resultSet = [self->_database executeQuery:query];
	});

	while ([resultSet next]) {
		MPHBARTStation *station = [[MPHBARTStation alloc] init];
		station.name = [resultSet stringForColumn:@"name"];
		station.abbreviation = [resultSet stringForColumn:@"abbreviation"];
		station.address = [resultSet stringForColumn:@"address"];
		station.city = [resultSet stringForColumn:@"city"];
		station.county = [resultSet stringForColumn:@"county"];
		station.state = [resultSet stringForColumn:@"state"];
		station.zipCode = [resultSet intForColumn:@"zipcode"];
		station.northRoutes = [resultSet arrayForColumn:@"north_routes"];
		station.southRoutes = [resultSet arrayForColumn:@"south_routes"];
		station.northPlatforms = [resultSet arrayForColumn:@"north_platforms"];
		station.southPlatforms = [resultSet arrayForColumn:@"south_platforms"];
		station.location = CLLocationCoordinate2DMake([resultSet doubleForColumn:@"latitude"], [resultSet doubleForColumn:@"longitude"]);
		[stops addObject:station];
	}

	return stops;
}

- (NSArray *) routesInRegion:(MKCoordinateRegion) region {
	return nil;
}

- (NSArray *) stopsForRoute:(id<MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction {
	return nil;
}

- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction {
	return nil;
}
@end
