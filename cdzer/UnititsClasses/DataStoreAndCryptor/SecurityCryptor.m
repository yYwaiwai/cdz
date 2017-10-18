//
//  SecurityCryptor.m
//  frp_test
//
//  Created by KEns0n on 4/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "SecurityCryptor.h"
#import <CocoaSecurity/CocoaSecurity.h>

@interface SecurityCryptor ()
@end

@implementation SecurityCryptor

static SecurityCryptor *cryptoreInstance = nil;

+ (SecurityCryptor *)shareInstance {
    
    if (!cryptoreInstance) {
        cryptoreInstance = [SecurityCryptor new];
    }
    
    return cryptoreInstance;
}

- (NSString *)getencryptionKey {
    CocoaSecurityResult *result = [CocoaSecurity md5:@"#G@@QFYg>\65zjtFBYNc6:<HN;YP^d4X3kfj|G;Y"];
    return result.hex;
}

- (NSString *)getIVKey {
    CocoaSecurityResult *result = [CocoaSecurity md5:@"Y6DFKBPFZMDcL1GN5vTR8sSZ7SoK3KnR"];
    return result.hex;
}

- (NSString *)tokenEncryption:(NSString *)token {
    if (!token) return nil;
    CocoaSecurityResult *result = [CocoaSecurity aesEncrypt:token hexKey:[self getencryptionKey] hexIv:[self getIVKey]];
    return result.base64;
}

- (NSString *)tokenDecryption:(NSString *)encryptedToken {
    if (!encryptedToken) return nil;
    CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithBase64:encryptedToken hexKey:[self getencryptionKey] hexIv:[self getIVKey]];
    return result.utf8String;
}

@end
