#import "MPHAnnotation.h"

@implementation MPHStopAnnotation {
	id <MPHStop> _stop;
}

+ (MPHStopAnnotation *) annotationWithStop:(id <MPHStop>) stop {
	MPHStopAnnotation *annotation = [[MPHStopAnnotation alloc] init];
	annotation->_stop = stop;

	return annotation;
}

- (CLLocationCoordinate2D) coordinate {
	return _stop.coordinate;
}

- (NSString *) title {
	if (_stop.name.length)
		return _stop.name;
	return NSStringFromCLLocationCoordinate2D(self.coordinate);
}

//- (NSString *) subtitle {
//	return _stop;
//}
#pragma mark -

- (NSUInteger) hash {
	return _stop.hash;
}

- (BOOL) isEqual:(id) object {
	return [_stop isEqual:object];
}
@end

@interface MPHMapItemAnnotation ()
@property (strong, readwrite) MKMapItem *mapItem;
@end

@implementation MPHMapItemAnnotation

+ (MPHMapItemAnnotation *) annotationWithMapItem:(MKMapItem *) mapItem {
	MPHMapItemAnnotation *annotation = [[MPHMapItemAnnotation alloc] init];
	annotation.mapItem = mapItem;

	return annotation;
}

- (CLLocationCoordinate2D) coordinate {
	return _mapItem.placemark.location.coordinate;
}

- (NSString *) title {
	if (self.isCurrentLocation)
		return NSLocalizedString(@"Current Location", @"Current Location pin title");

	if (self.isDroppedPin)
		return NSLocalizedString(@"Dropped Pin", @"Dropped Pin pin title");

	if (_mapItem.name.length)
		return _mapItem.name;

	NSString *addressString = _mapItem.placemark.mph_readableAddressString;
	if (addressString.length)
		return addressString;
	return [NSString stringWithFormat:@"%f, %f", _mapItem.placemark.coordinate.latitude, _mapItem.placemark.coordinate.longitude];
}

- (NSString *) subtitle {
	if (!self.isCurrentLocation && !self.isDroppedPin)
		return nil;

	if (_mapItem.name.length)
		return _mapItem.name;

	NSString *addressString = _mapItem.placemark.mph_readableAddressString;
	if (addressString.length)
		return addressString;
	return [NSString stringWithFormat:@"%f, %f", _mapItem.placemark.coordinate.latitude, _mapItem.placemark.coordinate.longitude];
}

#pragma mark -

- (void) updateToMapItem:(MKMapItem *) mapItem {
	[self willChangeValueForKey:@"title"];
	[self willChangeValueForKey:@"subtitle"];
	[self willChangeValueForKey:@"coordinate"];

	_mapItem = mapItem;

	[self didChangeValueForKey:@"title"];
	[self didChangeValueForKey:@"subtitle"];
	[self didChangeValueForKey:@"coordinate"];
}
@end
