
#import <Foundation/Foundation.h>

@interface PositionDto : NSObject 

@property (nonatomic,strong) NSString* imei;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) double moveSpeed;
@property (nonatomic) double moveDirection;
@property (nonatomic,strong) NSString* time;
@property (nonatomic) double mileage;
@property (nonatomic,strong) NSString* gsm;
@property (nonatomic,strong) NSString* gpsNum;
//点火1 熄火0
@property (nonatomic) int acc;

@end
