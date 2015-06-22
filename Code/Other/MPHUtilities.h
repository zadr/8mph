@protocol MPHStop;

NSString *NSStringFromMPHService(MPHService service);

extern NSComparisonResult (^compareMUNIRoutes)(id, id);
extern NSComparisonResult (^compareMUNIRoutesWithTitles)(id, id);

extern NSComparisonResult (^compareStopsByTitle)(id <MPHStop>, id <MPHStop>);
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
extern NSComparisonResult (^compareStopsByDistance)(id <MPHStop>, id <MPHStop>);
#endif
