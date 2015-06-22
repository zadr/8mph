#import "MPHAlertTypeSelectionViewController.h"

#import "MPHPopupAlertViewController.h"
#import "MPHSoundAlertViewController.h"
#import "MPHRunScriptAlertViewController.h"
#import "MPHFlashScreenAlertViewController.h"
#import "MPHDockIconAlertViewController.h"

#import "MPHAlertGenerator.h"

#import "MPHAlertTypeSelectionView.h"

#import "MPHRule.h"

@interface MPHAlertTypeSelectionViewController () <MPHHovering>
@end

@implementation MPHAlertTypeSelectionViewController {
	NSViewController <MPHAlertEditing> *_activeOptionsView;
	MPHRule *_rule;
	NSMutableDictionary *_alerts;
}

- (id) init {
	if (!(self = [super initWithNibName:@"MPHAlertTypeSelectionView" bundle:nil]))
		return nil;

	_alerts = [NSMutableDictionary dictionary];

	return self;
}

#pragma mark -

- (NSArray *) alerts {
	NSMutableArray *alerts = [NSMutableArray array];
	if (self.selectionView.popupButton.state == NSOnState)
		[alerts addObject:_alerts[MPHPopoverAlertTypeKey]];
	if (self.selectionView.soundButton.state == NSOnState)
		[alerts addObject:_alerts[MPHAudioAlertTypeKey]];
	if (self.selectionView.speakButton.state == NSOnState)
		[alerts addObject:_alerts[MPHVoiceoverAlertTypeKey]];
	if (self.selectionView.notificationButton.state == NSOnState)
		[alerts addObject:_alerts[MPHNotificationAlertTypeKey]];
	if (self.selectionView.dockButton.state == NSOnState)
		[alerts addObject:_alerts[MPHDockAlertTypeKey]];
	if (self.selectionView.runScriptButton.state == NSOnState)
		[alerts addObject:_alerts[MPHScriptAlertTypeKey]];
	return [alerts copy];
}

- (MPHAlertTypeSelectionView *) selectionView {
	return (MPHAlertTypeSelectionView *)self.view;
}

- (void) setRepresentedObject:(id) representedObject {
	_rule = representedObject;

	if ([_rule alertOfType:MPHPopoverAlertTypeKey])
		self.selectionView.popupButton.state = NSOnState;
	if ([_rule alertOfType:MPHAudioAlertTypeKey])
		self.selectionView.soundButton.state = NSOnState;
	if ([_rule alertOfType:MPHVoiceoverAlertTypeKey])
		self.selectionView.speakButton.state = NSOnState;
	if ([_rule alertOfType:MPHNotificationAlertTypeKey])
		self.selectionView.notificationButton.state = NSOnState;
	if ([_rule alertOfType:MPHDockAlertTypeKey])
		self.selectionView.dockButton.state = NSOnState;
	if ([_rule alertOfType:MPHScriptAlertTypeKey])
		self.selectionView.runScriptButton.state = NSOnState;

	[self didBeginHoveringOverButton:self.selectionView.popupButton];
}

#pragma mark -

