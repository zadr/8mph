@interface MPHCircleView : UIView
@property (nonatomic, readonly) UILabel *textLabel;

@property CGFloat strokeWidth; // default: 0
@property (strong) UIColor *strokeColor; // default: nil
@property (strong) UIColor *fillColor; // default: black
@end
