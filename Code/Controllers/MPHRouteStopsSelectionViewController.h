@class MPHRouteStopsSelectionViewController;

@protocol MPHRoute;
@protocol MPHStop;

@protocol MPHRouteStopsSelectionDelegate <NSObject>
@required
- (void) routeStopsSelectionViewController:(MPHRouteStopsSelectionViewController *) routeStopsSelectionViewController didSelectStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route;
- (void) routeStopsSelectionViewController:(MPHRouteStopsSelectionViewController *) routeStopsSelectionViewController didDeselectStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route;
@end

@interface MPHRouteStopsSelectionViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (nonatomic, weak) id <MPHRouteStopsSelectionDelegate> delegate;

- (IBAction) outlineViewDidSelectRow:(id) sender;
@end
