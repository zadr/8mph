@interface UIScreen (Additions)
@property (nonatomic, readonly) CGSize orientedSize; // based on screenMin and screenMax

- (CGSize) sizeForOrientation:(UIInterfaceOrientation) orientation;
@end
