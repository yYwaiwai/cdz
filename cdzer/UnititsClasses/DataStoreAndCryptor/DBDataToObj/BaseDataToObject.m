//
//  BaseDataToObject.m
//  cdzer
//
//  Created by KEns0nLau on 7/1/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"

@implementation BaseDataToObject

- (NSString *)verifyAndConvertDataToString:(id)data {
    NSString *string = data;
    if ([data isKindOfClass:NSNumber.class]) {
        string = [(NSNumber*)data stringValue];
    }
    if (!string||[string isKindOfClass:NSNull.class]) {
        string = @"";
    }
    return string;
}

- (NSNumber *)verifyAndConvertDataToNumber:(id)data {
    NSNumber *number = data;
    if ([data isKindOfClass:NSString.class]) {
        if ([data rangeOfString:@"."].location!=NSNotFound) {
            number = @([(NSString*)data doubleValue]);
        }else {
            number = @([(NSString*)data longLongValue]);
        }
    }
    if (!number||[number isKindOfClass:NSNull.class]) {
        number = @(0);
    }
    return number;
}
@end
