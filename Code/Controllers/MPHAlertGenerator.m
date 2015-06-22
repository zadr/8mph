#import "MPHAlertGenerator.h"

NSString *const MPHAlertMachineIdentifierKey = @"alert-identifier";
NSString *const MPHAlertTitleKey = @"alert-title";
NSString *const MPHAlertMessageKey = @"alert-message";
NSString *const MPHAlertTypeKey = @"alert-type"; // internal use only
NSString *const MPHAlertUserInfoKey = @"alert-user-info";
NSString *const MPHAlertInternalUserInfoKey = @"alert-user-info-internal"; // internal use only

NSString *const MPHPopoverAlertTypeKey = @"popover";

NSString *const MPHAudioAlertTypeKey = @"audio";
NSString *const MPHAudioAlertFileKey = @"audio-file";
NSString *const MPHAudioAlertVolumeKey = @"audio-volume";
NSString *const MPHAudioAlertRepeatsKey = @"audio-repeats";

NSString *const MPHVoiceoverAlertTypeKey = @"voiceover";
NSString *const MPHVoiceoverVoiceKey = @"voiceover-voice";
NSString *const MPHVoiceoverVolumeKey = @"voiceover-volume";
NSString *const MPHVoiceoverAlertRepeatsKey = @"voiceover-repeats"; 

NSString *const MPHNotificationAlertTypeKey = @"notification";

NSString *const MPHScriptAlertTypeKey = @"script";
NSString *const MPHScriptAlertPathKey = @"script-path";
NSString *const MPHScriptAlertEnvironmentVariablesKey = @"MPHScriptAlertEnvironmentVariablesKey";

NSString *const MPHFlashAlertTypeKey = @"flash";
NSString *const MPHFlashAlertColorKey = @"flash-color";
  NSString *const MPHFlashAlertColorRedKey = @"red";
  NSString *const MPHFlashAlertColorBlueKey = @"blue";
  NSString *const MPHFlashAlertColorGreenKey = @"green";
  NSString *const MPHFlashAlertColorAlphaKey = @"alpha";
NSString *const MPHFlashAlertDurationKey = @"flash-duration";
NSString *const MPHFlashAlertWindowKey = @"flash-window";
NSString *const MPHFlashAlertBehindForegroundWindowKey = @"flash-behind";

NSString *const MPHDockAlertTypeKey = @"dock";
NSString *const MPHDockBounceKey = @"dock-bounce";
NSString *const MPHDockBounceRepeatsKey = @"dock-bounce-repeat";
NSString *const MPHDockBadgeKey = @"dock-badge";
NSString *const MPHDockIconKey = @"dock-icon";

@interface MPHAlertGenerator () <NSSoundDelegate, NSSpeechSynthesizerDelegate>
@end

@implementation MPHAlertGenerator {
	NSMutableArray *_queuedAlerts;
	NSMutableArray *_ongoingAlerts;
	BOOL _isSpeakingMessage;
	BOOL _isPlayingSound;
}

