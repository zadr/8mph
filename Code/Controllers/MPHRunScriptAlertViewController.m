#import "MPHRunScriptAlertViewController.h"

#import "MPHAlertGenerator.h"

#import "NSDictionaryAdditions.h"

static NSString *const MPHEnvironmentVariableTitle = @"env-var-title";
static NSString *const MPHEnvironmentVariableValue = @"env-var-value";

@implementation MPHRunScriptAlertViewController
- (id) init {
	return (self = [super initWithNibName:@"MPHRunScriptAlertView" bundle:nil]);
}

- (IBAction) selectScript:(id) sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = @[@"public.executable"];

	if ([openPanel runModal] == NSFileHandlingPanelCancelButton)
		return;

	_scriptPathTextField.stringValue = ((NSURL *)openPanel.URLs[0]).path;
}

- (void) setValuesWithDictionary:(NSDictionary *) dictionary {
	_scriptPathTextField.stringValue = dictionary[MPHScriptAlertPathKey];
	_environmentVariablesCheckboxButton.state = [dictionary[MPHScriptAlertEnvironmentVariablesKey] intValue];
}

- (NSDictionary *) dictionaryValue {
	NSString *filePath = _scriptPathTextField.stringValue;

	if (!filePath.length)
		return @{ MPHAlertTypeKey: MPHScriptAlertTypeKey };

	return @{
		MPHScriptAlertPathKey: filePath,
		MPHScriptAlertEnvironmentVariablesKey: @(_environmentVariablesCheckboxButton.state),
		MPHAlertTypeKey: MPHScriptAlertTypeKey
	};
}

#pragma mark -

- (void) controlTextDidBeginEditing:(NSNotification *) notification {
	[self selectScript:notification.object];
}
@end
