#import "MPHAlertsTableViewController.h"

#import "MPHAlertTableViewController.h"
#import "MPHImageGenerator.h"

#import "MPHTableViewCell.h"

#import "MPHNextBusRoute.h"
#import "MPHNextBusMessage.h"

static const CGFloat MPHEdgeHorizontalInset = 13.;
static const CGFloat MPHEdgeVerticalInset = 14.;

@implementation MPHAlertsTableViewController {
	NSMutableArray *_alerts;
	NSString *_groupingSeparator;

	NSMutableDictionary *_hiddenAlerts;

	MPHImageGenerator *_imageGenerator;
}

- (id) initWithAlerts:(NSArray *) alerts {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_hiddenAlerts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"alerts"] mutableCopy];
	if (!_hiddenAlerts)
		_hiddenAlerts = [NSMutableDictionary dictionary];

	NSMutableArray *workingAlerts = [alerts mutableCopy];
	for (MPHMessage *message in alerts) {
		NSDictionary *hiddenServiceAlerts = _hiddenAlerts[[NSString stringWithFormat:@"%d", message.service]];

		if (hiddenServiceAlerts[message.identifier])
			[workingAlerts removeObject:message];
		else if (!message.affectedLines.count) {
			[workingAlerts removeObject:message];
			[workingAlerts insertObject:message atIndex:0];
		}
	}

	_alerts = workingAlerts;
	_groupingSeparator = [NSString stringWithFormat:@"%@ ", [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];;
	_imageGenerator = [[MPHImageGenerator alloc] init];

	return self;
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Rider Messages", @"Rider Messages");
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	[self.tableView reloadData];
}

#pragma mark -

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	return _alerts.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell)
		cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	MPHMessage *message = _alerts[indexPath.row];
	cell.textLabel.text = message.text;
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.numberOfLines = 0;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:message.identifier])
		cell.textLabel.textColor = cell.detailTextLabel.textColor;

	if (message.affectedLines.count) {
		if (message.hasDetails)
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		NSMutableArray *images = [NSMutableArray array];
		for (NSString *line in message.affectedLines) {
			UIImage *image = [_imageGenerator generateImageWithParameters:@{
				MPHImageFillColor: [MPHNextBusRoute colorFromRouteTag:[line stringByAppendingString:@"-"]],
				MPHImageText: line,
				MPHImageTextColor: [UIColor whiteColor],
				MPHImageFont: line.length <= 3 ? line.length == 3 ? [UIFont systemFontOfSize:12.] : [UIFont systemFontOfSize:14.] : [UIFont systemFontOfSize:10.],
				MPHImageRadius: @(15.)
			}];

			[images addObject:image];
		}
		cell.routeIcons = images;
	} else if (message.service == MPHServiceMUNI) { // Hark, a hack!
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = NSLocalizedString(@"All Lines", @"All Lines subtitle text");
	}

    return cell;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHMessage *message = _alerts[indexPath.row];

	CGFloat width = CGRectGetWidth(tableView.frame) - (MPHEdgeHorizontalInset * 2);
	if (message.hasDetails)
		width -= (MPHEdgeHorizontalInset * 2);

	CGSize size = [message.text boundingRectWithSize:CGSizeMake(width, 90000) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] } context:nil].size;
	CGSize subSize = CGSizeZero;

	if (message.affectedLines.count) {
		const CGFloat side = 25.5;
		CGFloat numberOfRows = (message.affectedLines.count / 10) + 1;
		CGFloat remainder = message.affectedLines.count % 10;
		subSize = CGSizeMake((numberOfRows > 1 ? 10 : remainder) * side, numberOfRows * side);
	} else subSize = [NSLocalizedString(@"All Lines", @"All Lines subtitle text") boundingRectWithSize:CGSizeMake(width, 90000) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin) attributes:nil context:nil].size;

	return (size.height + subSize.height) + (MPHEdgeVerticalInset * 2);
}

- (NSString *) tableView:(UITableView *) tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *) indexPath {
	return NSLocalizedString(@"Hide", @"Hide button title");
}

- (void) tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHMessage *message = _alerts[indexPath.row];

	NSMutableDictionary *hiddenServiceAlerts = [_hiddenAlerts[[NSString stringWithFormat:@"%d", message.service]] mutableCopy];
	if (!hiddenServiceAlerts) {
		hiddenServiceAlerts = [NSMutableDictionary dictionary];
		_hiddenAlerts[[NSString stringWithFormat:@"%d", message.service]] = hiddenServiceAlerts;
	}
	_hiddenAlerts[[NSString stringWithFormat:@"%d", message.service]] = hiddenServiceAlerts;
	hiddenServiceAlerts[message.identifier] = message.identifier;

	[[NSUserDefaults standardUserDefaults] setObject:_hiddenAlerts forKey:@"alerts"];

	[_alerts removeObjectAtIndex:indexPath.row];

	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:[UIView areAnimationsEnabled]];

	MPHMessage *message = _alerts[indexPath.row];

	if (!message.affectedLines.count || !message.hasDetails)
		return;

	MPHAlertTableViewController *alertTableViewController = [[MPHAlertTableViewController alloc] initWithMessage:message];
	[self.navigationController pushViewController:alertTableViewController animated:[UIView areAnimationsEnabled]];

	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:message.identifier];
}
@end
