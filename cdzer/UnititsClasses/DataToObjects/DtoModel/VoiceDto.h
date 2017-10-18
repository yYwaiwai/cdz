//
//  VoiceDto.h
//  iCars
//
//  Created by zcwl_mac_mini on 14-6-13.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceDto : NSObject

@property (strong, nonatomic) NSString *imei;
@property (strong, nonatomic) NSString *speedValue;//播放速度值
@property (strong, nonatomic) NSString *voiceValue;//声量值
@property (nonatomic) BOOL isWeatherOn;//天气播报是否开启
@end
