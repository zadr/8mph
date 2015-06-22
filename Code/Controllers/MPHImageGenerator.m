#import "MPHImageGenerator.h"

// #define USE_CGCONTEXT 1

NSString *const MPHImageFillColor = @"fill";
NSString *const MPHImageStrokeColor = @"stroke";
NSString *const MPHImageStrokeWidth = @"stroke-width";
NSString *const MPHImageText = @"text";
NSString *const MPHImageTextColor = @"text-color";
NSString *const MPHImageRadius = @"radius";
NSString *const MPHImageFont = @"font";

@implementation MPHImageGenerator {
	NSOperationQueue *_queue;
	CGColorSpaceRef _colorSpace;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_queue = [[NSOperationQueue alloc] init];
	_queue.maxConcurrentOperationCount = 1;
	_colorSpace = CGColorSpaceCreateDeviceRGB();

	return self;
}

#pragma mark -

- (UIImage *) _generateImageWithParameters:(NSDictionary *) parameters {
	NSNumber *radiusValue = parameters[MPHImageRadius];
	if (!radiusValue) {
		return nil;
	}

	CGFloat strokeWidth = ([parameters[MPHImageStrokeWidth] doubleValue] / 2.) ?: 0.;
	CGFloat radius = radiusValue.doubleValue + strokeWidth;
	CGFloat width = radius;

	UIImage *image = nil;
#ifdef USE_CGCONTEXT
	CGContextRef contextRef = CGBitmapContextCreate(NULL, width, width, 8, width * 4, _colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	CGContextTranslateCTM(contextRef, 0.0, width);
	CGContextScaleCTM(contextRef, 1.0, -1.0);
	UIGraphicsPushContext(contextRef);
#else
	CGSize size = CGSizeMake(width + (strokeWidth / 2.) + (strokeWidth / 4.), width + (strokeWidth / 2.) + (strokeWidth / 4.));
	UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale * 2.);
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
#endif
	{
		CGRect ellipsesRect = CGRectMake((strokeWidth / 2.) + (strokeWidth / 16.) + (strokeWidth / 32), (strokeWidth / 2.) + (strokeWidth / 16.) + (strokeWidth / 32.), width, width);
		ellipsesRect.size.width -= (strokeWidth / 2.) - (strokeWidth / 16.);
		ellipsesRect.size.height -= (strokeWidth / 2.) - (strokeWidth / 16.);

		CGContextSetAllowsAntialiasing(contextRef, true);
		CGContextSetShouldAntialias(contextRef, true);

		UIColor *fillColor = parameters[MPHImageFillColor] ?: [UIColor blackColor];
		CGContextSetFillColorWithColor(contextRef, fillColor.CGColor);
		CGContextFillEllipseInRect(contextRef, ellipsesRect);

		UIColor *strokeColor = parameters[MPHImageStrokeColor];
		if (strokeColor) {
			CGContextSetLineWidth(contextRef, strokeWidth);
			CGContextSetStrokeColorWithColor(contextRef, strokeColor.CGColor); NSLog(@"%@", strokeColor.CGColor);
			CGContextStrokeEllipseInRect(contextRef, ellipsesRect);
		}

		NSString *text = parameters[MPHImageText];
		if (text.length) {
			UIFont *font = parameters[MPHImageFont] ?: [UIFont systemFontOfSize:[UIFont systemFontSize]];

			CGContextSetAllowsFontSmoothing(contextRef, true);
			CGContextSetShouldSmoothFonts(contextRef, true);

			CGContextSetAllowsFontSubpixelPositioning(contextRef, true);
			CGContextSetShouldSubpixelPositionFonts(contextRef, true);

			CGContextSetAllowsFontSubpixelQuantization(contextRef, true);
			CGContextSetShouldSubpixelQuantizeFonts(contextRef, true);

			CGSize textSize = [text sizeWithAttributes:@{ NSFontAttributeName: [font fontWithSize:(font.pointSize / 2.)] }];
			CGPoint center = CGPointMake((CGRectGetWidth(ellipsesRect) / 2.) - (textSize.width / 2.), (CGRectGetHeight(ellipsesRect) / 2.) - (textSize.height / 2.));
			center.x += (strokeWidth / 2.) + (strokeWidth / 8.);
			center.y += (strokeWidth / 2.) + (strokeWidth / 8.) - (strokeWidth / 32.);

			[text drawAtPoint:center withAttributes:@{
				NSFontAttributeName: [font fontWithSize:(font.pointSize / 2.)],
				NSForegroundColorAttributeName: (parameters[MPHImageTextColor] ?: [UIColor whiteColor])
			}];
		}

		CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
		image = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
	}
#ifdef USE_CGCONTEXT
	UIGraphicsPopContext();
#else
	UIGraphicsEndImageContext();
#endif

	return image;
}

#pragma mark -

- (UIImage *) generateImageWithParameters:(NSDictionary *) parameters {
	return [self _generateImageWithParameters:parameters];
}

- (void) generateImageWithParameters:(NSDictionary *) parameters completionHandler:(void (^)(UIImage *)) completionHandler {
	if (!completionHandler)
		return;

	[_queue addOperationWithBlock:^{
		completionHandler([self _generateImageWithParameters:parameters]);
	}];
}
@end
