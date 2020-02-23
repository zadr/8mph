#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MPHMapViewController : UIViewController <MKMapViewDelegate>
@property (readonly) MKMapView *mapView;
@end
