//
//  PaymentCenterVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/26/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PaymentCenterVC.h"
#import "OrderForm.h"
#import "WXPaymentObject.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MyOrdersVC.h"
#import "OrderDetailsVC.h"
#import "MyMaintenanceManagementVC.h"
#import "MyCarInsuranceVC.h"

@interface PaymentCenterVC ()

@property (weak, nonatomic) IBOutlet UILabel *remindPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *productInfoLabel;

@property (strong, nonatomic) OrderForm *orderForm;

@property (strong, nonatomic) NSString *signType;

@property (strong, nonatomic) NSString *signedString;

@property (nonatomic, strong) NSString *remindPriceString;

@property (nonatomic, strong) NSString *mainOrderID;

@property (nonatomic, strong) NSString *firstOrderID;

@property (nonatomic, assign) NSUInteger selectedPaymentTypeID;

@property (nonatomic, assign) NSUInteger productNumCount;

@property (nonatomic, assign) BOOL isGPSDevice;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *codViewTopConstraint;

@end

@implementation PaymentCenterVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"支付订单";
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        self.title = @"维修支付";
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self submitAlipay:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [[self.view viewWithTag:20] setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0];
    [[self.view viewWithTag:100] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.view viewWithTag:200] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.view viewWithTag:300] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        self.navShouldPopOtherVC = YES;
        self.selectedPaymentTypeID = 1;
        if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
            self.mainOrderID = self.paymentDetail[@"order_id"];
            self.firstOrderID = self.mainOrderID;
            self.remindPriceString = [NSString stringWithFormat:@"%0.2f", [SupportingClass verifyAndConvertDataToString:self.paymentDetail[@"sum_price"]].floatValue];
            self.remindPriceLabel.text = self.remindPriceString;
            self.productInfoLabel.text = @"维修费费用支付";
        }else {
            self.navShouldPopOtherVC = YES;
            self.selectedPaymentTypeID = 1;
            self.productNumCount = 1;
            NSArray *orderIDList = self.paymentDetail[@"order_info"];
            self.productNumCount = orderIDList.count;
            self.mainOrderID = self.paymentDetail[@"out_trade_no"];
            self.firstOrderID = orderIDList.firstObject;
            
            self.remindPriceString = [NSString stringWithFormat:@"%0.2f", [SupportingClass verifyAndConvertDataToString:self.paymentDetail[@"total_fee"]].floatValue];
            self.remindPriceLabel.text = self.remindPriceString;
            NSString * string=self.paymentDetail[@"body"];
            string=[string stringByReplacingOccurrencesOfString:@","withString:@""];
            self.productInfoLabel.text = string;
            NSLog(@"%@",self.paymentDetail[@"body"]);
            self.isGPSDevice = ([self.productInfoLabel.text isContainsString:@"GPS"]||[self.productInfoLabel.text isContainsString:@"OBD"]);
            
        }
        
        BOOL showCODOption = (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts&&!self.isUseCredit&&!self.isGPSDevice);
        UIControl *controlView = [self.view viewWithTag:300];
        controlView.hidden = !showCODOption;
        self.codViewTopConstraint.constant = showCODOption?0:-CGRectGetHeight(controlView.frame);
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNavBackBtnPopOtherAction {
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfInsurance) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        if (self.pushFromDetail) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self pushToRepairList];
        }
    }else {
        [self pushToOrderListOrOrderDetail];
    }
}

