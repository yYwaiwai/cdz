//
//  AppDelegate.h
//  cdzer
//
//  Created by KEns0n on 2/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BaseNavigationController *navViewController;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;


@end

