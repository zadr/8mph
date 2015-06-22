typedef enum {
	MPHServiceNone,
	MPHServiceMUNI,
	MPHServiceBART,
	MPHServiceCaltrain,
	MPHServiceACTransit,
	MPHServiceDumbartonExpress,
	MPHServiceSamTrans,
	MPHServiceVTA,
	MPHServiceWestCat
} MPHService;

typedef enum {
	MPHDirectionInbound,
	MPHDirectionOutbound,
	MPHDirectionIgnored,
	MPHDirectionNone
} MPHDirection;

typedef enum {
	MPHBARTDirectionNone,
	MPHBARTDirectionNorth,
	MPHBARTDirectionSouth
} MPHBARTDirection;

#define MPHNearbyDefaultDistance 0.001953125

static NSString *const MPHBARTAPIKey = @"MW9S-E7SL-26DU-VV8V";
static NSString *const MPH511APIKey = @"";
#warning 511 API Key not specified

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@compatibility_alias MPHColor UIColor;
#else
@compatibility_alias MPHColor NSColor;
#endif

#define MPHUnreachable \
	do { \
		__builtin_unreachable(); \
	} while (0);
