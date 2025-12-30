#import "MPHMUNIAmalgamation.h"

#import "MPHNextBusMessage.h"
#import "MPHNextBusRoute.h"
#import "MPHNextBusStop.h"

#import "MPHKeyedDictionary.h"
#import "MPHUtilities.h"

#import "CLLocationAdditions.h"
#import "NSFileManagerAdditions.h"
#import "NSStringAdditions.h"

#import "DDXMLDocument.h"
#import "DDXMLElement.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSetMPHAdditions.h"
#import <sqlite3.h>

@implementation MPHMUNIAmalgamation {
	dispatch_queue_t _queue;
	FMDatabase *_database;
	NSMutableDictionary *_messages;
	NSMutableDictionary *_affectedLinesForMessage;
	MPHKeyedDictionary *_affectedStopsPerLine;
	NSMutableDictionary *_messagesForStops;
}

+ (instancetype) amalgamation {
	static MPHMUNIAmalgamation *dataImporter = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		dataImporter = [[self alloc] init];
	});

	return dataImporter;
}

- (instancetype) init {
	if (!(self = [super init]))
		return nil;

	_queue = dispatch_queue_create([[NSString stringWithFormat:@"%@-%p", NSStringFromClass([self class]), self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);

	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSFileManager defaultManager].documentsDirectory error:nil];
	for (NSString *file in files) {
		if ([file mph_hasCaseInsensitivePrefix:@"MUNI"]) {
			NSString *path = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:file];

			_database = [FMDatabase databaseWithPath:path];
		}

		if (_database)
			break;
	}

	if (!_database) {
		NSString *defaultMUNIPath = [[NSBundle mainBundle] pathForResource:@"muni" ofType:@"db"];
		_database = [FMDatabase databaseWithPath:defaultMUNIPath];

		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *newMUNIPath = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:@"muni.db"];

			if (newMUNIPath) {
//				[[NSFileManager defaultManager] copyItemAtPath:defaultMUNIPath toPath:newMUNIPath error:nil];
			}
		});
	}

	[_database openWithFlags:SQLITE_OPEN_READWRITE];
	_database.crashOnErrors = YES;

	_messages = [[NSMutableDictionary alloc] init];
	_messagesForStops = [[NSMutableDictionary alloc] init];
	_affectedLinesForMessage = [[NSMutableDictionary alloc] init];
	_affectedStopsPerLine = [[MPHKeyedDictionary alloc] init];

	return self;
}

#pragma mark -

- (NSString *) routeDataVersion {
	return nil;
}

- (void) slurpRouteDataVersion:(NSString *) version {
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *path  = nil;
	if (!version.length)
		path = [fileManager.documentsDirectory stringByAppendingPathComponent:@"muni.db"];
	else path = [fileManager.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"muni-%@.db", version]];
	[fileManager removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];

	FMDatabase *newDatabase = [FMDatabase databaseWithPath:path];
	newDatabase.crashOnErrors = YES;

	dispatch_sync(_queue, ^{
		[newDatabase open];
		[newDatabase executeUpdate:@"CREATE TABLE routes (tag STRING, title STRING, inbound_routes STRING, outbound_routes STRING, row_id INTEGER PRIMARY KEY);"];
		[newDatabase executeUpdate:@"CREATE TABLE stops (tag STRING, title STRING, latitude REAL, longitude REAL, stopId INTEGER, routeTag STRING, row_id INTEGER PRIMARY KEY);"];
		[newDatabase executeUpdate:@"CREATE TABLE directions (tag STRING, title STRING, name STRING, useForUI INTEGER, stops STRING, row_id INTEGER PRIMARY KEY);"];
		[newDatabase executeUpdate:@"CREATE TABLE paths (tag STRING, pathCount INTEGER, latitude REAL, longitude REAL, row_id INTEGER PRIMARY KEY);"];
	});

	NSMutableURLRequest *routeListRequest = [[NSMutableURLRequest alloc] init];
