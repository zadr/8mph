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

- (BOOL) bordered;
@end
