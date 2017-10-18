//
//  ProgressHUDHandler.m
//  cdzer
//
//  Created by KEns0n on 4/18/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
static PHUDCompletionBlock completionBlock;

#import "ProgressHUDHandler.h"
//#import <KVNProgress/KVNProgress.h>
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ProgressHUDHandler

# pragma mark - Show HUD

+ (void)setUpNotificationResponse{
    [NSNotificationCenter.defaultCenter addObserver:ProgressHUDHandler.class selector:@selector(completionBlock:) name:SVProgressHUDDidDisappearNotification object:nil];
}

+ (void)completionBlock:(NSNotification *)notiObj {
    if (completionBlock) {
        completionBlock();
        [NSNotificationCenter.defaultCenter removeObserver:ProgressHUDHandler.class];
    }
}

+ (void)setCompletionBlock:(PHUDCompletionBlock)completion {
    if (completion) {
        completionBlock = completion;
    }else {
        [NSNotificationCenter.defaultCenter removeObserver:ProgressHUDHandler.class];
    }
}

+ (void)showHUD {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD show];
}

+ (void)showHUDWithTitle:(NSString *)title onView:(UIView *)superview {
    [SVProgressHUD setViewForExtension:superview];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showWithStatus:title];

}
# pragma mark Show HUD End

# pragma mark - Show Progress HUD
+ (void)showStartProgress {
    [self showStartProgressStatusWithTitle:nil onView:nil];
}

+ (void)showStartProgressStatusWithTitle:(NSString *)title onView:(UIView *)superview {
    [SVProgressHUD setViewForExtension:superview];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showProgress:0.0f status:title];
}

+ (void)updateHUDProgress:(CGFloat)progress {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showProgress:progress];
}

+ (void)updateProgressStatusWithTitle:(NSString *)title {
    [SVProgressHUD setStatus:title];
}
# pragma mark Show Progress HUD End

# pragma mark - Show Success HUD
+ (void)showSuccess {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showSuccessWithStatus:getLocalizationString(@"success")];
}

+ (void)showSuccessWithStatus:(NSString *)status onView:(UIView *)superview completion:(PHUDCompletionBlock)completion {
    [self setUpNotificationResponse];
    [SVProgressHUD setViewForExtension:superview];
    if ([status isEqualToString:@""]) {
        status = getLocalizationString(@"success");
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showSuccessWithStatus:status];
    [self setCompletionBlock:(PHUDCompletionBlock)completion];
}
# pragma mark Show Success HUD End

# pragma mark - Show Error HUD
+ (void)showError {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showErrorWithStatus:getLocalizationString(@"error")];
}

+ (void)showErrorWithStatus:(NSString *)status onView:(UIView *)superview completion:(PHUDCompletionBlock)completion {
    [self setUpNotificationResponse];
    [SVProgressHUD setViewForExtension:superview];
    if ([status isEqualToString:@""]) {
        status = getLocalizationString(@"error");
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
    [SVProgressHUD showErrorWithStatus:status];
    [self setCompletionBlock:(PHUDCompletionBlock)completion];
}
# pragma mark Show Error HUD End

# pragma mark - Dismiss HUD
+ (void)dismissHUD {
    [self dismissHUDWithCompletion:nil];
}

+ (void)dismissHUDWithCompletion:(PHUDCompletionBlock)completion {
    [self setUpNotificationResponse];
    [self setCompletionBlock:(PHUDCompletionBlock)completion];
    [SVProgressHUD dismiss];
}
# pragma mark Dismiss HUD End

# pragma mark - HUD Status

+ (BOOL)isVisible {
    return [SVProgressHUD isVisible];
}

# pragma mark HUD Status End

//static void dispatch_main_after(NSTimeInterval delay, void (^block)(void))
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        block();
//    });
//}

@end
