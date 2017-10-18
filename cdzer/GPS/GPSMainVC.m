//
//  GPSMainVC.m
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "GPSMainVC.h"
#import "GPSSettingVC.h"
#import "RealtimeAutoInfoVC.h"
#import "GPSAutosLocationVC.h"
#import "GPSAutosDrivingRecordVC.h"
#import "OBDDiagnosisVC.h"
#import "FastPreventionVC.h"
#import "MessageAlertVC.h"
#import "GPSApplicationFormVC.h"
#import "PartsDetailVC.h"
#define vButtonTag 100

@interface GPSMainVC ()

@property (nonatomic, weak) IBOutlet UIImageView *lockedImageView;

@property (nonatomic, weak) IBOutlet UIImageView *unlockedImageView;

@property (nonatomic, weak) IBOutlet UILabel *lockStatusLabel;

@property (nonatomic, weak) IBOutlet UILabel *lockStatusHitsLabel;

@property (nonatomic, strong) IBOutlet UIView *nonGPSReminderView;

@property (nonatomic, weak) IBOutlet UIButton *applayButton;

@property (nonatomic, strong) NSNumber *lockStatus;


@property (nonatomic, strong) NSLayoutConstraint *nonGPSReminderViewLeftMargin;

@property (nonatomic, strong) NSLayoutConstraint *nonGPSReminderViewRightMargin;

@property (nonatomic, strong) NSLayoutConstraint *nonGPSReminderViewTopMargin;

@property (nonatomic, strong) NSLayoutConstraint *nonGPSReminderViewBottomMargin;

@end

