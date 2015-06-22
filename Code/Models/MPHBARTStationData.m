#import "MPHBARTStationData.h"

@implementation MPHBARTStationData
- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@" Platform information: %@, Introduction: %@, Cross street: %@, Food: %@, Shopping: %@, Attraction: %@, Entering: %@, Exiting: %@, Parking: %d (Filled by: %@) %@, Car Share: %d, Lockers: %d %@, Bikes: Allowed: %d, Station: %d, Information: %@", _platformInfo, _introduction, _crossStreet, _food, _shopping, _attraction, _entering, _exiting, _parkingAvailable, _lotFilledBy, _parking, _carShareAvailable, _lockersAvailable, _lockerInformation, _bikesAvailable, _bikeStationAvailable, _bikeInformation];

	return description;
}
@end
