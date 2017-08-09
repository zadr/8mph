#import "MPHAlertTableViewController.h"

#import "MPHTableViewCell.h"

#import "MPHMessage.h"
#import "MPHStop.h"

#import "MPHAmalgamator.h"
#import "MPHAmalgamation.h"

@implementation MPHAlertTableViewController {
	MPHMessage *_message;
}

- (id) initWithMessage:(MPHMessage *) message {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_message = message;

	if (_message.affectedLines.count == 1)
		self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ - Notices", @"%@ (line) - Notices"), [_message.affectedLines lastObject]];
	else self.title = NSLocalizedString(@"Notices", @"Notices view title");

	return self;
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
	return _message.affectedLines.count;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	return [[MPHAmalgamator amalgamator] stopsForMessage:_message onRouteTag:_message.affectedLines[section]].count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	id <MPHStop> stop = [[MPHAmalgamator amalgamator] stopsForMessage:_message onRouteTag:_message.affectedLines[indexPath.section]][indexPath.row];
	cell.textLabel.text = stop.name;

	return cell;
}

#pragma mark -

- (NSString *) _titleForHeaderInSection:(NSInteger) section {
	NSMutableString *string = [NSMutableString string];
	if (section == 0) {
		[string appendString:_message.text];
		if (_message.affectedLines.count > 1)
			[string appendFormat:@"\n\n%@", _message.affectedLines[section]];
	} else {
		if (_message.affectedLines.count > 1)
			[string appendString:_message.affectedLines[section]];
	}

	return [string copy];
}

- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
		headerView.textLabel.numberOfLines = 0;
	}

	headerView.textLabel.text = [self _titleForHeaderInSection:section];

    return headerView;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section {
    CGFloat width = CGRectGetWidth(tableView.frame) - 15.;;
	CGSize size = [[self _titleForHeaderInSection:section] boundingRectWithSize:CGSizeMake(width, 90000) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:18.] } context:nil].size;

    return fmax(size.height, section ? 38. : self.tableView.rowHeight);
}

@end
