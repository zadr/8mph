#import "MPHMenuController.h"

#import "MPHRule.h"

#import "MPHApplicationDelegate.h"

#import "MPHRulesTableController.h"

#define PreferencesMenuItemTag 10000
#define QuitMenuItemTag 10001

@interface MPHMenuController () <NSPopoverDelegate>
@end

@implementation MPHMenuController {
	MPHRulesTableViewController *_rulesTableViewController;
	NSPopover *_popover;

	NSStatusItem *_statusItem;

	MPHRule *_rule;
}

#pragma mark -

- (void) showPopover:(id) sender {
	if (!_popover) {
		_popover = [[NSPopover alloc] init];
		_popover.behavior = NSPopoverBehaviorTransient;
		_popover.delegate = self;

		_rulesTableViewController = [[MPHRulesTableViewController alloc] init];
	}

	_popover.contentViewController = _rulesTableViewController;

	[_popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}

#pragma mark -

- (NSWindow *) detachableWindowForPopover:(NSPopover *) popover {
	return [(MPHApplicationDelegate *)[NSApplication sharedApplication].delegate rulesTableWindowController].window;
}

- (void) popoverDidClose:(NSNotification *) notification {
	_popover.contentViewController = nil;
}

#pragma mark -

- (void) addStatusBarItem {
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	_statusItem.title = @"A";
	_statusItem.highlightMode = YES;
	_statusItem.target = self;
	_statusItem.action = @selector(showPopover:);
}

- (void) removeStatusBarItem {
	[_popover close];

	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	_statusItem = nil;
	_popover = nil;
}

- (void) refreshStatusBarItem {
	[self removeStatusBarItem];
	[self addStatusBarItem];
}

- (void) prepareStatusItemForRule:(MPHRule *) rule {
	if (rule.service == MPHServiceMUNI) {

	} else if (rule.service == MPHServiceBART) {

	} else if (rule.service == MPHServiceCaltrain) {

	} else { // 
		
	}
}
@end
