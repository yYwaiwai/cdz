//
//  APIsErrorHandler.m
//  cdzer
//
//  Created by KEns0n on 4/20/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "APIsErrorHandler.h"
#import "APIsDefine.h"
#import "SignInVC.h"
#import "AppDelegate.h"
#import "BaseNavigationController.h"
@implementation APIsErrorHandler
static APIsErrorHandler *errorInstance;

+ (void)setErrorInstance {
    if (!errorInstance) {
        errorInstance = APIsErrorHandler.new;
        [NSNotificationCenter.defaultCenter addObserver:errorInstance selector:@selector(getLoginResponse:) name:CDZNotiKeyOfTokenUpdate object:nil];   
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:errorInstance];
}

- (void)getLoginResponse:(NSNotification*)notiObj {
    BaseNavigationController *navigationController = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
    BaseViewController *lastVisibleViewController = (BaseViewController *)navigationController.visibleViewController;
    if ([lastVisibleViewController respondsToSelector:@selector(handleUserLoginResult:fromAlert:)]&&notiObj.userInfo[@"result"]) {
        BOOL isSuccess = [notiObj.userInfo[@"result"] boolValue];
        [lastVisibleViewController handleUserLoginResult:isSuccess fromAlert:NO];
        
    }else {
        NSLog(@"_responseBlock or userInfo missing");
    }
}

+ (BOOL)isTokenErrorWithResponseObject:(id)responseObject dismissHUD:(BOOL)dismissHUD {
    @autoreleasepool {
        [self setErrorInstance];
        if (![responseObject isKindOfClass:NSDictionary.class]) return NO;
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([message rangeOfString:@"token"].location!=NSNotFound && [message rangeOfString:@"错误"].location!=NSNotFound ) {
            [[DBHandler shareInstance] clearUserIdentData];
            if (dismissHUD) {
                [ProgressHUDHandler dismissHUDWithCompletion:^{
                    [self responseAction];
                }];
            }else {
                [self responseAction];
            }
            return YES;
        }
        
        return NO;
    }
}

+ (void)responseAction {
    if (UserBehaviorHandler.shareInstance.wasShowLoginAlert) {return;}
    [UserBehaviorHandler.shareInstance setShowLoginAlert:YES];
    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"你登录凭证已失效请重新登录已取得跟多功能" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        BaseNavigationController *navigationController = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
        if (btnIdx.integerValue>0) {
            SignInVC *vc = [SignInVC new];
            vc.ignoreViewResize = YES;
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationPageSheet;
            nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nav.navigationBarHidden = YES;
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [navigationController presentViewController:nav animated:YES completion:nil];

        }else {
            [UserBehaviorHandler.shareInstance userLogoutWasPopupDialog:NO andCompletionBlock:^{
                BaseViewController *vc = navigationController.viewControllers.lastObject;
                if ([navigationController.viewControllers.lastObject isKindOfClass:BaseTabBarController.class]) {
                    vc = (BaseViewController *)[(BaseTabBarController *)navigationController.viewControllers.lastObject selectedViewController];
                }
                
                if ([vc respondsToSelector:@selector(handleUserLoginResult:fromAlert:)]&&!vc.loginAfterShouldPopToRoot) {
                    [vc handleUserLoginResult:NO fromAlert:YES];
                }else {
                    [navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
        [UserBehaviorHandler.shareInstance setShowLoginAlert:NO];
    }];

}

@end
