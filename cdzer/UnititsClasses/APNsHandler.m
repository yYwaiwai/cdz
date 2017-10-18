//
//  APNsHandler.m
//  cdzer
//
//  Created by KEns0n on 3/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kAlert @"alert"
#define kAPBody @"aps"
#define kActionBody @"jsonObject"
#define kMessageMainType @"messageMainType"
#define kMessageSubType @"type"
#define kDataID @"id"
#import "APNsHandler.h"
#import "BPush.h"
#import "AppDelegate.h"
#import <TWMessageBarManager/TWMessageBarManager.h>
#import "MYCumulativeScoringVC.h"
#import "MyEnquiryVC.h"
#import "MessageAlertVC.h"
#import "OrderCommentNReviewsVC.h"
#import "OrderDetailsVC.h"



@implementation APNsHandler

static APNsHandler *_APNsHandlerInstance  = nil;

+ (APNsHandler *)shareInstance {
    if (!_APNsHandlerInstance) {
        _APNsHandlerInstance = APNsHandler.new;
    }
    return _APNsHandlerInstance;
}

+ (void)createLocalNotification {
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:10]; //触发通知的时间
        notification.repeatInterval=0; //循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody=@"该去吃晚饭了！";
        
        notification.alertAction = @"打开";  //提示框按钮
        notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
        
        //下面设置本地通知发送的消息，这个消息可以接受
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
        notification.userInfo = infoDic;
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

+ (void)handleLocalNotificationWithApplication:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if (application.applicationState==UIApplicationStateInactive) {
        NSLog(@"UIApplicationStateInactive－接收远程通知啦！！！");
    }
    if (application.applicationState==UIApplicationStateBackground) {
        NSLog(@"UIApplicationStateBackground－接收远程通知啦！！！");
    }
    
    if (application.applicationState==UIApplicationStateActive) {
        NSLog(@"UIApplicationStateActive－接收远程通知啦！！！");
    }
}

+ (void)handleRemoteNotificationWithApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self shareInstance];
    NSMutableDictionary *userInfoWithMessageType = [self verifyMainMessageType:userInfo];
    [self handleNotificationWithApplication:application withNotificationInfo:userInfoWithMessageType];
}

+ (NSMutableDictionary *)verifyMainMessageType:(NSDictionary *)userInfo {
    if (userInfo.count==0) {
        return nil;
    }
    NSDictionary *messageBody = userInfo[kAPBody];
    NSString *message = messageBody[kAlert];
    NSMutableDictionary *userInfoWithMessageType = [SupportingClass deepMutableObject:userInfo];
    if ([message isContainsString:@"订单消息"]) {
        [userInfoWithMessageType setObject:@(NotificationMessageMainTypeOfOrderMessage) forKey:kMessageMainType];
    }
    if ([message isContainsString:@"系统消息"]) {
        [userInfoWithMessageType setObject:@(NotificationMessageMainTypeOfSystemMessage) forKey:kMessageMainType];
    }
    if ([message isContainsString:@"维修消息"]) {
        [userInfoWithMessageType setObject:@(NotificationMessageMainTypeOfAutosMaintenanceMessage) forKey:kMessageMainType];
    }
    if ([message isContainsString:@"GPS消息"]) {
        [userInfoWithMessageType setObject:@(NotificationMessageMainTypeOfGPSMessage) forKey:kMessageMainType];
    }
    if (!userInfoWithMessageType[kMessageMainType]) {
        [userInfoWithMessageType setObject:@(NotificationMessageMainTypeOfUnknow) forKey:kMessageMainType];
    }
    return userInfoWithMessageType;
}

+ (NSString *)messageMainTypeStringWithType:(NotificationMessageMainType)type {
    NSString *message = @"";
    switch (type) {
        case NotificationMessageMainTypeOfOrderMessage:
            message = @"订单消息";
            break;
            
        case NotificationMessageMainTypeOfSystemMessage:
            message = @"系统消息";
            break;
            
        case NotificationMessageMainTypeOfAutosMaintenanceMessage:
            message = @"维修消息";
            break;
            
        case NotificationMessageMainTypeOfGPSMessage:
            message = @"GPS消息";
            break;
            
        default:
            break;
    }
    return message;
}

+ (void)handleNotificationWithApplication:(UIApplication *)application withNotificationInfo:(NSDictionary *)userInfo {
    NotificationMessageMainType type = [userInfo[kMessageMainType] integerValue];
    if (type==NotificationMessageMainTypeOfUnknow) return;
    NSString *messageTypeStr = [self messageMainTypeStringWithType:type];
    
    NSDictionary *apnsDetial = userInfo[kAPBody];
    NSString *messageBody = apnsDetial[kAlert];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:[messageTypeStr stringByAppendingString:@":"] withString:@""];
    
    NSMutableDictionary *actionInfo = [userInfo[kActionBody] mutableCopy];
    [actionInfo setObject:@(type) forKey:kMessageMainType];
    @weakify(self);
    if (application.applicationState == UIApplicationStateActive) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:messageTypeStr description:messageBody type:TWMessageBarMessageTypeInfo duration:5 statusBarHidden:YES callback:^{
            @strongify(self);
            [self navPushToMessageRequestAction:actionInfo];
        }];
    }else {
        [self navPushToMessageRequestAction:actionInfo];
    }
    
}

