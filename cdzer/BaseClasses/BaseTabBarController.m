//
//  BaseTabBarController.m
//  cdzer
//
//  Created by KEns0n on 3/23/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseTabBarController.h"
#import "SignInVC.h"
#import "XIBBaseViewController.h"
#import "BaseViewController.h"
#import "WKWebViewController.h"
#import "FullScreenAdvertisementVC.h"

@interface BaseTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIImageView *dotImgView;

@property (nonatomic, strong) FullScreenAdvertisementVC *advertView;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

static NSString *EventActiveDate = @"EventActiveDate";
static NSString *InfoActiveDateKey = @"InfoActiveDate";
static NSString *InfoActiveIsPressKey = @"InfoActiveIsPressKey";

@implementation BaseTabBarController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark- UI initialization

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    
    return kShouldHiddenStatusBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self setUpTabBariCons];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectOrderViewTab)
                                                 name:CDZNotiKeyOfSelectOrderViewInTabBarVC
                                               object:nil];
    self.tabBar.tintColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    if (![userDefaults objectForKey:EventActiveDate]) {
        [userDefaults setObject:[self.dateFormatter stringFromDate:[NSDate date]] forKey:EventActiveDate];
    }
    if (![userDefaults objectForKey:InfoActiveDateKey]) {
        [userDefaults setObject:[self.dateFormatter stringFromDate:[NSDate date]] forKey:InfoActiveDateKey];
    }
    if (![userDefaults objectForKey:InfoActiveIsPressKey]) {
        [userDefaults setBool:NO forKey:InfoActiveIsPressKey];
    }
    [userDefaults synchronize];
    self.dotImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.dotImgView.backgroundColor = CDZColorOfWeiboColor;
    [self.dotImgView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.dotImgView.frame)/2.0];
    [self getReadedStatus];
}

- (void)selectOrderViewTab {
    self.selectedIndex = 3;
}

- (void)setUpTabBariCons {
    @autoreleasepool {
        
        UIImage *imageTabOneOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_main_on_icon_new@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabOneOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_main_off_icon_new@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"首页" image:imageTabOneOff selectedImage:imageTabOneOn];
        tabBarItem1.tag = 0;
        
        
        UIImage *imageTabTwoOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_info_on_icon_new@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabTwoOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_info_off_icon_new@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:getLocalizationString(@"news")  image:imageTabTwoOff selectedImage:imageTabTwoOn];
        tabBarItem2.tag = 1;
        
        
        UIImage *imageTabThreeOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_cs_on_icon_new@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabThreeOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_cs_off_icon_new@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:getLocalizationString(@"cs_hotline")  image:imageTabThreeOff selectedImage:imageTabThreeOn];
        tabBarItem3.tag = 2;
        
        
        UIImage *imageTabFourOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_my_on_icon_new@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabFourOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"main_view_my_off_icon_new@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"我的" image:imageTabFourOff selectedImage:imageTabFourOn];
        tabBarItem4.tag = 3;
        
        NSArray * tabBarItems = @[tabBarItem1, tabBarItem2, tabBarItem3, tabBarItem4];
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[BaseViewController class]]||
                [obj isKindOfClass:[WKWebViewController class]]||
                [obj isKindOfClass:[XIBBaseViewController class]]) {
                [obj setTabBarItem:tabBarItems[idx]];
            }
        }];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

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
        
        SignInVC *vc = [SignInVC new];
        vc.ignoreViewResize = YES;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nav.navigationBarHidden = YES;
        [viewController presentViewController:nav animated:flag completion:completion];
    }
}

- (void)createAdvertView {
    self.advertView = [FullScreenAdvertisementVC new];
    [self.advertView setSuperView:self.view];
    @weakify(self);
    self.advertView.closingBlock = ^void() {
        @strongify(self);
        [self cleanupAdvertView];
    };
}

- (void)cleanupAdvertView {
    self.advertView.closingBlock = nil;
    self.advertView = nil;
}

