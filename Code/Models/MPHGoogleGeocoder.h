#import <Foundation/Foundation.h>

// API to use Google for geocoding addresses instead of whatever Apple uses in CLGeocoder.
// Uses include working around data limitations (such as 15570392 - unable to geocode Caltrain stations).

typedef void (^MPHGeocodeCompletionHandler)(NSArray *placemarks, NSError *error);

@interface MPHGoogleGeocoder : NSObject
+ (void) geocodeAddressString:(NSString *) addressString completionHandler:(MPHGeocodeCompletionHandler) completionHandler;
@end
