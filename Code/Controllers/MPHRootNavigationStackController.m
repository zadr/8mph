#import <UIKit/UIKit.h>

#import "MPHRootNavigationStackController.h"

#import "MPHServicesTableViewController.h"

@interface MPHRootNavigationStackController ()
@end

@implementation MPHRootNavigationStackController
- (void) buildUserInterfaceInWindow:(UIWindow *) window {
	MPHServicesTableViewController *servicesTableViewController = [[MPHServicesTableViewController alloc] init];

	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"MPHSelectedRow"] inSection:[[NSUserDefaults standardUserDefaults] integerForKey:@"MPHSelectedSection"]];

	window.rootViewController = [[UINavigationController alloc] initWithRootViewController:servicesTableViewController];

	[UIView performWithoutAnimation:^{
		[servicesTableViewController tableView:servicesTableViewController.tableView didSelectRowAtIndexPath:selectedIndexPath];
	}];
}
@end
