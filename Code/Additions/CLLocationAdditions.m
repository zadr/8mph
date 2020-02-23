#import <MapKit/MapKit.h>

#import "CLLocationAdditions.h"

NSString *NSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
	return [NSString stringWithFormat:@"{ latitude: %f, longitude: %f }", coordinate.latitude, coordinate.longitude];
}

// MKMetersBetweenMapPoints accounts for the curvature of the earth!
CLLocationDistance distanceBetweenCoordinates(CLLocationCoordinate2D a, CLLocationCoordinate2D b) {
	if (!CLLocationCoordinate2DIsValid(a) || !CLLocationCoordinate2DIsValid(b))
		return 0.;
	if ((a.latitude == 0. && a.latitude == 0.) || (b.latitude == 0. && b.latitude == 0.))
		return 0.;
	return MKMetersBetweenMapPoints(MKMapPointForCoordinate(a), MKMapPointForCoordinate(b)) * MPHDistanceFeetPerMeter;
}

@implementation NSValue (CLLocationCoordinate2DAdditions)
- (CLLocationCoordinate2D) locationCoordinate2D {
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0., 0.);

	[self getValue:&coordinate];

	return coordinate;
}

+ (NSValue *) valueWithLocationCoordinate2D:(CLLocationCoordinate2D) coordinate {
	return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
}
@end
