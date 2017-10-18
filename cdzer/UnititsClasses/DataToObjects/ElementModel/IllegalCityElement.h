//
//  IllegalCityElement.h
//  iCars
//
//  Created by xuhu on 14-10-16.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 违章城市的数据模型类
 */
@interface IllegalCityElement : NSObject

@property (strong ,nonatomic) NSString *cityName ;
@property (strong ,nonatomic) NSString *cityCode ;
@property (strong ,nonatomic) NSString *abbr ;
@property (strong ,nonatomic) NSString *engine ;
@property (strong ,nonatomic) NSString *engineNo ;
@property (strong ,nonatomic) NSString *classa ;
@property (strong ,nonatomic) NSString *classNo ;
@property (strong ,nonatomic) NSString *regist ;
@property (strong ,nonatomic) NSString *registNo ;

@end
