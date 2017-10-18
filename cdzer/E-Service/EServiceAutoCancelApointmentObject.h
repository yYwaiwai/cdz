//
//  EServiceAutoCancelApointmentObject.h
//  cdzer
//
//  Created by KEns0n on 16/4/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//
#define kMaxTime (60*15);
#import <Foundation/Foundation.h>
#import "EServiceConfig.h"

@interface EServiceAutoCancelApointmentObject : NSObject

+ (BOOL)startService;

+ (void)stopService;

+ (void)addServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto;

+ (BOOL)cancelServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto;

+ (BOOL)cancelServiceCancelRecordByServiceType:(EServiceType)serviceType;

+ (NSTimeInterval)getCurrentCountDownTimeByServiceType:(EServiceType)serviceType;

@end
