#import "MPHAppDelegate.h"

#import "MPHAmalgamator.h"

#import "MPHDefines.h"

#import "MPHURLProtocol.h"

@implementation MPHAppDelegate
- (void) applicationDidFinishLaunching:(NSNotification *) notification {
	[NSURLProtocol registerClass:[MPHURLProtocol class]];

//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceWestCat];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceVTA];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceSamTrans];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceDumbartonExpress];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceACTransit];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceCaltrain];
	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceMUNI];
//	[[MPHAmalgamator amalgamator] slurpRouteDataVersion:@"" forService:MPHServiceBART];
}
@end
