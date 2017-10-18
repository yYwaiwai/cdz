//
//  SecurityCryptor.h
//  frp_test
//
//  Created by KEns0n on 4/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityCryptor : NSObject
+ (SecurityCryptor *)shareInstance;

- (NSString *)tokenEncryption:(NSString *)token;

- (NSString *)tokenDecryption:(NSString *)encryptedToken;
@end
