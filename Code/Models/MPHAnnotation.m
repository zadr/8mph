#import "MPHAnnotation.h"

#import "CLLocationAdditions.h"
#import "CLPlacemarkAdditions.h"

@implementation MPHStopAnnotation
@synthesize stop = _stop;
@synthesize route = _route;

+ (MPHStopAnnotation *) annotationWithStop:(id <MPHStop>) stop route:(id <MPHRoute>)route {
	MPHStopAnnotation *annotation = [[MPHStopAnnotation alloc] init];
	annotation->_stop = stop;
	annotation->_route = route;

	return annotation;
}

- (CLLocationCoordinate2D) coordinate {
	return _stop.coordinate;
}

- (NSString *) title {
	NSString *title = nil;
	if (_stop.name.length && _route.tag.length)
		title = [NSString stringWithFormat:@"%@ @ %@", _route.tag, _stop.name];
	else if (_stop.name.length)
		title = _stop.name;
	else if (_route.tag.length)
		title = _route.tag;
	else title = NSStringFromCLLocationCoordinate2D(self.coordinate);

	if (self.titlePrefix.length) {
		return [NSString stringWithFormat:@"%@ %@", self.titlePrefix, title];
	}

	return title;
}

- (NSString *) subtitle {
	return self.subtitleText;
}

#pragma mark -

- (NSUInteger) hash {
	return _stop.hash;
}

- (BOOL) isEqual:(id) object {
	if ([object class] != [self class]) {
		return NO;
	}

	MPHStopAnnotation *stopAnnotation = (MPHStopAnnotation *)object;
	return _stop.rowID == stopAnnotation->_stop.rowID;
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
