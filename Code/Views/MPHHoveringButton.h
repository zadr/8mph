@class MPHHoveringButton;

@protocol MPHHovering <NSObject>
@optional
- (void) didBeginHoveringOverButton:(MPHHoveringButton *) hoveringButton;
- (void) didEndHoveringOverButton:(MPHHoveringButton *) hoveringButton;
@end

@interface MPHHoveringButton : NSButton
@property (nonatomic, weak) IBOutlet id <MPHHovering> delegate;
@end
