@protocol MPHRoute;
@protocol MPHStop;

@protocol MPHRouteControllerDelegate;

@protocol MPHRouteController <NSObject>
@required
@property (nonatomic, weak) id <MPHRouteControllerDelegate> delegate;
@property (readonly) NSDate *predictionLoadedDate;
@property (readonly) id <MPHRoute> route;

- (id) initWithRoute:(id <MPHRoute>) route;

- (void) reloadStopTimes;

- (id <MPHStop>) nearestStopForDirection:(MPHDirection) direction;

- (NSArray *) messagesForStop:(id <MPHStop>) stop;
- (NSArray *) predictionsForStop:(id <MPHStop>) stop;
- (NSArray *) stopsForDirection:(MPHDirection) direction;
- (NSArray *) pathsForMap;

#if TARGET_OS_IPHONE
@property (nonatomic, readonly) UIColor *color;
#else
@property (nonatomic, readonly) NSColor *color;
#endif

@optional
@property (atomic, readonly) NSArray *vehicleLocations;

- (void) reloadVehicleLocations;
@end

@protocol MPHRouteControllerDelegate <NSObject>
@optional
- (void) routeController:(id <MPHRouteController>) routeController didLoadRoutesForDirection:(MPHDirection) direction;
- (void) routeController:(id <MPHRouteController>) routeController didLoadPredictionsForDirection:(MPHDirection) direction;
- (void) routeControllerDidLoadVehicleLocations:(id <MPHRouteController>) routeController;
@end

@interface MPHRouteController : NSObject
+ (id <MPHRouteController>) routeControllerForRoute:(id <MPHRoute>) route onService:(MPHService) service;
@end
