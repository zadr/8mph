#import <Foundation/Foundation.h>

@interface NSObject (MPHAdditions)
- (void) mph_associateValue:(id) value withKey:(void *) key; // retain
- (id) mph_associatedValueForKey:(void *) key;
@end
