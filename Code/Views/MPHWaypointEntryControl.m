#import "MPHWaypointEntryControl.h"

#import "MPHOTPPlan.h"

@interface MPHSearchBar : UISearchBar
@property CGFloat maxPortraitWidth;
@property CGFloat maxLandscapeWidth;

@property MPHOTPPlan *plan;
@end

@implementation MPHSearchBar
- (void) setFrame:(CGRect) frame {
	CGFloat cappedWidth = self.maxPortraitWidth;
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
		cappedWidth = self.maxPortraitWidth;
	if (frame.size.width > cappedWidth)
		frame.size.width = cappedWidth;
	[super setFrame:frame];
}
@end

@interface MPHWaypointEntryControl ()
@property (strong) UIView *backgroundView;
@property (strong) UIView *containerView;

@property (nonatomic, readonly) MPHSearchBar *customSearchBar;

@property (strong) MPHOTPPlan *plan;
@end

@implementation MPHWaypointEntryControl
- (id) initWithFrame:(CGRect) frame {
	if (!(self = [super initWithFrame:frame]))
		return nil;

	_backgroundView = [[UIView alloc] initWithFrame:frame];
	_backgroundView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.7];

	_containerView = [[UIView alloc] initWithFrame:frame];

	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{
		NSForegroundColorAttributeName: [UIColor whiteColor],
	} forState:UIControlStateNormal];

	_searchBar = [[MPHSearchBar alloc] initWithFrame:CGRectZero];
	_searchBar.barTintColor = [UIColor colorWithWhite:.01 alpha:.01];
	_searchBar.placeholder = NSLocalizedString(@"From…", @"From… search text");
	_searchBar.tintColor = [UIColor colorWithRed:(63. / 255.) green:(102. / 255.) blue:(246. / 255.) alpha:1.];

	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	self.customSearchBar.maxPortraitWidth = MIN(screenSize.width, screenSize.height) - 40;
	self.customSearchBar.maxLandscapeWidth = MAX(screenSize.width, screenSize.height) - 40;

	[self addSubview:_backgroundView];
	[self addSubview:_containerView];
	[_containerView addSubview:_searchBar];

	[self _positionSearchBar];

	return self;
}

#pragma mark -

- (void) layoutSubviews {
	[super layoutSubviews];

	_containerView.frame = self.frame;
	_backgroundView.frame = self.frame;

	NSLog(@"%@", NSStringFromCGRect(self.frame));
	NSLog(@"%@", NSStringFromCGRect(_backgroundView.frame));

	[self _positionSearchBar];
}

#pragma mark -

- (void) _positionSearchBar {
	CGRect frame = self.searchBar.frame;
	frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
	if (self.showingSearchController) {
		frame.origin.x = 0.;
		frame.size.width = self.frame.size.width;
	} else {
		frame.origin.x = 20.;
		frame.size.width = self.frame.size.width - 40.;
	}
	self.searchBar.frame = frame;
}

#pragma mark -

- (void) setShowingSearchController:(BOOL) showingSearchController {
	_showingSearchController = showingSearchController;

	[self _positionSearchBar];
}

- (MPHSearchBar *) customSearchBar {
	return (MPHSearchBar *)self.searchBar;
}

#pragma mark -

- (void) slideFromDirection:(MPHWaypointSlideDirection) direction simultaneouslyPerformingActions:(void (^)()) actions completionHandler:(void (^)()) completionHandler {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);

	[_containerView drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];

	UIImageView *snapshotView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];

	UIGraphicsEndImageContext();

	[self addSubview:snapshotView];

	[UIView performWithoutAnimation:^{
		CGRect frame = _containerView.frame;
		if (direction == MPHWaypointSlideDirectionPushFromLeft)
			frame.origin.x -= frame.size.width;
		else if (direction == MPHWaypointSlideDirectionPushFromRight)
			frame.origin.x += frame.size.width;
		_containerView.frame = frame;
	}];

	[UIView animateWithDuration:(1. / 3.) delay:0. options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut) animations:^{
		CGRect containerFrame = _containerView.frame;
		CGRect snapshotFrame = snapshotView.frame;
		if (direction == MPHWaypointSlideDirectionPushFromLeft) {
			containerFrame.origin.x += containerFrame.size.width;
			snapshotFrame.origin.x += containerFrame.size.width;
		} else if (direction == MPHWaypointSlideDirectionPushFromRight) {
			containerFrame.origin.x -= containerFrame.size.width;
			snapshotFrame.origin.x -= containerFrame.size.width;
		}
		_containerView.frame = containerFrame;
		snapshotView.frame = snapshotFrame;

		if (actions)
			actions();
	} completion:^(BOOL finished) {
		[snapshotView removeFromSuperview];

		if (completionHandler)
			completionHandler();
	}];
}

- (void) showWaypointSelectorFromPlan:(MPHOTPPlan *) plan {
	if (!self.plan) {
		[UIView animateWithDuration:(1. / 3.) animations:^{
			NSLog(@"expanding");
			CGRect frame = self.frame;
			frame.size.height += 60.;
			self.frame = frame;

			_backgroundView.frame = frame;
		}];
	}

	self.plan = plan;
}
@end
