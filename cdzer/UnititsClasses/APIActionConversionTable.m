//
//  APIActionConversionTable.m
//  cdzer
//
//  Created by KEns0n on 1/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#import "AppDelegate.h"
#import "SignInVC.h"
#import "WKWebViewController.h"
#import "APIActionConversionTable.h"
#import "UIViewController+ShareAction.h"

@implementation APIActionConvertedObject

+ (APIActionConvertedObject *)setObjectWithDetail:(NSDictionary *)detail withObjects:(id)objects title:(NSString *)title{
    if (detail&&detail.count>0) {
        APIActionConvertedObject *conObj = APIActionConvertedObject.new;
        BOOL titleShouldSet = [detail[@"titleShouldSet"] boolValue];
        conObj->_objects = objects;
        conObj->_title = titleShouldSet?title:nil;
        conObj->_actionString = detail[@"actionString"];
        conObj->_targetViewClass = NSClassFromString(detail[@"targetViewClass"]);
        conObj->_shouldLogin = [detail[@"shouldLogin"] boolValue];
        conObj->_shouldNavPush = [detail[@"shouldNavPush"] boolValue];
        conObj->_withAnimation = [detail[@"animation"] boolValue];
        return conObj;
    }
    return nil;
}

@end

@implementation APIActionConversionTable

+ (APIActionConvertedObject *)getAPIActionConversionDetailWithActionString:(NSString*)actionString withObjects:(id)objects title:(NSString *)title {
    APIActionConvertedObject *actionObject = nil;
    if (actionString&&![actionString isEqualToString:@""]) {
        actionObject = [APIActionConvertedObject setObjectWithDetail:[self getConversionDetailWithActionString:actionString] withObjects:objects title:title];
    }
    return actionObject;
}

+ (void)presentLoginViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag completion:(void (^)(void))completion{
    
    if ([self isKindOfClass:SignInVC.class]) {
        return;
    }
    BaseNavigationController *navigationController = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
    @autoreleasepool {
        SignInVC *vc = [SignInVC new];
        vc.ignoreViewResize = YES;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nav.navigationBarHidden = YES;
        [navigationController presentViewController:nav animated:flag completion:completion];
    }
}

+ (void)runTheAction:(APIActionConvertedObject *)config {
    if (config) {
        @autoreleasepool {
            AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
            BaseNavigationController *navigationController = delegate.navViewController;
            if (config.shouldLogin&&!vGetUserToken) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
                return;
            }

            id vc = [config.targetViewClass new];
            if ([config.actionString isEqualToString:@"gpsqr"]) {
                BaseViewController *theVC = (BaseViewController *)vc;
                
                theVC.view.frame = [UIScreen mainScreen].bounds;
                [UIApplication.sharedApplication.keyWindow addSubview:theVC.view];
                theVC.view.alpha = 0;
                [UIView animateWithDuration:0.25 animations:^{
                    theVC.view.alpha = 1;
                }];
                navigationController.tmpVCHolder = theVC;
                return;
            }
            
            
            if (config.title&&![config.title isEqualToString:@""]) {
                [(UIViewController*)vc setTitle:config.title];
            }
            
            if (vc&&config.shouldNavPush) {
                if ([config.actionString isEqualToString:@"web"]) {
                    if ([config.objects isKindOfClass:NSString.class]&&
                        [vc isKindOfClass:WKWebViewController.class]&&config.objects&&
                        [(NSString *)config.objects rangeOfString:@"http"].location!=NSNotFound) {
                        WKWebViewController *wvc = (WKWebViewController *)vc;
                        wvc.URL = [NSURL URLWithString:config.objects];
                        wvc.showPageTitleAndURL = NO;
                        wvc.hideBarsWithGestures = NO;
                        wvc.supportedWebNavigationTools = WKWebNavigationToolNone;
                        wvc.supportedWebActions = WKWebActionNone;
                        wvc.navigationItem.titleView = nil;
                        wvc.title = config.title;
                    }else {
                        return;
                    }
                }
                [navigationController.visibleViewController setDefaultNavBackButtonWithoutTitle];
                [navigationController pushViewController:vc animated:config.withAnimation];
            }
            if (vc&&!config.shouldNavPush) {
                [navigationController presentViewController:vc animated:config.withAnimation completion:^{
                    
                }];
            }

        }
    }
}

+ (NSDictionary *)getConversionDetailWithActionString:(NSString*)actionString  {
    @autoreleasepool {
        NSDictionary *detail = nil;
        if (actionString&&![actionString isEqualToString:@""]) {
            NSArray *actionList = @[@{@"actionString":@"gpsqr",
                                      @"targetViewClass":@"AppQRcodeVC",
                                      @"shouldLogin":@NO,
                                      @"animation":@NO,
                                      @"shouldNavPush":@NO,
                                      @"titleShouldSet":@NO,},
                                    
                                    @{@"actionString":@"gpsappoint",
                                      @"targetViewClass":@"GPSApplicationFormVC",
                                      @"shouldLogin":@NO,
                                      @"animation":@YES,
                                      @"shouldNavPush":@YES,
                                      @"titleShouldSet":@NO,},
                                    
                                    @{@"actionString":@"appqa",
                                      @"targetViewClass":@"CDZAppSurveyVC",
                                      @"shouldLogin":@NO,
                                      @"animation":@YES,
                                      @"shouldNavPush":@YES,
                                      @"titleShouldSet":@NO,},
                                    
                                    @{@"actionString":@"member",
                                      @"targetViewClass":@"MemberRightListVC",
                                      @"shouldLogin":@NO,
                                      @"animation":@YES,
                                      @"shouldNavPush":@YES,
                                      @"titleShouldSet":@NO,},
                                    
                                    @{@"actionString":@"web",
                                      @"targetViewClass":@"WKWebViewController",
                                      @"shouldLogin":@NO,
                                      @"animation":@YES,
                                      @"shouldNavPush":@YES,
                                      @"titleShouldSet":@YES,},];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.actionString CONTAINS[cd] %@", actionString];
            NSArray *result = [actionList filteredArrayUsingPredicate:predicate];
            if (result>0) {
                detail = result.lastObject;
            }
        }
        return detail;
    }
}

@end
