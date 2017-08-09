#import "MPH511Amalgamation.h"

#import "MPH511Route.h"
#import "MPH511Stop.h"

#import "MPHGoogleGeocoder.h"

#import "NSDictionaryAdditions.h"
#import "NSFileManagerAdditions.h"
#import "NSStringAdditions.h"

#import "FMDB.h"
#import "FMResultSetMPHAdditions.h"
#import <sqlite3.h>

@implementation MPH511Amalgamation {
	dispatch_queue_t _queue;
	FMDatabase *_database;
}

+ (instancetype) amalgamation {
	static NSMutableDictionary *amalgamations = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		amalgamations = [NSMutableDictionary dictionary];
	});

	MPH511Amalgamation *amalgamation = nil;
	@synchronized(self) {
		amalgamation = amalgamations[NSStringFromClass([self class])];
		if (!amalgamation) {
			amalgamation = [[self alloc] init];
			amalgamations[NSStringFromClass([self class])] = amalgamation;
		}
	}

	return amalgamation;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	NSAssert(![self isMemberOfClass:[MPH511Amalgamation class]], @"Don't instantiate MPH511Amalgamation directly!");

	_queue = dispatch_queue_create([[NSString stringWithFormat:@"%@-%p", NSStringFromClass([self class]), self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);

	NSString *serviceDatabaseName = [NSStringFromMPHService(self.service) stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSFileManager defaultManager].documentsDirectory error:nil];
	for (NSString *file in files) {
		if ([file mph_hasCaseInsensitivePrefix:serviceDatabaseName]) {
			NSString *path = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:file];

			_database = [FMDatabase databaseWithPath:path];
		}

		if (_database)
			break;
	}

	if (!_database) {
		NSString *defaultDatabasePath = [[NSBundle mainBundle] pathForResource:serviceDatabaseName ofType:@"db"];
		_database = [FMDatabase databaseWithPath:defaultDatabasePath];

		dispatch_async(dispatch_get_main_queue(), ^{
//			NSString *newServiceDatabaseName = [NSString stringWithFormat:@"%@.db", serviceDatabaseName];
//			NSString *newDatabasePath = [[NSFileManager defaultManager].documentsDirectory stringByAppendingPathComponent:newServiceDatabaseName];

//			[[NSFileManager defaultManager] copyItemAtPath:defaultDatabasePath toPath:newDatabasePath error:nil];
		});
	}

	[_database openWithFlags:SQLITE_OPEN_READONLY];
	_database.crashOnErrors = YES;

	return self;
}

#pragma mark -

- (NSMutableURLRequest *) APIReqestWithURLString:(NSString *) URLString parameters:(NSDictionary *) parameters {
	NSMutableDictionary *workingParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
	workingParameters[@"token"] = MPH511APIKey;

	URLString = [URLString stringByAppendingFormat:@"?%@", workingParameters.mph_queryRepresentation];

	NSURL *URL = [NSURL URLWithString:URLString];
	return [NSMutableURLRequest requestWithURL:URL];
}

#pragma mark -

- (MPHService) service {
	return MPHServiceNone;
}

- (NSString *) APIAgencyName {
	return @"";
}

- (NSString *) routeDataVersion {
	return @"";
}

