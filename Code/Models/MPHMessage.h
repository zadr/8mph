@interface MPHMessage : NSObject
@property MPHService service;

@property (copy) NSString *message;
@property (copy) NSDate *startDate;
@property (copy) NSDate *endDate;
@property (copy) NSString *identifier;

@property (nonatomic, readonly) NSString *text;
- (NSDate *) effectiveUntil;

@property (nonatomic, readonly) BOOL messageWithoutAffectedLinesIsSystemMessage; // NO, unless overridden
@property (nonatomic, copy) NSArray *affectedLines;
@property (copy) NSArray *affectedStops;

@property (nonatomic, readonly) BOOL hasDetails;

#if TARGET_OS_IPHONE
- (UIColor *) colorForAffectedLine:(NSString *) line;
#endif
@end
