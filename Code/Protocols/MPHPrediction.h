@protocol MPHPrediction <NSObject>
@required
@property (nonatomic, readonly) id uniqueIdentifier;

@property MPHService service;
@property (nonatomic, readonly) NSString *route;
@property (nonatomic, readonly) NSString *stop;

// Calculated based on downloaded data
@property (nonatomic, readonly) NSInteger minutesETA;
@property (readonly) NSTimeInterval updatedAt;
@end
