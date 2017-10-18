//
//  CreditExchangeResponse.m
//  iCars
//
//  Created by xuhu on 14-11-26.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "CreditExchangeResponse.h"

/*
 * 积分对换响应类
 */
@implementation CreditExchangeResponse

- (void)setResultData:(id)inParam {
    [self setHeadData:inParam];
    NSLog(@"%@",inParam);
    if([inParam isKindOfClass:[NSDictionary class]]){
        NSArray *resuAry = [inParam objectForKey:RESULT];
        self.creExcAry = [[NSMutableArray alloc] init];
        for (NSDictionary *resuDic in resuAry) {
            CreditExchangeElement *element = [JsonElementUtils jsonCreditExchangeElement:resuDic];
            [self.creExcAry addObject:element];
        }
    }
}

- (void)setHeadData:(id)inParam{
    self.resultCode = [inParam objectForKey:MSGCODE];
}

@end
