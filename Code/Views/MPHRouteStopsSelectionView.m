#import "MPHRouteStopsSelectionView.h"

#define MPHRoutePadding 30.

@implementation MPHRouteStopsSelectionView
//- (BOOL) isFlipped {
//	return YES;
//}
//
//- (void) setFrame:(NSRect) frameRect {
//	if (!self.window.frame.size.width || !self.window.frame.size.height) {
//		[super setFrame:frameRect];
//		return;
//	}
//
//	frameRect = self.window.frame;
//
//	if (!frameRect.size.width || !frameRect.size.height)
//		return;
//
//	frameRect.origin = CGPointZero;
//
//	[super setFrame:frameRect];
//
//	CGFloat leftPercent = fmod((_mapView.frame.size.width / _splitView.frame.size.width), 1);
//	CGFloat rightPercent = fmodf((_outlineView.frame.size.width / _splitView.frame.size.width), 1);
//
//	if (leftPercent < 0. && rightPercent > 0.)
//		leftPercent = (100. - rightPercent) - 1.;
//	else if (leftPercent > 0. && rightPercent < 0.)
//		rightPercent = (100. - leftPercent) - 1.;
//	else if (leftPercent < 0. && rightPercent < 0.)
// 		return;
//
//	NSRect rect = _splitView.frame;
//	rect.size.width = frameRect.size.width - (_splitView.frame.origin.x * 2);
//	rect.size.height = frameRect.size.height - (_splitView.frame.origin.x * 2);
//	_splitView.frame = rect;
//
//	rect = _mapView.frame;
//	rect.size.height = _splitView.frame.size.height;
//	rect.size.width = (_splitView.frame.size.width * leftPercent);
//	_mapView.frame = rect;
//
//	rect = _outlineView.frame;
//	rect.size.height = _splitView.frame.size.height;
//	rect.size.width = (_splitView.frame.size.width * rightPercent);
//	_outlineView.frame = rect;
//
//	[_splitView adjustSubviews];
//}
@end
