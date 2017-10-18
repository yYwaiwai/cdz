//
//  EServiceAutoCancelApointmentObject.m
//  cdzer
//
//  Created by KEns0n on 16/4/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//
#define kESACAListKey @"ESACAListKey"
#define kUserID @"UserID"
#define kERepairAutoCancelKey @"ERepairAutoCancelKey"
#define kEInspectAutoCancelKey @"EInspectAutoCancelKey"
#define kEInsuranceAutoCancelKey @"EInsuranceAutoCancelKey"
#import "EServiceAutoCancelApointmentObject.h"
#import "EServiceCancelRecordDTO.h"

@interface EServiceAutoCancelApointmentObject ()

@property (nonatomic) NSTimer *eRepairAutoCancelTimer;

@property (nonatomic) NSTimer *eInspectAutoCancelTimer;

@property (nonatomic) NSTimer *eInsuranceAutoCancelTimer;

@property (nonatomic) EServiceCancelRecordDTO *currentERepairDTO;

@property (nonatomic) EServiceCancelRecordDTO *currentEInspectDTO;

@property (nonatomic) EServiceCancelRecordDTO *currentEInsuranceDTO;

@property (nonatomic) NSInteger eRepairTryCount;

@property (nonatomic) NSInteger eInspectTryCount;

@property (nonatomic) NSInteger eInsuranceTryCount;

@end

@implementation EServiceAutoCancelApointmentObject

static EServiceAutoCancelApointmentObject *_ESACAObjectInstance = nil;

+ (EServiceAutoCancelApointmentObject *)serviceInitialize {
    if (!_ESACAObjectInstance) {
        _ESACAObjectInstance = [EServiceAutoCancelApointmentObject new];
    }
    if (vGetUserToken&&vGetUserID&&![vGetUserID isEqualToString:@"0"]) {
        NSArray <EServiceCancelRecordDTO *> *cancelList = [DBHandler.shareInstance getEServiceCancelRecord];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval maxTime = kMaxTime;
        [cancelList enumerateObjectsUsingBlock:^(EServiceCancelRecordDTO * _Nonnull dto, NSUInteger idx, BOOL * _Nonnull stop) {
            if (dto.serviceType==EServiceTypeOfERepair) {
                _ESACAObjectInstance.currentERepairDTO = dto;
                if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
                    if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
                        [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
                    }
                    _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
                }
                
                NSTimeInterval theTimeGap = round([currentDate timeIntervalSinceDate:dto.createdDateTime]);
                if (maxTime<=theTimeGap) {
                    
                }else {
                    _ESACAObjectInstance.eRepairAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime-theTimeGap target:self selector:@selector(cancelERepairAppointment) userInfo:nil repeats:NO];
                }
            }
            
            if (dto.serviceType==EServiceTypeOfEInspect) {
                _ESACAObjectInstance.currentEInspectDTO = dto;
                if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
                    if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
                        [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
                    }
                    _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
                }
                NSTimeInterval theTimeGap = round([currentDate timeIntervalSinceDate:dto.createdDateTime]);
                if (maxTime<=theTimeGap) {
                    
                }else {
                    _ESACAObjectInstance.eInspectAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime-theTimeGap target:self selector:@selector(cancelEInspectAppointment) userInfo:nil repeats:NO];
                }
            }
            
            if (dto.serviceType==EServiceTypeOfEInsurance) {
                _ESACAObjectInstance.currentEInsuranceDTO = dto;
                if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
                    if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
                        [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
                    }
                    _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
                }
                
                NSTimeInterval theTimeGap = round([currentDate timeIntervalSinceDate:dto.createdDateTime]);
                if (maxTime<=theTimeGap) {
                    
                }else {
                    _ESACAObjectInstance.eInsuranceAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime-theTimeGap target:self selector:@selector(cancelEInsuranceAppointment) userInfo:nil repeats:NO];
                }
            }
            
        }];
        
    }else {
        if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
            if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
        }
        if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
        }
        if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
        }
        _ESACAObjectInstance.currentERepairDTO = nil;
        _ESACAObjectInstance.currentEInspectDTO = nil;
        _ESACAObjectInstance.currentEInsuranceDTO = nil;
    }
    return _ESACAObjectInstance;
}

