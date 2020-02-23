#import "MPHMapViewController.h"

#import "MPHLocationCenter.h"

@implementation MPHMapViewController {
	MKMapView *_mapView;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
	_mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	_mapView.showsUserLocation = YES;
	_mapView.userTrackingMode = MKUserTrackingModeFollow;
	_mapView.pitchEnabled = NO;
	_mapView.delegate = self;

	return self;
}

- (void) loadView {
	self.view = _mapView;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	_mapView.centerCoordinate = [MPHLocationCenter locationCenter].currentLocation.coordinate;
}

- (BOOL) shouldAutorotate {
	return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}
@end
