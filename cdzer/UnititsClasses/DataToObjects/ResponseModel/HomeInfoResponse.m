//
//  HomeInfoResponse.m
//  iCars
//
//  Created by xuhu on 14-11-26.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "HomeInfoResponse.h"

@implementation HomeInfoResponse

- (void)setResultData:(id)inParam {
    [self setHeadData:inParam];
    NSLog(@"%@",inParam);
}

- (void)setHeadData:(id)inParam {
    self.resultCode = [NSString stringWithFormat:@"%@",[inParam objectForKey:@"msgCode"]];
}

@end