+ (BOOL)startService {
    return ([self serviceInitialize]!=nil);
}

+ (void)stopService {
    if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
        if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
            [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
        }
        _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
    }
    if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
        if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
            [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
        }
        _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
    }
    if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
        if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
            [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
        }
        _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
    }
    _ESACAObjectInstance.currentERepairDTO = nil;
    _ESACAObjectInstance.currentEInspectDTO = nil;
    _ESACAObjectInstance.currentEInsuranceDTO = nil;

}


+ (void)addServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto {
    NSTimeInterval maxTime = kMaxTime;
    if (dto.serviceType==EServiceTypeOfERepair) {
        _ESACAObjectInstance.currentERepairDTO = dto;
        if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
            if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
        }
        
        _ESACAObjectInstance.eRepairAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime target:self selector:@selector(cancelERepairAppointment) userInfo:nil repeats:NO];
        [DBHandler.shareInstance insertEServiceCancelRecord:dto];
    }
    
    if (dto.serviceType==EServiceTypeOfEInspect) {
        _ESACAObjectInstance.currentEInspectDTO = dto;
        if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
        }
        _ESACAObjectInstance.eInspectAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime target:self selector:@selector(cancelEInspectAppointment) userInfo:nil repeats:NO];
        [DBHandler.shareInstance insertEServiceCancelRecord:dto];
    }
    
    if (dto.serviceType==EServiceTypeOfEInsurance) {
        _ESACAObjectInstance.currentEInsuranceDTO = dto;
        if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
        }
        
        _ESACAObjectInstance.eInsuranceAutoCancelTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime target:self selector:@selector(cancelEInsuranceAppointment) userInfo:nil repeats:NO];
        [DBHandler.shareInstance insertEServiceCancelRecord:dto];
    }

}

+ (BOOL)cancelServiceCancelRecordByServiceType:(EServiceType)serviceType {
    EServiceCancelRecordDTO *dto = nil;
    if (serviceType==EServiceTypeOfERepair) {
        dto = _ESACAObjectInstance.currentERepairDTO;
        _ESACAObjectInstance.currentERepairDTO = nil;
        if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
            if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
        }
    }
    
    if (serviceType==EServiceTypeOfEInspect) {
        dto = _ESACAObjectInstance.currentEInspectDTO;
        _ESACAObjectInstance.currentEInspectDTO = nil;
        if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
        }
    }
    
    if (serviceType==EServiceTypeOfEInsurance) {
        dto = _ESACAObjectInstance.currentEInsuranceDTO;
        _ESACAObjectInstance.currentEInsuranceDTO = nil;
        if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
        }
    }
    return [DBHandler.shareInstance deleteEServiceCancelRecordWithDto:dto];
}

