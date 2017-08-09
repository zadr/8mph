#import "MPHRulesTableController.h"

#import "MPHRulesCreationViewController.h"
#import "MPHRulesController.h"

#import "MPHAlertTableViewCell.h"

#import "MPHRule.h"
#import "MPHDateRange.h"

#import "MPHRoute.h"
#import "MPHStop.h"

typedef void (^MPHRuleChangedBlock)(void);

typedef NS_ENUM(NSInteger, MPHAlertItem) {
	MPHAddAlertItem = 1,
	MPHPauseAlertItem = 2
};

typedef NS_ENUM(NSInteger, MPHMenuItem) {
	MPHEditMenuItem = 1,
	MPHPauseMenuItem = 2,
	MPHDeleteMenuItem = 3
};

@interface MPHRulesTableController ()
@property (nonatomic, copy) MPHRuleChangedBlock changedBlock;
@end

@implementation MPHRulesTableWindowController {
	MPHRulesCreationViewController *_creationViewController;
}

- (id) init {
	return (self = [super initWithWindowNibName:@"MPHRulesTableWindowController" owner:self]);
}

- (void) awakeFromNib {
	[super awakeFromNib];

	_rulesTableViewController = [[MPHRulesTableViewController alloc] init];
	[self.window.contentView addSubview:_rulesTableViewController.view];
	_rulesTableViewController.view.frame = [self.window.contentView frame];

	__weak typeof(self) weakSelf = self;
	_rulesTableViewController.rulesTableController.changedBlock = ^{
		__strong typeof(self) strongSelf = weakSelf;

		[strongSelf validateToolbarItems];
	};
}

#pragma mark -

- (IBAction) addAlert:(id) sender {
	if (!_creationViewController)
		_creationViewController = [[MPHRulesCreationViewController alloc] init];

	_creationViewController.rule = [[MPHRule alloc] init];

	[[NSApplication sharedApplication] beginSheet:_creationViewController.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)self];
}

- (IBAction) editAlert:(id) sender {
	NSInteger mph_choosenRow = _rulesTableViewController.rulesTableController.tableView.mph_chosenRow;
	if (mph_choosenRow == -1)
		return;

	if (!_creationViewController)
		_creationViewController = [[MPHRulesCreationViewController alloc] init];

	_creationViewController.rule = [MPHRulesController rulesController].rules[mph_choosenRow];

	[[NSApplication sharedApplication] beginSheet:_creationViewController.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)self];
}

- (IBAction) showRules:(id) sender {
	[self.window makeKeyAndOrderFront:sender];
}

#pragma mark -

- (void) sheetDidEnd:(NSWindow *) sheet returnCode:(NSInteger) returnCode contextInfo:(void *) contextInfo {
	[sheet orderOut:nil];

	if (returnCode == NSRunStoppedResponse)
		return;

	[[MPHRulesController rulesController] addRule:_creationViewController.rule];

	[_rulesTableViewController.rulesTableController.tableView reloadData];
}

#pragma mark -

- (void) validateToolbarItems {
	for (NSToolbarItem *item in _toolbar.items)
		[self validateToolbarItem:item];
}

- (BOOL) validateToolbarItem:(NSToolbarItem *) item {
	item.target = _rulesTableViewController.rulesTableController;

	NSInteger choosenRow = _rulesTableViewController.rulesTableController.tableView.selectedRow;
	if (choosenRow == -1) {
		if (item.tag == MPHAddAlertItem) {
			item.target = self;
			item.action = @selector(addAlert:);
			item.label = NSLocalizedString(@"Add Alert", @"Add Alert toolbar item title");
		} else if (item.tag == MPHPauseAlertItem) {
			__block BOOL hasEnabledRule = NO;
			[[MPHRulesController rulesController].rules enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
				MPHRule *rule = (MPHRule *)object;
				if (rule.enabled) {
					hasEnabledRule = YES;

					*stop = YES;
				}
			}];

			if (hasEnabledRule) {
				item.action = @selector(pauseAlerts:);
				item.label = NSLocalizedString(@"Pause Alerts", @"Pause Alerts toolbar item title");
			} else {
				item.action = @selector(resumeAlerts:);
				item.label = NSLocalizedString(@"Resume Alerts", @"Resume Alerts toolbar item title");
			}
		}

		return YES;
	}

	if (item.tag == MPHAddAlertItem) {
		item.action = @selector(deleteAlert:);
		item.label = NSLocalizedString(@"Remove Alert", @"Remove Alert toolbar item title");
	} else if (item.tag == MPHPauseAlertItem) {
		MPHRule *rule = nil;
		if (choosenRow >= (NSInteger)[MPHRulesController rulesController].rules.count)
			return YES;

		rule = [MPHRulesController rulesController].rules[choosenRow];

		if (rule.enabled) {
			item.action = @selector(pauseAlert:);
			item.label = NSLocalizedString(@"Pause Alert", @"Pause Alert toolbar item title");
		} else {
			item.action = @selector(resumeAlert:);
			item.label = NSLocalizedString(@"Resume Alert", @"Resume Alert toolbar item title");
		}
	}
	
	return YES;
}
@end

#pragma mark -

@implementation MPHRulesTableViewController
- (void) loadView {
	MPHRulesTableController *rulesTableController = nil;
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"MPHRulesTableController" bundle:nil];

	NSArray *topLevelObjects = nil;
	[nib instantiateWithOwner:self topLevelObjects:&topLevelObjects];

	for (id object in topLevelObjects) {
		if ([object isKindOfClass:[MPHRulesTableController class]]) {
			rulesTableController = object;
			break;
		}
	}

	self.view = rulesTableController;
}

- (MPHRulesTableController *) rulesTableController {
	return (MPHRulesTableController *)self.view;
}
@end

