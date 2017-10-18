//
//  UIViewController+ShareAction.h
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectedAutosInfoDTO.h"
#import "KeyCityDTO.h"
typedef void(^UserAutosSelectonResultBlock)(UserSelectedAutosInfoDTO *selectedAutosDto);

@protocol UserLoginHandlerProtocol <NSObject>
@optional
- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert;

- (BOOL)viewControllerDefautLoginAfterShouldPopToRoot;

@end

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
- (BOOL)navigationShouldPopOnBackButton;

- (void)handleNavBackBtnPopOtherAction;

@end

@interface UIViewController (ShareAction) <UserLoginHandlerProtocol, BackButtonHandlerProtocol>

@property (nonatomic, assign) BOOL navShouldPopOtherVC;

@property (nonatomic, assign) BOOL loginAfterShouldPopToRoot;

#pragma mark-- 配置导航栏按钮
- (void)setDefaultNavBackButtonWithoutTitle;

- (void)setNavBackButtonTitleOrImage:(id)titleOrImage titleColor:(UIColor *)color;

- (void)setNavBackButtonTitleOrImage:(id)titleOrImage titleColor:(UIColor *)color withTarget:(id)target action:(SEL)action;

- (UIBarButtonItem *)setRightNavButtonWithTitleOrImage:(id)sender style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action titleColor:(UIColor *)color isNeedToSet:(BOOL)isNeedToSet;

- (UIBarButtonItem *)setRightNavButtonWithSystemItemStyle:(UIBarButtonSystemItem)style target:(id)target action:(SEL)action isNeedToSet:(BOOL)isNeedToSet;

- (UIBarButtonItem *)setLeftNavButtonWithTitleOrImage:(id)sender style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action titleColor:(UIColor *)color isNeedToSet:(BOOL)isNeedToSet;

- (UIBarButtonItem *)setLeftNavButtonWithSystemItemStyle:(UIBarButtonSystemItem)style target:(id)target action:(SEL)action isNeedToSet:(BOOL)isNeedToSet;

#pragma mark-- VC公用功能

- (void)pushToAutosSelectionViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag onlyForSelection:(BOOL)onlyForSelection andSelectionResultBlock:(UserAutosSelectonResultBlock)resultBlock;

- (void)presentLoginViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag completion:(void (^)(void))completion;

- (void)pushToCitySelectionViewWithBackTitle:(NSString *)backTitle selectedCity:(KeyCityDTO *)selectedCity hiddenLocation:(BOOL)hidden onlySelection:(BOOL)onlySelection animated:(BOOL)flag;

@end
