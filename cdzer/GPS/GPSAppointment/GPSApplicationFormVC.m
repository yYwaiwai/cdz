//
//  GPSApplicationFormVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "GPSApplicationFormVC.h"
#import "WKWebViewController.h"
#import "MyShoppingCartVC.h"
#import "MyCarVC.h"
#import "OrderDetailsVC.h"

@interface GPSApplicationFormVC ()

@property (nonatomic, weak) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, weak) IBOutlet UIView *gpsOptionView;

@property (nonatomic, weak) IBOutlet UIView *dataPlanOptionView;

@property (nonatomic, weak) IBOutlet UIView *performanceBondOptionView;

@property (nonatomic, weak) IBOutlet UIView *gpsCountView;

@property (nonatomic, weak) IBOutlet UIView *bottomInfoCountView;

@property (nonatomic, weak) IBOutlet UIButton *GPSDeviceButton;

@property (nonatomic, weak) IBOutlet UIButton *GPSDeviceWithODBButton;

@property (nonatomic, weak) IBOutlet UIButton *dataPlanButton;

@property (nonatomic, weak) IBOutlet UIButton *performanceBondOneButton;

@property (nonatomic, weak) IBOutlet UIButton *performanceBondTwoButton;

@property (nonatomic, assign) NSUInteger gpsCurrentSelectionID;

@property (nonatomic, assign) NSUInteger performanceBondCurrentSelectionID;

@property (nonatomic, assign) BOOL tncSelectionStatus;

@property (nonatomic, weak) IBOutlet UIButton *checkmarkBtn;

@end

@implementation GPSApplicationFormVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GPS";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self borderLineSetting];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)borderLineSetting {
    
    BorderOffsetObject *borderOffset = BorderOffsetObject.new;
    borderOffset.bottomLeftOffset = 12.0f;
    borderOffset.bottomRightOffset = 12.0f;
    [self.gpsOptionView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                          withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                   withBroderOffset:borderOffset];
    [self.dataPlanOptionView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                               withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                        withBroderOffset:borderOffset];
    [self.performanceBondOptionView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                                      withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                               withBroderOffset:borderOffset];
    [self.bottomInfoCountView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5
                                                withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                         withBroderOffset:nil];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (IBAction)changeGPSType:(UIButton *)sender {
    [self.GPSDeviceButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                            withColor:[self.GPSDeviceButton titleColorForState:UIControlStateNormal]
                                     withBroderOffset:nil];
    [self.GPSDeviceWithODBButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                   withColor:[self.GPSDeviceWithODBButton titleColorForState:UIControlStateNormal]
                                            withBroderOffset:nil];
    self.GPSDeviceButton.selected = NO;
    self.GPSDeviceWithODBButton.selected = NO;
    
    
    sender.selected = YES;
    [sender setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                              withColor:[sender titleColorForState:UIControlStateSelected]
                       withBroderOffset:nil];
    self.gpsCurrentSelectionID = sender.tag;
    
    NSString *totalPrice = @"¥600";
    if (self.gpsCurrentSelectionID==1) {
        totalPrice = @"¥900";
    }
    self.totalPriceLabel.text = totalPrice;
}

- (IBAction)changePerformanceBondType:(UIButton *)sender {
    self.performanceBondOneButton.selected = NO;
    self.performanceBondTwoButton.selected = NO;
    [self.performanceBondOneButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                     withColor:[self.performanceBondOneButton titleColorForState:UIControlStateNormal]
                                              withBroderOffset:nil];
    [self.performanceBondTwoButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                     withColor:[self.performanceBondTwoButton titleColorForState:UIControlStateNormal]
                                              withBroderOffset:nil];
    
    sender.selected = YES;
    [sender setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                              withColor:[sender titleColorForState:UIControlStateSelected]
                       withBroderOffset:nil];
    self.performanceBondCurrentSelectionID = sender.tag;

}

