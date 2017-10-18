//
//  ProgressHUDHandler.h
//  cdzer
//
//  Created by KEns0n on 4/18/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PHUDCompletionBlock)(void);

@interface ProgressHUDHandler : NSObject

# pragma mark - Show HUD
+ (void)showHUD;

+ (void)showHUDWithTitle:(NSString *)title onView:(UIView *)superview;


# pragma mark - Show Progress HUD
+ (void)showStartProgress;

+ (void)showStartProgressStatusWithTitle:(NSString *)title onView:(UIView *)superview;

+ (void)updateHUDProgress:(CGFloat)progress;

+ (void)updateProgressStatusWithTitle:(NSString *)title;


# pragma mark - Show Success HUD
+ (void)showSuccess;

+ (void)showSuccessWithStatus:(NSString *)status onView:(UIView *)superview completion:(PHUDCompletionBlock)completion;


# pragma mark - Show Error HUD
+ (void)showError;

+ (void)showErrorWithStatus:(NSString *)status onView:(UIView *)superview completion:(PHUDCompletionBlock)completion;


# pragma mark - Dismiss HUD
+ (void)dismissHUD;

+ (void)dismissHUDWithCompletion:(PHUDCompletionBlock)completion;

# pragma mark - HUD Status
+ (BOOL)isVisible;

@end
