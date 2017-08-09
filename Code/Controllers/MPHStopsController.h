typedef NS_ENUM(NSInteger, MPHStopsSortType) {
	MPHStopsSortTypeAlphabetical,
	MPHStopsSortTypeDistanceFromDistance
};

@protocol MPHRoute;
@protocol MPHStop;
@protocol MPHStopsControllerDelegate;

@protocol MPHStopsController <NSObject>
@required
- (NSArray *) stopsSortedByType:(MPHStopsSortType) sortType;
- (NSArray *) stopsForRoutes:(NSArray <id <MPHRoute>> *) routes; // array of 's

- (void) fetchPredictions;
- (void) fetchPredictionsForStop:(id <MPHStop>) stop;
- (id) predictionsForStop:(id <MPHStop>) stop;
- (NSAttributedString *) predictionStringForStop:(id <MPHStop>) stop;

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