- (void) slurpRouteDataVersion:(NSString *) version {
	NSString *serviceDatabaseName = [NSStringFromMPHService(self.service) stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *path  = nil;
	if (!version.length)
		path = [fileManager.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", serviceDatabaseName]];
	else path = [fileManager.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.db", serviceDatabaseName, version]];
	[fileManager removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
	NSLog(@"To: %@", path);

	FMDatabase *newDatabase = [FMDatabase databaseWithPath:path];
	dispatch_sync(_queue, ^{
		[newDatabase open];
		// "BABY BULLET" "BABY BULLET" "SB1" "SOUTHBOUND TO SAN JOSE DIRIDON"
		[newDatabase executeUpdate:@"CREATE TABLE routes (route_name STRING NOT NULL, route_code STRING NOT NULL, direction_name STRING NOT NULL, direction_code STRING NOT NULL);"];
		// "San Francisco Caltrain Station" "70012" "LOCAL" "SB1"
		[newDatabase executeUpdate:@"CREATE TABLE stops (stop_name STRING NOT NULL, stop_codes STRING NOT NULL, route_code STRING NOT NULL, direction_code STRING NOT NULL, latitude REAL, longitude REAL);"];
	});

	NSURLRequest *routesRequest = [self APIReqestWithURLString:@"http://services.my511.org/Transit2.0/GetRoutesForAgency.aspx" parameters:@{ @"agencyName": self.APIAgencyName }];

	__weak typeof(self) weakSelf = self;
	[[[NSURLSession sharedSession] dataTaskWithRequest:routesRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {		__strong typeof(weakSelf) strongSelf = weakSelf;

		NSXMLDocument *routeDocument = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentXMLKind error:nil];
		NSXMLElement *routeAgencyListElement = [[routeDocument.rootElement elementsForName:@"AgencyList"] lastObject];
		NSXMLElement *routeAgencyElement = [[routeAgencyListElement elementsForName:@"Agency"] lastObject];
		NSXMLElement *routeRouteListElement = [[routeAgencyElement elementsForName:@"RouteList"] lastObject];
		for (NSXMLElement *routeRouteElement in [routeRouteListElement elementsForName:@"Route"]) {
			NSXMLElement *routeDirectionListElement = [[routeRouteElement elementsForName:@"RouteDirectionList"] lastObject];
			NSMutableString *routeStopsRequestIDF = [NSMutableString string];
			for (NSXMLElement *routeDirectionElement in [routeDirectionListElement elementsForName:@"RouteDirection"]) {
				NSString *routeCode = [routeRouteElement attributeForName:@"Code"].stringValue;
				NSString *routeDirectionCode = [routeDirectionElement attributeForName:@"Code"].stringValue;
				NSString *update = [NSString stringWithFormat:@"INSERT INTO routes (route_name, route_code, direction_name, direction_code) VALUES (\"%@\", \"%@\", \"%@\", \"%@\");", [routeRouteElement attributeForName:@"Name"].stringValue, routeCode, [routeDirectionElement attributeForName:@"Name"].stringValue, routeDirectionCode];

				dispatch_sync(strongSelf->_queue, ^{
					[newDatabase executeUpdate:update];
				});

				[routeStopsRequestIDF appendFormat:@"%@~%@~%@", self.APIAgencyName, routeCode.mph_stringByPercentEncodingString, routeDirectionCode.mph_stringByPercentEncodingString];
				[routeStopsRequestIDF appendString:@"%7C"]; // |, percent-encoded
			}
			if (routeStopsRequestIDF.length)
				[routeStopsRequestIDF deleteCharactersInRange:NSMakeRange(routeStopsRequestIDF.length - 3, 3)];

			NSURLRequest *routeStopsRequest = [self APIReqestWithURLString:@"http://services.my511.org/Transit2.0/GetStopsForRoutes.aspx" parameters:@{ @"routeIDF": routeStopsRequestIDF }];
			[[[NSURLSession sharedSession] dataTaskWithRequest:routeStopsRequest completionHandler:^(NSData *routeStopsData, NSURLResponse *routeStopsResponse, NSError *routeStopsError) {
				NSXMLDocument *stopsDocument = [[NSXMLDocument alloc] initWithData:routeStopsData options:NSXMLDocumentXMLKind error:nil];
				NSXMLElement *stopsAgencyListElement = [[stopsDocument.rootElement elementsForName:@"AgencyList"] lastObject];
				for (NSXMLElement *stopsAgencyElement in [stopsAgencyListElement elementsForName:@"Agency"]) {
					NSXMLElement *stopsRouteListElement = [[stopsAgencyElement elementsForName:@"RouteList"] lastObject];
					for (NSXMLElement *stopsRouteElement in [stopsRouteListElement elementsForName:@"Route"]) {
						NSXMLElement *stopsRouteDirectionListElement = [[stopsRouteElement elementsForName:@"RouteDirectionList"] lastObject];
						for (NSXMLElement *stopsRouteDirectionElement in [stopsRouteDirectionListElement elementsForName:@"RouteDirection"]) {
							NSXMLElement *stopStopsListElement = [[stopsRouteDirectionElement elementsForName:@"StopList"] lastObject];
							for (NSXMLElement *stopElement in [stopStopsListElement elementsForName:@"Stop"]) {

								NSString *query = [NSString stringWithFormat:@"SELECT stop_codes FROM stops WHERE stop_name = '%@';", [stopElement attributeForName:@"name"].stringValue];
								NSString *codes = [newDatabase stringForQuery:query];
								if (codes.length) {
									codes = [codes stringByAppendingFormat:@"`%@", [stopElement attributeForName:@"StopCode"].stringValue];
									NSString *update = [NSString stringWithFormat:@"INSERT INTO stops (stop_name, stop_codes, route_code, direction_code) VALUES(\"%@\", \"%@\", \"%@\", \"%@\");", [stopElement attributeForName:@"name"].stringValue, codes, [stopsRouteElement attributeForName:@"Code"].stringValue, [stopsRouteDirectionElement attributeForName:@"Code"].stringValue];
									dispatch_sync(strongSelf->_queue, ^{
										[newDatabase executeUpdate:update];
									});
								}  else {
									NSString *update = [NSString stringWithFormat:@"INSERT INTO stops (stop_name, stop_codes, route_code, direction_code) VALUES(\"%@\", \"%@\", \"%@\", \"%@\");", [stopElement attributeForName:@"name"].stringValue, [stopElement attributeForName:@"StopCode"].stringValue, [stopsRouteElement attributeForName:@"Code"].stringValue, [stopsRouteDirectionElement attributeForName:@"Code"].stringValue];
									dispatch_sync(strongSelf->_queue, ^{
										[newDatabase executeUpdate:update];
									});

									[MPHGoogleGeocoder geocodeAddressString:[stopElement attributeForName:@"name"].stringValue completionHandler:^(NSArray *placemarks, NSError *innerError) {
										CLPlacemark *placemark = placemarks.firstObject;
										if (placemark) {
											NSString *completedStationInformationUpdate = [NSString stringWithFormat:@"UPDATE stops SET latitude = \"%f\", longitude = \"%f\" WHERE stop_name = \"%@\";", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude, [stopElement attributeForName:@"name"].stringValue];
											dispatch_sync(strongSelf->_queue, ^{
												[newDatabase executeUpdate:completedStationInformationUpdate];
											});
										}
									}];
								}
							}
						}
					}
				}
			}] resume];
		}
	}] resume];
}

#pragma mark -

- (NSArray *) routes {
	return [self routesFromQuery:@"SELECT * FROM routes;"];
}

- (NSArray *) sortedRoutes {
	return [[self routes] sortedArrayUsingComparator:compareStopsByTitle];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction {
	return [self stopsForRoute:route inDirection:direction];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) aRoute inDirection:(MPHDirection) direction {
	if (![aRoute isKindOfClass:[MPH511Route class]])
		return nil;

	MPH511Route *route = (MPH511Route *)aRoute;
	return [self stopFromQuery:[NSString stringWithFormat:@"SELECT * FROM stops WHERE route_code = \"%@\"AND direction_code = \"%@\";", route.routeCode, route.directionCode]];
}

- (NSArray *) pathsForRoute:(id <MPHRoute>) route {
	return nil;
}

- (id <MPHRoute>) routeWithTag:(id) tag {
	return nil;
}

- (NSArray <id <MPHRoute>> *) routesForStop:(id<MPHStop>) stop {
	return nil;
}

#pragma mark -

- (NSArray *) messages {
	return nil;
}

- (NSArray *) messagesForStop:(id <MPHStop>) stop {
	return nil;
}

- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag {
	return nil;
}

- (void) fetchMessages {

}

#pragma mark -

- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction {
	return nil;
}

- (NSArray *) stopsInRegion:(MKCoordinateRegion) region {
	return [self stopFromQuery:@"SELECT DISTINCT * FROM stops WHERE stop_name IN (SELECT DISTINCT stop_name FROM stops) GROUP BY stop_name;"];
}

- (NSArray *) routesInRegion:(MKCoordinateRegion) region {
	return nil;
}

- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag {
	return nil;
}

#pragma mark -

- (NSArray *) routesFromQuery:(NSString *) query {
	NSMutableArray *routes = [NSMutableArray array];
	__block FMResultSet *results = nil;

	dispatch_sync(_queue, ^{
		results = [self->_database executeQuery:query];
	});

	while ([results next]) {
		MPH511Route *route = [[MPH511Route alloc] init];
		route.routeName = [results stringForColumn:@"route_name"];
		route.routeCode = [results stringForColumn:@"route_code"];
		route.directionCode = [results stringForColumn:@"direction_code"];
		route.directionName = [results stringForColumn:@"direction_name"];

		[routes addObject:route];
	}

	return routes;
}

- (NSArray *) stopFromQuery:(NSString *) query {
	NSMutableArray *stops = [NSMutableArray array];
	__block FMResultSet *results = nil;

	dispatch_sync(_queue, ^{
		results = [self->_database executeQuery:query];
	});

	while ([results next]) {
		MPH511Stop *stop = [[MPH511Stop alloc] init];
		stop.stopName = [[results stringForColumn:@"stop_name"] stringByReplacingOccurrencesOfString:@" Caltrain Station" withString:@""];
		stop.stopCodes = [results arrayForColumn:@"stop_codes"];
		stop.routeCode = [results stringForColumn:@"route_code"];
		stop.directionCode = [results stringForColumn:@"direction_code"];
		stop.coordinate = CLLocationCoordinate2DMake([results doubleForColumn:@"latitude"], [results doubleForColumn:@"longitude"]);

		[stops addObject:stop];
	}

	return stops;
}
@end

#pragma mark -

@implementation MPHCaltrainAmalgamation
- (MPHService) service {
	return MPHServiceCaltrain;
}

- (NSString *) APIAgencyName {
	return @"Caltrain";
}
@end


@implementation MPHACTransitAmalgamation
- (MPHService) service {
	return MPHServiceACTransit;
}

- (NSString *) APIAgencyName {
	return @"AC%20Transit";
}
@end

@implementation MPHDumbartonAmalgamation
- (MPHService) service {
	return MPHServiceDumbartonExpress;
}

- (NSString *) APIAgencyName {
	return @"Dumbarton%20Express";
}
@end

@implementation MPHSamTransAmalgamation
- (MPHService) service {
	return MPHServiceSamTrans;
}

- (NSString *) APIAgencyName {
	return @"SamTrans";
}
@end

@implementation MPHVTAAmalgamation
- (MPHService) service {
	return MPHServiceVTA;
}

- (NSString *) APIAgencyName {
	return @"VTA";
}
@end

@implementation MPHWestcatAmalgamation
- (MPHService) service {
	return MPHServiceWestCat;
}

- (NSString *) APIAgencyName {
	return @"WESTCAT";
}
@end
