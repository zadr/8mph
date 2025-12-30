#import <Foundation/Foundation.h>

@protocol MPHAlertEditing <NSObject>
@required
- (void) setValuesWithDictionary:(NSDictionary *) dictionary;

@property (nonatomic, readonly) NSDictionary *dictionaryValue;
@end
