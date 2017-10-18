//
//  HomeInfoDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeInfoDto : NSObject<NSCopying>

@property (strong, nonatomic) NSString *imei;
@property (strong, nonatomic) NSString *carNo;
//    mileage 里程
@property (strong, nonatomic) NSString *mileage;
//    mileageKeep 距离保养里程数
@property (strong, nonatomic) NSString *mileageKeep;
//    lastDate 到期时间
@property (strong, nonatomic) NSString *lastDate;
//    channelPhone 手机号
@property (strong, nonatomic) NSString *channelPhone;
//    carbid 品牌id
//carBName 品牌名称
//carBUrl品牌图片
@property (strong, nonatomic) NSString *carbid;
@property (strong, nonatomic) NSString *carBName;
@property (strong, nonatomic) NSString *carBUrl;
//    carsid 车型id
//carSName 车型名称
//carTypeUrl 车型图片
@property (strong, nonatomic) NSString *carsid;
@property (strong, nonatomic) NSString *carSName;
@property (strong, nonatomic) NSString *carSUrl;
//    carTypeId 年代款id
//carTypeName 年代款名称
//carTypeUrl 车型图片
@property (strong, nonatomic) NSString *carTypeId;
@property (strong, nonatomic) NSString *carTypeName;
@property (strong, nonatomic) NSString *carTypeUrl;
//    socre 分数
@property (strong, nonatomic) NSString *socre;
//    warrantyNo 保单号
@property (strong, nonatomic) NSString *warrantyNo;
//    color 颜色
@property (strong, nonatomic) NSString *color;
//    engineCode 发动机编号
@property (strong, nonatomic) NSString *engineCode;
//    signCode 车架号
@property (strong, nonatomic) NSString *signCode;


@end
