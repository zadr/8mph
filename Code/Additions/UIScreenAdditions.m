#import "UIScreenAdditions.h"

@implementation UIScreen (Additions)
- (CGFloat) screenMin {
	CGSize screenSize = self.bounds.size;
	return fminf(screenSize.height, screenSize.width);
}

- (CGFloat) screenMax {
	CGSize screenSize = self.bounds.size;
	return fmaxf(screenSize.height, screenSize.width);
}

- (CGSize) orientedSize {
	return [self sizeForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGSize) sizeForOrientation:(UIInterfaceOrientation) orientation {
	if (UIInterfaceOrientationIsLandscape(orientation))
		return CGSizeMake(self.screenMax, self.screenMin);
	return CGSizeMake(self.screenMin, self.screenMax);
}
@end
