//
//  BDPushConfigDTO.m
//  cdzer
//
//  Created by KEns0n on 9/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BDPushConfigDTO.h"

@interface BDPushConfigDTO ()
{
    NSNumber *_dbUID;
}
@end



@implementation BDPushConfigDTO

- (instancetype)init {
    self = [super init];
    if (self) {
        _dbUID = @(1);
        _bdpUserID = @"";
        _deviceToken = @"";
        _channelID = @"";
    }
    return self;
}

- (NSDictionary *)processObjectToDBData {
    NSDictionary *data = @{@"id":_dbUID,
                           @"bdp_user_id":_bdpUserID,
                           @"channel_id":_channelID,
                           @"device_token":_deviceToken};
    
    return data;
}

@end
