#import "MPHRouteTableViewController.h"

#import "MPHRouteController.h"
#import "MPHLocationCenter.h"

#import "MPHTableViewCell.h"

#import "MPHDefines.h"
#import "MPHStop.h"
#import "MPHPrediction.h"

#import "CLLocationAdditions.h"
#import "NSArrayAdditions.h"

@implementation MPHRouteTableViewController {
	BOOL _usesMetric;
	NSString *_groupingSeparator;
	NSNumberFormatter *_numberFormatter;
	NSMutableDictionary *_cachedDistances;

	__weak id <MPHRouteController> _routeController;
	MPHDirection _selectedDirection;

	CGFloat _previousNearestDistance;
	id <MPHStop> _nearestStop;

    NSIndexPath *_selectedIndexPath;
    NSIndexPath *_selectingIndexPath;
    NSAttributedString *_cachedPredictionString;
}

- (id) initWithRouteController:(id <MPHRouteController>) routeController {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_groupingSeparator = [[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator] copy];
	_numberFormatter = [[NSNumberFormatter alloc] init];
	_numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	_numberFormatter.maximumFractionDigits = 1;
	_numberFormatter.minimumFractionDigits = 1;
	_numberFormatter.roundingMode = NSNumberFormatterRoundHalfEven;
	_cachedDistances = [[NSMutableDictionary alloc] init];

	_usesMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
	_routeController = routeController;

	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPHLocationDidUpdateNotification object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideToolbar) object:nil];
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:MPHLocationDidUpdateNotification object:nil];
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	[self selectNearestStopAnimated:NO];

	[self performSelector:@selector(reloadData) withObject:nil afterDelay:30.];
}

- (void) viewDidDisappear:(BOOL) animated {
	[super viewDidDisappear:animated];

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
}

#pragma mark -

- (void) locationDidUpdate:(NSNotification *) notification {
	[_cachedDistances removeAllObjects];

	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

#pragma mark -

- (void) _hideToolbar {
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *) scrollView {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideToolbar) object:nil];
	[self performSelector:@selector(_hideToolbar) withObject:nil afterDelay:.2 inModes:@[ NSRunLoopCommonModes ]];
}

- (void) scrollViewWillEndDragging:(UIScrollView *) scrollView withVelocity:(CGPoint) velocity targetContentOffset:(inout CGPoint *) targetContentOffset {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideToolbar) object:nil];

	if (fabs((*targetContentOffset).y - scrollView.contentOffset.y) < 2.)
		return;

	if (velocity.y < 0 || (*targetContentOffset).y > scrollView.contentSize.height)
		[self.navigationController setToolbarHidden:NO animated:YES];
	else if (fabs(velocity.y) > 0.0) /* -0 is a thing */
		[self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark -

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	__strong id <MPHRouteController> strongRouteController = _routeController;
	return [strongRouteController stopsForDirection:_selectedDirection].signedCount;
}