- (void) didBeginHoveringOverButton:(MPHHoveringButton *) hoveringButton {
	NSViewController <MPHAlertEditing> *nextViewController = nil;

	if (hoveringButton == self.selectionView.popupButton) {
		NSDictionary *alert = [_rule alertOfType:MPHPopoverAlertTypeKey];

		MPHPopupAlertViewController *popupViewController = [[MPHPopupAlertViewController alloc] init];
		NSCellStateValue state = alert ? NSOnState : NSOffState;

		[popupViewController setValuesWithDictionary:@{
			MPHPopupAlertDisplayNameKey: NSLocalizedString(@"Show Over All Windows", @"Show Over All Windows checkbox title"),
			MPHPopupAlertStateKey: @(state),
			MPHPopupAlertReturnDictionaryKeyKey: MPHPopoverAlertTypeKey,
			MPHAlertTypeKey: MPHPopoverAlertTypeKey
		 }];

		nextViewController = popupViewController;
	} else if (hoveringButton == self.selectionView.soundButton) {
		NSDictionary *alert = [_rule alertOfType:MPHAudioAlertTypeKey];
		if (!alert)
			alert = @{ MPHAudioAlertVolumeKey: @(100.), MPHAudioAlertRepeatsKey: @(NSOffState) };

		NSArray *sounds = [[NSBundle mainBundle] pathsForResourcesOfType:@"aiff" inDirectory:nil];
		NSMutableArray *soundNames = [NSMutableArray array];
		for (NSString *file in sounds)
			[soundNames addObject:[file.lastPathComponent substringToIndex:(file.lastPathComponent.length - 5)]]; // skip .aiff at the end
		[soundNames addObject:NSLocalizedString(@"Other…", @"Other title")];

		NSString *defaultSound = alert[MPHAudioAlertFileKey];
		defaultSound = defaultSound.lastPathComponent;
		NSRange dotRange = [defaultSound rangeOfString:@"."];

		if (dotRange.location != NSNotFound)
			defaultSound = [defaultSound substringToIndex:dotRange.location];

		if (!defaultSound.length)
			defaultSound = soundNames[0];

		MPHSoundAlertViewController *soundViewController = [[MPHSoundAlertViewController alloc] init];
		[soundViewController setValuesWithDictionary:@{
			MPHSoundAlertPopUpDisplayNameKey: NSLocalizedString(@"Sound: ", @"Sound: checkbox title"),
				MPHSoundAlertPopUpValuesKey: soundNames,
				MPHSoundAlertPopUpSelectedValuesKey: @[defaultSound],
				MPHSoundAlertPopUpReturnDictionaryKeyKey: MPHAudioAlertFileKey,
			MPHSoundAlertSliderDisplayNameKey: NSLocalizedString(@"Volume", @"Volume slider"),
				MPHSoundAlertSliderValueKey: alert[MPHAudioAlertVolumeKey],
				MPHSoundAlertSliderReturnDictionaryKeyKey: MPHAudioAlertVolumeKey,
			MPHSoundAlertCheckboxDisplayNameKey: NSLocalizedString(@"Repeatedly: ", @"Repeatedly: checkbox title"),
				MPHSoundAlertCheckboxStateKey: alert[MPHAudioAlertRepeatsKey],
				MPHSoundAlertCheckboxReturnDictionaryKeyKey: MPHAudioAlertRepeatsKey,
			MPHAlertTypeKey: MPHAudioAlertTypeKey
		}];

		nextViewController = soundViewController;
	} else if (hoveringButton == self.selectionView.speakButton) {
		NSDictionary *alert = [_rule alertOfType:MPHVoiceoverAlertTypeKey];
		if (!alert)
			alert = @{ MPHVoiceoverVolumeKey: @(100.), MPHVoiceoverAlertRepeatsKey: @(NSOffState) };

		NSMutableArray *voiceNames = [NSMutableArray array];
		for (NSString *voiceIdentifier in [NSSpeechSynthesizer availableVoices])
			[voiceNames addObject:[NSSpeechSynthesizer attributesForVoice:voiceIdentifier][NSVoiceName]];

		NSString *defaultVoiceName = alert[MPHVoiceoverVoiceKey];
		if (!defaultVoiceName)
			defaultVoiceName = [NSSpeechSynthesizer attributesForVoice:[NSSpeechSynthesizer defaultVoice]][NSVoiceName];

		MPHSoundAlertViewController *soundViewController = [[MPHSoundAlertViewController alloc] init];
		[soundViewController setValuesWithDictionary:@{
			MPHSoundAlertPopUpDisplayNameKey: NSLocalizedString(@"Voice: ", @"Voice: checkbox title"),
				MPHSoundAlertPopUpValuesKey: voiceNames,
				MPHSoundAlertPopUpSelectedValuesKey: @[defaultVoiceName],
				MPHSoundAlertPopUpReturnDictionaryKeyKey: MPHAlertMessageKey,
			MPHSoundAlertSliderDisplayNameKey: NSLocalizedString(@"Volume", @"Volume slider"),
				MPHSoundAlertSliderValueKey: alert[MPHVoiceoverVolumeKey],
				MPHSoundAlertSliderReturnDictionaryKeyKey: MPHVoiceoverVolumeKey,
			MPHSoundAlertCheckboxDisplayNameKey: NSLocalizedString(@"Repeatedly: ", @"Repeatedly: checkbox title"),
				MPHSoundAlertCheckboxStateKey: alert[MPHVoiceoverAlertRepeatsKey],
				MPHSoundAlertCheckboxReturnDictionaryKeyKey: MPHVoiceoverAlertRepeatsKey,
			 MPHAlertTypeKey: MPHVoiceoverAlertTypeKey
		 }];

		nextViewController = soundViewController;
	} else if (hoveringButton == self.selectionView.notificationButton) {
		NSDictionary *alert = [_rule alertOfType:MPHNotificationAlertTypeKey];

		MPHPopupAlertViewController *popupViewController = [[MPHPopupAlertViewController alloc] init];
		NSCellStateValue state = alert ? NSOnState : NSOffState;

		[popupViewController setValuesWithDictionary:@{
			MPHPopupAlertDisplayNameKey: NSLocalizedString(@"Require Confirmation", @"Require Confirmation"),
			MPHPopupAlertStateKey: @(state),
			MPHPopupAlertReturnDictionaryKeyKey: MPHNotificationAlertTypeKey,
			MPHAlertTypeKey: MPHNotificationAlertTypeKey
		 }];

		nextViewController = popupViewController;
	} else if (hoveringButton == self.selectionView.dockButton) {
		NSDictionary *alert = [_rule alertOfType:MPHDockAlertTypeKey];
		if (!alert)
			alert = @{ MPHDockIconBouncesKey: @(NSOnState), MPHDockIconBadgesKey: @(NSOnState) };

		MPHDockIconAlertViewController *dockViewController = [[MPHDockIconAlertViewController alloc] init];
		[dockViewController setValuesWithDictionary:alert];

		nextViewController = dockViewController;
	} else if (hoveringButton == self.selectionView.runScriptButton) {
		MPHRunScriptAlertViewController *runScriptViewController = [[MPHRunScriptAlertViewController alloc] init];
		[runScriptViewController setValuesWithDictionary:[_rule alertOfType:MPHScriptAlertTypeKey]];

		nextViewController = runScriptViewController;
	}

	if (nextViewController) {
		NSRect frame = NSMakeRect(0., 0., 0., 0.);
		frame.size = self.selectionView.optionsView.frame.size;
		nextViewController.view.frame = frame;

		[self.selectionView.optionsView addSubview:nextViewController.view];
		[_activeOptionsView.view removeFromSuperview];

		_activeOptionsView = nextViewController;
	}
}

- (void) didEndHoveringOverButton:(MPHHoveringButton *) hoveringButton {
	if (!_activeOptionsView)
		return;

	if (hoveringButton.state == NSOnState)
		_alerts[_activeOptionsView.dictionaryValue[MPHAlertTypeKey]] = _activeOptionsView.dictionaryValue;
	else [_alerts removeObjectForKey:_activeOptionsView.dictionaryValue[MPHAlertTypeKey]];
}
@end
