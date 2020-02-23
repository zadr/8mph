#import <Foundation/Foundation.h>

#import "MPHRoute.h"

@class MPHBARTPrediction;
@class MPHBARTStation;
@class MPHNextBusRoute;
@class MPHNextBusPrediction;
@class MPH511Prediction;
@class DDXMLElement;

@protocol MPHPrediction;

@interface NSURLRequest (Predictions)
+ (NSURLRequest *) nextBusPredictionsForStops:(NSArray *) stops onRoute:(id <MPHRoute>) route;
+ (NSURLRequest *) nextBusPredictionsWithStopsAndRoutes:(NSDictionary *) stopsAndRoutes; // { N: [5237, 4510], ... }
+ (MPHNextBusPrediction *) predictionFromXMLElement:(DDXMLElement *) predictionElement onRoute:(MPHNextBusRoute *) route withPredictionsElement:(DDXMLElement *) predictionsElement;

+ (NSArray *) BARTPredictionsForStops:(NSArray *) stops;
+ (MPHBARTPrediction *) predictionFromETDElement:(DDXMLElement *) etdElement estimateElement:(DDXMLElement *) estimateElement atStation:(MPHBARTStation *) station;

+ (NSArray *) VIIPredictionsForStops:(NSArray *) stops;
+ (MPH511Prediction *) predictionFromDepartureTimeElement:(DDXMLElement *) departureTimeElement inRouteDirectionElement:(DDXMLElement *) routeDirectionElement;
@end
