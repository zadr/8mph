#import "MPHRoute.h"

@class MPHBARTPrediction;
@class MPHBARTStation;
@class MPHNextBusRoute;
@class MPHNextBusPrediction;
@class MPH511Prediction;

@protocol MPHPrediction;

@interface NSURLRequest (Predictions)
+ (NSURLRequest *) nextBusPredictionsForStops:(NSArray *) stops onRoute:(id <MPHRoute>) route;
+ (NSURLRequest *) nextBusPredictionsWithStopsAndRoutes:(NSDictionary *) stopsAndRoutes; // { N: [5237, 4510], ... }
+ (MPHNextBusPrediction *) predictionFromXMLElement:(NSXMLElement *) predictionElement onRoute:(MPHNextBusRoute *) route withPredictionsElement:(NSXMLElement *) predictionsElement;

+ (NSArray *) BARTPredictionsForStops:(NSArray *) stops;
+ (MPHBARTPrediction *) predictionFromETDElement:(NSXMLElement *) etdElement estimateElement:(NSXMLElement *) estimateElement atStation:(MPHBARTStation *) station;

+ (NSArray *) VIIPredictionsForStops:(NSArray *) stops;
+ (MPH511Prediction *) predictionFromDepartureTimeElement:(NSXMLElement *) departureTimeElement inRouteDirectionElement:(NSXMLElement *) routeDirectionElement;
@end
