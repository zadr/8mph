#import "MPHTimesTableCellContentView.h"

#import "MPHPrediction.h"

@implementation MPHTimesTableCellContentView
- (void) setPredictions:(NSArray *) predictions {
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

	NSArray *orderedPredictions = [predictions sortedArrayUsingComparator:^(id one, id two) {
		id <MPHPrediction> onePrediction = one;
		id <MPHPrediction> twoPrediction = two;

		return (NSComparisonResult)(onePrediction.minutesETA > twoPrediction.minutesETA);
	}];
}
@end
