#import "MPHStop.h"

@interface MPHStopAnnotation : NSObject <MKAnnotation>
+ (MPHStopAnnotation *) annotationWithStop:(id <MPHStop>) stop;
@end

@interface MPHMapItemAnnotation : NSObject <MKAnnotation>
+ (MPHMapItemAnnotation *) annotationWithMapItem:(MKMapItem *) mapItem;

@property (readonly) MKMapItem *mapItem;

@property BOOL isCurrentLocation;
@property BOOL isDroppedPin;

- (void) updateToMapItem:(MKMapItem *) mapItem;
@end
