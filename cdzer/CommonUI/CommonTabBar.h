//
//  CommonTabBar.h
//  cdzer
//
//  Created by KEns0n on 2/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommonTabBar;
@protocol CommonTabBarDelegate <NSObject>

@optional

- (void)commonTabBar:(CommonTabBar *)tabBar didSelectItemID:(NSInteger)itemID;

@end

@interface CommonTabBar : UITabBar

@property (nonatomic, assign) id <CommonTabBarDelegate> CTBDelegate;

- (void)initializationUIWithID:(NSInteger)theID;

@end
