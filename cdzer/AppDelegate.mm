//
//  AppDelegate.m
//  cdzer
//
//  Created by KEns0n on 2/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "AppFunctionPreloadConfig.h"
//微信SDK头文件
#import "WXPaymentObject.h"

#import "BPush.h"
#import "AppDelegate.h"
#import "SignInVC.h"
#import "ATAppUpdater.h"
#import "UserInfosDTO.h"
#import "BDPushConfigDTO.h"
#import "GuideController.h"
#import <AlipaySDK/AlipaySDK.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "APNsHandler.h"
#import "EServiceAutoCancelApointmentObject.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


#define  kBMapAccessKey @"sV9ZVgp0QYf4QBuEGZ2kNfnK"
#define  vRepeatTime 45



#define  AUTO_START_UP_ENABLE 0
#define  ENABLE 1
#define  DISABLE 0

#if (AUTO_START_UP_ENABLE == ENABLE)
#import "NVTKitModel.h"
#import "SocketHBModel.h"
#endif // #if (AUTO_START_UP_ENABLE == ENABLE)
typedef NS_OPTIONS(NSUInteger, CDZCommonDataOptions) {
    CDZCommonDataUpdateOptionsForRepairShopTypeList             = 1 << 0,
    CDZCommonDataUpdateOptionsForRepairShopServiceTypeListW     = 1 << 1,
    CDZCommonDataUpdateOptionsForPurchaseOrderStatusList        = 1 << 2,
    CDZCommonDataUpdateOptionsForRepairShopServiceList          = 1 << 3,
    CDZCommonDataUpdateOptionsForMaintenanceServiceList         = 1 << 4,
    CDZCommonDataUpdateOptionsForAll                            = ~0UL,
};

@interface AppDelegate ()<BMKGeneralDelegate>{
    
    BMKMapManager* _mapManager;
    NSTimer *_timer;
    BOOL _wasUpdateShopType;
    BOOL _wasUpdateShopServiceType;
    BOOL _wasUpdateOrderStatusList;
    BOOL _wasUpdateRepairShopServiceList;
    BOOL _wasUpdateMaintenanceServiceList;
    NSDictionary *_inactivePushData;
    CDZCommonDataOptions _currentLoadingDataOptions;
}

@property (nonatomic, assign) BOOL delayLoadNVTKit;

@end

@implementation AppDelegate

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#ifdef DEBUG
    // do some things
    if (DEBUG&&![defaults valueForKey:@"APIsPrefixAddress"]) {
        [defaults registerDefaults:@{@"APIsPrefixAddress":@"https://tes.cdzer.net/"}];
        [defaults synchronize];
    }
#endif
    [AppFunctionPreloadConfig application:application didFinishLaunchingWithOptions:launchOptions];
    
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    reach.reachableOnWWAN = YES;
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];
//    [[ATAppUpdater sharedUpdater] forceOpenNewAppVersion:NO];
    
    
    // iOS10 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted) {
                                      [application registerForRemoteNotifications];
                                  }
                              }];
#endif
    }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) { // iOS8 下需要使用新的 API
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    
    if (launchOptions&&launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
//        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:[NSString stringWithFormat:@"Received Remote Notification :\n %@",launchOptions] isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
    
#if (AUTO_START_UP_ENABLE == ENABLE)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        [NVTKitModel sharedNVTKitModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
        });
    });
#endif // #if (AUTO_START_UP_ENABLE == ENABLE)

    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    NSString *pushKey = @"x1vchlzsRwM14NGY4OxTaRLi";
    BPushMode pushMode = BPushModeProduction;
#ifdef DEBUG
    //测试 开发环境 时需要修改BPushMode为BPushModeDevelopment 需要修改Apikey为自己的Apikey
    pushKey = @"H7WwHd2ATsD2cunjCau38LtT";
    pushMode = BPushModeDevelopment;
#endif
    [BPush registerChannel:launchOptions apiKey:pushKey pushMode:pushMode withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:YES];
    
    
// App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
#if TARGET_IPHONE_SIMULATOR
    Byte dt[32] = {0xc6, 0x1e, 0x5a, 0x13, 0x2d, 0x04, 0x83, 0x82, 0x12, 0x4c, 0x26, 0xcd, 0x0c, 0x16, 0xf6, 0x7c, 0x74, 0x78, 0xb3, 0x5f, 0x6b, 0x37, 0x0a, 0x42, 0x4f, 0xe7, 0x97, 0xdc, 0x9f, 0x3a, 0x54, 0x10};
    [self application:application didRegisterForRemoteNotificationsWithDeviceToken:[NSData dataWithBytes:dt length:32]];
