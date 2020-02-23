// a plan contains itineraries, which contains legs that have leg endpoints (transit) and steps (walking)

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MPHOTPPlan : NSObject
+ (MPHOTPPlan *) planFromData:(NSData *) data;

@property (readonly, copy) NSDate *date;
@property (readonly) CLLocationCoordinate2D fromCoordinate;
@property (readonly) CLLocationCoordinate2D toCoordinate;
@property (readonly, copy) NSArray *itineraries;
@end

@interface MPHOTPItinerary : NSObject
@property (readonly) NSTimeInterval duration; // in milliseconds
@property (readonly, copy) NSDate *startTime;
@property (readonly, copy) NSDate *endTime;
@property (readonly) NSTimeInterval walkTime;
@property (readonly) NSTimeInterval transitTime;
@property (readonly) NSTimeInterval waitTime;
@property (readonly) CLLocationDistance walkDistance;
@property (readonly) CLLocationDistance elevationLost; // meters
@property (readonly) CLLocationDistance elevationGained; // meters
@property (readonly) NSUInteger transfers;
@property (readonly, copy) NSArray *legs;
@property (readonly) BOOL tooSloped;
// TODO: fare
@end

@interface MPHOTPLegEndpoint : NSObject
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *stopAgencyId;
@property (readonly, copy) NSString *stopId;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly, copy) NSDate *arrival;
@property (readonly, copy) NSDate *departure;
@property (readonly) NSUInteger legGeometryLength;
@property (readonly, copy) NSString *legGeometryPoints;
@property (readonly, strong) MKPolyline *legGeometryPolyline;
@property (readonly) NSTimeInterval duration; // seconds
@end

@interface MPHOTPLeg : NSObject
@property (readonly, copy) NSString *mode;
@property (readonly, copy) NSString *route;
@property (readonly, copy) NSString *agencyTimeZoneOffset;
@property (readonly, copy) NSString *routeType;
@property (readonly, copy) NSString *routeId;
@property (readonly, copy) NSString *tripBlockId;
@property (readonly, copy) NSString *headsign;
@property (readonly, copy) NSString *agencyId;
@property (readonly, copy) NSString *tripId;
@property (readonly, copy) NSString *routeShortName;
@property (readonly, copy) NSString *routeLongName;
@property (readonly, copy) NSDate *startTime;
@property (readonly, copy) NSDate *endTime;
@property (readonly) CLLocationDistance distance; // meters
@property (readonly, strong) MPHOTPLegEndpoint *fromEndpoint;
@property (readonly, strong) MPHOTPLegEndpoint *toEndpoint;
@property (readonly, copy) NSArray *steps;
@end

@interface MPHOTPStep : NSObject
@property (readonly) CLLocationDirection distance; // meters
@property (readonly, copy) NSString *streetName;
@property (readonly, copy) NSString *relativeDirection;
@property (readonly, copy) NSString *absoluteDirection;
@property (readonly) BOOL stayOn;
@property (readonly) BOOL area;
@property (readonly) BOOL bogusName;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly) CLLocationDistance elevation;
@end
