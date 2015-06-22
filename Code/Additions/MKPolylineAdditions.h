#import <MapKit/MapKit.h>

@interface MKPolyline (Additions)
+ (MKPolyline *) mph_polylineWithEncodedString:(NSString *) encodedString;
@end
