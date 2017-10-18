//
//  UserInfoDto.h
//  HouseExhibits
//
//  Created by Alex on 13-3-8.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CarInfoDto;

@interface UserInfoDto : NSObject<NSCopying>

@property (strong, nonatomic) NSString *userId;
// 帐号
@property (strong, nonatomic) NSString *account;
// 密码
@property (strong, nonatomic) NSString *pwd;

// 客户姓名
@property (strong, nonatomic) NSString *name;
// 联系方式
@property (strong, nonatomic) NSString *phone;
// 性别
@property (strong, nonatomic) NSString *sex;
// 年龄
@property (strong, nonatomic) NSString *age;
// QQ或微信
@property (strong, nonatomic) NSString *qq;
//  服务密码
@property (strong, nonatomic) NSString *servicePassword;
//  驾照
@property (strong, nonatomic) NSString *drivingLicence;

// 联系地址
@property (strong, nonatomic) NSString *addr; 
// 电子邮箱
@property (strong, nonatomic) NSString *email;

// 账户余额
@property (strong, nonatomic) NSString *balance;
// 积分
@property (strong, nonatomic) NSString *credits;
// 礼品卡余额
@property (strong, nonatomic) NSString *gift_balance;

// 车辆列表
@property (strong, nonatomic) NSArray *carInfos;

@property (strong ,nonatomic) NSString *userType ;

@end
