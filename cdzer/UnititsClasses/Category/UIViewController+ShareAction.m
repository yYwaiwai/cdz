//
//  UIViewController+ShareAction.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "UIViewController+ShareAction.h"
#import "UserAutosSelectonVC.h"
#import "SignInVC.h"
#import "CitySelectionVC.h"

@implementation UIViewController (ShareAction)

- (void)setDefaultNavBackButtonWithoutTitle {
    [self setNavBackButtonTitleOrImage:nil titleColor:nil withTarget:nil action:NULL];
}

- (void)setNavBackButtonTitleOrImage:(id)titleOrImage titleColor:(UIColor *)color {
    
    [self setNavBackButtonTitleOrImage:titleOrImage titleColor:color withTarget:nil action:NULL];
}
// 设置 所有功能的点击方法
- (void)setNavBackButtonTitleOrImage:(id)titleOrImage titleColor:(UIColor *)color withTarget:(id)target action:(SEL)action {
    if (!titleOrImage||[titleOrImage isEqualToString:@""]) {
        titleOrImage = @"";
    }else {
        titleOrImage = getLocalizationString(titleOrImage); //#define getLocalizationString(string) [SupportingClass getLocalizationString:string]
    }
    
    if (!color) {
        color = UINavigationBar.appearance.tintColor;
    }
    
    UINavigationItem *navigationItem = self.tabBarController.navigationItem;
    
    if (!navigationItem) {
        navigationItem = self.navigationItem;
    }
    
    if ([SupportingClass isOS7Plus]) {
        UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] initWithTitle:titleOrImage
                                             style:UIBarButtonItemStylePlain target:target action:action];
//        returnButtonItem.target = target;
//        returnButtonItem.action = action;
        returnButtonItem.title = titleOrImage;
        returnButtonItem.tintColor = color;
        [returnButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
        navigationItem.backBarButtonItem = returnButtonItem;
    } else {
        // 设置返回按钮的文本
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle:titleOrImage
                                       style:UIBarButtonItemStylePlain target:target action:action];
        [navigationItem setBackBarButtonItem:backButton];
        
        // 设置返回按钮的背景图片
        UIImage *img = [UIImage imageNamed:@"ic_back_nor"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f)];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:img
                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
        // 设置文本与图片的偏移量
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f)
                                                             forBarMetrics:UIBarMetricsDefault];
        // 设置文本的属性
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
                                     NSShadowAttributeName:[NSValue valueWithUIOffset:UIOffsetZero]};
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
}

