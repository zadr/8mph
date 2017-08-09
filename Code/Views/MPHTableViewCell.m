#import "MPHTableViewCell.h"

@implementation MPHTableViewCell {
	NSMutableArray *_routeIconImageViews;
}

- (id) initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *) reuseIdentifier {
	if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
		return nil;

	self.selectionStyle = UITableViewCellSelectionStyleGray;
	self.textLabel.textColor = [UIColor darkTextColor];
	self.textLabel.backgroundColor = [UIColor clearColor];

	_subTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_subTextLabel.textColor = self.textLabel.textColor;
	_subTextLabel.font = [UIFont systemFontOfSize:13.];
	_subTextLabel.backgroundColor = [UIColor clearColor];
	_subTextLabel.highlightedTextColor = self.textLabel.highlightedTextColor;

	self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	self.detailTextLabel.backgroundColor = [UIColor clearColor];

	[self.contentView addSubview:_subTextLabel];

    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];

	if (_subTextLabel.text.length) {
		if (self.frame.size.height > 54.) {
			CGRect frame = self.textLabel.frame;
			frame.origin.y = 8.;
			self.textLabel.frame = frame;
		}

		CGRect frame = _subTextLabel.frame;
		frame.size = [_subTextLabel.text sizeWithAttributes:@{ NSFontAttributeName: _subTextLabel.font }];
		frame.origin.y = (self.textLabel.frame.origin.y + ((self.textLabel.frame.size.height - frame.size.height) / (CGFloat)2.));
		frame.origin.x = (self.contentView.frame.size.width - (self.textLabel.frame.origin.x + frame.size.width));
		_subTextLabel.frame = CGRectIntegral(frame);

		if (CGRectGetMaxX(self.textLabel.frame) > frame.origin.x) {
			frame = self.textLabel.frame;
			frame.size.width = (_subTextLabel.frame.origin.x - frame.origin.x);
			self.textLabel.frame = frame;
		}
	}

	if (_routeIconImageViews.count) {
		CGRect frame = self.textLabel.frame;
		frame.origin.y = 8.;
		self.textLabel.frame = frame;
		CGFloat yOrigin = self.detailTextLabel.text.length > 0 ? CGRectGetMaxY(self.detailTextLabel.frame) : CGRectGetMaxY(self.textLabel.frame);
		yOrigin += 4.;

		frame = [_routeIconImageViews.firstObject frame];
		frame.origin.y = yOrigin;

		NSInteger i = 0;
		for (UIImageView *imageView in _routeIconImageViews) {
			imageView.frame = frame;
			frame.origin.x += (frame.size.width + 4.);

			i++;

			if (i == 10) {
				i = 0;
				frame.origin.x = CGRectGetMinX([_routeIconImageViews.firstObject frame]);
				frame.origin.y += CGRectGetHeight(frame) + 4.;
			}
		}
	}
}

- (void) prepareForReuse {
	[super prepareForReuse];

	_subTextLabel.text = @"";
	self.textLabel.text = @"";
	self.detailTextLabel.text = @"";
	self.textLabel.textColor = [UIColor darkTextColor];
	self.accessoryType = UITableViewCellAccessoryNone;
	self.selectionStyle = UITableViewCellSelectionStyleGray;

	[_routeIconImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_routeIconImageViews removeAllObjects];
}

#pragma mark -

- (void) setRouteIcons:(NSArray *) routeIcons {
	[_routeIconImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	_routeIconImageViews = [NSMutableArray array];

	for (UIImage *routeIcon in routeIcons) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:routeIcon];
		imageView.transform = CGAffineTransformMakeScale(.425, .425);

		[self addSubview:imageView];
		[_routeIconImageViews addObject:imageView];
	}

	[self setNeedsLayout];
}

- (NSArray *) routeIcons {
	return [_routeIconImageViews valueForKey:@"image"];
}
@end
