#import "MPHServiceSelectionViewController.h"

#import "MPHServiceSelectionView.h"

#import "MPHRule.h"

@implementation MPHServiceSelectionViewController {
	MPHRule *_rule;
}

- (id) init {
	return (self = [self initWithNibName:@"MPHServiceSelectionView" bundle:nil]);
}

#pragma mark -

- (void) setRepresentedObject:(id) representedObject {
	_rule = representedObject;
}

#pragma mark -

- (IBAction) selectService:(id) sender {
	__strong typeof(_delegate) strongDelegate = _delegate;
	[strongDelegate serviceSelectionViewController:self didSelectService:(MPHService)[sender tag]];
}
@end
