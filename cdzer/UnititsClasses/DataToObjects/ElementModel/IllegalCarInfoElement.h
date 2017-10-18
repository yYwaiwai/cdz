//
//  IllegalCarInfoElement.h
//  iCars
//
//  Created by xuhu on 14-10-16.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 违章车辆信息模型类
 */
@interface IllegalCarInfoElement : NSObject

@property (strong ,nonatomic) NSString *cityName ;
@property (strong ,nonatomic) NSString *cityCode ;
@property (strong ,nonatomic) NSString *carType ;
@property (strong ,nonatomic) NSString *plateNo ;
@property (strong ,nonatomic) NSString *enginerNo ;
@property (strong ,nonatomic) NSString *rackNo ;

@end
