//
//  APNsHandler.h
//  cdzer
//
//  Created by KEns0n on 3/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NotificationMessageMainType)
{
    NotificationMessageMainTypeOfUnknow = 0,
    NotificationMessageMainTypeOfOrderMessage,
    NotificationMessageMainTypeOfGPSMessage,
    NotificationMessageMainTypeOfSystemMessage,
    NotificationMessageMainTypeOfAutosMaintenanceMessage,
    
};

@interface APNsHandler : NSObject

+ (void)handleLocalNotificationWithApplication:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

+ (void)handleRemoteNotificationWithApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