//	routeListRequest.URL = [NSURL URLWithString:@"https://retro.umoiq.com/service/publicXMLFeed?command=routeList&a=sfmta-cis"];
	routeListRequest.URL = [NSURL URLWithString:@"https://retro.umoiq.com/api/pub/v1/agencies/sfmta-cis/routes?key=6fbba0cb1477045caa0ea47c9c4b081c"];
	[routeListRequest addValue:@"https://retro.umoiq.com/" forHTTPHeaderField:@"Referer"];

	[[[NSURLSession sharedSession] dataTaskWithRequest:routeListRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSArray *routesJSON = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
		for (NSDictionary *route in routesJSON) {
			NSMutableURLRequest *routeRequest = [[NSMutableURLRequest alloc] init];
			NSString *tag = route[@"id"];

//			routeRequest.URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://retro.umoiq.com/service/publicXMLFeed?command=routeConfig&a=sfmta-cis&r=%@", [tag mph_stringByPercentEncodingString]]];
			routeRequest.URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://retro.umoiq.com/api/pub/v1/agencies/sfmta-cis/routes/%@?key=6fbba0cb1477045caa0ea47c9c4b081c", [tag mph_stringByPercentEncodingString]]];
			[routeRequest addValue:@"https://retro.umoiq.com/" forHTTPHeaderField:@"Referer"];

			[[[NSURLSession sharedSession] dataTaskWithRequest:routeRequest completionHandler:^(NSData *successfulRouteRequestData, NSURLResponse *successfulRouteRequestResponse, NSError *successfulRouteRequestError) {
				NSDictionary *routeJSON = [NSJSONSerialization JSONObjectWithData:successfulRouteRequestData options:(NSJSONReadingOptions)0 error:nil];
				NSString *routeTag = routeJSON[@"id"];
				NSString *routeTitle = routeJSON[@"title"];
				NSString *inboundRoutes = @"";
				NSString *outboundRoutes = @"";

				NSMutableDictionary *stops = [NSMutableDictionary dictionary];
				for (NSDictionary *stopJSON in routeJSON[@"stops"]) {
					NSMutableDictionary *stop = [NSMutableDictionary dictionary];
					stop[@"tag"] = stopJSON[@"id"];
					stop[@"title"] = stopJSON[@"name"];
					stop[@"latitude"] = [NSString stringWithFormat:@"%@", stopJSON[@"lat"]];
					stop[@"longitude"] = [NSString stringWithFormat:@"%@", stopJSON[@"lon"]];
					stop[@"stopId"] = stop[@"code"];

					stops[stop[@"tag"]] = stop;
				}

//				for (DDXMLElement *directionElement in [requestRouteElement elementsForName:@"direction"]) {
//					NSString *directionTag = [directionElement attributeForName:@"tag"].stringValue;
//					NSString *directionTitle = [directionElement attributeForName:@"title"].stringValue;
//					NSString *directionName = [directionElement attributeForName:@"name"].stringValue;
//					NSString *directionUseForUI = [directionElement attributeForName:@"useForUI"].stringValue;
//
//					if ([directionTag mph_hasCaseInsensitiveSubstring:@"OB"] || [directionTitle mph_hasCaseInsensitiveSubstring:@"outbound"] || [directionName mph_hasCaseInsensitiveSubstring:@"outbound"]) {
//						if (outboundRoutes.length)
//							outboundRoutes = [outboundRoutes stringByAppendingFormat:@"`%@", directionTag];
//						else outboundRoutes = [outboundRoutes stringByAppendingString:directionTag];
//					} else {
//						if (inboundRoutes.length)
//							inboundRoutes = [inboundRoutes stringByAppendingFormat:@"`%@", directionTag];
//						else inboundRoutes = [inboundRoutes stringByAppendingString:directionTag];
//					}
//
//					NSString *stopList = @"";
//					for (DDXMLElement *stopElement in [directionElement elementsForName:@"stop"]) {
//						NSString *stopTag = [stopElement attributeForName:@"tag"].stringValue;
//						NSDictionary *stopDictionary = stops[stopTag];
//
//						if (stopDictionary) {
//							NSString *stopInsert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO stops (tag, title, latitude, longitude, stopId, routeTag) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", stopTag, stopDictionary[@"title"], stopDictionary[@"latitude"], stopDictionary[@"longitude"], stopDictionary[@"stopId"], routeTag];
//							dispatch_sync(self->_queue, ^{
//								[newDatabase executeUpdate:stopInsert];
//							});
//						}
//
//						if (stopList.length)
//							stopList = [stopList stringByAppendingFormat:@"`%@", stopTag];
//						else stopList = [stopList stringByAppendingString:stopTag];
//					}
//
//					NSString *directionInsert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO directions (tag, title, name, useForUI, stops) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", directionTag, directionTitle, directionName, directionUseForUI, stopList];
//					dispatch_sync(self->_queue, ^{
//						[newDatabase executeUpdate:directionInsert];
//					});
//
//				}

				NSString *routeInsert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO routes (tag, title, inbound_routes, outbound_routes) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")", routeTag, routeTitle, inboundRoutes, outboundRoutes];
				dispatch_sync(self->_queue, ^{
					[newDatabase executeUpdate:routeInsert];
				});

//				NSUInteger pathCount = 1;
//				for (DDXMLElement *pathElement in routeJSON[@"paths"]) {
//					for (DDXMLElement *pointElement in [pathElement elementsForName:@"point"]) {
//						NSString *latitude = [pointElement attributeForName:@"lat"].stringValue;
//						NSString *longitude = [pointElement attributeForName:@"lon"].stringValue;
//						NSString *pointInsert = [NSString stringWithFormat:@"INSERT INTO paths (tag, pathCount, latitude, longitude) VALUES (\"%@\", \"%zd\", \"%@\", \"%@\")", routeTag, pathCount, latitude, longitude];
//						dispatch_sync(self->_queue, ^{
//							[newDatabase executeUpdate:pointInsert];
//						});
//					}
//
//					pathCount++;
//				}
			}] resume];
		}
	}] resume];
}

