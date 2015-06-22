@class MPHNextBusStop;

extern NSString *const MPHLocationDidUpdateNotification;

@interface MPHLocationCenter : NSObject <CLLocationManagerDelegate>
+ (MPHLocationCenter *) locationCenter;

@property (nonatomic, readonly) CLLocation *currentLocation;

- (void) alertWhenNearStop:(MPHNextBusStop *) stop;
@end
