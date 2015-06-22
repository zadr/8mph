#import "MPHRulesTimeSelectionView.h"

#import "MPHDatePicker.h"

@implementation MPHRulesTimeSelectionView
- (void) awakeFromNib {
	[super awakeFromNib];

	_fromTextView.delegate = _fromTextView;
	_toTextView.delegate = _toTextView;

	[self centerTextView:_fromTextView];
	[self centerTextView:_toTextView];
}

- (void) centerTextView:(NSTextView *) textView {
	NSRect textRect = [textView.layoutManager boundingRectForGlyphRange:textView.selectedRange inTextContainer:textView.textContainer];
	NSSize containerInset = textView.textContainerInset;
	containerInset.height = ((NSMaxY(textView.frame) - NSMaxY(textRect)) / 2.);
	containerInset.height -= log10(containerInset.height);

	textView.textContainerInset = containerInset;
}
@end