#endif
    
    
    //App Setting
    //init instance objects
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UserBehaviorHandler shareInstance];
    [DBHandler shareInstance];
    [SecurityCryptor shareInstance];
    [EServiceAutoCancelApointmentObject startService];
    //init instance objects
    

    
    [defaults setValue:@(NO) forKey:kRunUpdateAutoRTData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettingDataFromTokenUpdate:) name:CDZNotiKeyOfTokenUpdate object:nil];
    
    
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:kBMapAccessKey  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:@"确定"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //判断是否是新版本
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    NSString *version = dict[@"CFBundleShortVersionString"];
    
    //取出旧的版本号
    NSString *oldVersion = [defaults objectForKey:@"CFBundleShortVersionString"];
    if ([version isEqualToString:oldVersion]) { //已经显示过新特性,进入主程序
        [self enter];
    }else { //新版本或者是第一次使用app
        GuideController *guide = [[GuideController alloc]init];
        self.window.rootViewController = guide;
    }
    
    [self.window makeKeyAndVisible];
    [self updateCommonData:CDZCommonDataUpdateOptionsForAll];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDZNotiKeyOfManualUpdateAutoGPSInfo object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDZNotiKeyOfTokenUpdate object:nil];
    [self stopSocketHB];
    
//    [self beingBackgroundUpdateTask];
//    // 在这里加上你需要长久运行的代码
//    [self endBackgroundUpdateTask];
}

- (void)stopSocketHB {
#if (AUTO_START_UP_ENABLE == ENABLE)
    [[NVTKitModel sharedSocketHBModel] socketHBStop];
#endif // #if (AUTO_START_UP_ENABLE == ENABLE)
}

- (void)startSocketHB {
    self.delayLoadNVTKit = YES;
#if (AUTO_START_UP_ENABLE == ENABLE)
    NVTKit *NVTKitObj = [NVTKitModel sharedNVTKitModel];
    
    
    // re-register socket notify port
    [NVTKitObj closeNvtkitNotifyListener];
    [NVTKitObj initNvtkitNotifyListener];
    
    // Check if need APP Start
    BOOL bClosed;
    
    if (E_OK == [NVTKitObj devAPPSessionQryIsClosed:&bClosed]) {
        
    }
    if (YES == bClosed){
        
        //            SPINNER_CREATE_START
        
        //            [CodeTools showMsg:@"Reconnect..." textColor:[UIColor greenColor] bgAlpha:0.7f timeoutSec:2.0 onView:NVT_TOPVIEW];
        
        // device WIFI mode is closed, we have to do APPSessionOpen first
        if (E_TMOUT == [NVTKitObj devAPPSessionOpen]) {
            //                [CodeTools showMsg:@"Connect Fail !!" textColor:[UIColor redColor] bgAlpha:0.7f timeoutSec:1.0 onView:NVT_TOPVIEW];
        }
        
        //            SPINNER_CREATE_END
    }else {
        //        [CodeTools showMsg:@"Connect Fail !!" textColor:[UIColor redColor] bgAlpha:0.7f timeoutSec:1.0 onView:NVT_TOPVIEW];
    }
    
    // determine if we (still) need socket heartbeat tactics
    [[NVTKitModel sharedSocketHBModel] socketHBAutoSwitchOnOff];

#endif // #if (AUTO_START_UP_ENABLE == ENABLE)
}


- (void)beingBackgroundUpdateTask {
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAutoGPSRealtimeData) name:CDZNotiKeyOfManualUpdateAutoGPSInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettingDataFromTokenUpdate:) name:CDZNotiKeyOfTokenUpdate object:nil];
    _timer = [NSTimer scheduledTimerWithTimeInterval:vRepeatTime target:self selector:@selector(updateUserAutoGPSRealtimeDataFromTimer) userInfo:nil repeats:YES];
    [self updateSettingDataFromTokenUpdate:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.delayLoadNVTKit) {
        [self startSocketHB];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        return  [WXPaymentManager.defaultManager application:application handleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        return  [WXPaymentManager.defaultManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
   
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        return  [WXPaymentManager.defaultManager application:app openURL:url options:options];
    }
    
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    return YES;
}

//登录
- (void)enter
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.navViewController = [storyBoard instantiateInitialViewController];
    
    
    // remove the 1px bottom border from UINavigationBar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    //BaseTabBarController is UITabBarController's subclass
    BaseTabBarController *rootVC = (BaseTabBarController *)self.navViewController.visibleViewController;
    //    rootVC.delegate = self;
    
    
    rootVC.selectedIndex = 0;   //TabBarController must set it to 0
    
    self.window.rootViewController = self.navViewController;
    
    self.window.backgroundColor = CDZColorOfWhite;
    
    if (vGetUserToken&&vGetUserID) {
        [ProgressHUDHandler showHUD];
        [self performSelector:@selector(validUserToken) withObject:nil afterDelay:1.5];
    }
}

