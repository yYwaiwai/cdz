//
//  MaintenanceDetailsVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//


#import "MaintenanceDetailsVC.h"
#import "RepairManagementUIConfigModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "GroupCommentListVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import "PaymentCenterVC.h"
#import "CDZOrderPaymentClearanceVC.h"
#import "MyMaintenanceManagementVC.h"
#import "MaintenanceDetailHeaderView.h"


@interface MaintenanceDetailsVC () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

//是否重新加载列表
@property (nonatomic, assign) BOOL isNeedReload;

@property (nonatomic, strong) RepairManagementUIConfigModel *tvConfigModel;

@property (nonatomic,strong) NSDictionary *confirmPayResultDic;

@property (strong, nonatomic) IBOutlet MaintenanceDetailHeaderView *headerView;


@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *xmzsLabel;

@property (weak, nonatomic) IBOutlet UILabel *wxzeLabel;

@property (weak, nonatomic) IBOutlet UILabel *xmzsNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *wxzeNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;




@end

@implementation MaintenanceDetailsVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"维修单详情";
    self.navShouldPopOtherVC = YES;
    [self componentSetting];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.tableHeaderView = _headerView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)componentSetting {
    self.tvConfigModel = [RepairManagementUIConfigModel new];
    self.tvConfigModel.tableView = self.tableView;
    self.tvConfigModel.processID = self.processID;
    self.tvConfigModel.currentStatusType = self.currentStatusType;
    self.tvConfigModel.contentDetail = self.contentDetail;
    self.tableView.delegate = self.tvConfigModel;
    self.tableView.dataSource = self.tvConfigModel;
    self.tableView.tableFooterView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    [self headViewUI];
    self.footerView.hidden=YES;
    NSLog(@"%@",_contentDetail[@"sum_price"]);
    if (_contentDetail[@"sum_price"]) {
        [self footerViewUI];
    }
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)headViewUI {
    
    [[UINib nibWithNibName:@"MaintenanceDetailHeaderView" bundle:nil] instantiateWithOwner:self options:nil];
    [self.headerView.phoneButton addTarget:self action:@selector(phoneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView updateUIData:self.contentDetail];
    [self.headerView setNeedsUpdateConstraints];
    [self.headerView setNeedsDisplay];
    [self.headerView setNeedsLayout];
    
    
    
    [self.headerView addSelfByFourMarginToSuperview:self.tableView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0]];;
    self.tableView.tableHeaderView=self.headerView;
    
}

- (void)footerViewUI {
    self.footerView.hidden=NO;
    self.leftButton.layer.cornerRadius=3.0;
    self.leftButton.layer.masksToBounds=YES;
    self.rightButton.layer.cornerRadius=3.0;
   self. rightButton.layer.masksToBounds=YES;

    self.leftButton.hidden=YES;
    self.rightButton.hidden=YES;
    if (self.currentStatusType==CDZMaintenanceStatusTypeOfDiagnosis) {
        if ([_processID isEqualToString:@"4"]) {
            self.leftButton.hidden=NO;
            self.rightButton.hidden=NO;
            [self.rightButton setTitle:@"同意维修" forState:UIControlStateNormal];
            [self.leftButton setTitle:@"取消维修" forState:UIControlStateNormal];
            [self.leftButton addTarget:self action:@selector(cancelMaintenance) forControlEvents:UIControlEventTouchUpInside];
            [self.rightButton addTarget:self action:@selector(agreedToRepair) forControlEvents:UIControlEventTouchUpInside];
        }

    }
    if (self.currentStatusType==CDZMaintenanceStatusTypeOfHasBeenClearing) {
        if ([_processID isEqualToString:@"8"]) {
            self.rightButton.hidden=NO;
            [self.rightButton setTitle:@"确认付款" forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(confirmThePayment) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([_processID isEqualToString:@"9"]) {
            self.rightButton.hidden=NO;
            [self.rightButton setTitle:@"评论" forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([_processID isEqualToString:@"10"]) {
            self.rightButton.hidden=NO;
            [self.rightButton setTitle:@"查看评论" forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(viewComments) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    NSArray *repairItems = self.contentDetail[@"repair_item"];
    self.xmzsNumberLabel.text=@(repairItems.count).stringValue;
    self.wxzeNumberLabel.text=[NSString stringWithFormat:@"￥%@",_contentDetail[@"sum_price"]];
    
}

- (void)phoneButtonClick {
    [SupportingClass makeACall:_contentDetail[@"contact_tel"]];
}
//取消维修
- (void)cancelMaintenance {
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要取消维修吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsPostRefuseRepairWithAccessToken:self.accessToken keyID:self.repairID success:^(NSURLSessionDataTask *operation, id responseObject) {
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//同意维修
- (void)agreedToRepair {
    if (self.tvConfigModel.selectedItemsString.length==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择维修项目" isShowImmediate:YES cancelButtonTitle:@"确定" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
        return;
    }
    [SupportingClass showAlertViewWithTitle:nil message:@"确定同意维修后，您的爱车将委托给商家进行维修，确定同意维修？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsPostAgreeRepairWithAccessToken:self.accessToken keyID:self.repairID repairItemsString:self.tvConfigModel.selectedItemsString success:^(NSURLSessionDataTask *operation, id responseObject) {
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
    
}
//确认付款
- (void)confirmThePayment {
    [self confirmPay];
}
//评论
- (void)comment {
    GroupCommentListVC *vc = [GroupCommentListVC new];
    vc.commentGroupID = self.repairID;
    vc.commentForRepair = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}
//查看评论
- (void)viewComments {
    GroupCommentListVC *vc = [GroupCommentListVC new];
    vc.commentGroupID = self.repairID;
    vc.commentForRepair = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
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
        NSLog(@"%@---%@",message,operation.currentRequest);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSLog(@"%@",responseObject);
        [ProgressHUDHandler showSuccessWithStatus:message onView:nil completion:^{
            self.isNeedReload = YES;
            [self handleNavBackBtnPopOtherAction];
            
            
        }];
        
    }
    
}

- (void)confirmPay {
    NSNumber *mark = [SupportingClass verifyAndConvertDataToNumber:self.contentDetail[@"mark"]];
    if (mark.integerValue==3) {
        CDZOrderPaymentClearanceVC *vc = [CDZOrderPaymentClearanceVC new];
        vc.repairOrderID = self.repairID;
        vc.repairShopName = self.contentDetail[@"wxs_name"];
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRepairNMaintenance;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    }else {
        NSString *repairID = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"order_id"]];
        NSString *totalPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"sum_price"]];
        PaymentCenterVC *vc = [PaymentCenterVC new];
        vc.pushFromDetail = YES;
        vc.paymentDetail = @{@"order_id":repairID,
                             @"sum_price":totalPrice};
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRepairNMaintenance;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNavBackBtnPopOtherAction {
    MyMaintenanceManagementVC *vc = nil;
    
    NSPredicate *predicateTabBarVC = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *theResult = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicateTabBarVC];
    if (theResult&&theResult.count>0) {
        [(BaseTabBarController *)theResult.lastObject setSelectedIndex:3];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyMaintenanceManagementVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        vc = result.lastObject;
        vc.shouldReloadData = self.isNeedReload;
        [self.navigationController popToViewController:vc animated:YES];
        return;
    }
    
    vc = [MyMaintenanceManagementVC new];
    vc.shouldReloadData = self.isNeedReload;
    vc.currentStatusType = CDZMaintenanceStatusTypeOfAppointment;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    
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
