#import "NSObjectAdditions.h"

#import <objc/runtime.h>

@implementation NSObject (MPHAdditions)
- (void) mph_associateValue:(id) value withKey:(void *) key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id) mph_associatedValueForKey:(void *) key {
	return objc_getAssociatedObject(self, key);
}
@end
