//
//  CityDto.h
//  CityBus
//
//  Created by Alex on 13-10-17.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityDto : NSObject

// 城市Id
@property (strong, nonatomic) NSString *cityId;
// 区域编码
@property (strong, nonatomic) NSString *cityCode;
// 城市名称
@property (strong, nonatomic) NSString *cityName;
// 省Id
@property (strong, nonatomic) NSString *parentId;
// children
@property (strong, nonatomic) NSArray *children;

@end
