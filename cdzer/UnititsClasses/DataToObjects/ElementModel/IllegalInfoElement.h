//
//  IllegalInfo.h
//  iCars
//
//  Created by xuhu on 14-10-17.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 违章信息的数据模型类
 */
@interface IllegalInfoElement : NSObject


@property (strong ,nonatomic) NSString *act ;
@property (strong ,nonatomic) NSString *area ;
@property (strong ,nonatomic) NSString *code ;
@property (strong ,nonatomic) NSString *date ;
@property (strong ,nonatomic) NSString *fen ;
@property (strong ,nonatomic) NSString *handled ;
@property (strong ,nonatomic) NSString *money ;

@end
