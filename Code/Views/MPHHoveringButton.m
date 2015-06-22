#import "MPHHoveringButton.h"

@implementation MPHHoveringButton
- (void) awakeFromNib {
    NSTrackingAreaOptions options = (NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside | NSTrackingInVisibleRect);
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:options owner:self userInfo:nil];

    [self addTrackingArea:trackingArea];
}

- (void) mouseEntered:(NSEvent *) event {
	[super mouseEntered:event];

	__strong typeof(_delegate) strongDelegate = _delegate;
	if ([strongDelegate respondsToSelector:@selector(didBeginHoveringOverButton:)])
		[strongDelegate didBeginHoveringOverButton:self];
}

- (void) mouseExited:(NSEvent *) event {
	[super mouseExited:event];

	__strong typeof(_delegate) strongDelegate = _delegate;
	if ([strongDelegate respondsToSelector:@selector(didEndHoveringOverButton:)])
		[strongDelegate didEndHoveringOverButton:self];
}
@end
