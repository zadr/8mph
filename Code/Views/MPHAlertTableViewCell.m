#import "MPHAlertTableViewCell.h"

#import "MPHAlertTableCellContentView.h"
#import "MPHTimesTableCellContentView.h"

@implementation MPHAlertTableViewCell {
	NSViewController *_alertCellViewController;
	NSViewController *_timeCellViewController;
}

- (id) initWithCoder:(NSCoder *) aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;

	_alertCellViewController = [[NSViewController alloc] initWithNibName:@"MPHAlertTableCellContentView" bundle:nil];
	_timeCellViewController = [[NSViewController alloc] init];
	_timeCellViewController.view = [[MPHTimesTableCellContentView alloc] initWithFrame:NSZeroRect];

	return self;
}

- (void) awakeFromNib {
	[self addSubview:_alertCellViewController.view];
}

- (void) setFrame:(NSRect) frameRect {
	[super setFrame:frameRect];

	_alertCellViewController.view.frame = frameRect;
	_timeCellViewController.view.frame = frameRect;
}

#pragma mark -

- (MPHAlertTableCellContentView *) alertContentView {
	return (MPHAlertTableCellContentView *)_alertCellViewController.view;
}

- (MPHTimesTableCellContentView *) timesContentView {
	return (MPHTimesTableCellContentView *)_timeCellViewController.view;
}

#pragma mark -

- (NSImage *) logo {
	return self.alertContentView.logoImageView.image;
}

- (void) setLogo:(NSImage *) logo {
	self.alertContentView.logoImageView.image = logo;
}

- (NSString *) routeStop {
	return self.alertContentView.routeStopTextField.stringValue;
}

- (void) setRouteStop:(NSString *) routeStop {
	self.alertContentView.routeStopTextField.stringValue = routeStop;
}

- (NSString *) time {
	return self.alertContentView.timeTextField.stringValue;
}

- (void) setTime:(NSString *) time {
	self.alertContentView.timeTextField.stringValue = time;
}

- (NSDictionary *) predictions {
	return self.timesContentView.predictions;
}

- (void) setPredictions:(NSDictionary *) predictions {
	self.timesContentView.predictions = predictions;
}

#pragma mark -

- (void) swipeWithEvent:(NSEvent *) event {
	// 
}
@end
