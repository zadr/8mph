#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

#import "MPHDefines.h"

@protocol MPHStop;

extern NSString *NSStringFromMPHService(MPHService service);
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
extern UIColor *UIColorForMPHService(MPHService service);
#endif

extern NSComparisonResult (^compareMUNIRoutes)(id, id);
extern NSComparisonResult (^compareMUNIRoutesWithTitles)(id, id);

extern NSComparisonResult (^compareStopsByTitle)(id <MPHStop>, id <MPHStop>);
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
extern NSComparisonResult (^compareStopsByDistance)(id <MPHStop>, id <MPHStop>);
#endif
