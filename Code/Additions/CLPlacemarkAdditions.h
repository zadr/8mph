#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (Additions)
@property (nonatomic, readonly) NSString *mph_readableAddressString;
@end
