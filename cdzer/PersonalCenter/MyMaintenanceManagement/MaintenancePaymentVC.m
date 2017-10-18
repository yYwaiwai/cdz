//
//  MaintenancePaymentVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintenancePaymentVC.h"
#import "MaintenanceDetailsOneCell.h"
#import "MaintenanceDetailsTwoCell.h"
#import "MaintenanceDetailsThreeCell.h"
#import "MaintenanceDetailsFourCell.h"
#import "MaintenanceDetailsSixCell.h"
#import "MaintenancePaymentUIConfigModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIView+LayoutConstraintHelper.h"
#import "MaintenanceDetailsFiveCell.h"
#import "MyCouponVC.h"

@interface MaintenancePaymentVC ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MaintenancePaymentUIConfigModel *tvConfigModel;

@property (nonatomic, strong) UIView*footerView;


@property (nonatomic,strong) NSString *mark;

//@property (nonatomic,strong) NSDictionary *confirmPayResultDic;


@end

@implementation MaintenancePaymentVC
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"维修支付";
    
    
    [self componentSetting];
}
- (void)viewWillAppear:(BOOL)animated
{
    if (![self.contentDetail[@"mark"] isEqualToString:@"3"]) {
        if ([self.contentDetail[@"mark"] isEqualToString:@"5"]) {
            [self paymentNotPreferAndCredits];
        }
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.tableFooterView = _footerView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
- (void)componentSetting {

    self.tvConfigModel = [MaintenancePaymentUIConfigModel new];
    self.tvConfigModel.tableView = self.tableView;
    self.tableView.delegate = self.tvConfigModel;
    self.tableView.dataSource = self.tvConfigModel;
    self.tableView.tableFooterView.backgroundColor=self.view.backgroundColor;
    self.tableView.tableFooterView=_footerView;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 280;
    self.tvConfigModel.contentDetail = self.contentDetail;
    @weakify(self);
    self.tvConfigModel.pushingBlock = ^(){
        @strongify(self);
        MyCouponVC*vc=[MyCouponVC new];
        NSMutableArray*preferInfo=self.contentDetail[@"prefer_info"];
//        if (preferInfo.count>0) {
//             vc.preferInfoArray=preferInfo;
//        }
//       
//        vc.fromVCStr=@"维修支付";
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    };
    
    self.tvConfigModel.couponContent = @"";
    
//    MaintenanceDetailsFiveCell *cell=[self.tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    [self footerViewUI];
    
    [self.tableView reloadData];
}
- (void)footerViewUI
{
    _footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];
    _footerView.clipsToBounds = NO;
    UIButton*rightButton=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-100, 0, 100, 43)];
    UILabel*sfzjNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(rightButton.frame)-90, 15, 80, 15)];
    UILabel*sfzjLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(sfzjNumLabel.frame)-70, CGRectGetMinY(sfzjNumLabel.frame), 60, 13)];
    
    
    sfzjNumLabel.font=[UIFont systemFontOfSize:11];
    sfzjLabel.font=[UIFont systemFontOfSize:11];
    rightButton.titleLabel.font=[UIFont systemFontOfSize:13];
    
    sfzjNumLabel.textColor=[UIColor colorWithRed:248.0/255.0 green:175.0/255.0 blue:48.0/255.0 alpha:1.0];
    sfzjLabel.textColor=[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
   
    rightButton.backgroundColor=[UIColor colorWithRed:73.0/255.0 green:199.0/255.0 blue:245.0/255.0 alpha:1.0];

    rightButton.tintColor=CDZColorOfWhite;
    _mark=self.contentDetail[@"mark"];
    sfzjNumLabel.text=[NSString stringWithFormat:@"￥%@",self.contentDetail[@"sum_price"]];
    sfzjLabel.text=@"实付总价:";
    [rightButton setTitle:@"确认付款" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(paymentClick) forControlEvents:UIControlEventTouchUpInside];

    [_footerView addSubview:sfzjNumLabel];
    [_footerView addSubview:sfzjLabel];
    [_footerView addSubview:rightButton];
    rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [rightButton addSelfByFourMarginToSuperview:_footerView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeTrailing];
    [rightButton addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:43]];
    
    [rightButton addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:100]];
    sfzjNumLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [sfzjNumLabel addSelfByFourMarginToSuperview:_footerView withEdgeConstant:UIEdgeInsetsMake(15.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeTop];
    [_footerView addConstraint:[NSLayoutConstraint constraintWithItem:sfzjNumLabel
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:rightButton
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1
                                                             constant:-5]];

    
    [sfzjNumLabel addConstraint:[NSLayoutConstraint constraintWithItem:sfzjNumLabel
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:80]];
    
    sfzjLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [sfzjLabel addSelfByFourMarginToSuperview:_footerView withEdgeConstant:UIEdgeInsetsMake(15.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeTop];
    [_footerView addConstraint:[NSLayoutConstraint constraintWithItem:sfzjLabel
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:sfzjNumLabel
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1
                                                             constant:0]];

    [sfzjLabel addConstraint:[NSLayoutConstraint constraintWithItem:sfzjLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:57]];
   
    
}
- (void)paymentClick
{
    
    if (self.tvConfigModel.integralStr.length==0&&self.tvConfigModel.VerificationCode.length==0&&self.tvConfigModel.discountID.length==0) {
        
        [self paymentNotPreferAndCredits];
    }else
    {
        if ([self.tvConfigModel.discountStr isEqualToString:@"使用优惠券"]) {
            self.tvConfigModel.discountStr=@"";
            self.tvConfigModel.discountID=@"";
        }
        if (self.tvConfigModel.discountStr.length!=0) {
            self.tvConfigModel.integralStr=@"";
            self.tvConfigModel.VerificationCode=@"";
        }
        [self paymentUsePreferOrCredits];
    }
    
    
    
    
}
//  使用积分或者优惠券的情况
- (void)paymentUsePreferOrCredits
{
    [SupportingClass showAlertViewWithTitle:nil message:@"您是否要支付？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
             NSLog(@"4-%@----3-%@----2-%@----1-%@===%@",self.tvConfigModel.integralStr,self.tvConfigModel.VerificationCode,self.tvConfigModel.discountID,self.tvConfigModel.discountStr,self.accessToken);
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsPostEnsurePayorderWithAccessToken:self.accessToken repairOrderID:self.repairID mark:@0 credits:self.tvConfigModel.integralStr validCode:self.tvConfigModel.VerificationCode preferId:self.tvConfigModel.discountID invoiceHead:self.tvConfigModel.invoiceTextStr  success:^(NSURLSessionDataTask *operation, id responseObject) {
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}
//未  使用积分或者优惠券的情况
- (void)paymentNotPreferAndCredits
{
    [SupportingClass showAlertViewWithTitle:nil message:@"您是否要支付？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
             NSLog(@"%@----%@",self.repairID,self.mark);
//            [ProgressHUDHandler showHUD];
//            [[APIsConnection shareConnection] personalCenterAPIsPostEnsurePayorderWithNoCreditsWithAccessToken:self.accessToken keyID:self.repairID mark:self.mark success:^(NSURLSessionDataTask *operation, id responseObject) {
//                [self requestResultHandle:operation responseObject:responseObject withError:nil];
//            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//                [self requestResultHandle:operation responseObject:nil withError:error];
//            }];
        }
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
//            self.confirmPayResultDic=[responseObject objectForKey:CDZKeyOfResultKey];
//            MaintenancePaymentVC*vc=[MaintenancePaymentVC new];
//            vc.repairID=self.repairID;
//            vc.contentDetail=self.confirmPayResultDic;
//            [self.navigationController pushViewController:vc animated:YES];
//            [self setDefaultNavBackButtonWithoutTitle];
            [ProgressHUDHandler dismissHUD];
        }else {
            
            [ProgressHUDHandler showSuccessWithStatus:message onView:nil completion:^{
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
        }
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
