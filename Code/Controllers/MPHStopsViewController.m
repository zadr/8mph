#import "MPHStopsViewController.h"

#import "MPHAmalgamator.h"
#import "MPHStopsController.h"
#import "MPHLocationCenter.h"

#import "MPHTableViewCell.h"

#import "MPHBARTStation.h"
#import "MPHBARTPrediction.h"

#import "MPH511Prediction.h"
#import "MPHStop.h"

#import "MPHAlertsTableViewController.h"

#import "UIColorAdditions.h"

#import "PSPDFActionSheet.h"

@interface MPHStopsViewController () <MPHStopsControllerDelegate>
@end

@implementation MPHStopsViewController {
	id <MPHStopsController> _stopsController;
	NSArray *_stops;

	NSNumberFormatter *_numberFormatter;
	NSMutableDictionary *_cachedDistances;
	NSAttributedString *_cachedPredictionString;

	BOOL _usesMetric;
	NSString *_groupingSeparator;

	MPHService _service;

	NSIndexPath *_selectedIndexPath;
	NSIndexPath *_selectingIndexPath;
}

- (id) initWithService:(MPHService) service {
	if (!(self = [super init]))
		return nil;

	_stopsController = [MPHStopsController stopsControllerForService:service];
	_stopsController.delegate = self;

	_numberFormatter = [[NSNumberFormatter alloc] init];
	_numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	_numberFormatter.maximumFractionDigits = 1;
	_numberFormatter.minimumFractionDigits = 1;
	_numberFormatter.roundingMode = NSNumberFormatterRoundHalfEven;
	_cachedDistances = [[NSMutableDictionary alloc] init];

	_groupingSeparator = [[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator] copy];
	_usesMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];

	_service = service;

	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPHLocationDidUpdateNotification object:nil];
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Alerts" style:UIBarButtonItemStylePlain target:self action:@selector(showAlerts:)];

	NSString *key = [NSString stringWithFormat:@"MPHStopsSortDirection-%d", _service];
	_stops = [_stopsController stopsSortedByType:[[NSUserDefaults standardUserDefaults] integerForKey:key]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:MPHLocationDidUpdateNotification object:nil];

	UIBarButtonItem *filterByLinesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Lines: All", @"Lines: All button title") style:UIBarButtonItemStylePlain target:self action:@selector(showFilterByLinesOptions:)];
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	UIBarButtonItem *sortByItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort By…", @"Sort By… button title") style:UIBarButtonItemStylePlain target:self action:@selector(showSortByOptions:)];

	[self setToolbarItems:@[filterByLinesItem, spaceItem, sortByItem] animated:NO];
}

- (void) viewWillAppear:(BOOL) animated {
	[self.navigationController setToolbarHidden:NO animated:animated];

	[super viewWillAppear:animated];

	self.title = NSStringFromMPHService(_service);

	if (_service == MPHServiceBART) {
		self.navigationController.navigationBar.barTintColor = [UIColor BARTColor];
		self.navigationController.toolbar.tintColor = [UIColor BARTColor];
	} else if (_service == MPHServiceMUNI) {
		self.navigationController.toolbar.tintColor = [UIColor BARTColor];
		self.navigationController.navigationBar.barTintColor = [UIColor BARTColor];
	} else if (_service == MPHServiceCaltrain) {
		self.navigationController.navigationBar.barTintColor = [UIColor caltrainColor];
		self.navigationController.toolbar.tintColor = [UIColor caltrainColor];
	}
}

- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

- (void) locationDidUpdate:(NSNotification *) notification {
	[_cachedDistances removeAllObjects];

	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

- (void) viewWillTransitionToSize:(CGSize) size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>) coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

#pragma mark -

- (void) showAlerts:(id) sender {
	MPHAlertsTableViewController *alertsTableViewController = [[MPHAlertsTableViewController alloc] initWithAlerts:[[MPHAmalgamator amalgamator] messagesForService:_service]];

	[self.navigationController pushViewController:alertsTableViewController animated:YES];
}

- (void) showFilterByLinesOptions:(id) sender {

}

