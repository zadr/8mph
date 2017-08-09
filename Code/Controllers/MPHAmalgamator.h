#import "MPHRoute.h"
#import "MPHStop.h"

@class MPHNextBusRoute;
@class MPHMessage;

@protocol MPHAmalgamation;

@interface MPHAmalgamator : NSObject <NSFastEnumeration>
+ (MPHAmalgamator <MPHAmalgamation> *) amalgamator;

// While we ship with a default MUNI.db and BART.db for routes/stops along a route, this data will periodically
// change, and we should be able to silently update (ie: without forcing the user to download a new app). So,
// lets grab data from NextBus/.. directly, client-side, and make bandwidth costs on our end much cheaper.
- (NSString *) routeDataVersionForService:(MPHService) service;
- (void) slurpRouteDataVersion:(NSString *) version forService:(MPHService) service;

- (NSArray *) messagesForService:(MPHService) service;
- (NSArray *) messagesForStop:(id <MPHStop>) stop ofService:(MPHService) service;
- (NSArray *) routesForService:(MPHService) service; // sorted:NO
- (NSArray *) routesForService:(MPHService) service sorted:(BOOL) sorted;

- (id <MPHRoute>) routeWithTag:(id) tag onService:(MPHService) service;
- (NSArray <id <MPHRoute>> *) routesForStop:(id <MPHStop>) stop onService:(MPHService) service;
- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag onService:(MPHService) service;

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction;
- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag;
- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route onService:(MPHService) service inDirection:(MPHDirection) direction;

- (NSArray *) pathsForRoute:(id <MPHRoute>) route;

- (NSArray *) stopsForService:(MPHService) service inRegion:(MKCoordinateRegion) region;
- (NSArray *) routesForService:(MPHService) service inRegion:(MKCoordinateRegion) region;
- (NSArray *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction ofService:(MPHService) service;
@end
