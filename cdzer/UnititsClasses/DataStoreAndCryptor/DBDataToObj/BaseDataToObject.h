//
//  BaseDataToObject.h
//  cdzer
//
//  Created by KEns0nLau on 7/1/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDataToObject : NSObject

- (NSString *)verifyAndConvertDataToString:(id)data;

- (NSNumber *)verifyAndConvertDataToNumber:(id)data;

@end
