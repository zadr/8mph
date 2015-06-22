#import "MPHApplication.h"

#import "MPHURLProtocol.h"

#import "MPHLocationCenter.h"
#import "MPHRootNavigationStackController.h"

@implementation MPHApplication {
	MPHRootNavigationStackController *_rootNavigationStackController;
	NSExtensionContext *_extensionContext;
}

- (BOOL) application:(UIApplication *) application didFinishLaunchingWithOptions:(NSDictionary *) options {
	[NSURLProtocol registerClass:[MPHURLProtocol class]];

	application.statusBarStyle = UIStatusBarStyleLightContent;

	[[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];

	[MPHLocationCenter locationCenter];

	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_window.tintColor = [UIColor whiteColor];

	_rootNavigationStackController = [[MPHRootNavigationStackController alloc] init];
	[_rootNavigationStackController buildUserInterfaceInWindow:_window];

	[_window makeKeyAndVisible];

	return YES;
}
@end
