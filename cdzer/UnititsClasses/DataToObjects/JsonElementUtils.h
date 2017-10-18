//
//  JsonElementUtils.h
//  iCars
//
//  Created by xuhu on 14-9-23.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnectronicElement.h"
#import "PositionDto.h"
#import "IllegalInfoElement.h"
#import "CreditExchangeElement.h"
#import "ParamKeyString.h"
#import "CreditRecordElement.h"


/*
 * Json的数据解析工具类
 */
@interface JsonElementUtils : NSObject


#pragma mark -电子围栏信息类的解析方法
+(EnectronicElement *) jsonEnectronicElement:(id) jsonResult ;

#pragma mark -位置信息模型解析方法
+(PositionDto *)jsonPositionDto:(id) jsonResult ;

#pragma mark -违章信息模型的解析方法
+(IllegalInfoElement *)jsonIllegalInfoElement:(id) jsonResult ;

#pragma mark -积分对换模型的解析方法
+(CreditExchangeElement *)jsonCreditExchangeElement:(id) jsonResult ;

#pragma mark -积分记录模型的解析方法
+(CreditRecordElement *)jsonCreditRecordElement:(id) jsonResult ;

@end
