#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "MPHDefines.h"


@protocol MPHPrediction <NSObject>
@required
@property (nonatomic, readonly) id uniqueIdentifier;

@property MPHService service;
@property (nonatomic, readonly) NSString *route;
@property (nonatomic, readonly) NSString *stop;

// Calculated based on downloaded data
@property (nonatomic, readonly) NSInteger minutesETA;
@property (readonly) NSTimeInterval updatedAt;

@optional
@property (copy) UIColor *color;
@end