#pragma mark -

- (NSArray *) routes {
	return [self routesFromQuery:@"SELECT * FROM routes;"];
}

- (NSArray *) sortedRoutes {
	return [[self routes] sortedArrayUsingComparator:compareMUNIRoutes];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction {
	return [self stopsForRoute:route inRegion:MKCoordinateRegionForMapRect(MKMapRectWorld) direction:direction];
}

- (NSArray *) pathsForRoute:(id <MPHRoute>) route {
	NSMutableArray *paths = [NSMutableArray array];

	NSString *query = [NSString stringWithFormat:@"SELECT * FROM paths WHERE tag = \"%@\";", route.tag];
	FMResultSet *results = [_database executeQuery:query];

	NSInteger previousPathCount = 0;
	NSMutableArray *points = nil;
	while ([results next]) {
		NSInteger currentPathCount = [results intForColumn:@"pathCount"];
		if (currentPathCount != previousPathCount) {
			points = [NSMutableArray array];

			[paths addObject:points];

			previousPathCount = currentPathCount;
		}

		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([results doubleForColumn:@"latitude"], [results doubleForColumn:@"longitude"]);

		[points addObject:[NSValue valueWithLocationCoordinate2D:coordinate]];
	}

	return paths;
}

- (id <MPHRoute>) routeWithTag:(id) tag {
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM routes WHERE tag = \"%@\";", tag];
	return [[self routesFromQuery:query] lastObject];
}

- (NSArray <id <MPHRoute>> *) routesForStop:(id <MPHStop>) stop {
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM routes WHERE tag = \"%@\";", stop.routeTag];
	return [self routesFromQuery:query];
}

#pragma mark -

- (NSArray *) messages {
	return [_messages.allValues copy];
}

- (NSArray *) routesForMessage:(MPHMessage *) message {
	return _affectedLinesForMessage[message.identifier];
}

- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag {
	return [_affectedStopsPerLine objectForKey:message.identifier key:tag];
}

- (NSArray *) messagesForStop:(id <MPHStop>) stop {
	return [_messagesForStops[[NSString stringWithFormat:@"%zd", stop.tag]] allValues];
}

- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction {
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM stops WHERE stops.tag = \"%@\" AND stops.routeTag = \"%@\";", tag, route.tag];

	return [[self stopFromQuery:query] lastObject];
}

#pragma mark -

