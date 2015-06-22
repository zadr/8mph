#import "MPHStop.h"

@class MPHBARTStationData;

@interface MPHBARTStation : NSObject <MPHStop>
@property (copy) NSString *name;
@property (copy) NSString *abbreviation;
@property CLLocationCoordinate2D location;
@property (copy) NSString *address;
@property (copy) NSString *city;
@property (copy) NSString *county;
@property (copy) NSString *state;
@property NSInteger zipCode;

@property (copy) NSArray *northRoutes;
@property (copy) NSArray *southRoutes;
@property (copy) NSArray *northPlatforms;
@property (copy) NSArray *southPlatforms;

@property (retain) MPHBARTStationData *stationData;

@property NSInteger rowID;
@end
