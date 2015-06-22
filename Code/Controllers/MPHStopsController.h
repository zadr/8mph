typedef NS_ENUM(NSInteger, MPHStopsSortType) {
	MPHStopsSortTypeAlphabetical,
	MPHStopsSortTypeDistanceFromDistance
};

@protocol MPHStop;
@protocol MPHStopsControllerDelegate;

@protocol MPHStopsController <NSObject>
@required
- (NSArray *) stopsSortedByType:(MPHStopsSortType) sortType;
- (NSArray *) stopsForRoutes:(NSArray *) routes; // array of id <MPHRoute>'s

- (id) predictionsForStop:(id <MPHStop>) stop;
- (void) fetchPredictionsForStop:(id <MPHStop>) stop;
- (void) fetchPredictions;

@property (weak) id <MPHStopsControllerDelegate> delegate;

@property (readonly) MPHService service;
@property (atomic, copy) NSArray *stops;
@end

@protocol MPHStopsControllerDelegate <NSObject>
@optional
- (void) stopsController:(id <MPHStopsController>) stopsController didLoadPredictionsForStop:(id <MPHStop>) stop;
- (void) stopsControllerDidLoadPredictionsForStop:(id <MPHStopsController>) stopsController;
@end

@interface MPHStopsController : NSObject
+ (id <MPHStopsController>) stopsControllerForService:(MPHService) service;
+ (id <MPHStopsController>) stopsControllerForService:(MPHService) service withStops:(NSArray *) stops;
@end