- (void)submitAlipay:(BOOL)onlyGetInfo {
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        [APIsConnection.shareConnection personalCenterAPIsGetMaintenanceClearingPaymentInfoWithAccessToken:self.accessToken keyID:self.mainOrderID success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSLog(@"%@", operation.currentRequest.URL.absoluteString);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            
            [ProgressHUDHandler dismissHUD];
            
            NSDictionary *dataDetail = responseObject[CDZKeyOfResultKey];
            self.orderForm = [[OrderForm alloc] init];
            self.orderForm.partner = dataDetail[@"partner"];
            self.orderForm.seller = dataDetail[@"seller_id"];
            self.orderForm.tradeNO = dataDetail[@"out_trade_no"];//[self generateTradeNO]; //订单ID（由商家自行制定）
            self.orderForm.productName = dataDetail[@"subject"]; //商品标题
            self.orderForm.productDescription = dataDetail[@"body"]; //商品描述
            self.orderForm.amount = dataDetail[@"total_fee"]; //商品价格
            self.orderForm.notifyURL = dataDetail[@"notify_url"]; //回调URL
            
            self.orderForm.service = dataDetail[@"service"];
            self.orderForm.paymentType = dataDetail[@"payment_type"];
            self.orderForm.inputCharset = dataDetail[@"_input_charset"];
            self.orderForm.itBPay = dataDetail[@"it_b_pay"];
            self.orderForm.showUrl = dataDetail[@"show_url"];
            self.orderForm.appID = dataDetail[@"app_id"];
            self.signType = dataDetail[@"sign_type"];
            self.signedString = dataDetail[@"sign"];
            if (!onlyGetInfo) {
                [self aliPay];
            }
            
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSLog(@"%@", operation.currentRequest.URL.absoluteString);
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

    }else {
        [APIsConnection.shareConnection personalCenterAPIsPaymentMethodByAlipayWithAccessToken:self.accessToken orderMainID:self.mainOrderID success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSLog(@"%@", operation.currentRequest.URL.absoluteString);
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            
            [ProgressHUDHandler dismissHUD];
            
            NSDictionary *dataDetail = responseObject[CDZKeyOfResultKey];
            self.orderForm = [[OrderForm alloc] init];
            self.orderForm.partner = dataDetail[@"partner"];
            self.orderForm.seller = dataDetail[@"seller_id"];
            self.orderForm.tradeNO = dataDetail[@"out_trade_no"];//[self generateTradeNO]; //订单ID（由商家自行制定）
            self.orderForm.productName = dataDetail[@"subject"]; //商品标题
            self.orderForm.productDescription = dataDetail[@"body"]; //商品描述
            self.orderForm.amount = dataDetail[@"total_fee"]; //商品价格
            self.orderForm.notifyURL = dataDetail[@"notify_url"]; //回调URL
            
            self.orderForm.service = dataDetail[@"service"];
            self.orderForm.paymentType = dataDetail[@"payment_type"];
            self.orderForm.inputCharset = dataDetail[@"_input_charset"];
            self.orderForm.itBPay = dataDetail[@"it_b_pay"];
            self.orderForm.showUrl = dataDetail[@"show_url"];
            self.orderForm.appID = dataDetail[@"app_id"];
            self.signType = dataDetail[@"sign_type"];
            self.signedString = dataDetail[@"sign"];
            if (!onlyGetInfo) {
                [self aliPay];
            }
            
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSLog(@"%@", operation.currentRequest.URL.absoluteString);
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
    
}

- (void)aliPay {
    //应用注册scheme,在Info.plist定义URL types
    NSString *appScheme = @"cdzerpersonal";
    
    NSString *orderBodyString = _orderForm.description;
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (_signedString) {
        [ProgressHUDHandler dismissHUD];
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderBodyString, _signedString, _signType];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSLog(@"reslut = %@",resultDic);
            NSNumber *status = [SupportingClass verifyAndConvertDataToNumber:resultDic[@"resultStatus"]];
            NSString *message = @"支付失败！";
            NSString *title = @"error";
            switch (status.integerValue) {
                case 4000:
                    message = @"系统繁忙，请稍后再试";
                    title = nil;
                case 9000:
                    message = @"支付成功！";
                    title = nil;
                    break;
                case 8000:
                    message = @"支付成功，处理中！";
                    title = nil;
                    break;
                case 3:
                case 6001:
                    message = @"你已取消该次支付！";
                    title = nil;
                    break;
                    
                default:
                    break;
            }
            [self handleAliPayMessage:message andErrorCode:status.integerValue];
        }];
        
    }else {
        [ProgressHUDHandler showErrorWithStatus:@"遗失交易信息，支付失败！" onView:nil completion:nil];
        [self handleAliPayMessage:@"遗失交易信息，支付失败！" andErrorCode:4000];
    }
}

- (void)handleAliPayMessage:(NSString *)resultMessage andErrorCode:(NSInteger)errorCode {
    NSString *message = @"支付失败！";
    NSString *title = @"error";
    switch (errorCode) {
        case 9000:
            message = @"支付成功！";
            title = nil;
            break;
        case 8000:
            message = @"支付成功，处理中！";
            title = nil;
            break;
        case 6001:
        case 3:
            message = @"你已取消该次支付！";
            title = nil;
            break;
        case 6002:
            message = @"网络错误，无法支付！";
            break;
            
        default:
            break;
    }
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:title  message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (errorCode>=8000) {
            [self pushToListOrDetail];
        }
    }];
    
}

