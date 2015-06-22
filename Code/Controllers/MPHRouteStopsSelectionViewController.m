#import "MPHRouteStopsSelectionViewController.h"

#import "MPHAmalgamator.h"
#import "MPHLocationCenter.h"

#import "MPHRouteStopsSelectionView.h"

#import "MPHRule.h"
#import "MPHStop.h"
#import "MPHRoute.h"

@interface MPHRouteStopsSelectionViewController () <MKMapViewDelegate>
@end

@implementation MPHRouteStopsSelectionViewController {
	MPHRule *_rule;
	NSDictionary *_routeStopData; // [{"line":[stop, stop, stop]}, …]
	NSArray *_sortedRoutes; // _routeStopData.allkeys, sorted
	NSArray *_stopsForSelectedRoute;
}

- (id) init {
	return (self = [super initWithNibName:@"MPHRouteStopsSelectionView" bundle:nil]);
}

#pragma mark -

- (void) awakeFromNib {
	[super awakeFromNib];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:MPHLocationDidUpdateNotification object:nil];

	MPHRouteStopsSelectionView *selectionView = (MPHRouteStopsSelectionView *)self.view;
	selectionView.mapView.delegate = self;
	selectionView.mapView.showsUserLocation = YES;
	selectionView.popupButton.target = self;
	selectionView.popupButton.action = @selector(directionChanged:);
}

#pragma mark -

- (void) setRepresentedObject:(id) representedObject {
	_rule = representedObject;

	[self refreshLocation];
}

#pragma mark -

- (void) directionChanged:(id) sender {
	[self refreshRouteList];
}

- (void) refreshLocation {
	MPHRouteStopsSelectionView *selectionView = (MPHRouteStopsSelectionView *)self.view;
	selectionView.mapView.centerCoordinate = [MPHLocationCenter locationCenter].currentLocation.coordinate;
	selectionView.mapView.region = MKCoordinateRegionMake([MPHLocationCenter locationCenter].currentLocation.coordinate, MKCoordinateSpanMake(0.001953125, 0.001953125));
}

- (void) refreshRouteList {
	if (_rule.service == MPHServiceNone)
		return;

	MPHRouteStopsSelectionView *selectionView = (MPHRouteStopsSelectionView *)self.view;

	NSArray *visibleRoutes = [[MPHAmalgamator amalgamator] routesForService:_rule.service inRegion:selectionView.mapView.region];
	NSMutableDictionary *routeStopMapping = [NSMutableDictionary dictionary];
	for (id <MPHRoute> route in visibleRoutes) {
		NSArray *stops = [[MPHAmalgamator amalgamator] stopsForRoute:route inRegion:selectionView.mapView.region direction:(MPHDirection)selectionView.popupButton.indexOfSelectedItem ofService:_rule.service];
		if (stops.count)
			routeStopMapping[route] = stops;
	}

	_routeStopData = [routeStopMapping copy];
	_sortedRoutes = [_routeStopData.allKeys sortedArrayUsingComparator:^(id one, id two) {
		return compareMUNIRoutesWithTitles([one title], [two title]);
	}];

	[selectionView.outlineView reloadData];
}

#pragma mark -

- (void) locationDidUpdate:(NSNotification *) notification {
	[self refreshLocation];
	[self refreshRouteList];
}

#pragma mark -

- (void) mapView:(MKMapView *) mapView regionDidChangeAnimated:(BOOL) animated {
	[self refreshRouteList];
}

#pragma mark -

- (NSInteger) outlineView:(NSOutlineView *) outlineView numberOfChildrenOfItem:(id) item {
	if (!item)
		return _sortedRoutes.count;
	return [_routeStopData[item] count];
}

- (id) outlineView:(NSOutlineView *) outlineView child:(NSInteger) index ofItem:(id) item {
	if (!item)
		return _sortedRoutes[index];

	id returnValue = _routeStopData[item][index];

	[returnValue mph_associateValue:item withKey:@"route"];

	return returnValue;
}

- (BOOL) outlineView:(NSOutlineView *) outlineView isItemExpandable:(id) item {
	return [self outlineView:outlineView isGroupItem:item];
}

- (BOOL) outlineView:(NSOutlineView *) outlineView isGroupItem:(id) item {
	return [_sortedRoutes containsObject:item];
}

- (NSView *) outlineView:(NSOutlineView *) outlineView viewForTableColumn:(NSTableColumn *) tableColumn item:(id) item {
	NSTableCellView *tableViewCell = nil;
	BOOL isGroupItem = [self outlineView:outlineView isGroupItem:item];

	if (isGroupItem)
		tableViewCell = [outlineView makeViewWithIdentifier:[outlineView.tableColumns[0] identifier] owner:self];
	else tableViewCell = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];

	tableViewCell.textField.editable = NO;
	if ([_rule.stops containsObject:item] && [_rule.routes containsObject:[item mph_associatedValueForKey:@"route"]]) {
//		NSRect frame = tableViewCell.textField.frame;
//		frame.origin.x = 0;
//		tableViewCell.textField.frame = frame;

		tableViewCell.textField.stringValue = [@"✓ " stringByAppendingString:[item name]];
	} else {
		if (!isGroupItem) {
//			NSRect frame = tableViewCell.textField.frame;
//			frame.origin.x = [@"✓ " boundingRectWithSize:NSMakeSize(64, 32) options:(NSLineBreakByWordWrapping | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics) attributes:nil].size.width + 1;
//			tableViewCell.textField.frame = frame;
			tableViewCell.textField.stringValue = [@"    " stringByAppendingString:[item name]];
		} else tableViewCell.textField.stringValue = [item name];
	}

	tableViewCell.toolTip = [item name];

	return tableViewCell;
}

- (IBAction) outlineViewDidSelectRow:(NSOutlineView *) sender {
	NSInteger selectedRow = sender.selectedRow;

	if (selectedRow == -1)
		return;

	id item = [sender itemAtRow:selectedRow];

	if ([self outlineView:sender isGroupItem:item]) {
		if ([sender isItemExpanded:item])
			[sender collapseItem:item];
		else [sender expandItem:item];
	} else {
		id <MPHStop> stop = item;
		id <MPHRoute> route = [item mph_associatedValueForKey:@"route"];

		__strong typeof(_delegate) strongDelegate = _delegate;
		if ([_rule.stops containsObject:stop] && [_rule.routes containsObject:route])
			[strongDelegate routeStopsSelectionViewController:self didDeselectStop:stop onRoute:route];
		else [strongDelegate routeStopsSelectionViewController:self didSelectStop:stop onRoute:route];
	}

	[sender deselectRow:selectedRow];
	[sender reloadData];
}
@end
