#import "MPHHoveringButton.h"

@class MPHHoveringButton;

@interface MPHAlertTypeSelectionView : NSView <MPHHovering>
@property (nonatomic, retain) IBOutlet MPHHoveringButton *popupButton;
@property (nonatomic, retain) IBOutlet MPHHoveringButton *soundButton;
@property (nonatomic, retain) IBOutlet MPHHoveringButton *speakButton;
@property (nonatomic, retain) IBOutlet MPHHoveringButton *notificationButton;
@property (nonatomic, retain) IBOutlet MPHHoveringButton *dockButton;
@property (nonatomic, retain) IBOutlet MPHHoveringButton *runScriptButton;

@property (nonatomic, retain) IBOutlet NSImageView *arrowImageView;

@property (nonatomic, retain) IBOutlet NSView *optionsView;
@end
