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

@end