//推送
- (void)applications:(UIApplication *)application didReceiveRemoteNotifications:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"background : %@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Register use deviceToken : %@",[deviceToken.description stringByTrimmingCharactersInSet:NSCharacterSet.nonBaseCharacterSet]);
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        NSLog(@"Method: %@\n%@",BPushRequestMethodBind, result);
        if (!error&&result) {
            NSString *dtString = [[deviceToken.description stringByTrimmingCharactersInSet:NSCharacterSet.symbolCharacterSet] stringByReplacingOccurrencesOfString:@" " withString:@""];
            BDPushConfigDTO *dto = [BDPushConfigDTO new];
            dto.deviceToken = dtString;
            dto.bdpUserID = result[@"user_id"];
            dto.channelID = result[@"channel_id"];
            BOOL updateSuccess = [DBHandler.shareInstance updateBDAPNSConfigData:dto];
            NSLog(@"update is success %d", updateSuccess);
        }
    }];

}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
    if (application.applicationState==UIApplicationStateActive) {
        NSLog(@"UIApplicationStateActive－接收远程通知啦！！！");
        [APNsHandler handleRemoteNotificationWithApplication:application didReceiveRemoteNotification:userInfo];
    }
    if (application.applicationState==UIApplicationStateInactive||application.applicationState==UIApplicationStateBackground) {
        NSLog(@"UIApplicationStateActive||UIApplicationStateBackground－接收远程通知啦！！！");
        _inactivePushData = userInfo;
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"接收本地通知啦！！！");
//    [BPush showLocalNotificationAtFront:notification identifierKey:nil];
    [APNsHandler handleLocalNotificationWithApplication:application didReceiveLocalNotification:notification];
}

//网络检测
- (void)reachabilityChanged:(NSNotification *)notiObject {
    Reachability *theReach = notiObject.object;
    if ([theReach isKindOfClass:[Reachability class]]) {
        NSLog(@"%@", theReach.currentReachabilityString);
        NSLog(@"%@", theReach.currentReachabilityFlags);
        NSLog(@"%ld", (long)theReach.currentReachabilityStatus);
    }
    if (theReach.currentReachabilityStatus==NotReachable) {
        countRequest = 13;
        [ProgressHUDHandler dismissHUD];
    }
}

//更新资料由登录成功后触发
- (void)updateSettingDataFromTokenUpdate:(NSNotification *)notiObject {
    [self updateUserData];
    if (vGetUserType==CDZUserTypeOfGPSUser||vGetUserType==CDZUserTypeOfGPSWithODBUser ) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:vRepeatTime target:self selector:@selector(updateUserAutoGPSRealtimeDataFromTimer) userInfo:nil repeats:YES];
        [self updateUserAutoGPSRealtimeData];
    }
}
//更新GPS车辆资料由 NSTimer 以定时方式触发
- (void)updateUserAutoGPSRealtimeDataFromTimer {
    NSString *token = vGetUserToken;
    NSNumber *updateAutoRTDataOn = [[NSUserDefaults standardUserDefaults] objectForKey:kRunUpdateAutoRTData];
    if (!token||!updateAutoRTDataOn.boolValue) return;
    [self updateUserAutoGPSRealtimeData];
}

#pragma mark- APIs Access Request

- (void)validUserToken {
    @weakify(self);
    [[UserBehaviorHandler shareInstance] validUserTokenWithSuccessBlock:^{
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            @strongify(self);
            [self updateSettingDataFromTokenUpdate:nil];
        }];
    } failureBlock:^(NSString *errorMessage, NSError *error) {
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            if (error.code==CDZUserDataNetworkUpdateAccessError) {
                if (self->_inactivePushData) {
                    [APNsHandler handleRemoteNotificationWithApplication:UIApplication.sharedApplication didReceiveRemoteNotification:[self->_inactivePushData copy]];
                    self->_inactivePushData = nil;
                }
                
            }else {
                if (UserBehaviorHandler.shareInstance.wasShowLoginAlert) {return;}
                [UserBehaviorHandler.shareInstance setShowLoginAlert:YES];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"你登录凭证已失效请重新登录已取得跟多功能" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    @strongify(self);
                    if (btnIdx.integerValue>=1) {
                        SignInVC *vc = [SignInVC new];
                        vc.ignoreViewResize = YES;
                        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
                        nav.modalPresentationStyle = UIModalPresentationPageSheet;
                        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        nav.navigationBarHidden = YES;
                        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [self.navViewController presentViewController:nav animated:YES completion:nil];
                    }else {
                        [[UserBehaviorHandler shareInstance] userLogoutWasPopupDialog:NO andCompletionBlock:nil];
                        
                        if (self->_inactivePushData) {
                            [APNsHandler handleRemoteNotificationWithApplication:UIApplication.sharedApplication didReceiveRemoteNotification:[self->_inactivePushData copy]];
                            self->_inactivePushData = nil;
                        }
                    }
                    [UserBehaviorHandler.shareInstance setShowLoginAlert:NO];
                }];
            }
        }];
    }];
}

