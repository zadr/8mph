#define MPHDistanceKilometersPerFoot 0.0003048
#define MPHDistanceFeetPerMeter 3.28084
#define MPHDistanceMilesPerFoot 5280

NSString *NSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate);

CLLocationDistance distanceBetweenCoordinates(CLLocationCoordinate2D a, CLLocationCoordinate2D b); // in feet

@interface NSValue (CLLocationCoordinate2DAdditions)
- (CLLocationCoordinate2D) locationCoordinate2D;
+ (NSValue *) valueWithLocationCoordinate2D:(CLLocationCoordinate2D) coordinate;
@end
