//
//  DefencesDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 设防
 */
@interface DefencesDto : NSObject

//name 名称
@property (strong, nonatomic) NSString *name;
//address 地址
@property (strong, nonatomic) NSString *address;
//dtoId - 设防ID
@property (strong, nonatomic) NSString *dtoId;
//imei - 设备号
@property (strong, nonatomic) NSString *imei;
//startTime 开始时间
@property (strong, nonatomic) NSString *startTime;
//endTime 结束时间
@property (strong, nonatomic) NSString *endTime;
//status 状态
@property (strong, nonatomic) NSString *status;
//smsStatus 短信提醒
@property (strong, nonatomic) NSString *smsStatus;
//cycle 周期
@property (strong, nonatomic) NSString *cycle;
//timing 固定时间点
@property (strong, nonatomic) NSString *timing;
//type 类型
@property (strong, nonatomic) NSString *type;
// past 是否过期
@property (strong, nonatomic) NSString *pasts;

@end
