//
//  APIsErrorHandler.h
//  cdzer
//
//  Created by KEns0n on 4/20/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIsErrorHandler : NSObject
+ (BOOL)isTokenErrorWithResponseObject:(id)responseObject dismissHUD:(BOOL)dismissHUD;
@end