+ (BOOL)cancelServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto {
    if (dto.serviceType==EServiceTypeOfERepair) {
        _ESACAObjectInstance.currentERepairDTO = nil;
        if (_ESACAObjectInstance.eRepairAutoCancelTimer) {
            if ([_ESACAObjectInstance.eRepairAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eRepairAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eRepairAutoCancelTimer = nil;
        }
    }
    
    if (dto.serviceType==EServiceTypeOfEInspect) {
        _ESACAObjectInstance.currentERepairDTO = nil;
        if (_ESACAObjectInstance.eInspectAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInspectAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInspectAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInspectAutoCancelTimer = nil;
        }
    }
    
    if (dto.serviceType==EServiceTypeOfEInsurance) {
        _ESACAObjectInstance.currentEInsuranceDTO = nil;
        if (_ESACAObjectInstance.eInsuranceAutoCancelTimer) {
            if ([_ESACAObjectInstance.eInsuranceAutoCancelTimer isValid]) {
                [_ESACAObjectInstance.eInsuranceAutoCancelTimer invalidate];
            }
            _ESACAObjectInstance.eInsuranceAutoCancelTimer = nil;
        }
    }
    
    return [DBHandler.shareInstance deleteEServiceCancelRecordWithDto:dto];
}

+ (void)cancelERepairAppointment {
    if (!_ESACAObjectInstance.currentERepairDTO) {
        return;
    }
    [self cancelEServiceAppointment:_ESACAObjectInstance.currentERepairDTO];
}

+ (void)cancelEInspectAppointment {
    if (!_ESACAObjectInstance.currentEInspectDTO) {
        return;
    }
    [self cancelEServiceAppointment:_ESACAObjectInstance.currentEInspectDTO];
    
}

+ (void)cancelEInsuranceAppointment {
    if (!_ESACAObjectInstance.currentEInsuranceDTO) {
        return;
    }
    [self cancelEServiceAppointment:_ESACAObjectInstance.currentEInsuranceDTO];
    
}

+ (void)cancelEServiceAppointment:(EServiceCancelRecordDTO *)dto {
    NSString *token = [vGetUserToken copy];
    NSString *eServiceID = dto.eServiceID;
    if (!token||!eServiceID) {
        if (dto.serviceType==EServiceTypeOfERepair) {
            _ESACAObjectInstance.eRepairTryCount = 0;
        }
        if (dto.serviceType==EServiceTypeOfEInspect) {
            _ESACAObjectInstance.eInspectTryCount = 0;
        }
        if (dto.serviceType==EServiceTypeOfEInsurance) {
            _ESACAObjectInstance.eInsuranceTryCount = 0;
        }
        return;
    }
    @weakify(_ESACAObjectInstance)
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:token eServiceID:eServiceID isAutoCancel:NO success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(_ESACAObjectInstance);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([message isEqualToString:@"返回成功"]||[message isEqualToString:@"重复取消"]) {
            [DBHandler.shareInstance deleteEServiceCancelRecordWithDto:dto];
            if (dto.serviceType==EServiceTypeOfERepair) {
                _ESACAObjectInstance.eRepairTryCount = 0;
                _ESACAObjectInstance.currentERepairDTO = nil;
            }
            if (dto.serviceType==EServiceTypeOfEInspect) {
                _ESACAObjectInstance.eInspectTryCount = 0;
                _ESACAObjectInstance.currentEInspectDTO = nil;
            }
            if (dto.serviceType==EServiceTypeOfEInsurance) {
                _ESACAObjectInstance.eInsuranceTryCount = 0;
                _ESACAObjectInstance.currentEInsuranceDTO = nil;
            }
            
            return;
        }
        if (dto.serviceType==EServiceTypeOfERepair) {
            _ESACAObjectInstance.eRepairTryCount = 0;
        }
        if (dto.serviceType==EServiceTypeOfEInspect) {
            _ESACAObjectInstance.eInspectTryCount = 0;
        }
        if (dto.serviceType==EServiceTypeOfEInsurance) {
            _ESACAObjectInstance.eInsuranceTryCount = 0;
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(_ESACAObjectInstance);
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            if (dto.serviceType==EServiceTypeOfERepair) {
                _ESACAObjectInstance.eRepairTryCount = 0;
            }
            if (dto.serviceType==EServiceTypeOfEInspect) {
                _ESACAObjectInstance.eInspectTryCount = 0;
            }
            if (dto.serviceType==EServiceTypeOfEInsurance) {
                _ESACAObjectInstance.eInsuranceTryCount = 0;
            }
            return;
        }
        _ESACAObjectInstance.eRepairTryCount++;
        [self cancelEServiceAppointment:dto];
    }];
    
}

+ (NSTimeInterval)getCurrentCountDownTimeByServiceType:(EServiceType)serviceType {
    EServiceCancelRecordDTO *dto = nil;
    if (serviceType==EServiceTypeOfERepair) {
        dto = _ESACAObjectInstance.currentERepairDTO;
    }
    
    if (serviceType==EServiceTypeOfEInspect) {
        dto = _ESACAObjectInstance.currentEInspectDTO;
    }
    
    if (serviceType==EServiceTypeOfEInsurance) {
        dto = _ESACAObjectInstance.currentEInsuranceDTO;
    }
    if (dto) {
        NSTimeInterval maxTime = kMaxTime;
        NSDate *date = [NSDate date];
        NSLog(@"%@",date);
        NSLog(@"%@",dto.createdDateTime);
        NSTimeInterval timeGap = round([date timeIntervalSinceDate:dto.createdDateTime]);
        NSLog(@"%@",dto.createdDateTime);
        if (timeGap>maxTime) {
            return 0;
        }
        return (maxTime - timeGap);
    }
    
    return 0;
}
@end
