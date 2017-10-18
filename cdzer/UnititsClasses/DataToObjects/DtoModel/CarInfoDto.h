//
//  CarInfoDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarInfoDto : NSObject

//carNo - 车牌号
@property (strong, nonatomic) NSString *carNo;
//imei - 设备号
@property (strong, nonatomic) NSString *imei;
//bid - 品牌id
@property (strong, nonatomic) NSString *bid;
//sid - 车型id
@property (strong, nonatomic) NSString *sid;
//carTypeId - 年代款id
@property (strong, nonatomic) NSString *carTypeId;
//initialMileage - 初始里程
@property (strong, nonatomic) NSString *initialMileage;
//warrantyNo - 保单号
@property (strong, nonatomic) NSString *warrantyNo;
//color - 颜色
@property (strong, nonatomic) NSString *color;
//engineCode - 发动机编号
@property (strong, nonatomic) NSString *engineCode;
//signCode - 车架号
@property (strong, nonatomic) NSString *signCode;

//kinsfolkPhone - 亲情号码
@property (strong, nonatomic) NSString *kinsfolkPhone;
//status - 状态 0行驶中1熄火2设备未连接到平台
@property (strong, nonatomic) NSString *status;

@end