- (void)componentSetting {
    @autoreleasepool {
        self.tncSelectionStatus = TRUE;
        self.gpsCurrentSelectionID = 0;
        self.performanceBondCurrentSelectionID = 0;
        
        [self.GPSDeviceButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.GPSDeviceWithODBButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.dataPlanButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.performanceBondOneButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.performanceBondTwoButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        
        
        [self.GPSDeviceButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                withColor:[self.GPSDeviceButton titleColorForState:UIControlStateSelected]
                                         withBroderOffset:nil];
        [self.GPSDeviceWithODBButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                       withColor:[self.GPSDeviceWithODBButton titleColorForState:UIControlStateNormal]
                                                withBroderOffset:nil];
        
        [self.dataPlanButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                               withColor:[self.dataPlanButton titleColorForState:UIControlStateSelected]
                                        withBroderOffset:nil];
        
        [self.performanceBondOneButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                         withColor:[self.performanceBondOneButton titleColorForState:UIControlStateSelected]
                                                  withBroderOffset:nil];
        [self.performanceBondTwoButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5
                                                         withColor:[self.performanceBondTwoButton titleColorForState:UIControlStateNormal]
                                                  withBroderOffset:nil];
    }    
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}


- (IBAction)tncSelectionType {
    self.tncSelectionStatus = !self.tncSelectionStatus;
    self.checkmarkBtn.selected = self.tncSelectionStatus;
}


- (IBAction)showTnCAgreement {
    @autoreleasepool {
        NSString *urlString = [kBaseURLString stringByAppendingString:@"b2bweb-gold/rulesm.jsp"];
        WKWebViewController *webVC = [[WKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
        webVC.title = @"车队长科技预约GPS协议";
        webVC.showPageTitleAndURL = NO;
        webVC.hideBarsWithGestures = NO;
        webVC.supportedWebNavigationTools = WKWebNavigationToolNone;
        webVC.supportedWebActions = WKWebActionNone;
        webVC.webViewContentScale = 500;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (IBAction)showEventDetail {
    @autoreleasepool {
        NSString *urlString = [kBaseURLString stringByAppendingString:@"b2bweb-gold/agreementm.jsp"];
        WKWebViewController *webVC = [[WKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
        webVC.title = @"车队长科技预约GPS协议";
        webVC.showPageTitleAndURL = NO;
        webVC.hideBarsWithGestures = NO;
        webVC.supportedWebNavigationTools = WKWebNavigationToolNone;
        webVC.supportedWebActions = WKWebActionNone;
        webVC.webViewContentScale = 500;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)pushToUserAutosEditView {
    @autoreleasepool {
        MyCarVC *vc = [MyCarVC new];
        vc.wasBackRootView = YES;
        vc.wasSubmitAfterLeave = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToMyCart {
    @autoreleasepool {
        MyShoppingCartVC *vc = MyShoppingCartVC.new;
        vc.navShouldPopOtherVC = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)submitGPSAppointment {
    
    if (!self.tncSelectionStatus) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"您必须同意《车队长科技预约GPS协议》才能预约" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
        return;
    }
    
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    UserInfosDTO *dto = [DBHandler.shareInstance getUserInfo];
    UserAutosInfoDTO *autosDto = [DBHandler.shareInstance getUserAutosDetail];
    if ([userID isEqualToString:@"0"]||!self.accessToken||!dto.telphone) {
        return;
    }
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostGPSPurchasesAppointmentWithAccessToken:self.accessToken gpsType:self.gpsCurrentSelectionID dataCardType:0 recognizanceType:self.performanceBondCurrentSelectionID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if ([message isContainsString:@"无车辆"]||[message isContainsString:@"请完善"]) {
            message = @"请添加个人车辆信息";
            if([message isContainsString:@"请完善"]) message = @"请完善个人车辆信息";
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                if(btnIdx.integerValue>0){
                    [self pushToUserAutosEditView];
                }
            }];
            return;
        }
        
        
        if ([message isContainsString:@"无车辆"]||[message isContainsString:@"请完善"]) {
            message = @"请添加个人车辆信息";
            if([message isContainsString:@"请完善"]) message = @"请完善个人车辆信息";
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                if(btnIdx.integerValue>0){
                    [self pushToUserAutosEditView];
                }
            }];
            return;
        }
        
        if ([message isContainsString:@"已购买"]) {
            [SupportingClass showAlertViewWithTitle:@"重复申请" message:@"您已购买了GPS，请查看订单详情！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                NSString *orderID = [responseObject[CDZKeyOfResultKey] objectForKey:@"order_id"];
                [self getOrderDetail:orderID];
            }];
            return;
        }
        
        if ([message isContainsString:@"已添加"]) {
            [SupportingClass showAlertViewWithTitle:@"重复申请" message:@"您已申请了GPS，请查看购物车！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                [self pushToMyCart];
            }];
            return;
        }
        
        
        
        if (errorCode==3) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:@"申请失败" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"" message:@"申请成功" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            [self pushToMyCart];
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@", error);
        
        if (error.code==-1009) {
             [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
             }];
            
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
    }];
    
}

/* 订单详情 */
- (void)getOrderDetail:(NSString *)orderID {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!orderID||[orderID isEqualToString:@""]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [ProgressHUDHandler dismissHUD];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    NSString *orderType = @"O";
    NSString *orderBack = @"no";
    NSNumber *regTag = @0;
    [[APIsConnection shareConnection] personalCenterAPIsGetOrderDetailByaccessToken:
     self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
         NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
         NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
         NSLog(@"详情%@-----%@",message,operation.currentRequest.URL.absoluteString);
         if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
             return;
         }
         [ProgressHUDHandler dismissHUD];
         
         if (errorCode!=0) {
             [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                 
             }];
             return;
         }
         
         OrderDetailsVC *vc = [OrderDetailsVC new];
         vc.orderID = orderID;
         vc.orderType = orderType;
         vc.orderBack = orderBack;
         vc.regTag = regTag;
         vc.contentDetail = responseObject[CDZKeyOfResultKey];
         [self setDefaultNavBackButtonWithoutTitle];
         [self.navigationController pushViewController:vc animated:YES];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
