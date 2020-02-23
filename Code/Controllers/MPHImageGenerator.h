#import <UIKit/UIKit.h>

extern NSString *const MPHImageFillColor; // UIColor, default black
extern NSString *const MPHImageStrokeColor; // UIColor, default clear
extern NSString *const MPHImageStrokeWidth; // NSNumber, default 0
extern NSString *const MPHImageText; // NSString, default nil
extern NSString *const MPHImageTextColor; // UIColor, default white
extern NSString *const MPHImageRadius; // NSNumber, required
extern NSString *const MPHImageFont; // UIFont, default system font + system font size

@interface MPHImageGenerator : NSObject
- (UIImage *) generateImageWithParameters:(NSDictionary *) parameters;
- (void) generateImageWithParameters:(NSDictionary *) parameters completionHandler:(void (^)(UIImage *)) completionHandler;
@end
