#import "MPHTableViewController.h"

@interface MPHTableViewController ()
@property (atomic, assign) BOOL shouldHideStatusBar;
@end

@implementation MPHTableViewController
- (void) dealloc {
	if ([self isViewLoaded]) {
		self.tableView.dataSource = nil;
		self.tableView.delegate = nil;
	}
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.tableView.rowHeight = 54.;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	self.navigationController.hidesBarsOnSwipe = NO;
	self.navigationController.hidesBarsOnTap = NO;
	self.navigationController.hidesBarsWhenVerticallyCompact = NO;

	[self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(statusBarActionGestureRecognizer:)];
}

- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];

	[self.navigationController.barHideOnSwipeGestureRecognizer removeTarget:self action:@selector(statusBarActionGestureRecognizer:)];
}

- (void) viewDidAppear:(BOOL) animated {
	[super viewDidAppear:animated];

	self.tableView.showsVerticalScrollIndicator = YES;
}

#pragma mark -

- (BOOL) shouldAutorotate {
	return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden {
	return NO;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
}

#pragma mark -

- (void) statusBarActionGestureRecognizer:(UIGestureRecognizer *) gestureRecognizer {
	self.shouldHideStatusBar = (self.navigationController.navigationBar.frame.origin.y < 0);

	[self setNeedsStatusBarAppearanceUpdate];
}
@end
