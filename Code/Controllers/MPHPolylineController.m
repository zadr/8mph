#import <MapKit/MapKit.h>

#import "MPHPolylineController.h"

#import "MPHAmalgamator.h"

#import "CLLocationAdditions.h"

@implementation MPHPolylineController {
	NSMutableDictionary *_polylines;
	NSMapTable *_polylineViews;
}

+ (MPHPolylineController *) polylineControllerForService:(MPHService) service {
	static NSMutableDictionary *polylineControllers = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		polylineControllers = [[NSMutableDictionary alloc] init];
	});

	MPHPolylineController *polylineController = polylineControllers[[NSString stringWithFormat:@"%zd", service]];
	if (!polylineController) {
		polylineController = [[MPHPolylineController alloc] init];

		[polylineControllers setObject:polylineController forKey:[NSString stringWithFormat:@"%zd", service]];
	}

	return polylineController;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_polylines = [NSMutableDictionary dictionary];
	_polylineViews = [NSMapTable strongToWeakObjectsMapTable];

	return self;
}

#pragma mark -

- (NSArray *) polylinesForRoute:(id <MPHRoute>) route {
	NSArray *polylines = _polylines[route.name];
	if (polylines)
		return polylines;

	NSMutableArray *newPolylines = [NSMutableArray array];
	for (NSArray *points in [[MPHAmalgamator amalgamator] pathsForRoute:route]) {
		CLLocationCoordinate2D coordinates[points.count];

		for (NSUInteger i = 0; i < points.count; i++) {
			NSValue *value = points[i];
			
			coordinates[i] = [value locationCoordinate2D];
		}
		
		MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:points.count];

		[newPolylines addObject:polyline];
	}

	[_polylines setObject:newPolylines forKey:route.name];

	return [newPolylines copy];
}

- (MKPolylineRenderer *) polylineViewForOverlay:(id <MKOverlay>) overlay {
	MKPolylineRenderer *view = [_polylineViews objectForKey:overlay];
	if (!view) {
		view = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
		view.strokeColor = [MPHColor blueColor];

		[_polylineViews setObject:view forKey:overlay];
	}

	return view;
}
@end
