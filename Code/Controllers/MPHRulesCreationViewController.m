#import "MPHRulesCreationViewController.h"

#import "MPHServiceSelectionViewController.h"
#import "MPHRouteStopsSelectionViewController.h"
#import "MPHRulesTimeSelectionViewController.h"
#import "MPHAlertTypeSelectionViewController.h"

#import "MPHLocationCenter.h"

#import "MPHRule.h"
#import "MPHDateRange.h"

#import "MPHRoute.h"

static NSString *const MPHRuleIdentifierService = @"service"; // NSNumber of MPHService
static NSString *const MPHRuleIdentifierRoute = @"route"; // id <MPHRoute>
static NSString *const MPHRuleIdentifierTimeDate = @"time-date"; // NSArray of MPHDateRange
static NSString *const MPHRuleIdentifierAlertType = @"alert-type"; // NSArray of NSDictionaries

enum {
	MPHPageService,
	MPHPageRouteStop,
	MPHPageTimeDate,
	MPHPageAlerts
};

@interface MPHRulesCreationViewController () <MPHServiceSelectionDelegate, MPHRouteStopsSelectionDelegate, MPHRulesTimeSelectionDelegate>
@end

@implementation MPHRulesCreationViewController {
	MPHAlertTypeSelectionViewController *_alertTypeSelectionViewController;
	MPHRouteStopsSelectionViewController *_routeStopsSelectionViewController;
	MPHServiceSelectionViewController *_serviceSelectionViewController;
	MPHRulesTimeSelectionViewController *_rulesTimeSelectionViewController;
}

- (id) init {
	return (self = [super initWithWindowNibName:@"MPHRulesCreationViewController"]);
}

#pragma mark -

- (void) awakeFromNib {
	[super awakeFromNib];

	_pageController.arrangedObjects = @[MPHRuleIdentifierService, MPHRuleIdentifierRoute, MPHRuleIdentifierTimeDate, MPHRuleIdentifierAlertType];
}

- (NSSize) windowWillResize:(NSWindow *) window toSize:(NSSize) newSize {
//	if (_pageController.selectedViewController == _serviceSelectionViewController)
		return window.frame.size;
//	return newSize;
}

#pragma mark -

- (void) setRule:(MPHRule *) rule {
	_rule = rule;

	if (rule.service == MPHServiceNone)
		_pageController.selectedIndex = MPHPageService;
	else _pageController.selectedIndex = MPHPageRouteStop;

	_pageController.selectedViewController.representedObject = _rule;
}

#pragma mark -

- (IBAction) navigateForward:(id) sender {
	if (_pageController.selectedIndex == MPHPageService) {
		if (_rule.service != MPHServiceNone)
			[_pageController navigateForward:sender];
	} else if (_pageController.selectedIndex == MPHPageRouteStop) {
		if (_rule.routes.count)
			[_pageController navigateForward:sender];
	} else if (_pageController.selectedIndex == MPHPageTimeDate) {
		[_pageController navigateForward:sender];
	} else if (_pageController.selectedIndex == MPHPageAlerts) {
		if (_alertTypeSelectionViewController.alerts.count) {
			_rule.alerts = _alertTypeSelectionViewController.alerts;

			[[NSApplication sharedApplication] endSheet:self.window returnCode:NSRunContinuesResponse];
		}
	}
}

- (IBAction) navigateBackward:(id) sender {
	if (_pageController.selectedIndex == 0)
		[[NSApplication sharedApplication] endSheet:self.window returnCode:NSRunStoppedResponse];
	else [_pageController navigateBack:sender];
}

#pragma mark -

- (void) serviceSelectionViewController:(MPHServiceSelectionViewController *) serviceSelectionViewController didSelectService:(MPHService) service {
	_rule.service = service;

	[_pageController navigateForward:nil];
}

#pragma mark -

- (void) routeStopsSelectionViewController:(MPHRouteStopsSelectionViewController *) routeStopsSelectionViewController didSelectStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route {
	[_rule addStop:stop onRoute:route];
}

- (void) routeStopsSelectionViewController:(MPHRouteStopsSelectionViewController *) routeStopsSelectionViewController didDeselectStop:(id <MPHStop>) stop onRoute:(id <MPHRoute>) route {
	[_rule removeStop:stop onRoute:route];
}

#pragma mark -

- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectDay:(MPHRuleDays) day {
	_rule.range.days ^= day;
}

- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didDeselectDay:(MPHRuleDays) day {
	_rule.range.days ^= day;
}

- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectStartTimeWithHours:(NSTimeInterval) hours minutes:(NSTimeInterval) minutes pm:(BOOL) amOrPM {
	if (amOrPM)
		hours += 12;

	_rule.range.hours = hours;
	_rule.range.minutes = minutes;
}

- (void) rulesTimeSelectionViewController:(MPHRulesTimeSelectionViewController *) rulesTimeSelectionViewController didSelectEndTimeWithHours:(NSTimeInterval) hours minutes:(NSTimeInterval) minutes pm:(BOOL) amOrPM {
	if (amOrPM)
		hours += 12;

	_rule.range.duration = ((hours - _rule.range.hours) * 3600) + ((minutes - _rule.range.minutes) * 60);;
}

#pragma mark -

- (NSString *) pageController:(NSPageController *) pageController identifierForObject:(id) object {
	return object;
}

- (NSViewController *) pageController:(NSPageController *) pageController viewControllerForIdentifier:(NSString *) identifier {
	if (identifier == MPHRuleIdentifierAlertType) {
		if (!_alertTypeSelectionViewController)
			_alertTypeSelectionViewController = [[MPHAlertTypeSelectionViewController alloc] init];
		return _alertTypeSelectionViewController;
	}

	if (identifier == MPHRuleIdentifierRoute) {
		if (!_routeStopsSelectionViewController) {
			_routeStopsSelectionViewController = [[MPHRouteStopsSelectionViewController alloc] init];
			_routeStopsSelectionViewController.delegate = self;
		}
		return _routeStopsSelectionViewController;
	}

	if (identifier == MPHRuleIdentifierService) {
		if (!_serviceSelectionViewController) {
			_serviceSelectionViewController = [[MPHServiceSelectionViewController alloc] init];
			_serviceSelectionViewController.delegate = self;
		}

		return _serviceSelectionViewController;
	}

	if (identifier == MPHRuleIdentifierTimeDate) {
		if (!_rulesTimeSelectionViewController) {
			_rulesTimeSelectionViewController = [[MPHRulesTimeSelectionViewController alloc] init];
			_rulesTimeSelectionViewController.delegate = self;
		}
		return _rulesTimeSelectionViewController;
	}

	MPHUnreachable
}

- (void) pageController:(NSPageController *) pageController prepareViewController:(NSViewController *) viewController withObject:(id) object {
	viewController.representedObject = _rule;

	self.window.showsResizeIndicator = [self pageController:pageController identifierForObject:object] != MPHRuleIdentifierService;
}

- (void) pageControllerDidEndLiveTransition:(NSPageController *) pageController {
	[pageController completeTransition];
}
@end
