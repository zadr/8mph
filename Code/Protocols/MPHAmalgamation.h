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

@property (nonatomic, readonly) NSArray *routes;
- (NSArray *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction;
- (NSArray *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction;
- (NSArray *) pathsForRoute:(id <MPHRoute>) route;

- (id <MPHRoute>) routeWithTag:(id) tag;
- (id <MPHRoute>) routeForStop:(id <MPHStop>) stop;
- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag;
- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route inDirection:(MPHDirection) direction;

@property (nonatomic, readonly) NSArray *messages;
- (void) fetchMessages;
- (NSArray *) messagesForStop:(id <MPHStop>) stop;
- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag;

- (NSArray *) stopsInRegion:(MKCoordinateRegion) region;
- (NSArray *) routesInRegion:(MKCoordinateRegion) region;
@end
