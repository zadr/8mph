#import <Foundation/Foundation.h>

// http://www.opentripplanner.org/apidoc/0.9.2/resource_Planner.html

extern NSString *const MPHParameterPlanFromPlaceKey; // lat,long
extern NSString *const MPHParameterPlanToPlaceKey; // lat,long
extern NSString *const MPHParameterPlanDateKey;
extern NSString *const MPHParameterPlanTimeKey;
extern NSString *const MPHParameterPlanArriveByKey; // true/false
extern NSString *const MPHParameterPlanWalkSpeedKey; // meters per second
extern NSString *const MPHParameterPlanModeKey; // TRANSIT or WALK
extern NSString *const MPHParameterPlanTimeBetweenTransfersKey; // seconds
extern NSString *const MPHParameterPlanViewIntermediateStops; // true/false
extern NSString *const MPHParameterPlanMaxTransfersKey; // int
extern NSString *const MPHParameterPlanWheelchairKey; // true/false

@interface NSURLRequest (OTPPlanning)
+ (NSURLRequest *) planTripWithParameters:(NSDictionary *) parameters;
@end
