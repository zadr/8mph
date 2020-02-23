#import "MPHOTPPlan.h"

#import "MKPolylineAdditions.h"

@interface MPHOTPItinerary ()
@property (readwrite) NSTimeInterval duration; // in milliseconds
@property (readwrite, copy) NSDate *startTime;
@property (readwrite, copy) NSDate *endTime;
@property (readwrite) NSTimeInterval walkTime;
@property (readwrite) NSTimeInterval transitTime;
@property (readwrite) NSTimeInterval waitTime;
@property (readwrite) CLLocationDistance walkDistance;
@property (readwrite) CLLocationDistance elevationLost; // meters
@property (readwrite) CLLocationDistance elevationGained; // meters
@property (readwrite) NSUInteger transfers;
@property (readwrite, copy) NSArray *legs;
@property (readwrite) BOOL tooSloped;
// TODO: fare
@end

@implementation MPHOTPItinerary
@end

@interface MPHOTPLeg ()
@property (readwrite, copy) NSString *mode;
@property (readwrite, copy) NSString *route;
@property (readwrite, copy) NSString *agencyTimeZoneOffset;
@property (readwrite, copy) NSString *routeType;
@property (readwrite, copy) NSString *routeId;
@property (readwrite, copy) NSString *tripBlockId;
@property (readwrite, copy) NSString *headsign;
@property (readwrite, copy) NSString *agencyId;
@property (readwrite, copy) NSString *tripId;
@property (readwrite, copy) NSString *routeShortName;
@property (readwrite, copy) NSString *routeLongName;
@property (readwrite, copy) NSDate *startTime;
@property (readwrite, copy) NSDate *endTime;
@property (readwrite) CLLocationDistance distance; // meters
@property (readwrite, strong) MPHOTPLegEndpoint *fromEndpoint;
@property (readwrite, strong) MPHOTPLegEndpoint *toEndpoint;
@property (readwrite, copy) NSArray *steps;
@end

@implementation MPHOTPLeg
@end

@interface MPHOTPLegEndpoint ()
@property (readwrite, copy) NSString *name;
@property (readwrite, copy) NSString *stopAgencyId;
@property (readwrite, copy) NSString *stopId;
@property (readwrite) CLLocationCoordinate2D coordinate;
@property (readwrite, copy) NSDate *arrival;
@property (readwrite, copy) NSDate *departure;
@property (readwrite) NSUInteger legGeometryLength;
@property (readwrite, copy) NSString *legGeometryPoints;
@property (readwrite, strong) MKPolyline *legGeometryPolyline;
@property (readwrite) NSTimeInterval duration; // seconds
@end

@implementation MPHOTPLegEndpoint
+ (MPHOTPLegEndpoint *) endpointWithDictionary:(NSDictionary *) dictionary {
	MPHOTPLegEndpoint *endpoint = [[MPHOTPLegEndpoint alloc] init];
	endpoint.name = dictionary[@"name"];
	endpoint.stopAgencyId = dictionary[@"stopId"][@"agencyId"];
	endpoint.stopId = dictionary[@"stopId"][@"id"];
	endpoint.coordinate = CLLocationCoordinate2DMake([dictionary[@"lat"] doubleValue], [dictionary[@"lon"] doubleValue]);
	endpoint.arrival = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"arrival"] doubleValue]];
	endpoint.departure = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"departure"] doubleValue]];
	endpoint.legGeometryLength = [dictionary[@"legGeometry"][@"length"] integerValue];
	endpoint.legGeometryPoints = dictionary[@"legGeometry"][@"points"];
	endpoint.legGeometryPolyline = [MKPolyline mph_polylineWithEncodedString:endpoint.legGeometryPoints];
	endpoint.duration = [dictionary[@"duration"] doubleValue];

	return endpoint;
}
@end

@interface MPHOTPStep ()
@property (readwrite) CLLocationDirection distance; // meters
@property (readwrite, copy) NSString *streetName;
@property (readwrite, copy) NSString *relativeDirection;
@property (readwrite, copy) NSString *absoluteDirection;
@property (readwrite) BOOL stayOn;
@property (readwrite) BOOL area;
@property (readwrite) BOOL bogusName;
@property (readwrite) CLLocationCoordinate2D coordinate;
@property (readwrite) CLLocationDistance elevation;
@end

@implementation MPHOTPStep
@end

@interface MPHOTPPlan ()
@property (readwrite, copy) NSDate *date;
@property (readwrite) CLLocationCoordinate2D fromCoordinate;
@property (readwrite) CLLocationCoordinate2D toCoordinate;
@property (readwrite, copy) NSArray *itineraries;
@end

