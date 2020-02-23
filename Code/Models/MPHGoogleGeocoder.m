#import <TargetConditionals.h>

#import "MPHGoogleGeocoder.h"
#import "NSStringAdditions.h"

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static CLLocationDistance mph_distanceBetweenCoordinates(CLLocationCoordinate2D a, CLLocationCoordinate2D b) {
	return MKMetersBetweenMapPoints(MKMapPointForCoordinate(a), MKMapPointForCoordinate(b));
}

@interface CLPlacemark (Private)
- (id) initWithLocation:(CLLocation *) location addressDictionary:(NSDictionary *) addressDictionary region:(CLRegion *) region areasOfInterest:(NSArray *) areasOfInterest;
@end

@implementation MPHGoogleGeocoder
+ (void) geocodeAddressString:(NSString *) addressString completionHandler:(MPHGeocodeCompletionHandler) completionHandler {
	if (!completionHandler)
		return;

	static NSMutableDictionary *cachedGeocodeLookups = nil;
	static NSMutableDictionary *cachedGeocodeCompletionHandlers = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cachedGeocodeLookups = [NSMutableDictionary dictionary];
		cachedGeocodeCompletionHandlers = [NSMutableDictionary dictionary];
	});

	NSArray *cachedPlacemarks = cachedGeocodeLookups[addressString];
	if (cachedPlacemarks) {
		completionHandler(cachedPlacemarks, nil);
		return;
	}

	NSMutableSet *completionHandlers = cachedGeocodeCompletionHandlers[addressString];
	if (completionHandlers) {
		[completionHandlers addObject:[completionHandler copy]];
		 return;
	}

	completionHandlers = [NSMutableSet set];
	[completionHandlers addObject:[completionHandler copy]];

	NSURLRequest *request = [NSString mph_requestWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressString.mph_stringByPercentEncodingString];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:NULL];
		NSMutableArray *placemarks = [NSMutableArray array];
		for (NSDictionary  *locationDictionary in JSONResponse[@"results"]) {
			CLLocation *location = [[CLLocation alloc] initWithLatitude:[locationDictionary[@"geometry"][@"location"][@"lat"] doubleValue] longitude:[locationDictionary[@"geometry"][@"location"][@"lng"] doubleValue]];
			NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];

			for (NSDictionary *component in locationDictionary[@"address_components"]) {
				if ([component[@"types"] containsObject:@"country"]) {
					addressDictionary[@"Country"] = component[@"long_name"]; // United States
					addressDictionary[@"CountryCode"] = component[@"short_name"]; // US
				}
				if ([component[@"types"] containsObject:@"neighborhood"])
					addressDictionary[@"SubLocality"] = component[@"long_name"]; // South of Market
				if ([component[@"types"] containsObject:@"administrative_area_level_1"])
					addressDictionary[@"State"] = component[@"short_name"]; // California
				if ([component[@"types"] containsObject:@"administrative_area_level_2"]) // San Francisco County
					addressDictionary[@"SubAdministrativeArea"] = component[@"long_name"];
				if ([component[@"types"] containsObject:@"locality"])
					addressDictionary[@"City"] = component[@"long_name"]; // San Francisco
				if ([component[@"types"] containsObject:@"postal_code"])
					addressDictionary[@"ZIP"] = component[@"long_name"]; // 94107
				if ([component[@"types"] containsObject:@"establishment"])
					addressDictionary[@"Thoroughfare"] = component[@"long_name"]; // San Francisco Caltrain Station
				if ([component[@"types"] containsObject:@"street_number"])
					addressDictionary[@"SubThoroughfare"] = component[@"long_name"]; // 1
				if ([component[@"types"] containsObject:@"route"])
					addressDictionary[@"Thoroughfare"] = component[@"long_name"]; // Infinite Loop
			}
			if (addressDictionary[@"SubThoroughfare"] && addressDictionary[@"Thoroughfare"])
				addressDictionary[@"Street"] = [NSString stringWithFormat:@"%@ %@", addressDictionary[@"SubThoroughfare"], addressDictionary[@"Thoroughfare"]];

			addressDictionary[@"FormattedAddressLines"] = [locationDictionary[@"formatted_address"] componentsSeparatedByString:@", "];

			CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake([locationDictionary[@"geometry"][@"viewport"][@"northeast"][@"lat"] doubleValue], [locationDictionary[@"geometry"][@"viewport"][@"northeast"][@"lng"] doubleValue]);
			CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake([locationDictionary[@"geometry"][@"viewport"][@"southwest"][@"lat"] doubleValue], [locationDictionary[@"geometry"][@"viewport"][@"southwest"][@"lng"] doubleValue]);
			CLLocationCoordinate2D center = CLLocationCoordinate2DMake([locationDictionary[@"geometry"][@"viewport"][@"location"][@"lat"] doubleValue], [locationDictionary[@"geometry"][@"viewport"][@"location"][@"lng"] doubleValue]);
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
			CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:(mph_distanceBetweenCoordinates(northeast, southwest) / 2.) identifier:addressDictionary.description];
#else
			CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:center radius:(mph_distanceBetweenCoordinates(northeast, southwest) / 2.) identifier:addressDictionary.description];
#endif
			CLPlacemark *placemark = [[CLPlacemark alloc] initWithLocation:location addressDictionary:addressDictionary region:region areasOfInterest:nil];
			[placemarks addObject:placemark];
		}

		cachedGeocodeLookups[addressString] = [placemarks copy];
		for ( MPHGeocodeCompletionHandler queuedCompletionHandler in completionHandlers)
			queuedCompletionHandler(placemarks, nil);
	}] resume];
}
@end
