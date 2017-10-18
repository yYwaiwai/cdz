//
//  OverSpeedDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 超速设置，语音设置
 */
@interface OverSpeedDto : NSObject

@property (strong, nonatomic) NSString *imei;
//ratedStatus - 超速提醒：1开启，0关闭
@property (strong, nonatomic) NSString *ratedStatus;
//ratedSpeed - 速度
@property (strong, nonatomic) NSString *ratedSpeed;
//voiceStatus - 语音提醒：1开启，0关闭
@property (strong, nonatomic) NSString *voiceStatus;
//createTime - 时间
@property (strong, nonatomic) NSString *createTime;

@end
