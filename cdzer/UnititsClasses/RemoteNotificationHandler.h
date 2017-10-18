//
//  RemoteNotificationHandler.h
//  cdzer
//
//  Created by KEns0n on 9/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteNotificationHandler : NSObject

+ (RemoteNotificationHandler *)shareInstance;

+ (BOOL)runningInBackground;

+ (BOOL)runningInForeground;

- (void)handleRemoteNotification:(NSDictionary *)pushData;

@end