- (void)updateUserData {
    NSString *token = vGetUserToken;
    if (!token) return;
    [[APIsConnection shareConnection] personalCenterAPIsGetPersonalInformationWithAccessToken:token success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"PersonalInformation"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"PersonalInformation"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)updateUserAutoGPSRealtimeData {
    if (vGetUserType==CDZUserTypeOfGPSUser||vGetUserType==CDZUserTypeOfGPSWithODBUser) {
        NSString *token = vGetUserToken;
        if (!token) return;
        [[APIsConnection shareConnection] personalGPSAPIsGetAutoGPSRealtimeInfoWithAccessToken:token success:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = @{@"ident":@"GPSRealtimeInfo"};
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = @{@"ident":@"GPSRealtimeInfo"};
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }
    
}

- (void)updateCommonData:(CDZCommonDataOptions)options {
    _currentLoadingDataOptions = options;
    if (options==CDZCommonDataUpdateOptionsForAll) {
        countRequest = 0;
    }
    
    if (CDZCommonDataUpdateOptionsForRepairShopTypeList&options) {
        NSDictionary *userInfo = @{@"ident":@"RepairShopTypeList",
                                   @"options":@(CDZCommonDataUpdateOptionsForRepairShopTypeList)};
        [[APIsConnection shareConnection] commonAPIsGetRepairShopTypeListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }
    
    if (CDZCommonDataUpdateOptionsForRepairShopServiceTypeListW&options) {
        NSDictionary *userInfo = @{@"ident":@"RepairShopServiceTypeList",
                                   @"options":@(CDZCommonDataUpdateOptionsForRepairShopServiceTypeListW)};
        
        [[APIsConnection shareConnection] commonAPIsGetRepairShopServiceTypeListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }
    
    if (CDZCommonDataUpdateOptionsForPurchaseOrderStatusList&options) {
        NSDictionary *userInfo = @{@"ident":@"PurchaseOrderStatusList",
                                   @"options":@(CDZCommonDataUpdateOptionsForPurchaseOrderStatusList)};
        
        [[APIsConnection shareConnection] commonAPIsGetPurchaseOrderStatusListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];

    }
    
    if (CDZCommonDataUpdateOptionsForRepairShopServiceList&options) {
        NSDictionary *userInfo = @{@"ident":@"RepairShopServiceList",
                                   @"options":@(CDZCommonDataUpdateOptionsForRepairShopServiceList)};
        
        [[APIsConnection shareConnection] commonAPIsGetRepairShopServiceListWithShopID:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }
    
    
    if (CDZCommonDataUpdateOptionsForMaintenanceServiceList&options) {
        NSDictionary *userInfo = @{@"ident":@"MaintenanceServiceList",
                                   @"options":@(CDZCommonDataUpdateOptionsForMaintenanceServiceList)};
        [APIsConnection.shareConnection maintenanceExpressAPIsGetmaintenanceExpressServiceItemListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            operation.userInfo = userInfo;
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }
}

#pragma mark- Data Handle Request
- (void)handleResponseData:(id)responseObject withIdentString:(NSString *)identString {
    @autoreleasepool {
        if (!responseObject) {
            NSLog(@"data Error");
            return;
        }
        if ([identString isEqualToString:@"PersonalInformation"]) {
            UserInfosDTO *dto = [UserInfosDTO new];
            [dto processDataToObjectWithData:responseObject isFromDB:NO];
            BOOL isDone = [[DBHandler shareInstance] updateUserInfo:dto];
            NSLog(@"PersonalInformationUpdateOK?:::%d", isDone);
            
        }
        if ([identString isEqualToString:@"GPSRealtimeInfo"]) {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObject:@(1) forKey:@"id"];
            [data addEntriesFromDictionary:responseObject];
            BOOL isDone = [[DBHandler shareInstance] updateAutoRealtimeData:data];
            NSLog(@"GPSRealtimeInfoUpdateOK?:::%d", isDone);
            if (isDone) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
            }
        }
        
        if ([identString isEqualToString:@"RepairShopTypeList"]) {
            BOOL isDone = [[DBHandler shareInstance] updateRepairShopTypeList:responseObject];
            NSLog(@"RepairShopTypeListUpdateOK?:::%d", isDone);
            _wasUpdateShopType = isDone;
        }
        
        if ([identString isEqualToString:@"RepairShopServiceTypeList"]) {
            BOOL isDone = [[DBHandler shareInstance] updateRepairShopSerivceTypeList:responseObject];
            NSLog(@"RepairShopServiceTypeListUpdateOK?:::%d", isDone);
            _wasUpdateShopServiceType = isDone;
            
        }
        
        if ([identString isEqualToString:@"PurchaseOrderStatusList"]) {
            BOOL isDone = [[DBHandler shareInstance] updatePurchaseOrderStatusList:responseObject];
            NSLog(@"PurchaseOrderStatusListUpdateOK?:::%d", isDone);
            _wasUpdateOrderStatusList = isDone;
        }
        
        if ([identString isEqualToString:@"RepairShopServiceList"]) {
            NSMutableArray *list = [NSMutableArray new];
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                id convention_maintain = responseObject[CDZObjectKeyOfConventionMaintain];
                id deepness_maintain = responseObject[CDZObjectKeyOfDeepnessMaintain];
                if (convention_maintain&&[convention_maintain isKindOfClass:NSArray.class]) {
                    [(NSArray *)convention_maintain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *object = [obj mutableCopy];
                        [object setObject:CDZObjectKeyOfConventionMaintain forKey:@"main_type"];
                        [list addObject:object];
                    }];
                }
                if (deepness_maintain&&[deepness_maintain isKindOfClass:NSArray.class]) {
                    [(NSArray *)deepness_maintain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *object = [obj mutableCopy];
                        [object setObject:CDZObjectKeyOfDeepnessMaintain forKey:@"main_type"];
                        [list addObject:object];
                    }];
                }
            }else if ([responseObject isKindOfClass:NSArray.class]) {
                [list addObjectsFromArray:responseObject];
            }
            
            
            BOOL isDone = [[DBHandler shareInstance] updateRepairShopServiceList:list];
            NSLog(@"RepairShopServiceListUpdateOK?:::%d", isDone);
            _wasUpdateRepairShopServiceList = isDone;
        }
        
        if ([identString isEqualToString:@"MaintenanceServiceList"]) {
            NSMutableArray *list = [NSMutableArray new];
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                id convention_maintain = responseObject[@"regular_maintain"];
                id deepness_maintain = responseObject[@"depth_maintain"];
                if (convention_maintain&&[convention_maintain isKindOfClass:NSArray.class]) {
                    [(NSArray *)convention_maintain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *object = [obj mutableCopy];
                        [object setObject:CDZObjectKeyOfConventionMaintain forKey:@"main_type"];
                        [list addObject:object];
                    }];
                }
                if (deepness_maintain&&[deepness_maintain isKindOfClass:NSArray.class]) {
                    [(NSArray *)deepness_maintain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *object = [obj mutableCopy];
                        [object setObject:CDZObjectKeyOfDeepnessMaintain forKey:@"main_type"];
                        [list addObject:object];
                    }];
                }
            }else if ([responseObject isKindOfClass:NSArray.class]) {
                [list addObjectsFromArray:responseObject];
            }
            
            BOOL isDone = [[DBHandler shareInstance] updateMaintenanceServiceList:list];
            NSLog(@"MaintenanceServiceListUpdateOK?:::%d", isDone);
            _wasUpdateMaintenanceServiceList = isDone;
        }
    }
}

NSUInteger countRequest = 0;
- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSString *identString = operation.userInfo[@"ident"];
    CDZCommonDataOptions options = [operation.userInfo[@"options"] unsignedIntegerValue];
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        countRequest++;
        if (operation.userInfo[@"options"]&&countRequest<11) {
            [self updateCommonData:[operation.userInfo[@"options"] integerValue]];
        }
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;}
        if (errorCode==0) {
            NSLog(@"%@ SuccessGetData",identString);
            _currentLoadingDataOptions -= options;
            [self handleResponseData:responseObject[CDZKeyOfResultKey] withIdentString:identString];
        }
    }
    
    if (_inactivePushData) {
        [APNsHandler handleRemoteNotificationWithApplication:UIApplication.sharedApplication didReceiveRemoteNotification:[_inactivePushData copy]];
        _inactivePushData = nil;
    }
    
}
@end
