#import "MPHCircleView.h"

#import <QuartzCore/QuartzCore.h>

@implementation MPHCircleView {
	CAShapeLayer *_circleLayer;
}

@synthesize textLabel = _textLabel;

- (id) initWithFrame:(CGRect) frame {
	if (!(self = [super initWithFrame:frame]))
		return nil;

	[self _mph_commonInitialization];

	return self;
}

- (id) initWithCoder:(NSCoder *) coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;

	[self _mph_commonInitialization];

	return self;
}

- (void) _mph_commonInitialization {
	_circleLayer = [CAShapeLayer layer];
	_circleLayer.frame = self.bounds;

	[self _updateShapeLayerForFrame:self.bounds];
	[self.layer addSublayer:_circleLayer];

	self.fillColor = [UIColor blackColor];
}

#pragma mark -

- (void) setFrame:(CGRect) frame {
	[super setFrame:frame];

	_circleLayer.frame = self.bounds;

	[self _updateShapeLayerForFrame:frame];
}

- (UILabel *) textLabel {
	if (_textLabel)
		return _textLabel;

	_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[_textLabel addObserver:self forKeyPath:NSStringFromSelector(@selector(text)) options:NSKeyValueObservingOptionNew context:NULL];
	[_textLabel addObserver:self forKeyPath:NSStringFromSelector(@selector(font)) options:NSKeyValueObservingOptionNew context:NULL];

	[self addSubview:_textLabel];

	return _textLabel;
}

- (void) setStrokeWidth:(CGFloat) strokeWidth {
	_circleLayer.lineWidth = strokeWidth;
}

- (CGFloat) strokeWidth {
	return _circleLayer.lineWidth;
}

- (void) setStrokeColor:(UIColor *) strokeColor {
	_circleLayer.strokeColor = strokeColor.CGColor;
}

- (UIColor *) strokeColor {
	return [UIColor colorWithCGColor:_circleLayer.strokeColor];
}

- (void) setFillColor:(UIColor *) fillColor {
	_circleLayer.fillColor = fillColor.CGColor;
}

- (UIColor *) fillColor {
	return [UIColor colorWithCGColor:_circleLayer.fillColor];
}

#pragma mark -

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
	[_textLabel sizeToFit];

	[self setNeedsLayout];
}

- (void) layoutSubviews {
	[super layoutSubviews];

	CGRect frame = _textLabel.frame;
	frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(_textLabel.frame)) / 2.;
	frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(_textLabel.frame)) / 2.;
	_textLabel.frame = frame;
}

#pragma mark -

- (void) _updateShapeLayerForFrame:(CGRect) frame {
	_circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0., 0., frame.size.width, frame.size.height)].CGPath;
}
@end
