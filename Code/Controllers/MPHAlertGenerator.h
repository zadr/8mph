#import <Foundation/Foundation.h>

extern NSString *const MPHAlertMachineIdentifierKey;
extern NSString *const MPHAlertTitleKey;
extern NSString *const MPHAlertMessageKey;
extern NSString *const MPHAlertTypeKey;
extern NSString *const MPHAlertUserInfoKey;

extern NSString *const MPHPopoverAlertTypeKey;

extern NSString *const MPHAudioAlertTypeKey;
extern NSString *const MPHAudioAlertFileKey;
extern NSString *const MPHAudioAlertVolumeKey; // NSNumber, CGFloat
extern NSString *const MPHAudioAlertRepeatsKey; // NSNumber, BOOL

extern NSString *const MPHVoiceoverAlertTypeKey;
extern NSString *const MPHVoiceoverVoiceKey;
extern NSString *const MPHVoiceoverVolumeKey; // NSNumber, CGFloat
extern NSString *const MPHVoiceoverAlertRepeatsKey; // NSNumber, BOOL

extern NSString *const MPHNotificationAlertTypeKey;

extern NSString *const MPHScriptAlertTypeKey;
extern NSString *const MPHScriptAlertPathKey;
extern NSString *const MPHScriptAlertEnvironmentVariablesKey;

extern NSString *const MPHFlashAlertTypeKey;
extern NSString *const MPHFlashAlertColorKey; // NSDictionary
  extern NSString *const MPHFlashAlertColorRedKey; // NSNumber, CGFloat 0.0 - 1.0
  extern NSString *const MPHFlashAlertColorBlueKey; // NSNumber, CGFloat 0.0 - 1.0
  extern NSString *const MPHFlashAlertColorGreenKey; // NSNumber, CGFloat 0.0 - 1.0
  extern NSString *const MPHFlashAlertColorAlphaKey; // NSNumber, CGFloat 0.0 - 1.0
extern NSString *const MPHFlashAlertDurationKey; // NSNumber, CGFloat
extern NSString *const MPHFlashAlertWindowKey; // NSNumer, CGFloat, -1 is all windows
extern NSString *const MPHFlashAlertBehindForegroundWindowKey; // NSNumer, BOOL

extern NSString *const MPHDockAlertTypeKey;
extern NSString *const MPHDockBounceKey;
extern NSString *const MPHDockBounceRepeatsKey;
extern NSString *const MPHDockBadgeKey;
extern NSString *const MPHDockIconKey;

@interface MPHAlertGenerator : NSObject <NSSoundDelegate>
+ (instancetype) sharedInstance;

- (BOOL) popupAlertWithInformation:(NSDictionary *) information;
- (BOOL) audioAlertWithInformation:(NSDictionary *) information;
- (BOOL) voiceoverAlertWithInformation:(NSDictionary *) information;
- (BOOL) notificationAlertWithInformation:(NSDictionary *) information;
- (BOOL) scriptAlertWithInformation:(NSDictionary *) information;
- (BOOL) flashScreenAlertWithInformation:(NSDictionary *) information;
- (BOOL) dockAlertWithInformation:(NSDictionary *) information;

- (BOOL) displayAlertsWithInformation:(NSDictionary *) information;

@property (nonatomic, readonly) NSArray *ongoingAlerts; // keeps track of the `information` dictionary passed in while an alert is running

- (void) endAlerts;
@end
