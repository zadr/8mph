#import "MPHNearbyStopsViewController.h"

#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPHAnnotation.h"

#import "MPHAmalgamation.h"
#import "MPHStop.h"

@implementation MPHNearbyStopsViewController {
	NSMutableDictionary *_annotations;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_annotations = [[NSMutableDictionary alloc] init];

	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Nearby", @"Nearby title");

	self.mapView.region =  MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(MPHNearbyDefaultDistance, MPHNearbyDefaultDistance));
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.2 alpha:.7];
}

#pragma mark -

- (NSSet *) stopsForRegion:(MKCoordinateRegion) region {
	NSMutableSet *stops = [NSMutableSet set];

	for (id <MPHAmalgamation> amalgmation in [MPHAmalgamator amalgamator])
		[stops addObjectsFromArray:[amalgmation stopsInRegion:region]];

	return stops;
}

#pragma mark -

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
	if (!annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
		annotationView.animatesDrop = mapView.annotations.count < 10;
		annotationView.canShowCallout = YES;
	} else annotationView.annotation = annotation;

	return annotationView;
}

- (void) mapView:(MKMapView *) mapView regionDidChangeAnimated:(BOOL) animated {
	NSMutableArray *oldAnnotations = [NSMutableArray array];
	for (id <MKAnnotation> annotation in mapView.annotations) {
		if (!MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(annotation.coordinate))) {
			[oldAnnotations addObject:annotation];
			[_annotations removeObjectForKey:@(annotation.hash)];
		}
	}
	[mapView removeAnnotations:oldAnnotations];

	NSMutableArray *annotations = [NSMutableArray array];
	for (id <MPHStop> stop in [self stopsForRegion:mapView.region]) {
		MPHStopAnnotation *annotation = _annotations[@(stop.hash)];
		if (!annotation) {
			annotation = [MPHStopAnnotation annotationWithStop:stop];

			_annotations[@(stop.hash)] = annotation;
		}

		if (annotation.title)
			[annotations addObject:annotation];
	}

	[self.mapView addAnnotations:annotations];
}
@end
