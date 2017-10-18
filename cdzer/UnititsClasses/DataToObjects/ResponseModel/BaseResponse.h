//
//  BaseResponse.h
//  iCars
//
//  Created by xuhu on 14-9-23.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonElementUtils.h"
#import "ParamKeyString.h"

/*
 * 请求数据响应基类
 */
@interface BaseResponse : NSObject

@property (strong ,nonatomic) NSString *resultCode ;
@property (strong ,nonatomic) NSString *errorMsg ;

#pragma mark -设置返回数据内容解析的方法
- (void)setResultData:(id) inParam ;


#pragma mark -设置返回数据内容头部解析方法
- (void)setHeadData:(id) inParam ;

@end