- (void) fetchMessages {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	request.URL = [NSURL URLWithString:@"https://retro.umoiq.com/service/publicXMLFeed?command=messages&a=sfmta-cis"];
	[request addValue:@"https://retro.umoiq.com/" forHTTPHeaderField:@"Referer"];

	__weak typeof(self) weakSelf = self;
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;

			static NSDateFormatter *formatter = nil;
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				formatter = [[NSDateFormatter alloc] init];
				formatter.dateFormat = @"EEE, MMM d HH:mm:ss zzz yyyy";
			});

			DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:nil];
			for (DDXMLElement *element in [document.rootElement elementsForName:@"route"]) {
				for (DDXMLElement *messageElement in [element elementsForName:@"message"]) {
					NSString *identifier = [[messageElement attributeForName:@"id"] stringValue];

					MPHMessage *message = strongSelf->_messages[identifier];
					if (!message) {
						message = [[MPHNextBusMessage alloc] init];
						message.service = MPHServiceMUNI;
						message.message = [[[messageElement elementsForName:@"text"] lastObject] stringValue];
						message.startDate = [formatter dateFromString:[[messageElement attributeForName:@"startBoundaryStr"] stringValue]];
						message.endDate = [formatter dateFromString:[[messageElement attributeForName:@"endBoundaryStr"] stringValue]];
						message.identifier = identifier;

						strongSelf->_messages[identifier] = message;
					}

					NSMutableOrderedSet *affectedLines = strongSelf->_affectedLinesForMessage[message.identifier];
					if (!affectedLines) {
						affectedLines = [[NSMutableOrderedSet alloc] init];
						strongSelf->_affectedLinesForMessage[message.identifier] = affectedLines;
					}

					NSString *line = [[element attributeForName:@"tag"] stringValue];
					if (![line isEqualToString:@"all"])
						[affectedLines addObject:line];

					NSMutableOrderedSet *affectedStops = [strongSelf->_affectedStopsPerLine objectForKey:message.identifier key:line];
					if (!affectedStops) {
						affectedStops = [[NSMutableOrderedSet alloc] init];

						[strongSelf->_affectedStopsPerLine setObject:affectedStops forKey:message.identifier key:line];
					}

					for (DDXMLElement *routeConfigurationElement in [messageElement elementsForName:@"routeConfiguredForMessage"]) {
						NSString *tag = [routeConfigurationElement attributeForName:@"tag"].stringValue;
						[affectedLines addObject:tag];

						for (DDXMLElement *stopElement in [routeConfigurationElement elementsForName:@"stop"]) {
							MPHNextBusStop *stop = [[MPHNextBusStop alloc] init];
							stop.tag = [[[stopElement attributeForName:@"tag"] stringValue] longLongValue];
							stop.title = [[stopElement attributeForName:@"title"] stringValue];

							[affectedStops addObject:stop];
						}

						[affectedStops addObjectsFromArray:message.affectedStops];
						message.affectedStops = [affectedStops objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, affectedStops.count)]];
					}

					[affectedLines addObjectsFromArray:message.affectedLines];
					message.affectedLines = [affectedLines objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, affectedLines.count)]];
				}
			}
		});
	}] resume];
}

#pragma mark -

- (NSArray *) stopsInRegion:(MKCoordinateRegion) region {
	CLLocationCoordinate2D coordinate = region.center;
	CGFloat halfLatitudeDelta = region.span.latitudeDelta / 2.;
	CGFloat halfLongitudeDelta = region.span.longitudeDelta / 2.;

	return [self stopFromQuery:[NSString stringWithFormat:@"SELECT * from stops WHERE latitude > \"%f\" AND latitude < \"%f\" AND longitude > \"%f\" AND longitude < \"%f\"", coordinate.latitude - halfLatitudeDelta, coordinate.latitude + halfLatitudeDelta, coordinate.longitude - halfLongitudeDelta, coordinate.longitude + halfLongitudeDelta]];
}

- (NSArray *) routesInRegion:(MKCoordinateRegion) region {
	CLLocationCoordinate2D coordinate = region.center;
	CGFloat halfLatitudeDelta = region.span.latitudeDelta / 2.;
	CGFloat halfLongitudeDelta = region.span.longitudeDelta / 2.;

	__block FMResultSet *results = nil;
	dispatch_sync(_queue, ^{
		results = [self->_database executeQuery:[NSString stringWithFormat:@"SELECT * from paths WHERE latitude > \"%f\" AND latitude < \"%f\" AND longitude > \"%f\" AND longitude < \"%f\";", coordinate.latitude - halfLatitudeDelta, coordinate.latitude + halfLatitudeDelta, coordinate.longitude - halfLongitudeDelta, coordinate.longitude + halfLongitudeDelta]];
	});

	NSMutableSet *knownLines = [NSMutableSet set];
	while ([results next])
		[knownLines addObject:[results objectForColumnName:@"tag"]];

	NSArray *nearbyRoutes = [self routesFromQuery:[NSString stringWithFormat:@"SELECT * from routes WHERE tag='%@';", [[knownLines allObjects] componentsJoinedByString:@"' OR tag='"]]];
	return [nearbyRoutes sortedArrayUsingComparator:compareMUNIRoutes];
}

- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag {
	return [[self routesFromQuery:[NSString stringWithFormat:@"SELECT * from routes where inbound_routes LIKE '%%%@%%' OR outbound_routes LIKE '%%%@%%';", directionTag, directionTag]] lastObject];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction {
	if (direction == MPHDirectionIgnored)
		return nil;

	CLLocationCoordinate2D coordinate = region.center;
	CGFloat halfLatitudeDelta = region.span.latitudeDelta / 2.;
	CGFloat halfLongitudeDelta = region.span.longitudeDelta / 2.;

	__block NSArray *directions = nil;
	if (direction == MPHDirectionInbound) {
		NSString *query = [NSString stringWithFormat:@"SELECT inbound_routes FROM routes WHERE tag = \"%@\";", route.tag];
		dispatch_sync(_queue, ^{
			directions = [self->_database arrayForQuery:query];
		});
	} else {
		NSString *query = [NSString stringWithFormat:@"SELECT outbound_routes FROM routes WHERE tag = \"%@\";", route.tag];
		dispatch_sync(_queue, ^{
			directions = [self->_database arrayForQuery:query];
		});
	}

	NSMutableOrderedSet *stopsArray = [[NSMutableOrderedSet alloc] init];
	for (NSString *directionIdentifier in directions) {
		__block NSString *stopsListQuery = nil;
		__block NSArray *stopList = nil;
		__block NSString *stopsQuery = nil;
		__block NSArray *directionStops = nil;

		dispatch_sync(_queue, ^{
			stopsListQuery = [NSString stringWithFormat:@"SELECT stops, tag from directions WHERE tag = \"%@\";", directionIdentifier];
			stopList = [self->_database arrayForQuery:stopsListQuery];
			stopsQuery = [NSString stringWithFormat:@"SELECT * from stops WHERE routeTag = \"%@\" AND (tag = \"%@\") AND (latitude > \"%f\" AND latitude < \"%f\" AND longitude > \"%f\" AND longitude < \"%f\") ORDER BY stops.row_id ASC;", route.tag, [stopList componentsJoinedByString:@"\" OR tag = \""], coordinate.latitude - halfLatitudeDelta, coordinate.latitude + halfLatitudeDelta, coordinate.longitude - halfLongitudeDelta, coordinate.longitude + halfLongitudeDelta];
			directionStops = [self stopFromQuery:stopsQuery];
		});

		[directionStops enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (![stopsArray containsObject:object]) {
				if (index != (directionStops.count - 1)) {
					id nextObject = directionStops[index + 1];

					NSUInteger nextIndex = [stopsArray indexOfObject:nextObject];
					if (nextIndex == NSNotFound) {
						[stopsArray addObject:object];
					} else {
						[stopsArray insertObject:object atIndex:(nextIndex > 0 ? nextIndex - 1 : nextIndex)];
					}
				} else {
					[stopsArray addObject:object];
				}
			}
		}];
	}
	return [stopsArray.array copy];
}

#pragma mark -

- (NSArray *) routesFromQuery:(NSString *) query {
	NSMutableArray *routes = [NSMutableArray array];
	FMResultSet *results = [_database executeQuery:query];

	while ([results next]) {
		MPHNextBusRoute *route = [[MPHNextBusRoute alloc] init];
		route.service = MPHServiceMUNI;

		route.tag = [results stringForColumn:@"tag"];
		route.title = [results stringForColumn:@"title"];
		route.inboundRoutes = [results arrayForColumn:@"inbound_routes"];
		route.outboundRoutes = [results arrayForColumn:@"outbound_routes"];

		[routes addObject:route];
	}

	return routes;
}

- (NSArray *) stopFromQuery:(NSString *) query {
	@autoreleasepool {
	NSMutableArray *stops = [NSMutableArray array];
	FMResultSet *resultSet = [_database executeQuery:query];

	while ([resultSet next]) {
		MPHNextBusStop *stop = [[MPHNextBusStop alloc] init];
		stop.tag = [resultSet intForColumn:@"tag"];
		stop.identifier = [[resultSet stringForColumn:@"stopId"] integerValue];
		stop.title = [resultSet stringForColumn:@"title"];
		stop.coordinate = CLLocationCoordinate2DMake([resultSet doubleForColumn:@"latitude"], [resultSet doubleForColumn:@"longitude"]);
		stop.rowID = [resultSet intForColumn:@"row_id"];
		stop.routeTag = [resultSet stringForColumn:@"routeTag"];

		[stops addObject:stop];
	}

	return stops;
	}
}
@end