- (void)wxPay {
    if (![WXApi isWXAppInstalled]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"无法发起支付请求，本系统还没安装微信客户端，支付前请先安装微信客户端或者使用另外支付方式！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"前往下载" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id414478124?mt=8"]];
            }
        }];
        return;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"无法发起支付请求，本系统不支援微信客户端！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [APIsConnection.shareConnection personalCenterAPIsPaymentMethodChangeByWXWithAccessToken:self.accessToken orderMainID:self.mainOrderID success:^(NSURLSessionDataTask *operation, id responseObject) {} failure:^(NSURLSessionDataTask *operation, NSError *error) {}];
    
    NSString *amount = @(_orderForm.amount.doubleValue*100).stringValue;
    
    @weakify(self);
    [WXPaymentManager.defaultManager sendWeChatPrePayAndPaymentRequestWithOrderID:_orderForm.tradeNO orderTitle:_orderForm.productName price:amount completion:^(NSError *error, id requestObject, id responseObject) {
        @strongify(self);
        if ([error.domain isEqualToString:PAYMENT_ERROR_DOMAIN_WX_PAY_RESULT_SUCCESS]) {
            [self pushToListOrDetail];
        }else {
            if (error) {
                [SupportingClass showToast:error.userInfo[NSLocalizedDescriptionKey]];
            }else {
                [SupportingClass showToast:@"无法发起支付请求，请稍后再试！"];
            }
        }
    }];
}

- (IBAction)payTypeSelection:(UIControl *)sender {
    for (int i=1; i<=3; i++) {
        [(UIButton *)[[self.view viewWithTag:i*100] viewWithTag:10] setSelected:NO];
    }
    [(UIButton *)[sender viewWithTag:10] setSelected:YES];
    self.selectedPaymentTypeID = sender.tag/100;
}

- (IBAction)payNow {
    if (self.selectedPaymentTypeID==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选一项支付方式" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    if (self.selectedPaymentTypeID==1) {
        [self submitAlipay:NO];
    }else if (self.selectedPaymentTypeID==2) {
        [self wxPay];
    }else if (self.selectedPaymentTypeID==3) {
        [self submibByCashOnDelivery];
    }
}

- (void)submibByCashOnDelivery {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [ProgressHUDHandler showHUDWithTitle:@"提交中" onView:nil];
    [[APIsConnection shareConnection] personalCenterAPIsPaymentMethodByPayAfterDeliveryWithAccessToken:UserBehaviorHandler.shareInstance.getUserToken isPayAfterDelivery:YES orderMainID:self.mainOrderID costType:@"15011215454926552861" costTypeName:@"货到付款" payType:@"14111909581880470390" payTypeName:@"货到付款" state:@"15011216013478759470" stateName:@"货到付款" success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        
        [ProgressHUDHandler dismissHUD];
        [self pushToListOrDetail];
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"提交失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        
    }];
}

- (void)pushToListOrDetail {
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfInsurance) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MyCarInsuranceVC class]]) {
                MyCarInsuranceVC *revise =(MyCarInsuranceVC *)controller;
                [self.navigationController popToViewController:revise animated:YES];
            }
        }

        return;
    }
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        [self pushToRepairList];
    }else {
        [self pushToOrderListOrOrderDetail];
    }
}

- (void)pushToOrderListOrOrderDetail {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyOrdersVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(MyOrdersVC *)result.lastObject setShouldReloadData:YES];
        [(MyOrdersVC *)result.lastObject setStateNumber:@0];
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyOrdersVC *vc = MyOrdersVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    return;
    if (self.productNumCount>1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyOrdersVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [(MyOrdersVC *)result.lastObject setShouldReloadData:YES];
            [(MyOrdersVC *)result.lastObject setStateNumber:@0];
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        MyOrdersVC *vc = MyOrdersVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [self getOrderDetail];
    }
}

- (void)pushToRepairList {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyMaintenanceManagementVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(MyMaintenanceManagementVC *)result.lastObject setShouldReloadData:YES];
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyMaintenanceManagementVC *vc = MyMaintenanceManagementVC.new;
    vc.currentStatusType = CDZMaintenanceStatusTypeOfHasBeenClearing;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    return;
}

- (void)getOrderDetail {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetOrderDetailByaccessToken:
     self.accessToken keyID:self.mainOrderID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
         vc.orderID = self.firstOrderID;
         vc.orderType = @"";
         if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
             NSString *orderType = [self.mainOrderID substringToIndex:1];
             vc.orderType = orderType;
         }
         vc.orderBack = @"no";
         vc.regTag = @0;
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

@end
