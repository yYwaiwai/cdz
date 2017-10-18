//
//  OrderDetailsVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "OrderDetailsVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIView+LayoutConstraintHelper.h"
#import "OrderDetailsModel.h"
#import "GroupCommentListVC.h"
#import "ApplyRefundVC.h"
#import "RepairOrReplacementVC.h"
#import "OrderDetailHeaderView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "PaymentCenterVC.h"
#import "MyOrdersVC.h"

@interface OrderDetailsVC ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet OrderDetailHeaderView *headerView;

@property (nonatomic, weak) IBOutlet UIView *bottomBtnView;

@property (nonatomic, weak) IBOutlet UIButton *bottomLeftBtn;

@property (nonatomic, weak) IBOutlet UIButton *bottomRightBtn;

@property (nonatomic, assign) BOOL isSpecProductService;

//@property (nonatomic, strong) NSString *stateName;

@property (nonatomic, strong) OrderDetailsModel *tvConfigModel;

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;


@end

@implementation OrderDetailsVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单详情";
    self.navShouldPopOtherVC = YES;
    [self componentSetting];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)componentSetting {
    self.isSpecProductService = (![self.orderType isEqualToString:@""]&&
                                 ![self.orderType isEqualToString:@"O"]&&
                                 ![self.orderType isEqualToString:@"M"]&&
                                 ![self.orderType isEqualToString:@"P"]);
    
    self.orderClearanceType = self.isSpecProductService?CDZOrderPaymentClearanceTypeOfSpecRepair:CDZOrderPaymentClearanceTypeOfMaintainExpress;
   
    if ([self.orderType isEqualToString:@""]||[self.orderType isEqualToString:@"O"]||[self.orderType isEqualToString:@"P"]){
        self.orderClearanceType = CDZOrderPaymentClearanceTypeOfRegularParts;
    }

    if ([self.orderType isEqualToString:@"V"]||[self.orderType isEqualToString:@"v"]){
        self.orderClearanceType = CDZOrderPaymentClearanceTypeOfUserMember;
    }
    
    self.tvConfigModel = [OrderDetailsModel new];
    self.tvConfigModel.orderClearanceType = self.orderClearanceType;
    self.tvConfigModel.contentDetail = self.contentDetail;
    self.tvConfigModel.tableView = self.tableView;
    self.tableView.delegate = self.tvConfigModel;
    self.tableView.dataSource = self.tvConfigModel;
    self.tableView.tableFooterView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    if (!self.tvConfigModel.applySuccessBlock) {
        @weakify(self);
        self.tvConfigModel.applySuccessBlock = ^{
            @strongify(self);
            self.orderBack = @"yes";
            [self getOrderDetail];
        };
    }
    
    //配置头顶总区头
    if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
        [self configHeadView];
    }
    
    self.tableView.showsVerticalScrollIndicator = NO;
    if (![_contentDetail[@"state_name"] containsString:@"已到"]) {
        [self footerViewUIUpdate];
    }
    
}

- (void)makeAcall {
    NSDictionary*wxsInfo=_contentDetail[@"wxs_info"];
    NSString *number = wxsInfo[@"wxs_tel"];
    [SupportingClass makeACall:number];
}

- (void)configHeadView {
    
    [[UINib nibWithNibName:@"OrderDetailHeaderView" bundle:nil] instantiateWithOwner:self options:nil];
    [self.headerView.telButton addTarget:self action:@selector(makeAcall) forControlEvents:UIControlEventTouchUpInside];
    self.headerView.orderType = self.orderType;
    self.headerView.contentDetail = self.contentDetail;
    [self.headerView updateUIData];
    [self.headerView setNeedsUpdateConstraints];
    [self.headerView setNeedsDisplay];
    [self.headerView setNeedsLayout];
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView addSelfByFourMarginToSuperview:self.tableView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0]];;
    
}