+ (void)getOrderReplayData:(NSString *)dataID {
    if (!vGetUserToken) {
        return;
    }
    OrderCommentNReviewsVC *vc = [OrderCommentNReviewsVC new];
    vc.orderID = dataID;
    [self navPushVCWithViewController:vc];
    return;
    
    if (!vGetUserToken||!dataID) return;
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:vGetUserToken orderMainID:dataID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        
        OrderCommentNReviewsVC *vc = [OrderCommentNReviewsVC new];
        [self navPushVCWithViewController:vc];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

+ (void)getOrderDetailData:(NSString *)dataID withOrderStatus:(NSString *)stateName andCommentStatus:(NSString *)commentStatus{
    return;
#warning need replan order Notify
    if (!vGetUserToken) {
//        [self handleMissingTokenAction];
        return;
    }
    if (!vGetUserToken||!dataID) return;
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetPurchaseOrderDetailWithAccessToken:vGetUserToken orderMainID:dataID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        [self pushToOrderDetail:responseObject[CDZKeyOfResultKey] withOrderStatus:stateName andCommentStatus:commentStatus];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

+ (void)pushToOrderDetail:(id)detail withOrderStatus:(NSString *)stateName andCommentStatus:(NSString *)commentStatus {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
        NSArray *stateParameterList = [DBHandler.shareInstance getPurchaseOrderStatusList];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stateName = %@",stateName];
        OrderStatusDTO *stateDetail = [[stateParameterList filteredArrayUsingPredicate:predicate] firstObject];
        if (stateDetail) {
            if (stateDetail.orderStatusType==MyOrderStatusOfOrderFinish) {
                if (![commentStatus isEqualToString:@"1"]) {
                    stateDetail.orderWasNotCommented = YES;
                    
                }
            }
//            MyOrderDetailByStatusVC *vc = [MyOrderDetailByStatusVC new];
//            vc.orderListReloadState = @YES;
//            vc.navShouldPopOtherVC = YES;
//            [vc setupOrderDetail:detail withOrderStatus:stateDetail];
//            [self navPushVCWithViewController:vc];
            
        }
    }
}

+ (void)navPushVCWithViewController:(id)baseVC {
    if (baseVC) {
        BaseNavigationController *nav = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
        NSLog(@"%@", nav.visibleViewController.class);
        if (![nav.visibleViewController isKindOfClass:[baseVC class]] ) {
            if ([(BaseViewController *)nav.visibleViewController respondsToSelector:@selector(setNavBackButtonTitleOrImage:titleColor:)]) {
                [(BaseViewController *)nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
            }
            [nav pushViewController:baseVC animated:YES];
        }else {
            [nav popViewControllerAnimated:NO];
            [nav pushViewController:baseVC animated:NO];
        }
    }
}

+ (void)navPushToMessageRequestAction:(NSDictionary *)actionInfo {
    NotificationMessageMainType mainMessagetype = [actionInfo[kMessageMainType] integerValue];
    NSString *subMessageType = actionInfo[kMessageSubType];
    NSString *dataID = actionInfo[kDataID];
    id baseVC = nil;
    BOOL reloadVC = NO;
     if (mainMessagetype == NotificationMessageMainTypeOfSystemMessage ) {
         if ([subMessageType isEqualToString:@"integral"]) {
             baseVC = [MYCumulativeScoringVC new];
             reloadVC = YES;
         }
         
         if ([subMessageType isEqualToString:@"askPrice"]) {
             baseVC = [MyEnquiryVC new];
             reloadVC = YES;
         }
         
         if ([subMessageType isEqualToString:@"orderRepy"]) {
             if (dataID&&![dataID isEqualToString:@""]) {
                 [self getOrderReplayData:dataID];
             }
             return;
         }
         if ([subMessageType isEqualToString:@"system"]) {
             MessageAlertVC *vc = [MessageAlertVC new];
             vc.isNormalAlertMessage = YES;
             baseVC = vc;
             reloadVC = YES;
         }
         
         
         if (!baseVC) {
             MessageAlertVC *vc = [MessageAlertVC new];
             vc.isNormalAlertMessage = YES;
             baseVC = vc;
             reloadVC = YES;
         }
     }
    
    if (mainMessagetype == NotificationMessageMainTypeOfAutosMaintenanceMessage ) {
        
        if (!baseVC) {
            MessageAlertVC *vc = [MessageAlertVC new];
            vc.isNormalAlertMessage = YES;
            baseVC = vc;
            reloadVC = YES;
        }
        
    }
    
    if (mainMessagetype == NotificationMessageMainTypeOfGPSMessage ) {
        
        if (!baseVC) {
            MessageAlertVC *vc = [MessageAlertVC new];
            vc.isNormalAlertMessage = NO;
            baseVC = vc;
            reloadVC = YES;
        }
        
    }
    
    if (mainMessagetype == NotificationMessageMainTypeOfOrderMessage ) {
        if ([subMessageType isEqualToString:@"order"]) {
            [self getOrderDetailData:dataID withOrderStatus:actionInfo[@"state_name"] andCommentStatus:[SupportingClass verifyAndConvertDataToString:actionInfo[@"reg_tag"]]];
            return;
        }
    }
    
    if (baseVC) {
        BaseNavigationController *nav = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
        NSLog(@"%@", nav.visibleViewController.class);
        if (![nav.visibleViewController isKindOfClass:[baseVC class]] ) {
            if ([(BaseViewController *)nav.visibleViewController respondsToSelector:@selector(setNavBackButtonTitleOrImage:titleColor:)]) {
                [(BaseViewController *)nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
            }
            [nav pushViewController:baseVC animated:YES];
        }else {
            if (reloadVC) {
                if ([(BaseViewController *)nav.visibleViewController respondsToSelector:@selector(reloadViewData)]) {
                    [(BaseViewController *)nav.visibleViewController reloadViewData];
                }
            }
        }
    }
    
    
}

@end
