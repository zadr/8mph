typedef NS_ENUM(NSInteger, MPHWaypointSlideDirection) {
	MPHWaypointSlideDirectionPushFromLeft,
	MPHWaypointSlideDirectionPushFromRight,
	MPHWaypointSlideDirectionNone
};

@class MPHOTPPlan;

@interface MPHWaypointEntryControl : UIView
@property (readonly) UISearchBar *searchBar;
@property (nonatomic) BOOL showingSearchController;

- (void) slideFromDirection:(MPHWaypointSlideDirection) direction simultaneouslyPerformingActions:(void (^)())actions completionHandler:(void (^)())completionHandler;
- (void) showWaypointSelectorFromPlan:(MPHOTPPlan *) plan;
@end