- (void) showSortByOptions:(id) sender {
	PSPDFActionSheet *actionSheet = [[PSPDFActionSheet alloc] initWithTitle:nil];

	void (^changeToSortType)(MPHStopsViewController *, MPHStopsSortType) = ^(MPHStopsViewController *strongSelf, MPHStopsSortType sortType){
		NSIndexPath *previouslySelectedIndexPath = strongSelf->_selectedIndexPath;
		id <MPHStop> selectedStop = strongSelf->_selectedIndexPath ? strongSelf->_stops[strongSelf->_selectedIndexPath.row] : nil;

		NSArray *newStops = [strongSelf->_stopsController stopsSortedByType:sortType];
		if ([strongSelf->_stops isEqualToArray:newStops])
			return;
		strongSelf->_stops = newStops;

		NSInteger newSelectedStopIndex = selectedStop ? [strongSelf->_stops indexOfObject:selectedStop] : NSNotFound;
		if (newSelectedStopIndex != NSNotFound)
			strongSelf->_selectedIndexPath = [NSIndexPath indexPathForRow:newSelectedStopIndex inSection:0];

		NSString *key = [NSString stringWithFormat:@"MPHStopsSortDirection-%d", strongSelf->_service];
		[[NSUserDefaults standardUserDefaults] setObject:@(sortType) forKey:key];

		[strongSelf.tableView beginUpdates];
		[strongSelf.tableView reloadRowsAtIndexPaths:strongSelf.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
		if (strongSelf->_selectedIndexPath) {
			if (previouslySelectedIndexPath && ![strongSelf.tableView.indexPathsForVisibleRows containsObject:previouslySelectedIndexPath])
				[strongSelf.tableView reloadRowsAtIndexPaths:@[previouslySelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			[strongSelf.tableView reloadRowsAtIndexPaths:@[strongSelf->_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		[strongSelf.tableView endUpdates];
		[strongSelf.tableView scrollToRowAtIndexPath:strongSelf->_selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	};

	__weak MPHStopsViewController *weakSelf = self;
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Sort Alphabetically" , @"Sort Alphabetically action sheet title") block:^(NSInteger buttonIndex){
		__strong MPHStopsViewController *strongSelf = weakSelf;
		changeToSortType(strongSelf, MPHStopsSortTypeAlphabetical);
	}];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Sort By Distance" , @"Sort By Distance action sheet title") block:^(NSInteger buttonIndex){
		__strong MPHStopsViewController *strongSelf = weakSelf;
		changeToSortType(strongSelf, MPHStopsSortTypeDistanceFromDistance);
	}];

	[actionSheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel action sheet title") block:NULL];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark -

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *) indexPath {
	return ![_selectedIndexPath isEqual:indexPath];
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	return _stops.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell)
		cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	id <MPHStop> stop = [_stops objectAtSignedIndex:indexPath.row];
	cell.textLabel.text = stop.name;
	cell.textLabel.minimumScaleFactor = (14. / cell.textLabel.font.pointSize);
	cell.textLabel.numberOfLines = 1;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;

	if ([MPHLocationCenter locationCenter].currentLocation) {
		CGFloat distance = distanceBetweenCoordinates(stop.coordinate, [MPHLocationCenter locationCenter].currentLocation.coordinate);

		NSString *subText = _cachedDistances[stop.name];
		if (!subText.length) {
			if ((stop.coordinate.latitude > 0.0 || stop.coordinate.latitude < 0.0) && (stop.coordinate.longitude > 0.0 || stop.coordinate.longitude < 0.0)) {
				if (_usesMetric)
					subText = [NSString stringWithFormat:@"%@ km", [_numberFormatter stringFromNumber:@(distance * MPHDistanceKilometersPerFoot)]];
				else subText = [NSString stringWithFormat:@"%@ mi", [_numberFormatter stringFromNumber:@(distance / MPHDistanceMilesPerFoot)]];
			} else {
				subText = @"";
			}

			_cachedDistances[stop.name] = subText;
		}

		cell.subTextLabel.text = subText;
	}

	if ([_selectedIndexPath isEqual:indexPath]) {
		if (!_cachedPredictionString)
			[self _generatePredictionString];

		cell.detailTextLabel.attributedText = _cachedPredictionString;
		cell.detailTextLabel.numberOfLines = 0;
	} else {
		cell.detailTextLabel.attributedText = nil;
	}

	return cell;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
	if ([_selectedIndexPath isEqual:indexPath]) {
		CGSize textSize = [@"Jy" sizeWithAttributes:@{
			NSFontAttributeName: [UIFont systemFontOfSize:18.]
		}];

		if (!_cachedPredictionString)
			[self _generatePredictionString];

		if (_cachedPredictionString.length > 0) {
			CGRect cachedStringRect = [_cachedPredictionString boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 36, 9000) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:NULL];
			return fmax(textSize.height + cachedStringRect.size.height + (4 * 2), tableView.rowHeight);
		}
	}

	return self.tableView.rowHeight;
}

- (NSIndexPath *) tableView:(UITableView *) tableView willSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	_cachedPredictionString = nil;
	_selectingIndexPath = indexPath;

	return indexPath;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	if (_selectedIndexPath && [_selectedIndexPath isEqual:indexPath]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	NSIndexPath *previouslySelectedIndexPath = _selectedIndexPath;
	_selectedIndexPath = indexPath;
	_cachedPredictionString = nil;

	if (![self.tableView.indexPathForSelectedRow isEqual:indexPath])
		return;

	[_stopsController fetchPredictionsForStop:_stops[indexPath.row]];

	if (!previouslySelectedIndexPath)
		return;

	[tableView beginUpdates];
	[tableView reloadRowsAtIndexPaths:@[previouslySelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[tableView endUpdates];
}

#pragma mark -

- (void) stopsController:(id <MPHStopsController>) routeController didLoadPredictionsForStop:(id <MPHStop>) stop {
	[self _generatePredictionString];

	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
}

#pragma mark -

- (void) _generatePredictionString {
	if (_stopsController.service == MPHServiceMUNI) {

	} else if (_stopsController.service == MPHServiceBART) {
		[self _generateBARTPredictionsString];
	} else {
		[self _generate511PredictionsString];
	}
}

- (void) _generate511PredictionsString {
	NSDictionary *predictions = [_stopsController predictionsForStop:_stops[_selectedIndexPath.row]];
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];

	[predictions enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stopIteration) {
		MPH511Prediction *anyPrediction = [object lastObject];
		NSString *stationString = [NSString stringWithFormat:@"\n • %@: ", anyPrediction.routeName.capitalizedString];
		NSAttributedString *station = [[NSAttributedString alloc] initWithString:stationString attributes:@{
			NSForegroundColorAttributeName: [UIColor darkTextColor],
			NSFontAttributeName: [UIFont boldSystemFontOfSize:13.]
		}];
		[text appendAttributedString:station];
		object = [object sortedArrayUsingComparator:^NSComparisonResult(id one, id two) {
			return [@([one minutesETA]) compare:@([two minutesETA])];
		}];

		for (MPH511Prediction *prediction in object) {
			if (prediction.minutesETA < 0.)
				continue;

			NSDictionary *attributes;
			if (prediction.minutesETA < 5) {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor colorWithRed:(0. / 255.) green:(102. / 255.) blue:(0. / 255.) alpha:1.],
					NSFontAttributeName: [UIFont systemFontOfSize:13.]
				};
			} else {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor darkTextColor],
					NSFontAttributeName: [UIFont systemFontOfSize:13.]
				};
			}
			if (prediction.minutesETA) {
				NSString *string = [NSString stringWithFormat:@"%zdm%@ ", prediction.minutesETA, _groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			} else {
				NSString *string = [NSString stringWithFormat:@"now%@ ", _groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			}
		}

		if (text.length)
			[text deleteCharactersInRange:NSMakeRange(text.length - (_groupingSeparator.length + 1), (_groupingSeparator.length + 1))];
	}];

	if (text.length)
		[text deleteCharactersInRange:NSMakeRange(0, 1)];
	else text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"No trains", @"No trains text") attributes:@{
			NSForegroundColorAttributeName: [UIColor darkTextColor],
			NSFontAttributeName: [UIFont systemFontOfSize:13.]
		}];
	
	_cachedPredictionString = [text copy];
}