+ (instancetype) sharedInstance {
	static MPHAlertGenerator *sharedInstance = nil;
	static dispatch_once_t once_t;

	dispatch_once(&once_t, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

#pragma mark -

- (id) init {
	if (!(self = [super init]))
		return nil;

	_queuedAlerts = [NSMutableArray array];
	_ongoingAlerts = [NSMutableArray array];

	return self;
}

#pragma mark -

- (NSDictionary *) _queuedAlertOfType:(NSString *) type {
	for (NSDictionary *dictionary in [_queuedAlerts copy]) {
		if ([dictionary[MPHAlertTypeKey] isEqual:type])
			return [dictionary copy];
	}

	return nil;
}

- (void) _playNextAlertOfType:(NSString *) type {
	NSDictionary *nextAlert = [self _queuedAlertOfType:type];
	if (!nextAlert)
		return;

	[_queuedAlerts removeObject:nextAlert];

	[self voiceoverAlertWithInformation:nextAlert];
}

#pragma mark -

- (BOOL) popupAlertWithInformation:(NSDictionary *) information {
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = information[MPHAlertTitleKey];
	alert.informativeText = information[MPHAlertMessageKey];

	[alert runModal];

	return YES;
}

- (BOOL) audioAlertWithInformation:(NSDictionary *) information {
	NSString *audioPath = information[MPHAudioAlertFileKey];

	if (![[NSFileManager defaultManager] fileExistsAtPath:audioPath])
		return NO;

	NSSound *sound = [[NSSound alloc] initWithContentsOfFile:audioPath byReference:NO];
	sound.delegate = self;

	if (information[MPHAudioAlertVolumeKey])
		sound.volume = [information[MPHAudioAlertVolumeKey] floatValue];
	else sound.volume = 1.;

	sound.loops = !!information[MPHAudioAlertRepeatsKey];

	[sound play];
	if (!sound.isPlaying)
		[sound play];

	return YES;
}

- (BOOL) voiceoverAlertWithInformation:(NSDictionary *) information {
	NSSpeechSynthesizer *speechSynthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:information[MPHVoiceoverVoiceKey]];
	speechSynthesizer.delegate = self;

	if (information[MPHVoiceoverVolumeKey])
		speechSynthesizer.volume = [information[MPHVoiceoverVolumeKey] floatValue];
	else speechSynthesizer.volume = 1.;

	return [speechSynthesizer startSpeakingString:information[MPHAlertMessageKey]];
}

- (BOOL) notificationAlertWithInformation:(NSDictionary *) information {
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.hasActionButton = NO;
	notification.title = information[MPHAlertTitleKey];
	notification.informativeText = information[MPHAlertMessageKey];

	[[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];

	return YES;
}

- (BOOL) scriptAlertWithInformation:(NSDictionary *) information {
	NSString *scriptPath = information[MPHScriptAlertPathKey];

	if (![[NSFileManager defaultManager] fileExistsAtPath:scriptPath])
		return NO;

	NSTask *task = [[NSTask alloc] init];
	task.launchPath = information[MPHScriptAlertPathKey];
	task.environment = information[MPHScriptAlertEnvironmentVariablesKey];

	[task launch];

	return YES;
}

- (BOOL) flashScreenAlertWithInformation:(NSDictionary *) information {
	return YES;
}

- (BOOL) dockAlertWithInformation:(NSDictionary *) information {
	if (information[MPHDockBounceRepeatsKey]) {
		if (![NSApplication sharedApplication].isActive)
			[[NSApplication sharedApplication] requestUserAttention:NSCriticalRequest];
	} else if (information[MPHDockBounceRepeatsKey]) {
		if (![NSApplication sharedApplication].isActive)
			[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
	}

	if (information[MPHDockBadgeKey]) {
		NSString *badgeTitle = [NSApplication sharedApplication].dockTile.badgeLabel;
		if (!badgeTitle)
			badgeTitle = [information[MPHDockBadgeKey] copy];
		else {
			if ([badgeTitle mph_hasCaseInsensitiveSubstring:information[MPHDockBadgeKey]]) {
				// TODO: double-check to make sure we don't do something like not add a 3 when we have a 31
			} else {
				badgeTitle = [badgeTitle stringByAppendingFormat:@"%@ %@", [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator], information[MPHDockBadgeKey]];
			}
		}

		[NSApplication sharedApplication].dockTile.badgeLabel = badgeTitle;
	}

	return YES;
}

#pragma mark -

- (BOOL) displayAlertsWithInformation:(NSDictionary *) information {
	BOOL didDisplayAlerts = YES;

	if (information[MPHPopoverAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self popupAlertWithInformation:information[MPHPopoverAlertTypeKey]];
	if (information[MPHAudioAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self audioAlertWithInformation:information[MPHAudioAlertTypeKey]];
	if (information[MPHVoiceoverAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self voiceoverAlertWithInformation:information[MPHVoiceoverAlertTypeKey]];
	if (information[MPHNotificationAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self notificationAlertWithInformation:information[MPHNotificationAlertTypeKey]];
	if (information[MPHScriptAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self scriptAlertWithInformation:information[MPHScriptAlertTypeKey]];
	if (information[MPHFlashAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self flashScreenAlertWithInformation:information[MPHFlashAlertTypeKey]];
	if (information[MPHDockAlertTypeKey])
		didDisplayAlerts = didDisplayAlerts && [self dockAlertWithInformation:information[MPHDockAlertTypeKey]];

	return didDisplayAlerts;
}

#pragma mark -

- (void) speechSynthesizer:(NSSpeechSynthesizer *) speechSynthesizer didFinishSpeaking:(BOOL) finishedSpeaking {
	_isSpeakingMessage = NO;

	[self _playNextAlertOfType:MPHVoiceoverAlertTypeKey];
}

#pragma mark -

- (void) sound:(NSSound *) sound didFinishPlaying:(BOOL) finishedPlaying {
	_isPlayingSound = NO;

	[self _playNextAlertOfType:MPHAudioAlertTypeKey];
}

- (void) endAlerts {
	[_queuedAlerts removeAllObjects];

	// cancel ongoing alerts

	[_ongoingAlerts removeAllObjects];
}
@end
