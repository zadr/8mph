@class MPHDateRange;

@protocol MPHPrediction;
@protocol MPHRoute;
@protocol MPHStop;

@interface MPHRule : NSObject <NSCoding>
@property (nonatomic) MPHService service;
@property (nonatomic) NSTimeInterval warningInterval; // in seconds

@property (nonatomic) BOOL enabled;

@property (nonatomic, strong) MPHDateRange *range;

@property (nonatomic, readonly) NSArray *routes;
@property (nonatomic, readonly) NSArray *stops;

- (void) addStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route;
- (void) removeStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route;

- (NSArray *) stopsForRoute:(id <MPHRoute>) route;
- (NSArray *) routesForStop:(id <MPHStop>) stop;

@property (nonatomic, copy) NSArray *alerts;

- (NSDictionary *) alertOfType:(NSString *) type;

@property (nonatomic, strong) id <MPHPrediction> prediction;
@end
