#import <Foundation/Foundation.h>

@interface MPHBARTStationData : NSObject
@property (copy) NSString *platformInfo;
@property (copy) NSString *introduction;
@property (copy) NSString *crossStreet;
@property (copy) NSString *food;
@property (copy) NSString *shopping;
@property (copy) NSString *attraction;
@property (copy) NSString *entering;
@property (copy) NSString *exiting;
@property (copy) NSString *parking;
@property BOOL parkingAvailable;
@property BOOL lockersAvailable;
@property BOOL carShareAvailable;
@property (copy) NSString *lotFilledBy;
@property (copy) NSString *lockerInformation;
@property (copy) NSString *bikeInformation;
@property BOOL bikesAvailable;
@property BOOL bikeStationAvailable;
@end
