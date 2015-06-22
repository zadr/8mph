@interface MPHAlertTableViewCell : NSTableCellView
@property (nonatomic, strong) NSImage *logo;
@property (nonatomic, copy) NSString *routeStop;
@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSDictionary *predictions; // { route: [prediction, prediction], route: [prediction, prediction] }
@end
