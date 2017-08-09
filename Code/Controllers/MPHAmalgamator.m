#import "MPHAmalgamator.h"

#import "MPHBARTAmalgamation.h"
#import "MPHMUNIAmalgamation.h"
#import "MPH511Amalgamation.h"

#import "MPHMessage.h"

#import "NSFileManagerAdditions.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "FMResultSetMPHAdditions.h"

@implementation MPHAmalgamator {
	NSMutableArray *_amalgamations;
}

+ (MPHAmalgamator <MPHAmalgamation> *) amalgamator {
	static MPHAmalgamator <MPHAmalgamation> *dataImporter = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		dataImporter = [[self alloc] init];
	});

	return dataImporter;
}

- (instancetype) init {
	if (!(self = [super init]))
		return nil;

	_amalgamations = [[NSMutableArray alloc] init];

	[_amalgamations addObject:[MPHMUNIAmalgamation amalgamation]];
	[_amalgamations addObject:[MPHBARTAmalgamation amalgamation]];
	[_amalgamations addObject:[MPHCaltrainAmalgamation amalgamation]];

#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif

	return self;
}

#pragma mark -

- (id <MPHAmalgamation>) amalgamationForService:(MPHService) service {
	if (service == MPHServiceMUNI)
		return [MPHMUNIAmalgamation amalgamation];
	if (service == MPHServiceBART)
		return [MPHBARTAmalgamation amalgamation];
	if (service == MPHServiceCaltrain)
		return [MPHCaltrainAmalgamation amalgamation];
	if (service == MPHServiceACTransit)
		return [MPHACTransitAmalgamation amalgamation];
	if (service == MPHServiceDumbartonExpress)
		return [MPHDumbartonAmalgamation amalgamation];
	if (service == MPHServiceSamTrans)
		return [MPHSamTransAmalgamation amalgamation];
	if (service == MPHServiceVTA)
		return [MPHVTAAmalgamation amalgamation];
	if (service == MPHServiceWestCat)
		return [MPHWestcatAmalgamation amalgamation];

	return nil;
}

#pragma mark -

- (NSString *) routeDataVersionForService:(MPHService) service {
	return [self amalgamationForService:service].routeDataVersion;
}

- (void) slurpRouteDataVersion:(NSString *) version forService:(MPHService) service {
	[[self amalgamationForService:service] slurpRouteDataVersion:version];
}

#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#pragma mark -

- (void) applicationDidBecomeActive:(NSNotification *) notification {
	for (id <MPHAmalgamation> amalgamation in self)
		[amalgamation fetchMessages];
}
#endif

#pragma mark -

- (NSArray *) messagesForService:(MPHService) service {
	return [[self amalgamationForService:service] messages];
}

- (NSArray *) messagesForStop:(id <MPHStop>) stop ofService:(MPHService) service {
	return [[self amalgamationForService:service] messagesForStop:stop];
}

- (NSArray *) routesForService:(MPHService) service {
	return [self routesForService:service sorted:NO];
}

- (NSArray *) routesForService:(MPHService) service sorted:(BOOL) sorted {
	if (!sorted) {
		return [self amalgamationForService:service].routes;
	}

	return [self amalgamationForService:service].sortedRoutes;
}

- (id <MPHRoute>) routeWithTag:(id) tag onService:(MPHService) service {
	return [[self amalgamationForService:service] routeWithTag:tag];
}

- (NSArray <id <MPHRoute>> *) routesForStop:(id <MPHStop>) stop onService:(MPHService) service {
	return [[self amalgamationForService:service] routesForStop:stop];
}

- (id <MPHRoute>) routeForDirectionTag:(NSString *) directionTag onService:(MPHService) service {
	return [[self amalgamationForService:service] routeForDirectionTag:directionTag];
}

#pragma mark -

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inDirection:(MPHDirection) travelDirection {
	return [[self amalgamationForService:route.service] stopsForRoute:route inDirection:travelDirection];
}

- (NSArray *) stopsForMessage:(MPHMessage *) message onRouteTag:(NSString *) tag {
	return [[self amalgamationForService:message.service] stopsForMessage:message onRouteTag:tag];
}

- (NSArray *) pathsForRoute:(id <MPHRoute>) route {
	return [[self amalgamationForService:route.service] pathsForRoute:route];
}

- (NSArray *) stopsForService:(MPHService) service inRegion:(MKCoordinateRegion) region {
	return [[self amalgamationForService:service] stopsInRegion:region];
}

- (NSArray *) routesForService:(MPHService) service inRegion:(MKCoordinateRegion) region {
	return [[self amalgamationForService:service] routesInRegion:region];
}

- (NSArray *) stopsForRoute:(id <MPHRoute>) route inRegion:(MKCoordinateRegion) region direction:(MPHDirection) direction ofService:(MPHService) service {
	return [[self amalgamationForService:service] stopsForRoute:route inRegion:region direction:direction];
}

- (id <MPHStop>) stopWithTag:(id) tag onRoute:(id <MPHRoute>) route onService:(MPHService) service inDirection:(MPHDirection) direction {
	return [[self amalgamationForService:service] stopWithTag:tag onRoute:route inDirection:direction];
}

#pragma mark -

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *) state objects:(id __unsafe_unretained []) buffer count:(NSUInteger) count {
	return [_amalgamations countByEnumeratingWithState:state objects:buffer count:count];
}
@end
