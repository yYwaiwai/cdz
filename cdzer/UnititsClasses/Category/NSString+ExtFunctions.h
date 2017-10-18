//
//  NSString+ExtFunctions.h
//  cdzer
//
//  Created by KEns0n on 2/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ExtFunctions)

- (BOOL)isContainsString:(NSString *)str;

- (NSString *)URLEncodedString;

- (NSString *)URLDecodedString;

// 十六进制转换为普通字符串的
- (NSString *)stringToHexString;

//普通字符串转换为十六进制的。
- (NSString *)hexStringToString;

@end