- (void) _generateBARTPredictionsString {
	NSDictionary *predictions = [_stopsController  predictionsForStop:_stops[_selectedIndexPath.row]];
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
	NSArray *keys = [predictions.allKeys sortedArrayUsingComparator:^(id one, id two) {
		MPHBARTPrediction *predictionOne = [predictions[one] lastObject];
		MPHBARTPrediction *predictionTwo = [predictions[two] lastObject];

		return [predictionOne.color mph_compare:predictionTwo.color];
	}];

	for (id key in keys) {
		id object = predictions[key];

		NSDictionary *attributes = @{
			NSForegroundColorAttributeName: [UIColor darkTextColor],
			NSFontAttributeName: [UIFont boldSystemFontOfSize:13.]
		};

		MPHBARTPrediction *anyPrediction = [object lastObject];
		NSAttributedString *prefix = [[NSAttributedString alloc] initWithString:@"\n " attributes:attributes];
		[text appendAttributedString:prefix];

		NSMutableDictionary *dotAttributes = [attributes mutableCopy];
		dotAttributes[NSForegroundColorAttributeName] = anyPrediction.color;

		NSAttributedString *dotString = [[NSAttributedString alloc] initWithString:@"•" attributes:dotAttributes];
		[text appendAttributedString:dotString];

		NSString *stationString = [NSString stringWithFormat:@" %@: ", key];
		NSAttributedString *station = [[NSAttributedString alloc] initWithString:stationString attributes:attributes];
		[text appendAttributedString:station];

		for (MPHBARTPrediction *prediction in object) {
			if (prediction.minutesETA < 0.)
				continue;

			if (prediction.minutesETA < 5) {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor colorWithRed:(0. / 255.) green:(102. / 255.) blue:(0. / 255.) alpha:1.],
					NSFontAttributeName: [UIFont systemFontOfSize:13.]
				};
			} else {
				attributes = @{
					NSForegroundColorAttributeName: [UIColor darkTextColor],
					NSFontAttributeName: [UIFont systemFontOfSize:13.]
				};
			}
			if (prediction.minutesETA) {
				NSString *string = [NSString stringWithFormat:@"%zdm%@ ", prediction.minutesETA, _groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			} else {
				NSString *string = [NSString stringWithFormat:@"now%@ ", _groupingSeparator];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
				[text appendAttributedString:attributedString];
			}
		}
		
		if (text.length)
			[text deleteCharactersInRange:NSMakeRange(text.length - (_groupingSeparator.length + 1), (_groupingSeparator.length + 1))];
	}

	if (text.length)
		[text deleteCharactersInRange:NSMakeRange(0, 1)];
	else text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"No trains", @"No trains text") attributes:@{
			NSForegroundColorAttributeName: [UIColor darkTextColor],
			NSFontAttributeName: [UIFont systemFontOfSize:13.]
		}];

	_cachedPredictionString = [text copy];
}
@end
