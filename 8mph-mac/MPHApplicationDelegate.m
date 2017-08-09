#import "MPHApplicationDelegate.h"

#import "MPHLocationCenter.h"
#import "MPHMenuController.h"
#import "MPHPreferencesViewController.h"
#import "MPHRulesTableController.h"

typedef NS_ENUM(NSInteger, MPHShow) {
	MPHShowNever,
	MPHShowAlways,
	MPHShowOnAlert // Unused for dock icon
};
typedef NSInteger MPHShowState;

@implementation MPHApplicationDelegate {
	MPHPreferencesViewController *_preferencesViewController;
}

- (void) applicationDidFinishLaunching:(NSNotification *) notification {
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];

	(void)[MPHLocationCenter locationCenter];

	[self userDefaultsDidChange:nil];

	_rulesTableWindowController = [[MPHRulesTableWindowController alloc] init];
	[_rulesTableWindowController showRules:nil];
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *) application hasVisibleWindows:(BOOL) hasVisibleWindows {
	if (!hasVisibleWindows)
		[_rulesTableWindowController showRules:nil];

	return YES;
}

- (void) userDefaultsDidChange:(NSNotification *) notification {
	[self reloadDockIcon];
	[self reloadStatusBarItem];
}

- (IBAction) showPreferences:(id) sender {
	if (!_preferencesViewController)
		_preferencesViewController = [[MPHPreferencesViewController alloc] init];

	[_preferencesViewController showWindow:sender];
}

#pragma mark -

- (void) reloadDockIcon {
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	MPHShowState state = [[NSUserDefaults standardUserDefaults] integerForKey:@"MPHShowDockIcon"];

	if (state == MPHShowAlways)
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	else TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}

- (void) reloadStatusBarItem {
	MPHShowState state = [[NSUserDefaults standardUserDefaults] integerForKey:@"MPHShowStatusBarItem"];

	if (!_menuController && state == MPHShowAlways) {
		_menuController = [[MPHMenuController alloc] init];

		[_menuController addStatusBarItem];
	} else if (_menuController && state == MPHShowNever) {
		[_menuController removeStatusBarItem];

		_menuController = nil;
	} else if (state == MPHShowOnAlert) {
		_menuController = [[MPHMenuController alloc] init];
	}
}
@end
