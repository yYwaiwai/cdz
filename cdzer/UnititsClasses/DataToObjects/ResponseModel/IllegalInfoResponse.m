//
//  IllegalInfoResponse.m
//  iCars
//
//  Created by xuhu on 14-10-17.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "IllegalInfoResponse.h"

/*
 *违章信息的服务响应类
 */
@implementation IllegalInfoResponse

- (void)setResultData:(id)inParam{
    if(inParam && [inParam isKindOfClass:[NSDictionary class]]){
        [self setHeadData:inParam];
        NSArray *resultAry = [inParam objectForKey:@"result"];
        self.illAry = [[NSMutableArray alloc] init];
        for (NSDictionary *resuDic in resultAry) {
           IllegalInfoElement *element = [JsonElementUtils jsonIllegalInfoElement:resuDic];
            [self.illAry addObject:element];
        }
    }
}

- (void)setHeadData:(id)inParam{
     self.resultCode = [NSString stringWithFormat:@"%@",[inParam objectForKey:@"msgCode"]];
}

@end
