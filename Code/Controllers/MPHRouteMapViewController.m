#import "MPHRouteMapViewController.h"

#import "MPHRouteController.h"

#import "MPHAmalgamator.h"
#import "MPHPolylineController.h"

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
	return [[MPHPolylineController polylineControllerForService:strongRouteController.route.service] polylineViewForOverlay:overlay];
}
@end
