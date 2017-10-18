//
//  NSString+ExtFunctions.m
//  cdzer
//
//  Created by KEns0n on 2/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "NSString+ExtFunctions.h"

@implementation NSString (ExtFunctions)

- (BOOL)isContainsString:(NSString *)str {
    if (!str) return NO;
    if ([self respondsToSelector:@selector(containsString:)]) {
        return [self containsString:str];
    }
    return ([self rangeOfString:str].location!=NSNotFound);
}

- (NSString *)URLEncodedString {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

- (NSString *)URLDecodedString {
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

// 十六进制转换为普通字符串的
- (NSString *)hexStringToString {
    @autoreleasepool {
        char *myBuffer = (char *)malloc((int)[self length] / 2 + 1);
        bzero(myBuffer, [self length] / 2 + 1);
        for (int i = 0; i < [self length] - 1; i += 2) {
            unsigned int anInt;
            NSString * hexCharStr = [self substringWithRange:NSMakeRange(i, 2)];
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            myBuffer[i / 2] = (char)anInt;
        }
        NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
        NSLog(@"------字符串=======%@",unicodeString);
        return unicodeString;
    }
    
}

//普通字符串转换为十六进制的。
- (NSString *)stringToHexString {
    NSData *myD = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

@end