- (void)showCSHotlineDialDialog {
    if (!UserBehaviorHandler.shareInstance.getCSHotline) {
        [SupportingClass showAlertViewWithTitle:@"亲，你还没有登录！" message:@"你的专属客服期待与你沟通！" isShowImmediate:YES cancelButtonTitle:@"cancel"  otherButtonTitles:@"登录" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue > 0) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            }
        }];
        return;
    }
    [SupportingClass makeACall:UserBehaviorHandler.shareInstance.getCSHotline andContents:@"%@\n是否拨打客服号码？" withTitle:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:UIProgressView.class]) {
            [view removeFromSuperview];
            NSLog(@"Found UIProgressView");
        }
        
    }];
    
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    if ([viewController isKindOfClass:NSClassFromString(@"NewsVC")]&&
        ![userDefaults boolForKey:InfoActiveIsPressKey]) {
        [userDefaults setBool:YES forKey:InfoActiveIsPressKey];
        [self.dotImgView removeFromSuperview];
    }
    
    if (([self.selectedViewController.class isSubclassOfClass:NSClassFromString(@"TheMainViewController")]||
        [self.selectedViewController.class isSubclassOfClass:NSClassFromString(@"PersonalCenterVC")])&&
        self.selectedViewController!=viewController) {
        if ([self.selectedViewController isKindOfClass:XIBBaseViewController.class]) {
            [(XIBBaseViewController *)self.selectedViewController setViewWillDisappearShoulPassIt:NO];
        }
        if ([self.selectedViewController isKindOfClass:BaseViewController.class]) {
            [(BaseViewController *)self.selectedViewController setViewWillDisappearShoulPassIt:NO];
        }
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)getReadedStatus {
    @weakify(self);
    [APIsConnection.shareConnection personalMessageAPIsGetMessageAlertWasReaderStatusWithAccessToken:vGetUserToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation);
        if (errorCode==0) {
            NSDictionary *result = responseObject[CDZKeyOfResultKey];
            NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
            if ([result objectForKey:@"activity_list"]) {
                NSDictionary *eventDetail = [result objectForKey:@"activity_list"];
                [userDefaults setObject:eventDetail forKey:@"EventDetailKey"];
//                NSString *recordDateStr = [userDefaults stringForKey:InfoActiveDateKey];
                [userDefaults synchronize];
                BOOL isActive = [eventDetail[@"activity"] boolValue];
                if (isActive) {
                    [self createAdvertView];
                }
            }
            
            if (result[@"no_read_information_num"]) {
                BOOL isActive = [result[@"no_read_information_num"] boolValue];
                BOOL isPress = [userDefaults boolForKey:InfoActiveDateKey];
                NSString *recordDateStr = [userDefaults stringForKey:InfoActiveDateKey];
                NSString *currentDateStr = [self.dateFormatter stringFromDate:NSDate.date];
                if (isActive&&!isPress&&
                    [recordDateStr compare:currentDateStr]==NSOrderedAscending) {
                    
                    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
                    [userDefaults setObject:[self.dateFormatter stringFromDate:NSDate.date] forKey:InfoActiveDateKey];
                    [userDefaults setBool:NO forKey:InfoActiveIsPressKey];
                    [userDefaults synchronize];
                    if (self.tabBar.subviews.count>1) {
                        UIView *view = nil;
                        NSUInteger countIdx = 0;
                        for (UIView *subview in self.tabBar.subviews) {
                            if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                                countIdx += 1;
                                if (countIdx==2) {
                                    view = subview;
                                }
                            }
                        }
                        CGRect frame = self.dotImgView.frame;
                        frame.origin.x = CGRectGetWidth(view.frame)/2.0f+8.0f;
                        self.dotImgView.frame = [view convertRect:frame toView:self.tabBar];
                        [self.tabBar addSubview:self.dotImgView];
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
    }];
}



@end
