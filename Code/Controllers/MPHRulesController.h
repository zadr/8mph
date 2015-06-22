@class MPHRule;

@interface MPHRulesController : NSObject
+ (instancetype) rulesController;

@property (nonatomic, readonly) NSArray *rules;

- (NSArray *) predictionsForRule:(MPHRule *) rule;

- (void) addRule:(MPHRule *) rule;
- (void) unpauseRule:(MPHRule *) rule;
- (void) pauseRule:(MPHRule *) rule;
- (void) removeRuleAtIndex:(NSUInteger) index;
@end