- (void)footerViewUIUpdate {
    
    self.bottomBtnView.clipsToBounds = NO;
    self.bottomBtnView.hidden = NO;
    self.tableView.tableFooterView = nil;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.bottomBtnView.frame))];

    self.bottomRightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.bottomLeftBtn.titleLabel.font = [UIFont systemFontOfSize:13];

    self.bottomLeftBtn.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:175.0/255.0 blue:48.0/255.0 alpha:1.0];
    self.bottomRightBtn.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:199.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.bottomLeftBtn.layer.cornerRadius = 3.0;
    self.bottomLeftBtn.layer.masksToBounds =YES;
    self.bottomRightBtn.layer.cornerRadius = 3.0;
    self.bottomRightBtn.layer.masksToBounds = YES;
    self.bottomRightBtn.tintColor = CDZColorOfWhite;
    self.bottomLeftBtn.tintColor = CDZColorOfWhite;
    self.bottomRightBtn.hidden = NO;
    self.bottomLeftBtn.hidden = NO;
    if ([_contentDetail[@"state_name"] isEqualToString:@"派送中"]) {
        self.bottomLeftBtn.hidden=YES;
        if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
            
            [self.bottomRightBtn setTitle:@"确认收货" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(confirmReceipt) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if ([self.orderBack isEqualToString:@"yes"]) {
                [self.bottomRightBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
                [self.bottomRightBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
            }else{
                self.bottomRightBtn.hidden=YES;
            }
            
        }
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"待付款"]||[_contentDetail[@"state_name"] isEqualToString:@"未付款"]) {
        [self.bottomRightBtn setTitle:@"立即支付" forState:UIControlStateNormal];
        [self.bottomLeftBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        [self.bottomLeftBtn addTarget:self action:@selector(cancelOrder1) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomRightBtn addTarget:self action:@selector(payImmediately) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([_contentDetail[@"state_name"] isEqualToString:@"货到付款"]) {
        self.bottomLeftBtn.hidden = YES;
        [self.bottomRightBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        [self.bottomRightBtn addTarget:self action:@selector(cancelOrder1) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([_contentDetail[@"state_name"] isEqualToString:@"交易关闭"]||
        [_contentDetail[@"state_name"] isEqualToString:@"订单取消"]) {
        [self.bottomRightBtn setTitle:@"删除订单" forState:UIControlStateNormal];
        [self.bottomRightBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
        self.bottomLeftBtn.hidden=YES;
//        if ([self.orderBack isEqualToString:@"yes"]) {
//            [self.bottomLeftBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
//            [self.bottomLeftBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
//        }else{
//            self.bottomLeftBtn.hidden=YES;
//        }
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"待安装"]) {
        self.bottomLeftBtn.hidden=YES;
        if ([self.orderBack isEqualToString:@"yes"]) {
           [self.bottomRightBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [self.bottomRightBtn setTitle:@"取消订单" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(cancelOrder2) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"已付款"]) {
        [self.bottomRightBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        [self.bottomRightBtn addTarget:self action:@selector(cancelOrder2) forControlEvents:UIControlEventTouchUpInside];
        self.bottomLeftBtn.hidden=YES;
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"已到店"]) {
       self.bottomLeftBtn.hidden=YES;
        if ([self.orderBack isEqualToString:@"yes"]) {
             [self.bottomRightBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
        }else{
            self.bottomRightBtn.hidden=YES;
        }
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"订单完成"]) {
        if ([_regTag  isEqual:@0]) {
            [self.bottomRightBtn setTitle:@"评价" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
            if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
                if (!self.isSpecProductService) {
                    if ([self.orderBack isEqualToString:@"yes"]) {
                        [self.bottomLeftBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
                        [self.bottomLeftBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
                    }else{
                        [self.bottomLeftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                        [self.bottomLeftBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
                    }
                }else{
                    [self.bottomLeftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                    [self.bottomLeftBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
                }
            }else {
                self.bottomLeftBtn.hidden=YES;
            }
        }else{
            [self.bottomRightBtn setTitle:@"查看评价" forState:UIControlStateNormal];
            [self.bottomRightBtn addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
                if (!self.isSpecProductService) {
                    if ([self.orderBack isEqualToString:@"yes"]) {
                        [self.bottomLeftBtn setTitle:@"返修/退换" forState:UIControlStateNormal];
                        [self.bottomLeftBtn addTarget:self action:@selector(repairOrReplacement) forControlEvents:UIControlEventTouchUpInside];
                    }else{
                        [self.bottomLeftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                        [self.bottomLeftBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
                    }
                }else{
                    [self.bottomLeftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                    [self.bottomLeftBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
                }
            }else {
                self.bottomLeftBtn.hidden=YES;
            }
            
        }
    }
    if (self.bottomRightBtn.hidden&&self.bottomLeftBtn.hidden) {
        self.bottomBtnView.hidden = YES;
        self.tableView.tableFooterView = nil;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 20)];
    }
}
//立即支付
- (void)payImmediately {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetPayNowByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"confirmPay"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"confirmPay"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];

}
//未付款、货到付款——取消订单
- (void)cancelOrder1 {
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要取消订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetCancleOrder1ByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//已付款、待安装——取消订单
- (void)cancelOrder2 {
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要取消订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetCancleOrder2ByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//评价
- (void)evaluate {
    @autoreleasepool {
        
        GroupCommentListVC*vc = [GroupCommentListVC new];
        vc.commentGroupID = self.orderID;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
        
    }
}
//删除订单
- (void)deleteOrder {
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要删除订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetDelOrderByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"deleteOrder"};
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"deleteOrder"};
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//确认收货
- (void)confirmReceipt {
    [SupportingClass showAlertViewWithTitle:nil message:@"您要确认收货？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetConfirmReceiveByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"ConfirmReceive"};
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"ConfirmReceive"};
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//退款进度——返修/退换
- (void)repairOrReplacement {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetRefundScheduleByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"repairOrReplacement"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"repairOrReplacement"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];


}

/* 订单详情 */
- (void)getOrderDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetOrderDetailByaccessToken:
     self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
         self.tableView.tableFooterView = nil;
         self.contentDetail = responseObject[CDZKeyOfResultKey];
         self.tvConfigModel.contentDetail = self.contentDetail;
         if (![self.contentDetail[@"state_name"] containsString:@"已到"]) {
             [self footerViewUIUpdate];
         }
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


- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSLog(@"%@",responseObject);
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"confirmPay"]) {
            PaymentCenterVC *vc = [PaymentCenterVC new];
            vc.paymentDetail = responseObject[CDZKeyOfResultKey];
            vc.orderClearanceType = self.isSpecProductService?CDZOrderPaymentClearanceTypeOfSpecRepair:CDZOrderPaymentClearanceTypeOfMaintainExpress;
            if ([[SupportingClass verifyAndConvertDataToString:self.contentDetail[@"cost_credits"]] isEqualToString:@"0.00"]) {
                vc.isUseCredit = NO;
            }
            if ([self.orderType isEqualToString:@""]||[self.orderType isEqualToString:@"O"]||[self.orderType isEqualToString:@"P"]){
                vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRegularParts;
            }
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
            [ProgressHUDHandler dismissHUD];
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"cancelOrder"]) {
            [ProgressHUDHandler dismissHUD];
            self.shouldReloadData = YES;
            [self handleNavBackBtnPopOtherAction];
            
        }

        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"repairOrReplacement"]) {
            [ProgressHUDHandler dismissHUD];
            NSArray*resultArr = [responseObject objectForKey:CDZKeyOfResultKey];
            RepairOrReplacementVC*vc=[RepairOrReplacementVC new];
            vc.commentArr = resultArr;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];

        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"deleteOrder"]) {
            
            [ProgressHUDHandler dismissHUD];
            self.shouldReloadData = YES;
            [self handleNavBackBtnPopOtherAction];
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"ConfirmReceive"]) {
            [ProgressHUDHandler dismissHUD];
            self.shouldReloadData = YES;
            [self handleNavBackBtnPopOtherAction];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNavBackBtnPopOtherAction {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyOrdersVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(MyOrdersVC *)result.lastObject setShouldReloadData:self.shouldReloadData];
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyOrdersVC *vc = MyOrdersVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    return;
    
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
