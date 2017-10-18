//
//  NSURLSessionTask+ExtUserInfo.m
//  cdzer
//
//  Created by 车队长 on 2017/4/19.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "NSURLSessionTask+ExtUserInfo.h"

@implementation NSURLSessionTask (ExtUserInfo)

@dynamic userInfo;
static char userInfoKey;

- (void)setUserInfo:(NSDictionary *)userInfo {
    objc_setAssociatedObject(self, &userInfoKey, userInfo ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)userInfo {
    return (NSDictionary *)objc_getAssociatedObject(self, &userInfoKey);
}



@end