- (BOOL) tableView:(UITableView *) tableView shouldHighlightRowAtIndexPath:(NSIndexPath *) indexPath {
    __strong id <MPHRouteController> strongRouteController = _routeController;
    id <MPHStop> stop = [[strongRouteController stopsForDirection:_selectedDirection] objectAtSignedIndex:indexPath.row];
    return [strongRouteController routesForStop:stop].count > 1;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	__strong id <MPHRouteController> strongRouteController = _routeController;
	id <MPHStop> stop = [[strongRouteController stopsForDirection:_selectedDirection] objectAtSignedIndex:indexPath.row];
	cell.textLabel.text = stop.name;

	if ([MPHLocationCenter locationCenter].currentLocation) {
		CGFloat distance = distanceBetweenCoordinates(stop.coordinate, [MPHLocationCenter locationCenter].currentLocation.coordinate);

		NSString *subText = _cachedDistances[stop.name];
		if (!subText.length) {
			if (_usesMetric)
				subText = [NSString stringWithFormat:@"%@ km", [_numberFormatter stringFromNumber:@(distance * MPHDistanceKilometersPerFoot)]];
			else subText = [NSString stringWithFormat:@"%@ mi", [_numberFormatter stringFromNumber:@(distance / MPHDistanceMilesPerFoot)]];

			_cachedDistances[stop.name] = subText;
		}
		cell.subTextLabel.text = subText;
		cell.subTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	}

	NSMutableAttributedString *minutes = [[NSMutableAttributedString alloc] init];
	NSArray *predictions = [strongRouteController predictionsForStop:stop];
	predictions = [predictions sortedArrayUsingComparator:^(id one, id two) {
		id <MPHPrediction> predictionOne = one;
		id <MPHPrediction> predictionTwo = two;

		if (predictionOne.minutesETA > predictionTwo.minutesETA)
			return NSOrderedDescending;
		if (predictionTwo.minutesETA > predictionOne.minutesETA)
			return NSOrderedAscending;
		return NSOrderedSame;
	}];

	for (id <MPHPrediction> prediction in predictions) {
		if (prediction.minutesETA < 0.)
			continue;

		NSDictionary *attributes = nil;
		if (prediction.minutesETA < 5) {
			attributes = @{
				NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
				NSBackgroundColorAttributeName: [UIColor clearColor],
				NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
			};
		} else if (prediction.minutesETA > 45) {
			attributes = @{
				NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
				NSBackgroundColorAttributeName: [UIColor clearColor],
				NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
			};
		} else {
			attributes = @{
				NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
				NSBackgroundColorAttributeName: [UIColor clearColor],
				NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
			};
		}
		if (prediction.minutesETA) {
			NSString *string = [NSString stringWithFormat:@"%zdm%@ ", prediction.minutesETA, _groupingSeparator];
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
			[minutes appendAttributedString:attributedString];
		} else {
			NSString *string = [NSString stringWithFormat:@"now%@ ", _groupingSeparator];
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
			[minutes appendAttributedString:attributedString];
		}
	}

	if (minutes.length)
		[minutes deleteCharactersInRange:NSMakeRange(minutes.length - (_groupingSeparator.length + 1), (_groupingSeparator.length + 1))];

	cell.detailTextLabel.attributedText = minutes;

	return cell;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    if (_selectedIndexPath && [_selectedIndexPath isEqual:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    if (![self tableView:tableView shouldHighlightRowAtIndexPath:indexPath])
        return;

    NSIndexPath *previouslySelectedIndexPath = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    _cachedPredictionString = nil;

    if (![self.tableView.indexPathForSelectedRow isEqual:indexPath])
        return;

    if (!previouslySelectedIndexPath)
        return;

    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[previouslySelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

#pragma mark -

- (void) directionSelected:(MPHDirection) direction {
	_selectedDirection = direction;
    _selectedIndexPath = nil;

	[self.tableView reloadData];

	[self selectNearestStopAnimated:NO];
}

- (void) selectNearestStopAnimated:(BOOL) animated {
	__strong id <MPHRouteController> strongRouteController = _routeController;
	_nearestStop = [strongRouteController nearestStopForDirection:_selectedDirection];
	NSInteger nearestStopIndex = [[strongRouteController stopsForDirection:_selectedDirection] indexOfObject:_nearestStop];

	for (NSInteger i = 4; i > -1; i--) {
		if (nearestStopIndex != NSNotFound && (nearestStopIndex - i) >= 0 && [self.tableView numberOfRowsInSection:0] > nearestStopIndex - i) {
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:nearestStopIndex - i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
			break;
		}
	}

	[self reloadData];
}

#pragma mark -

- (void) reloadData {
	__strong id <MPHRouteController> strongRouteController = _routeController;

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
	[self.tableView reloadData];

	BOOL shouldReload = NO;
	NSArray *predictions = [strongRouteController predictionsForStop:_nearestStop];
	if (!predictions.count)
		shouldReload = YES;
	else {
		id <MPHPrediction> prediction = [strongRouteController predictionsForStop:_nearestStop].firstObject;
		if (prediction.minutesETA < 3)
			shouldReload = YES;
	}

	if (shouldReload)
		[strongRouteController reloadStopTimes];

	[self performSelector:@selector(reloadData) withObject:nil afterDelay:30.];
}

#pragma mark -

- (void) tapGestureRecognizerRecognized:(UITapGestureRecognizer *) tapGestureRecognizer {
	CGPoint locationInView = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];

	if (locationInView.y > (CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.toolbar.frame)))
		[self.navigationController setToolbarHidden:NO animated:YES];
}

@end