@implementation MPHOTPPlan
+ (MPHOTPPlan *) planFromData:(NSData *) data {
	MPHOTPPlan *plan = [[MPHOTPPlan alloc] init];
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:NULL];

	plan.date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"plan"][@"date"] doubleValue]];
	plan.fromCoordinate = CLLocationCoordinate2DMake([dictionary[@"plan"][@"from"][@"lat"] doubleValue], [dictionary[@"plan"][@"from"][@"lon"] doubleValue]);
	plan.toCoordinate = CLLocationCoordinate2DMake([dictionary[@"plan"][@"to"][@"lat"] doubleValue], [dictionary[@"plan"][@"to"][@"lon"] doubleValue]);

	NSMutableArray *itineraries = [NSMutableArray array];
	for (NSDictionary *itineraryDictionary in dictionary[@"plan"][@"itineraries"]) {
		MPHOTPItinerary *itinerary = [[MPHOTPItinerary alloc] init];
		itinerary.duration = [itineraryDictionary[@"duration"] doubleValue];
		itinerary.startTime = [NSDate dateWithTimeIntervalSince1970:[itineraryDictionary[@"startTime"] doubleValue]];
		itinerary.endTime = [NSDate dateWithTimeIntervalSince1970:[itineraryDictionary[@"endTime"] doubleValue]];
		itinerary.walkTime = [itineraryDictionary[@"walkTime"] doubleValue];
		itinerary.transitTime = [itineraryDictionary[@"transitTime"] doubleValue];
		itinerary.waitTime = [itineraryDictionary[@"waitTime"] doubleValue];
		itinerary.walkDistance = [itineraryDictionary[@"walkDistance"] doubleValue];
		itinerary.elevationLost = [itineraryDictionary[@"elevationLost"] doubleValue];
		itinerary.elevationGained = [itineraryDictionary[@"elevationGained"] doubleValue];
		itinerary.transfers = [itineraryDictionary[@"transfers"] integerValue];
		itinerary.tooSloped = [itineraryDictionary[@"tooSloped"] boolValue];

		NSMutableArray *legs = [NSMutableArray array];
		for (NSDictionary *legDictionary in itineraryDictionary[@"legs"]) {
			MPHOTPLeg *leg = [[MPHOTPLeg alloc] init];
			leg.mode = legDictionary[@"mode"];
			leg.route = legDictionary[@"route"];
			leg.agencyTimeZoneOffset = legDictionary[@"agencyTimeZoneOffset"];
			leg.routeType = legDictionary[@"routeType"];
			leg.routeId = legDictionary[@"routeId"];
			leg.tripBlockId = legDictionary[@"tripBlockId"];
			leg.headsign = legDictionary[@"headsign"];
			leg.agencyId = legDictionary[@"agencyId"];
			leg.tripId = legDictionary[@"tripId"];
			leg.routeShortName = legDictionary[@"routeShortName"];
			leg.routeLongName = legDictionary[@"routeLongName"];
			leg.startTime = [NSDate dateWithTimeIntervalSince1970:[itineraryDictionary[@"startTime"] doubleValue]];
			leg.endTime = [NSDate dateWithTimeIntervalSince1970:[itineraryDictionary[@"endTime"] doubleValue]];
			leg.distance = [legDictionary[@"distance"] doubleValue];
			leg.fromEndpoint = legDictionary[@"from"];
			leg.toEndpoint = legDictionary[@"to"];

			NSMutableArray *steps = [NSMutableArray array];
			NSArray *stepsDictionaryArray = legDictionary[@"steps"];
			if ([stepsDictionaryArray isKindOfClass:[NSNull class]])
				stepsDictionaryArray = nil;

			for (NSDictionary *stepDictionary in stepsDictionaryArray) {
				MPHOTPStep *step = [[MPHOTPStep alloc] init];
				step.distance = [stepDictionary[@"distance"] doubleValue];
				step.streetName = stepDictionary[@"streetName"];
				step.relativeDirection = stepDictionary[@"relativeDirection"];
				step.absoluteDirection = stepDictionary[@"absoluteDirection"];
				step.stayOn = [stepDictionary[@"stayOn"] boolValue];
				step.area = [stepDictionary[@"area"] boolValue];
				step.bogusName = [stepDictionary[@"bogusName"] boolValue];
				step.coordinate = CLLocationCoordinate2DMake([stepDictionary[@"lat"] doubleValue], [stepDictionary[@"lon"] doubleValue]);

				[steps addObject:step];
			}
			leg.steps = steps;
			[legs addObject:leg];
		}
		itinerary.legs = legs;
		[itineraries addObject:itinerary];
	}
	plan.itineraries = itineraries;
	return plan;
}
@end
