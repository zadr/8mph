#import "MPHPageController.h"

@interface NSPageController (Private)
- (id) _snapshotOfView:(NSView *) view;
@end

@implementation MPHPageController {
	NSMapTable *_queueToViews;
}

- (id) _snapshotOfView:(NSView *) view {
	if (!_queueToViews)
		_queueToViews = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];

	dispatch_queue_t queueToUse = [_queueToViews objectForKey:view];
	if (!queueToUse) {
		queueToUse = dispatch_get_current_queue();

		[_queueToViews setObject:queueToUse forKey:view];
	}

	__block id response = nil;
	if (dispatch_get_current_queue() == queueToUse)
		response = [super _snapshotOfView:view];
	else dispatch_sync(queueToUse, ^{
			response = [super _snapshotOfView:view];
		});

	return response;
}
@end
