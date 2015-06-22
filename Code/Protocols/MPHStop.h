@protocol MPHStop <NSObject, NSCopying>
@required
- (NSString *) name;
- (CLLocationCoordinate2D) coordinate;
- (NSInteger) tag;

- (NSInteger) rowID;

- (id) link;

- (NSString *) routeTag;
@end
