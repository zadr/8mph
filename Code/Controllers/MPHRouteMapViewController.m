#import "MPHRouteMapViewController.h"

#import "MPHRouteController.h"

#import "MPHAmalgamator.h"
#import "MPHPolylineController.h"

#import "UIColorAdditions.h"

#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20

@implementation MKMapView (ZoomLevel)

- (double)getZoomLevel
{
    CLLocationDegrees longitudeDelta = self.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
//  zoomer = round(zoomer);
    return zoomer;
}

@end

@implementation MPHRouteMapViewController {
	__weak id <MPHRouteController> _routeController;
	MPHDirection _selectedDirection;

	NSMapTable *_polylineViews;
}

- (id) initWithRouteController:(id <MPHRouteController>) routeController {
	if (!(self = [super init]))
		return nil;

	_routeController = routeController;

	for (MKPolyline *polyline in [[MPHPolylineController polylineControllerForService:routeController.route.service] polylinesForRoute:routeController.route])
		[self.mapView addOverlay:polyline];

	[routeController reloadVehicleLocations];

	return self;
}

#pragma mark -

- (MKOverlayRenderer *) mapView:(MKMapView *) mapView rendererForOverlay:(id <MKOverlay>) overlay {
	// TODO: MKRoadWidthAtZoomScale
	__strong id <MPHRouteController> strongRouteController = _routeController;
	MKOverlayPathRenderer *renderer = [[MPHPolylineController polylineControllerForService:strongRouteController.route.service] polylineViewForOverlay:overlay];
	renderer.strokeColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? _routeController.route.color.mph_lightenedColor : _routeController.route.color.mph_darkenedColor;
	renderer.fillColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? _routeController.route.color.mph_lightenedColor : _routeController.route.color.mph_darkenedColor;
	renderer.lineWidth = MKRoadWidthAtZoomScale(mapView.getZoomLevel);
	return renderer;
}
@end
