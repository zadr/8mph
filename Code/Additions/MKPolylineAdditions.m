#import "MKPolylineAdditions.h"

@implementation MKPolyline (Additions)
+ (CLLocationDegrees) _mph_decodeBytes:(const char *) bytes atPosition:(NSUInteger *) position intoValue:(CLLocationDegrees *) value {
	char byte = 0;
	int res = 0;
	char shift = 0;

	do {
		byte = bytes[(*position)++] - 0x3F;
		res |= (byte & 0x1F) << shift;
		shift += 5;
	} while (byte >= 0x20);

	*value += ((res & 1) ? ~(res >> 1) : (res >> 1));

	return (*value) * 1E-5;
}

+ (MKPolyline *) mph_polylineWithEncodedString:(NSString *) encodedString {
	const char *bytes = [encodedString UTF8String];
	NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSUInteger position = 0;

	CLLocationCoordinate2D *coordinates = calloc((length / 4), sizeof(CLLocationCoordinate2D));
	NSUInteger coordinateIndex = 0;

	CLLocationDegrees latitude = 0;
	CLLocationDegrees longitude = 0;
	while (position < length) {
		CLLocationCoordinate2D coordinate;
		coordinate.latitude = [self _mph_decodeBytes:bytes atPosition:&position intoValue:&latitude];
		coordinate.longitude = [self _mph_decodeBytes:bytes atPosition:&position intoValue:&longitude];
		coordinates[coordinateIndex++] = coordinate;
	}

    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:(length / 4)];
    free(coordinates);

    return polyline;
}
@end
