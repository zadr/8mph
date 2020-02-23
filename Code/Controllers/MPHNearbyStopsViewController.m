#import "MPHNearbyStopsViewController.h"

#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPHAnnotation.h"

#import "MPHAmalgamation.h"
#import "MPHStop.h"
#import "MPHPrediction.h"

#import "MPHMUNIStopsController.h"
#import "MPHNextBusStop.h"
#import "MPHNextBusRoute.h"
#import "MPHNextBusPrediction.h"

@interface MPHNearbyStopsViewController () <MPHStopsControllerDelegate>
@end

@implementation MPHNearbyStopsViewController {
	NSMutableDictionary *_annotations;
	BOOL _isVisible;
	MPHMUNIStopsController *_stopsController;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_annotations = [[NSMutableDictionary alloc] init];
	_stopsController = [[MPHMUNIStopsController alloc] init];
	_stopsController.delegate = self;

	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Nearby", @"Nearby title");

	self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.2 alpha:.7];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	_isVisible = YES;
	self.mapView.region =  MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(MPHNearbyDefaultDistance, MPHNearbyDefaultDistance));
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	_isVisible = NO;
}

#pragma mark -

- (void) stopsController:(id <MPHStopsController>) stopsController didLoadPredictionsForStop:(id <MPHStop>) stop
{
	MPHStopAnnotation *annotation = _annotations[@(stop.hash)];
	NSArray <id<MPHPrediction>> *predictions = [stopsController predictionsForStop:stop];
	annotation.subtitleText = [self stringFromPredictions:predictions];
}

- (void) stopsControllerDidLoadPredictionsForStop:(id <MPHStopsController>) stopsController
{
	for (id<MPHStop> stop in stopsController.stops) {
		MPHStopAnnotation *annotation = _annotations[@(stop.hash)];
		NSArray <id<MPHPrediction>> *predictions = [stopsController predictionsForStop:stop];
		annotation.subtitleText = [self stringFromPredictions:predictions];

		if ([stop isKindOfClass:MPHNextBusStop.class]) {
			MPHNextBusPrediction *prediction = predictions.firstObject;
			if ([prediction.direction containsString:@"I"]) {
				annotation.titlePrefix = @"IB";
			} else if ([prediction.direction containsString:@"O"]) {
				annotation.titlePrefix = @"OB";
			}
		}
	}
}

- (NSString *)stringFromPredictions:(NSArray *)predictions {
	NSMutableString *minutes = [[NSMutableString alloc] init];
	predictions = [predictions sortedArrayUsingComparator:^(id one, id two) {
		id <MPHPrediction> predictionOne = one;
		id <MPHPrediction> predictionTwo = two;

		if (predictionOne.minutesETA > predictionTwo.minutesETA)
			return NSOrderedDescending;
		if (predictionTwo.minutesETA > predictionOne.minutesETA)
			return NSOrderedAscending;
		return NSOrderedSame;
	}];

	NSString *groupingSeperator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];

	for (id <MPHPrediction> prediction in predictions) {
		if (prediction.minutesETA < 0.)
			continue;

		if (prediction.minutesETA) {
			NSString *string = [NSString stringWithFormat:@"%zdm%@ ", prediction.minutesETA, groupingSeperator];
			[minutes appendString:string];
		} else {
			NSString *string = [NSString stringWithFormat:@"now%@ ", groupingSeperator];
			[minutes appendString:string];
		}
	}

	if (minutes.length)
		[minutes deleteCharactersInRange:NSMakeRange(minutes.length - (groupingSeperator.length + 1), (groupingSeperator.length + 1))];

	return minutes;
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
		if ([annotation isKindOfClass:MPHStopAnnotation.class]) {
			MPHStopAnnotation *stopAnnotation = (MPHStopAnnotation *)annotation;
			annotationView.pinTintColor = stopAnnotation.route.color;
		}
		annotationView.animatesDrop = NO;
		annotationView.canShowCallout = YES;
	} else annotationView.annotation = annotation;

	return annotationView;
}

- (void) mapView:(MKMapView *) mapView regionDidChangeAnimated:(BOOL) animated {
	if (!_isVisible) {
		return;
	}

	NSMutableArray *oldAnnotations = [NSMutableArray array];
	for (id <MKAnnotation> annotation in mapView.annotations) {
		if (!MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(annotation.coordinate))) {
			[oldAnnotations addObject:annotation];
			[_annotations removeObjectForKey:@(annotation.hash)];
		}
	}
	[mapView removeAnnotations:oldAnnotations];

	NSMutableArray *annotations = [NSMutableArray array];
	NSSet <id <MPHStop>> *stops = [self stopsForRegion:mapView.region];
	_stopsController.stops = stops.allObjects;
	[_stopsController fetchPredictions];

	for (id <MPHStop> stop in [self stopsForRegion:mapView.region]) {
		MPHStopAnnotation *annotation = _annotations[@(stop.hash)];
		if (!annotation) {
			MPHAmalgamator *amalgamator = [MPHAmalgamator amalgamator];
			NSArray *routes = [amalgamator routesForStop:stop onService:stop.service];
			annotation = [MPHStopAnnotation annotationWithStop:stop route:routes.firstObject];

			_annotations[@(stop.hash)] = annotation;
		}

		if (annotation.title)
			[annotations addObject:annotation];
	}

	[self.mapView addAnnotations:annotations];
}
@end
