//
//  JsonElementUtils.m
//  iCars
//
//  Created by xuhu on 14-9-23.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "JsonElementUtils.h"

/*
 * Json的数据解析工具类
 */
@implementation JsonElementUtils

#pragma mark -电子围栏信息类的解析方法
+(EnectronicElement *) jsonEnectronicElement:(id) jsonResult {
    EnectronicElement *element ;
    if([jsonResult isKindOfClass:[NSDictionary class]]){
        element = [[EnectronicElement alloc] init];
        element.imei = [jsonResult objectForKey:@"imei"];
        element.latitude = [jsonResult objectForKey:@"latitude"];
        element.longitude = [jsonResult objectForKey:@"longitude"];
        element.time = [jsonResult objectForKey:@"time"];
        element.type = [jsonResult objectForKey:@"type"];
    }
    return element ;
}

#pragma mark -位置信息模型解析方法
+(PositionDto *)jsonPositionDto:(id) jsonResult {
    PositionDto *element ;
    if([jsonResult isKindOfClass:[NSDictionary class]]){
        element = [[PositionDto alloc] init];
        element.imei = [jsonResult objectForKey:@"imei"];
        element.acc = [[jsonResult objectForKey:@"acc"] intValue];
        element.longitude = [[jsonResult objectForKey:@"lon"] doubleValue];
        element.latitude = [[jsonResult objectForKey:@"lat"] doubleValue];
        element.moveSpeed = [[jsonResult objectForKey:@"speed"] doubleValue];
        element.moveDirection = [[jsonResult objectForKey:@"direction"] doubleValue];
        element.mileage = [[jsonResult objectForKey:@"mileage"] doubleValue];
        element.time = [jsonResult objectForKey:@"time"];
    
    }
    return element ;
}

#pragma mark -违章信息模型的解析方法
+(IllegalInfoElement *)jsonIllegalInfoElement:(id) jsonResult {
    IllegalInfoElement *element ;
    if([jsonResult isKindOfClass:[NSDictionary class]]){
        element = [[IllegalInfoElement alloc] init];
        element.act = [jsonResult objectForKey:@"act"];
        element.area = [jsonResult objectForKey:@"area"];
        element.code = [jsonResult objectForKey:@"code"];
        element.date = [jsonResult objectForKey:@"date"];
        element.fen = [jsonResult objectForKey:@"fen"];
        element.handled = [NSString stringWithFormat:@"%@",[jsonResult objectForKey:@"handled"]];
        element.money = [jsonResult objectForKey:@"money"];
    }
    return element ;
}

#pragma mark -积分对换模型的解析方法
+(CreditExchangeElement *)jsonCreditExchangeElement:(id) jsonResult {
    CreditExchangeElement *element ;
    if([jsonResult isKindOfClass:[NSDictionary class]]){
        element = [[CreditExchangeElement alloc] init];
        element.marketPrice = [NSString stringWithFormat:@"%@",[jsonResult objectForKey:@"marketPrice"]];
        element.name = [jsonResult objectForKey:NAME];
        element.number = [jsonResult objectForKey:@"number"];
        element.productType = [jsonResult objectForKey:@"productType"];
        element.scale = [jsonResult objectForKey:@"scale"];
    }
    return element ;
}

#pragma mark -积分记录模型的解析方法
+(CreditRecordElement *)jsonCreditRecordElement:(id) jsonResult {
    CreditRecordElement *element  ;
    if([jsonResult isKindOfClass:[NSDictionary class]]){
        element = [[CreditRecordElement alloc] init];
        element.contacts = [NSString stringWithFormat:@"%@",[jsonResult objectForKey:@"contacts"]];
        element.costTypeName = [jsonResult objectForKey:@"costTypeName"];
        element.createTime = [jsonResult objectForKey:@"createTime"];
        element.credits = [jsonResult objectForKey:@"credits"];
        element.goodName = [jsonResult objectForKey:@"goodName"];
        element.orderPrice = [NSString stringWithFormat:@"%@",[jsonResult objectForKey:@"orderPrice"]];
        element.shopName = [jsonResult objectForKey:@"shopName"];
        element.stateName = [jsonResult objectForKey:@"stateName"];
    }
    return element ;
}

@end
