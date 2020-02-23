#import <TargetConditionals.h>

#import "MPHPredictions.h"

#import "MPHBARTPrediction.h"
#import "MPHBARTStation.h"

#import "MPHNextBusPrediction.h"
#import "MPHNextBusRoute.h"
#import "MPHNextBusStop.h"

#import "MPH511Prediction.h"

#import "NSStringAdditions.h"

#import "DDXMLElement.h"

@implementation NSURLRequest (Predictions)
+ (NSURLRequest *) nextBusPredictionsForStops:(NSArray *) stops onRoute:(id <MPHRoute>) route {
	NSString *encodedRouteTag = [route.tag mph_stringByPercentEncodingString];
	NSMutableString *stopsParameter = [NSMutableString string];

	for (MPHNextBusStop *stop in stops)
		[stopsParameter appendFormat:@"stops=%@%%7C%ld&", encodedRouteTag, (long)stop.tag];
	if (stopsParameter.length)
		[stopsParameter deleteCharactersInRange:NSMakeRange(stopsParameter.length - 1, 1)];

	return [NSString mph_requestWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&%@", stopsParameter];
}

+ (NSURLRequest *) nextBusPredictionsWithStopsAndRoutes:(NSDictionary *) stopsAndRoutes {
	NSMutableString *stopsParameter = [NSMutableString string];

	[stopsAndRoutes enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stopEnumerating) {
		NSString *encodedRouteTag = [key mph_stringByPercentEncodingString];
		for (MPHNextBusStop *stop in object)
			[stopsParameter appendFormat:@"stops=%@%%7C%ld&", encodedRouteTag, (long)stop.tag];
	}];

	if (!stopsParameter.length)
		return nil;

	[stopsParameter deleteCharactersInRange:NSMakeRange(stopsParameter.length - 1, 1)];

	return [NSString mph_requestWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&%@", stopsParameter];
}

+ (MPHNextBusPrediction *) predictionFromXMLElement:(DDXMLElement *) predictionElement onRoute:(MPHNextBusRoute *) route withPredictionsElement:(DDXMLElement *) predictionsElement {
	MPHNextBusPrediction *prediction = [[MPHNextBusPrediction alloc] init];
	prediction.stopTag = [predictionsElement attributeForName:@"stopTag"].stringValue;
	prediction.service = route.service;
	prediction.epochTime = [[predictionElement attributeForName:@"epochTime"].stringValue doubleValue];
	prediction.seconds = [[predictionElement attributeForName:@"seconds"].stringValue doubleValue];
	prediction.minutes = [[predictionElement attributeForName:@"minutes"].stringValue doubleValue];
	prediction.direction = [predictionElement attributeForName:@"dirTag"].stringValue;
	prediction.vehicle = [predictionElement attributeForName:@"vehicle"].stringValue;
	prediction.trip = [predictionElement attributeForName:@"tripTag"].stringValue;
	prediction.routeTitle = [predictionsElement attributeForName:@"routeTitle"].stringValue;
	prediction.stopTitle = [predictionsElement attributeForName:@"stopTitle"].stringValue;
	return prediction;
}

#pragma mark -

+ (MPHBARTPrediction *) predictionFromETDElement:(DDXMLElement *) etdElement estimateElement:(DDXMLElement *) estimateElement atStation:(nullable MPHBARTStation *) station {
	MPHBARTPrediction *prediction = [[MPHBARTPrediction alloc] init];
	prediction.destination = [[[etdElement elementsForName:@"destination"] lastObject] stringValue];
	prediction.abbreviation = [[[etdElement elementsForName:@"abbreviation"] lastObject] stringValue];

	NSString *minutes = [[[estimateElement elementsForName:@"minutes"] lastObject] stringValue];
	if ([minutes mph_isCaseInsensitiveEqualToString:@"Leaving"])
		prediction.minutes = 0;
	else prediction.minutes = minutes.integerValue;

	NSString *directionString = [[[estimateElement elementsForName:@"direction"] lastObject] stringValue];
	if ([directionString isEqualToString:@"North"])
		prediction.direction = MPHBARTDirectionNorth;
	else if ([directionString isEqualToString:@"South"])
		prediction.direction = MPHBARTDirectionSouth;

	prediction.platform = [[[[estimateElement elementsForName:@"platform"] lastObject] stringValue] integerValue];
	prediction.carLength = [[[[estimateElement elementsForName:@"length"] lastObject] stringValue] integerValue];
#if TARGET_OS_IPHONE
	[prediction setColorFromHexString:[[[estimateElement elementsForName:@"hexcolor"] lastObject] stringValue]];
#endif

	prediction.bikesAvailable = [[[[estimateElement elementsForName:@"bikeflag"] lastObject] stringValue] boolValue];

	return prediction;
}

+ (NSArray *) BARTPredictionsForStops:(NSArray *) stops {
	NSMutableArray *array = [NSMutableArray array];

	for (NSString *abbreviation in stops) {
		NSURLRequest *request = [NSString mph_requestWithFormat:@"http://api.bart.gov/api/etd.aspx?cmd=etd&orig=%@&key=%@", abbreviation, MPHBARTAPIKey];

		[array addObject:request];
	}

	return array;
}

#pragma mark -

+ (NSArray *) VIIPredictionsForStops:(NSArray *) stops {
	NSMutableArray *array = [NSMutableArray array];

	for (NSString *tag in stops) {
		NSURLRequest *request = [NSString mph_requestWithFormat:@"http://services.my511.org/Transit2.0/GetNextDeparturesByStopCode.aspx?token=%@&stopcode=%@&agencyName=%@", MPH511APIKey, tag.mph_stringByPercentEncodingString, @"Caltrain"];

		[array addObject:request];
	}

	return array;
}

+ (MPH511Prediction *) predictionFromDepartureTimeElement:(DDXMLElement *) departureTimeElement inRouteDirectionElement:(DDXMLElement *) routeDirectionElement {
	MPH511Prediction *prediction = [[MPH511Prediction alloc] init];
	prediction.routeCode = [routeDirectionElement attributeForName:@"Code"].stringValue;
	prediction.routeName = [routeDirectionElement attributeForName:@"Name"].stringValue;

	DDXMLElement *stopListElement = [routeDirectionElement elementsForName:@"StopList"].lastObject;
	DDXMLElement *stopElement = [stopListElement elementsForName:@"Stop"].lastObject;
	prediction.stopCode = [stopElement attributeForName:@"StopCode"].stringValue;
	prediction.stopName = [stopElement attributeForName:@"name"].stringValue;

	prediction.minutes = departureTimeElement.stringValue.integerValue;

	return prediction;
}
@end