@implementation GPSMainVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = NO;
    self.title = @"GPS";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    UIColor *barBKC = CDZColorOfWhite;
    UIColor *barForeC = CDZColorOfClearColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:barBKC};
    self.navigationController.navigationBar.barTintColor = barForeC;
    self.navigationController.navigationBar.backgroundColor = barForeC;
    self.navigationController.navigationBar.tintColor = barBKC;
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
    if (!self.lockStatus&&vGetUserType>=CDZUserTypeOfGPSUser&&self.accessToken) {
        [self getFastPreventionDetail];
    }
    if (!self.accessToken) {
        self.lockStatusHitsLabel.text = @"请登录";
    }else if (vGetUserType<CDZUserTypeOfGPSUser) {
        self.lockStatusHitsLabel.text = @"请购买GPS";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    UIColor *barBKC = [UIColor colorWithHexString:@"FAFAFA"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"]};
    self.navigationController.navigationBar.barTintColor = barBKC;
    self.navigationController.navigationBar.backgroundColor = barBKC;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"323232"];
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GPS_bkg_img@3x" ofType:@"png"]];
        [self.view setBackgroundImageByCALayerWithImage:image];
        
        UINib *nib = [UINib nibWithNibName:@"GPSMainViewComponent" bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        
        [self.applayButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    }
}

- (void)initializationUI {
    @autoreleasepool {
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushToGPSAppointment {
    
    @autoreleasepool {
        [self hidenNonGPSReminderView];
        [self getGPSPlusDetail];
//        GPSApplicationFormVC *vc = [GPSApplicationFormVC new];
//        [self setDefaultNavBackButtonWithoutTitle];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToMessageAlertVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        MessageAlertVC *vc = [MessageAlertVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToGPSAlertSettingVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        GPSSettingVC *vc = [GPSSettingVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToRealtimeAutoInfoVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        RealtimeAutoInfoVC *vc = [RealtimeAutoInfoVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToOBDDiagnosisVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        OBDDiagnosisVC *vc = [OBDDiagnosisVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToMyAutoLocationVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        GPSAutosLocationVC *vc = [GPSAutosLocationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToAutosDrivingRecordVC {
    if (!self.checkGPSStatusWasExist) return;
    
    @autoreleasepool {
        GPSAutosDrivingRecordVC *vc = [GPSAutosDrivingRecordVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)getGPSDetail {
    [ProgressHUDHandler showHUD];
    [self getPartsDetailDataWithPartsID:@"PD141120094853302030"];
}

- (void)getGPSPlusDetail {
    [ProgressHUDHandler showHUD];
    [self getPartsDetailDataWithPartsID:@"PD141120094853302030"];
}

// 官方产品 （GPS和 GPS+OBD）Parts组装零件;部件 Detail详情
- (void)getPartsDetailDataWithPartsID:(NSString *)partsID {
    if (!partsID) return;
    //请求
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:partsID  success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        NSString *urlss = operation.response.URL.absoluteString;
        NSLog(@"%@", urlss);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        //  配件信息VC
        PartsDetailVC *ridvc = PartsDetailVC.new;
        ridvc.itemDetail = responseObject[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [[self navigationController] pushViewController:ridvc animated:YES];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)showNonGPSReminderView {
    self.nonGPSReminderView.translatesAutoresizingMaskIntoConstraints = NO;
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    if (!self.nonGPSReminderViewTopMargin) {
        self.nonGPSReminderViewTopMargin = [NSLayoutConstraint constraintWithItem:self.nonGPSReminderView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:keyWindow
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:0];
    }
    
    if (!self.nonGPSReminderViewBottomMargin) {
        self.nonGPSReminderViewBottomMargin = [NSLayoutConstraint constraintWithItem:keyWindow
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.nonGPSReminderView
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1
                                                                            constant:0];
    }
    
    if (!self.nonGPSReminderViewLeftMargin) {
        self.nonGPSReminderViewLeftMargin = [NSLayoutConstraint constraintWithItem:self.nonGPSReminderView
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:keyWindow
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:0];
    }
    
    if (!self.nonGPSReminderViewRightMargin) {
        self.nonGPSReminderViewRightMargin = [NSLayoutConstraint constraintWithItem:keyWindow
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.nonGPSReminderView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:0];
    }
    self.nonGPSReminderView.bounds = keyWindow.bounds;
    [UIApplication.sharedApplication.keyWindow addSubview:self.nonGPSReminderView];
    [keyWindow addConstraints:@[self.nonGPSReminderViewTopMargin,
                                self.nonGPSReminderViewBottomMargin,
                                self.nonGPSReminderViewLeftMargin,
                                self.nonGPSReminderViewRightMargin,]];
    
}

- (IBAction)hidenNonGPSReminderView {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    [keyWindow removeConstraints:@[self.nonGPSReminderViewTopMargin,
                                   self.nonGPSReminderViewBottomMargin,
                                   self.nonGPSReminderViewLeftMargin,
                                   self.nonGPSReminderViewRightMargin,]];
    [self.nonGPSReminderView removeFromSuperview];
}

- (BOOL)checkGPSStatusWasExist {
    if (!self.accessToken) {
        [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
        return NO;
    }
    if (vGetUserType<CDZUserTypeOfGPSUser) {
        [self showNonGPSReminderView];
        return NO;
    }
    return YES;
}

- (IBAction)changeFastPreventionProtectStatus {
    if (!self.checkGPSStatusWasExist) return;
    
    if (self.lockStatus.boolValue) {
        [self shutdownFastPreventionProtect];
    }else {
        [self turnOnFastPreventionProtect];
    }
}

- (void)updateFastPreventionUIStatus {
    if (!self.lockStatus) return;
    
    BOOL isON = self.lockStatus.boolValue;
    self.lockedImageView.hidden = !isON;
    self.unlockedImageView.hidden = isON;
    self.lockStatusLabel.text = isON?@"已设防":@"未设防";
    self.lockStatusHitsLabel.text = isON?@"点击取消设防":@"点击开启设防";
}

- (void)getFastPreventionDetail {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    NSDictionary *userInfo = @{@"ident":@0};
    [[APIsConnection shareConnection] personalGPSAPIsGetFastPreventionDetailWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)turnOnFastPreventionProtect {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"正在开启设防...." onView:nil];
    NSDictionary *userInfo = @{@"ident":@1};
    [[APIsConnection shareConnection] personalGPSAPIsPostFastPreventionOfnWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)shutdownFastPreventionProtect {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler updateProgressStatusWithTitle:@"正在关闭设防...."];
    NSDictionary *userInfo = @{@"ident":@2};
    
    [[APIsConnection shareConnection] personalGPSAPIsPostFastPreventionOffWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSNumber *ident = operation.userInfo[@"ident"];
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        switch (errorCode) {
            case 0:
                NSLog(@"%@",responseObject);
                switch (ident.integerValue) {
                    case 0:{
                        BOOL isON = ![responseObject[CDZKeyOfResultKey] boolValue];
                        self.lockStatus = @(isON);
                        [self updateFastPreventionUIStatus];
                        [ProgressHUDHandler dismissHUD];
                    }
                        break;
                        
                    case 1:
                        self.lockStatus = @(YES);
                        [self updateFastPreventionUIStatus];
                        [ProgressHUDHandler showSuccessWithStatus:@"开启成功" onView:nil completion:^{
                            
                        }];
                        break;
                        
                    case 2:
                        self.lockStatus = @(NO);
                        [self updateFastPreventionUIStatus];
                        [ProgressHUDHandler showSuccessWithStatus:@"关闭成功" onView:nil completion:^{
                            
                        }];
                        break;
                        
                    default:
                        break;
                }
                break;
            case 1:
            case 2:{
                [ProgressHUDHandler dismissHUD];
                NSString *title = getLocalizationString(@"error");
                if (ident.integerValue >= 1) {
                    title = getLocalizationString(@"alert_remind");
                }
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;}
                
                [SupportingClass showAlertViewWithTitle:title message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
            }
                break;
                
            default:
                break;
        }
        
    }
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        if (UserBehaviorHandler.shareInstance.getUserType<CDZUserTypeOfGPSUser) {
//            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            }];
            [self showNonGPSReminderView];
            return;
        }
    }else {
    
    }
}


/*
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
