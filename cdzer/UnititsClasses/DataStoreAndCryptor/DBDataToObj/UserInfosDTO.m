//
//  UserInfosDTO.m
//  cdzer
//
//  Created by KEns0n on 8/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "UserInfosDTO.h"

@interface UserInfosDTO ()
{
    NSNumber *_dbUID;
    NSNumber *_lastUpdate;
}
@end

@implementation UserInfosDTO

- (instancetype)init {
    self = [super init];
    if (self) {
        _dbUID = @1;
        self.gender = @0;
        self.credits = @"0";
        self.qqNum = @"";
        self.nichen = @"";
        self.modelName = @"";
        self.portrait = @"";
        self.birthday = @"";
        self.email = @"";
        self.telphone = @"";
        self.realname = @"";
    }
    return self;
}

- (NSDictionary *)processObjectToDBData {
    NSDictionary *data = @{@"id":_dbUID,
                           @"birthday":_birthday,
                           @"email":_email,
                           @"face_img":_portrait,
                           @"nichen":_nichen,
                           @"credits":_credits,
                           @"qq":_qqNum,
                           @"sex":_gender,
                           @"spec_name":_modelName,
                           @"telphone":_telphone,
                           @"realname":_realname,};
    
    return data;
}


- (void)processDataToObjectWithData:(NSDictionary *)userData isFromDB:(BOOL)isFromDB {
    if (userData) {
        @autoreleasepool {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            _dbUID = @1;
            
            self.gender = userData[@"sex"];
            
            self.credits = @"0";
            id credits = userData[@"credits"];
            if (credits&&![credits isKindOfClass:NSNull.class]&&![credits isEqualToString:@""]) {
                self.credits = credits;
                if ([userData[@"credits"] isKindOfClass:NSNumber.class]) {
                    self.credits = [formatter stringFromNumber:userData[@"credits"]];
                }
            }
            
            self.realname = @"";
            id realname = userData[@"realname"];
            if (realname&&![realname isKindOfClass:NSNull.class]&&![realname isEqualToString:@""]) {
                self.realname = realname;
            }
            
            
            self.qqNum = @"";
            id qqNum = userData[@"qq"];
            if (qqNum&&![qqNum isKindOfClass:NSNull.class]&&![qqNum isEqualToString:@""]) {
                self.qqNum = qqNum;
                if ([userData[@"qq"] isKindOfClass:NSNumber.class]) {
                    self.qqNum = [formatter stringFromNumber:userData[@"qq"]];
                }
            }
            
            self.nichen = @"";
            id nichen = userData[@"nichen"];
            if (nichen&&![nichen isKindOfClass:NSNull.class]&&![nichen isEqualToString:@""]) {
                self.nichen = nichen;
            }
            
            self.modelName = @"";
            id modelName = userData[@"spec_name"];
            if (modelName&&![modelName isKindOfClass:NSNull.class]&&![modelName isEqualToString:@""]) {
                self.modelName = modelName;
            }
            
            self.portrait = @"";
            id portrait = userData[@"face_img"];
            if (portrait&&![portrait isKindOfClass:NSNull.class]&&![portrait isEqualToString:@""]) {
                self.portrait = portrait;
            }
            
            self.birthday = @"";
            id birthday = userData[@"birthday"];
            if (birthday&&![birthday isKindOfClass:NSNull.class]&&![birthday isEqualToString:@""]) {
                self.birthday = birthday;
            }
            
            self.email = @"";
            id email = userData[@"email"];
            if (email&&![email isKindOfClass:NSNull.class]&&![email isEqualToString:@""]) {
                self.email = email;
            }
            
            self.telphone = @"";
            id telphone = userData[@"telphone"];
            if (telphone&&![telphone isKindOfClass:NSNull.class]&&![telphone isEqualToString:@""]) {
                self.telphone = telphone;
            }
            
            
            _lastUpdate = nil;
            if (isFromDB) {
                _lastUpdate = userData[@"last_datetime"];
            }
        }
    }
}

@end
