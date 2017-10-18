//
//  BaseViewController.h
//  cdzer
//
//  Created by KEns0n on 2/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
@class KeyCityDTO;
#import <UIKit/UIKit.h>
#import "BaseConfigLoadingHeader.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIScrollView *scrollView;
///用户accessToken
@property (nonatomic, readonly) NSString *accessToken;

@property (nonatomic, assign) BOOL shouldReloadData;

@property (nonatomic, assign) BOOL ignoreViewResize;

@property (nonatomic, strong) NSMutableArray *reloadFuncWithParaList;

@property (nonatomic, assign) BOOL viewWillDisappearShoulPassIt;

@property (nonatomic, strong) NSNumber *pageNums;
@property (nonatomic, strong) NSNumber *pageSizes;
@property (nonatomic, strong) NSNumber *totalPageSizes;

- (void)pageObjectPlusOne;
- (void)pageObjectMinusOne;
- (void)pageObjectToDefault;

- (void)handleMissingTokenAction;

- (BOOL)executeReloadFunction;

- (void)reloadViewData;

- (void)setReloadFuncWithAction:(SEL)action parametersList:(NSArray *)parametersList;

@end



//
//[self setReloadFuncWithAction:_cmd parametersList:nil];
//- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
//    if (isSuccess) {
//        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
//            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            }];
//            return;
//        }
//        NSLog(@"success reload function %d", [self executeReloadFunction]);
//    }else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//}