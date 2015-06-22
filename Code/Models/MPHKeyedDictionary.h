@interface MPHKeyedDictionary : NSObject
- (id) objectForKey:(id <NSCopying>) aKey key:(id <NSCopying>) anotherKey;
- (void) setObject:(id) object forKey:(id <NSCopying>) aKey key:(id <NSCopying>) anotherKey;
@end
