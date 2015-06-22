@class MKMapView;

@interface MPHRouteStopsSelectionView : NSView
@property (nonatomic, assign) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, assign) IBOutlet NSPopUpButton *popupButton;
@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) IBOutlet NSSplitView *splitView;
@end
