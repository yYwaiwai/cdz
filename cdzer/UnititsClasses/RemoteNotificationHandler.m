//
//  RemoteNotificationHandler.m
//  cdzer
//
//  Created by KEns0n on 9/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RemoteNotificationHandler.h"

@implementation RemoteNotificationHandler
static RemoteNotificationHandler *_remoteNotificationnstance  = nil;

+ (RemoteNotificationHandler *)shareInstance {
    
    if (!_remoteNotificationnstance) {
        _remoteNotificationnstance = [RemoteNotificationHandler new];
    }
    return _remoteNotificationnstance;
}

+ (BOOL)runningInBackground {
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}

+ (BOOL)runningInForeground {
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateActive);
    
    return result;
}

- (void)handleRemoteNotification:(NSDictionary *)pushData {
    
}

@end
