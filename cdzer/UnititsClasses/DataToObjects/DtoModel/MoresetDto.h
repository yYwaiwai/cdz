//
//  MoresetDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoresetDto : NSObject

//imei 设备号
@property (strong, nonatomic) NSString *imei;
//cf - 侧翻
@property (strong, nonatomic) NSString *cf;
//pz - 碰撞
@property (strong, nonatomic) NSString *pz;
//dpddy 电瓶低电压
@property (strong, nonatomic) NSString *dpddy;
//tc 拖车
@property (strong, nonatomic) NSString *tc;
//dd 断电
@property (strong, nonatomic) NSString *dd;
//fdlb 防盗喇叭
@property (strong, nonatomic) NSString *fdlb;
//pljs 疲劳驾驶
@property (strong, nonatomic) NSString *pljs;
//alarmTime 报警时间
@property (strong, nonatomic) NSString *alarmTime;

//dto.defences=j_defences;
@property (strong, nonatomic) NSString *defences;
//dto.urgencyMessage=j_urgencyMessage;
@property (strong, nonatomic) NSString *urgencyMessage;
//dto.speedSet=j_speedSet;
@property (strong, nonatomic) NSString *speedSet;

@property (strong ,nonatomic) NSString *electronicFence ;


@end