- (UIBarButtonItem *)setRightNavButtonWithTitleOrImage:(id)sender style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action titleColor:(UIColor *)color isNeedToSet:(BOOL)isNeedToSet {
    @autoreleasepool {
        if (!sender)  return nil;
        
        UIBarButtonItem *rightButton;
        if ([sender isKindOfClass:[NSString class]]) {
            NSString *title = getLocalizationString((NSString*)sender);
            if ([(NSString*)sender isEqualToString:@""]) {
                title = (NSString*)sender;
            }
            rightButton = [[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action];
            
            if (!color) color = UINavigationBar.appearance.tintColor;
            rightButton.tintColor = color;
            
        }else if([sender isKindOfClass:[UIImage class]]){
            
            rightButton = [[UIBarButtonItem alloc] initWithImage:(UIImage*)sender style:style target:target action:action];
        }
        //        [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: color,  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        UINavigationItem *navigationItem = self.tabBarController.navigationItem;
        
        if (!navigationItem) {
            navigationItem = self.navigationItem;
        }
        if (isNeedToSet) {
            navigationItem.rightBarButtonItem = rightButton;
        }
        [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
        return rightButton;
    }
}

- (UIBarButtonItem *)setRightNavButtonWithSystemItemStyle:(UIBarButtonSystemItem)style target:(id)target action:(SEL)action isNeedToSet:(BOOL)isNeedToSet {
    @autoreleasepool {
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:action];
        UINavigationItem *navigationItem = self.tabBarController.navigationItem;
        if (!navigationItem) {
            navigationItem = self.navigationItem;
        }
        if (isNeedToSet) {
            navigationItem.rightBarButtonItem = rightButton;
        }
        return rightButton;
    }
}


- (UIBarButtonItem *)setLeftNavButtonWithTitleOrImage:(id)sender style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action titleColor:(UIColor *)color isNeedToSet:(BOOL)isNeedToSet {
    @autoreleasepool {
        if (!sender)  return nil;
        
        UIBarButtonItem *leftButton;
        if ([sender isKindOfClass:[NSString class]]) {
            NSString *title = getLocalizationString((NSString*)sender);
            if ([(NSString*)sender isEqualToString:@""]) {
                title = (NSString*)sender;
            }
            leftButton = [[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action];
            
            if (!color) color = UINavigationBar.appearance.tintColor;
            leftButton.tintColor = color;
            
        }else if([sender isKindOfClass:[UIImage class]]){
            
            leftButton = [[UIBarButtonItem alloc] initWithImage:(UIImage*)sender style:style target:target action:action];
        }
        //        [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: color,  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        if (isNeedToSet) {
            self.navigationItem.leftBarButtonItem = leftButton;
        }
        
        [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
        return leftButton;
    }
}

- (UIBarButtonItem *)setLeftNavButtonWithSystemItemStyle:(UIBarButtonSystemItem)style target:(id)target action:(SEL)action isNeedToSet:(BOOL)isNeedToSet {
    @autoreleasepool {
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:action];
        UINavigationItem *navigationItem = self.tabBarController.navigationItem;
        if (!navigationItem) {
            navigationItem = self.navigationItem;
        }
        if (isNeedToSet) {
            navigationItem.rightBarButtonItem = leftButton;
        }
        return leftButton;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static char navPop;
- (void)setNavShouldPopOtherVC:(BOOL)navShouldPopOtherVC {
    objc_setAssociatedObject(self,&navPop,@(navShouldPopOtherVC),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)navShouldPopOtherVC {
    return [(id)objc_getAssociatedObject(self, &navPop) boolValue];
}

static char loginPop;
- (void)setLoginAfterShouldPopToRoot:(BOOL)loginAfterShouldPopToRoot {
    objc_setAssociatedObject(self,&loginPop,@(loginAfterShouldPopToRoot),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)loginAfterShouldPopToRoot {
    return [(id)objc_getAssociatedObject(self, &loginPop) boolValue];
}

- (BOOL)navigationShouldPopOnBackButton {
    return !self.navShouldPopOtherVC;
}

- (BOOL)viewControllerDefautloginAfterShouldPopToRoot {
    return !self.loginAfterShouldPopToRoot;
}



- (void)pushToAutosSelectionViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag onlyForSelection:(BOOL)onlyForSelection andSelectionResultBlock:(UserAutosSelectonResultBlock)resultBlock {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        vc.onlyForSelection = onlyForSelection;
        vc.resultBlock = resultBlock;
        [self setNavBackButtonTitleOrImage:nil titleColor:nil];
        if (self.tabBarController) {
            [self.tabBarController.navigationController pushViewController:vc animated:YES];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//用户登录
- (void)presentLoginViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag completion:(void (^)(void))completion{
    
    if ([self isKindOfClass:SignInVC.class]) {
        return;
    }
    @autoreleasepool {
        id viewController = self;
        if (self.tabBarController) {
            viewController = self.tabBarController;
        }else if (self.navigationController) {
            viewController = self.navigationController;
        }
        
        @weakify(self);
        SignInVC *vc = [SignInVC new];
        vc.ignoreViewResize = YES;
        [vc setCancelLoginResponseBlock:^{
            [UserBehaviorHandler.shareInstance userLogoutWasPopupDialog:NO andCompletionBlock:^{
                @strongify(self);
                if ([self respondsToSelector:@selector(handleUserLoginResult:fromAlert:)]&&!self.loginAfterShouldPopToRoot) {
                    [self handleUserLoginResult:NO fromAlert:YES];
                }else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nav.navigationBarHidden = YES;
        [viewController presentViewController:nav animated:flag completion:completion];
    }
}


- (void)pushToCitySelectionViewWithBackTitle:(NSString *)backTitle selectedCity:(KeyCityDTO *)selectedCity hiddenLocation:(BOOL)hidden onlySelection:(BOOL)onlySelection animated:(BOOL)flag {
    if ([self isKindOfClass:UserAutosSelectonVC.class]) return;
    @autoreleasepool {
        if (backTitle) {
            backTitle = getLocalizationString(backTitle);
        }
        CitySelectionVC *vc = [CitySelectionVC new];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.selectedCity = selectedCity;
        vc.hiddenLocationView = hidden;
        vc.selectionWithoutSave = onlySelection;
        [self setNavBackButtonTitleOrImage:backTitle titleColor:nil];
        
        if (self.tabBarController) {
            
            [self.tabBarController.navigationController pushViewController:vc animated:flag];
            return;
        }
        
        [self.navigationController pushViewController:vc animated:flag];
    }
}


@end


@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [vc navigationShouldPopOnBackButton];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
        if ([vc respondsToSelector:@selector(handleNavBackBtnPopOtherAction)]) {
            [vc handleNavBackBtnPopOtherAction];
        }else {
            NSLog(@"navShouldPopOtherVC was active, but did not implement \"handleNavBackBtnPopOtherAction\"");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self popViewControllerAnimated:YES];
            });
        }
    }
    
    return NO;
}

@end
