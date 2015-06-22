#import "MPHKeyedDictionary.h"

@implementation MPHKeyedDictionary {
	NSMutableDictionary *_dictionary;
}

- (id) init {
	if (!(self = [super init]))
		return nil;

	_dictionary = [[NSMutableDictionary alloc] init];

	return self;
}

- (id) objectForKey:(id <NSCopying>) aKey key:(id <NSCopying>) anotherKey {
	return _dictionary[aKey][anotherKey];
}

- (void) setObject:(id) object forKey:(id <NSCopying>) aKey key:(id <NSCopying>) anotherKey {
	NSMutableDictionary *dictionary = _dictionary[aKey];
	if (!dictionary) {
		dictionary = [NSMutableDictionary dictionary];

		_dictionary[aKey] = dictionary;
	}

	dictionary[anotherKey] = object;
}
@end
