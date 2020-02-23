#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MPHRoute.h"
#import "MPHStop.h"

@class MPHMessage;

@protocol MPHRoute;
@protocol MPHStop;

@protocol MPHAmalgamation <NSObject>
@required
+ (instancetype) amalgamation;

@property (nonatomic, readonly) NSString *routeDataVersion;
- (void) slurpRouteDataVersion:(NSString *) version;

@property (nonatomic, readonly) NSArray <id <MPHRoute>> *routes;
@property (nonatomic, readonly) NSArray <id <MPHRoute>> *sortedRoutes;

- (NSArray <id <MPHStop>> *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction;
- (NSArray <id <MPHStop>> *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction;
- (NSArray <id <MPHStop>> *) pathsForRoute:(id <MPHRoute>) route;

- (id <MPHRoute>) routeWithTag:(id) tag;
- (NSArray <id <MPHRoute>> *) routesForStop:(id <MPHStop>) stop;
- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag;
- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction;

@property (nonatomic, readonly) NSArray *messages;
- (void) fetchMessages;
- (NSArray <MPHMessage *> *) messagesForStop:(id <MPHStop>) stop;
- (NSArray <id <MPHStop>> *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag;

- (NSArray <id <MPHStop>> *) stopsInRegion:(MKCoordinateRegion) region;
- (NSArray <id <MPHRoute>> *) routesInRegion:(MKCoordinateRegion) region;
@end
