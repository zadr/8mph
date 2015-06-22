#import "MPHOTPPlanning.h"

NSString *const MPHParameterPlanFromPlaceKey = @"fromPlace"; // lat,long
NSString *const MPHParameterPlanToPlaceKey = @"toPlace"; // lat,long
NSString *const MPHParameterPlanDateKey = @"date";
NSString *const MPHParameterPlanTimeKey = @"time";
NSString *const MPHParameterPlanArriveByKey = @"arriveBy"; // true/false
NSString *const MPHParameterPlanWalkSpeedKey = @"walkSpeed"; // meters per second
NSString *const MPHParameterPlanModeKey = @"mode"; // TRANSIT or WALK or TRANSIT,WALK
NSString *const MPHParameterPlanTimeBetweenTransfersKey = @"minTransferTime"; // seconds
NSString *const MPHParameterPlanViewIntermediateStops = @"showIntermediateStops"; // true/false
NSString *const MPHParameterPlanMaxTransfersKey = @"maxTransfers"; // int
NSString *const MPHParameterPlanWheelchairKey = @"wheelchair"; // true/false

@implementation NSURLRequest (OTPPlanning)
+ (NSURLRequest *) planTripWithParameters:(NSDictionary *) parameters {
	NSAssert(parameters[MPHParameterPlanFromPlaceKey], @"From place required for trip");
	NSAssert(parameters[MPHParameterPlanToPlaceKey], @"To place required for trip");

// 	http://144.76.219.36:9090/opentripplanner-api-webapp/plan?fromPlace=37.769722,-122.466027&toPlace=37.803681,-122.461617
	NSString *URLString = [NSString stringWithFormat:@"http://144.76.219.36:9090/opentripplanner-api-webapp/plan?%@", parameters.mph_queryRepresentation];
	NSURL *URL = [NSURL URLWithString:URLString];
	return [NSMutableURLRequest requestWithURL:URL];
}
@end
