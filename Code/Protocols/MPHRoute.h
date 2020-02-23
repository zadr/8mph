#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

#import "MPHDefines.h"

@protocol MPHRoute <NSObject, NSCopying>
@required
- (NSString *) tag;
- (NSString *) name;
- (MPHService) service;
- (NSInteger) rowID;

@optional
#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
- (NSColor *) color;
+ (NSColor *) colorFromRouteTag:(NSString *) tag;
#else
- (UIColor *) color;
+ (UIColor *) colorFromRouteTag:(NSString *) tag;
#endif
@end

