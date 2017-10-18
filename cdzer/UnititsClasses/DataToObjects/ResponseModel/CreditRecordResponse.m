//
//  CreditRecordResponse.m
//  iCars
//
//  Created by xuhu on 14-11-27.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "CreditRecordResponse.h"

/*
 * 积分记录的数据响应类
 */
@implementation CreditRecordResponse


- (void)setResultData:(id)inParam{
    [self setHeadData:inParam];
    if([inParam isKindOfClass:[NSDictionary class]]){
        NSArray *itemAry = [inParam objectForKey:RESULT];
        self.recordAry = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in itemAry) {
            CreditRecordElement *element = [JsonElementUtils jsonCreditRecordElement:dic];
            [self.recordAry addObject:element];
        }
    }
}

- (void)setHeadData:(id)inParam{
    self.resultCode = [inParam objectForKey:MSGCODE];
}

@end
