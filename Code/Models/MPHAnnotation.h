#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MPHStop.h"
#import "MPHRoute.h"

@interface MPHStopAnnotation : NSObject <MKAnnotation>
+ (MPHStopAnnotation *) annotationWithStop:(id <MPHStop>) stop route:(id <MPHRoute>)route;

@property (strong, readonly) id<MPHStop> stop;
@property (strong, readonly) id<MPHRoute> route;

@property (copy) NSString *titlePrefix;
@property (copy) NSString *subtitleText;

@end

@interface MPHMapItemAnnotation : NSObject <MKAnnotation>
+ (MPHMapItemAnnotation *) annotationWithMapItem:(MKMapItem *) mapItem;

@property (readonly) MKMapItem *mapItem;

@property BOOL isCurrentLocation;
@property BOOL isDroppedPin;

- (void) updateToMapItem:(MKMapItem *) mapItem;
@end