#pragma mark -

@implementation MPHRulesTableController
- (void) setChangedBlock:(MPHRuleChangedBlock) changedBlock {
	_changedBlock = [changedBlock copy];

	if (_changedBlock) _changedBlock();
}

#pragma mark -

- (IBAction) pauseAlert:(id) sender {
	NSInteger mph_choosenRow = self.tableView.mph_chosenRow;
	if (mph_choosenRow == -1)
		return;

	MPHRule *rule = [MPHRulesController rulesController].rules[mph_choosenRow];
	rule.enabled = NO;

	[self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:mph_choosenRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
	if (self.changedBlock) self.changedBlock();
}

- (IBAction) pauseAlerts:(id) sender {
	for (MPHRule *rule in [MPHRulesController rulesController].rules)
		rule.enabled = NO;

	[self.tableView reloadData];
	if (self.changedBlock) self.changedBlock();
}

- (IBAction) deleteAlert:(id) sender {
	NSInteger mph_choosenRow = self.tableView.mph_chosenRow;
	if (mph_choosenRow == -1)
		return;

	[[MPHRulesController rulesController] removeRuleAtIndex:mph_choosenRow];
	[self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:mph_choosenRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
	if (self.changedBlock) self.changedBlock();
}

- (IBAction) resumeAlert:(id) sender {
	NSInteger mph_choosenRow = self.tableView.mph_chosenRow;
	if (mph_choosenRow == -1)
		return;

	MPHRule *rule = [MPHRulesController rulesController].rules[mph_choosenRow];
	rule.enabled = YES;

	[self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:mph_choosenRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
	if (self.changedBlock) self.changedBlock();
}

- (IBAction) resumeAlerts:(id) sender {
	for (MPHRule *rule in [MPHRulesController rulesController].rules)
		rule.enabled = YES;

	[self.tableView reloadData];
	if (self.changedBlock) self.changedBlock();
}

#pragma mark -

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	return [MPHRulesController rulesController].rules.count;
}

- (NSView *) tableView:(NSTableView *) tableView viewForTableColumn:(NSTableColumn *) tableColumn row:(NSInteger) row {
	MPHAlertTableViewCell *tableViewCell = [tableView makeViewWithIdentifier:@"AlertCell" owner:self];

	MPHRule *rule = [MPHRulesController rulesController].rules[row];
	NSString *separator = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleGroupingSeparator];

	// stops and lines
	NSMutableString *lines = [NSMutableString string];
	for (id <MPHStop> stop in rule.stops) {
		for (id <MPHRoute> route in [rule routesForStop:stop])
			[lines appendFormat:@"%@%@ ", route.tag, separator];
		[lines deleteCharactersInRange:NSMakeRange(lines.length - 2, 2)];
		[lines appendFormat:@" at %@\n", stop.name];
	}
	[lines deleteCharactersInRange:NSMakeRange(lines.length - 1, 1)];
	tableViewCell.routeStop = lines;

	// days and times
	NSMutableString *days = [NSStringFromRuleDays(rule.range.days, NSDateFormatterFullStyle) mutableCopy];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.hour = rule.range.hours;
	components.minute = rule.range.minutes;
	components.timeZone = [NSTimeZone systemTimeZone];

	static NSDateFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterNoStyle;
		formatter.timeStyle = NSDateFormatterShortStyle;
	}

	NSDate *date = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
	NSString *startTime = [formatter stringFromDate:date];
	NSString *endTime = [formatter stringFromDate:[date dateByAddingTimeInterval:rule.range.duration]];

	[days appendFormat:NSLocalizedString(@" from %@ to %@" , @"from time to time"), startTime, endTime];

	tableViewCell.time = days;

	// service
//	if (self.tableView.selectedRow == row) {
//		if (rule.service == MPHServiceMUNI)
//			tableViewCell.logoImageView.image = [NSImage imageNamed:@"muni-white"];
//		else if (rule.service == MPHServiceBART)
//			tableViewCell.logoImageView.image = [NSImage imageNamed:@"bart-white"];
//		else if (rule.service == MPHServiceCaltrain)
//			tableViewCell.logoImageView.image = [NSImage imageNamed:@"caltrain-white"];
//	} else {
		if (rule.service == MPHServiceMUNI)
			tableViewCell.logo = [NSImage imageNamed:@"muni"];
		else if (rule.service == MPHServiceBART)
			tableViewCell.logo = [NSImage imageNamed:@"bart"];
		else if (rule.service == MPHServiceCaltrain)
			tableViewCell.logo = [NSImage imageNamed:@"caltrain"];
//	}

	for (NSView *view in tableViewCell.subviews)
		view.alphaValue = rule.enabled ? 1. : .5;

	return tableViewCell;
}

- (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(NSInteger) row {
	return [MPHRulesController rulesController].rules[row];
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification {
	if (self.changedBlock) self.changedBlock();
}

#pragma mark -

- (BOOL) validateMenuItem:(NSMenuItem *) menuItem {
	menuItem.target = self;

	NSInteger choosenRow = self.tableView.mph_chosenRow;

	if (choosenRow == -1) {
		menuItem.enabled = NO;
		return NO;
	}

	menuItem.enabled = YES;

	if (menuItem.tag == MPHPauseMenuItem) {
		MPHRule *rule = [MPHRulesController rulesController].rules[choosenRow];

		if (rule.enabled) {
			menuItem.action = @selector(pauseAlert:);
			menuItem.title = NSLocalizedString(@"Pause", @"Pause");
		} else {
			menuItem.action = @selector(resumeAlert:);
			menuItem.title = NSLocalizedString(@"Resume", @"Resume");
		}
	}

	return YES;
}
@end
