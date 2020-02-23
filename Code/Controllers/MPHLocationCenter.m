#import <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#endif

#import "MPHLocationCenter.h"

NSString *const MPHLocationDidUpdateNotification = @"MPHLocationDidUpdateNotification";

@implementation MPHLocationCenter {
	CLLocationManager *_locationManager;
	CLLocation *_currentLocation;
}

+ (MPHLocationCenter *) locationCenter {
	static MPHLocationCenter *locationCenter = nil;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		locationCenter = [[MPHLocationCenter alloc] init];
	});

	return locationCenter;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	_locationManager.distanceFilter = 10.;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	_locationManager.activityType = CLActivityTypeAutomotiveNavigation;
	_locationManager.pausesLocationUpdatesAutomatically = YES;
	_locationManager.activityType = CLActivityTypeOtherNavigation;

	__weak typeof(self) weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf->_locationManager stopUpdatingLocation];
		[strongSelf->_locationManager stopMonitoringSignificantLocationChanges];
	}];

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf->_locationManager startUpdatingLocation];
		[strongSelf->_locationManager startMonitoringSignificantLocationChanges];
	}];
#endif

	[_locationManager startUpdatingLocation];
	[_locationManager startMonitoringSignificantLocationChanges];

	return self;
}

#pragma mark -

- (CLLocation *) currentLocation {
#if TARGET_OS_IPHONE
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
		[_locationManager requestWhenInUseAuthorization];
#endif

	if (_currentLocation)
		return _currentLocation;
	return _locationManager.location;
}

#pragma mark -

- (BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *) manager {
	return NO;
}

- (void) locationManager:(CLLocationManager *) manager didUpdateLocations:(NSArray *) locations {
	if (!locations.count)
		return;

	CLLocation *newLocation = locations.firstObject;
	if (_currentLocation && (fabs(newLocation.coordinate.latitude - _currentLocation.coordinate.latitude) < .001) && (fabs(newLocation.coordinate.longitude - _currentLocation.coordinate.longitude) < .001))
		return;

	_currentLocation = [newLocation copy];

	[[NSNotificationCenter defaultCenter] postNotificationName:MPHLocationDidUpdateNotification object:nil];
}

- (void) locationManager:(CLLocationManager *) manager didChangeAuthorizationStatus:(CLAuthorizationStatus) status {
	if (!manager.location)
		return;
	[self locationManager:manager didUpdateLocations:@[manager.location]];
}

- (void) alertWhenNearStop:(MPHNextBusStop *) stop {
	// set up geofences
}
@end
