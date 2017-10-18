//
//  UserActoDto.h
//  CityBus
//
//  Created by Alex on 13-11-21.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserActoDto : NSObject
// 用户唯一标示符
@property (strong, nonatomic) NSString *userId;
// 点击类型：0登录，1线路，2站点，9其他
@property (strong, nonatomic) NSString *actType;
// 城市编码
@property (strong, nonatomic) NSString *cityCode;
// 终端类型：1web，2wap，3ios，4android
@property (strong, nonatomic) NSString *clientType;
// 客户端IP
@property (strong, nonatomic) NSString *clientIp;
// 客户端User Agent
@property (strong, nonatomic) NSString *clientUA;
// 发生时间
@property (strong, nonatomic) NSString *eventTime;

@end
