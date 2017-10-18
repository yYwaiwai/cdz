//
//  MyOrdersVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyOrdersVC.h"
#import "MyOrdersCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "OrderDetailsVC.h"
#import "GroupCommentListVC.h"
#import "PaymentCenterVC.h"
#import "RepairOrReplacementVC.h"

@interface MyOrdersVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *pendingPaymentButton;//待付款
@property (weak, nonatomic) IBOutlet UIButton *waitingForReceivingButton;//待收货
@property (weak, nonatomic) IBOutlet UIButton *waitingForInstallationButton;//安装
@property (weak, nonatomic) IBOutlet UIButton *waitingForEvaluateButton;//待评价
@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

/// 维修订单列表
@property (nonatomic, strong) NSMutableArray *orderList;




@end

@implementation MyOrdersVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.orderList.count==0||self.shouldReloadData) {
        [self getOrderStatusListWithRefreshView:nil isAllReload:YES];
        self.shouldReloadData = NO;
    }
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
    self.tabBarController.automaticallyAdjustsScrollViewInsets = YES;
    self.tabBarController.extendedLayoutIncludesOpaqueBars = NO;
    self.navigationController.navigationBar.hidden = NO;
    [self.tabBarController.view setNeedsLayout];
    [self.navigationController.view setNeedsLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"我的订单";
    self.navShouldPopOtherVC = YES;
    [self componentSetting];
    [self setReactiveRules];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 175.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"MyOrdersCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    _tableView.mj_footer.automaticallyHidden = NO;
    _tableView.mj_footer.hidden = YES;
    
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
    self.allButton.tag=0;
    self.pendingPaymentButton.tag=1;
    self.waitingForReceivingButton.tag=2;
    self.waitingForInstallationButton.tag=3;
    self.waitingForEvaluateButton.tag=4;
    
    [self.allButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendingPaymentButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.waitingForReceivingButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.waitingForInstallationButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.waitingForEvaluateButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)setReactiveRules {
    
}

- (void)filterAction {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self reloadPageData];
    self.stateNumber=@(0);
    [self getOrderStatusListWithRefreshView:nil isAllReload:YES];
}

- (void)reloadPageData {
    
    [self pageObjectToDefault];
}

- (void)componentSetting {
    if (!self.stateNumber) {
        self.stateNumber=@(0);
    }
    self.orderList = [NSMutableArray array];
    [self pageObjectToDefault];
}

- (void)handleNavBackBtnPopOtherAction {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(BaseTabBarController *)result.lastObject setSelectedIndex:3];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)buttonClick:(UIButton *)button {
    self.stateNumber = @(button.tag);
    [self updateBtnsBottomLine];
    [self getOrderStatusListWithRefreshView:nil isAllReload:YES];
}

- (void)updateBtnsBottomLine {
    
    self.allButton.selected = NO;
    self.pendingPaymentButton.selected = NO;
    self.waitingForReceivingButton.selected = NO;
    self.waitingForInstallationButton.selected = NO;
    self.waitingForEvaluateButton.selected = NO;
    
    [self.allButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.pendingPaymentButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.waitingForReceivingButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.waitingForInstallationButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.waitingForEvaluateButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    
    UIButton *button = (UIButton *)[self.buttonBgView viewWithTag:self.stateNumber.integerValue];
    if (self.stateNumber.integerValue==0) button = self.allButton;
    button.selected = YES;
    [button setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateBtnsBottomLine];
}

#pragma -mark UITableViewDelgate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉，暂无更多订单信息"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrdersCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    NSDictionary *sourceData = self.orderList[indexPath.row];
    [cell updateUIData:sourceData];
    if (!cell.btnActionBlock) {
        @weakify(self);
        cell.btnActionBlock = ^(NSIndexPath *indexPath, NSString *btnType) {
            @strongify(self);
            NSDictionary *sourceData = self.orderList[indexPath.row];
            NSString *status = sourceData[@"state_name"];
            if ([btnType isContainsString:@"取消订单"]) {
                if([status isEqualToString:@"待付款"]||[status isEqualToString:@"未付款"]||[status isEqualToString:@"货到付款"]) {
                    [self cancelOrder1:indexPath];
                }else if([status isEqualToString:@"待安装"]||[status isEqualToString:@"已付款"]) {
                    [self cancelOrder2:indexPath];
                }
            }else if ([btnType isContainsString:@"立即支付"]) {
                [self payImmediately:indexPath];
                
            }else if ([btnType isContainsString:@"删除订单"]) {
                [self deleteOrder:indexPath];
                
            }else if ([btnType isContainsString:@"返修/退换"]) {
                [self repairOrReplacement:indexPath];
                
            }else if ([btnType isContainsString:@"评价"]||[btnType isContainsString:@"查看评价"]) {
                [self evaluate:indexPath];
                
            }else if ([btnType isContainsString:@"确认收货"]) {
                [self confirmReceipt:indexPath];
                
            }
        };
    }
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orderList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self getOrderDetail:indexPath];
}


//立即支付
- (void)payImmediately:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetPayNowByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"confirmPay"};
        [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"confirmPay"};
        [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
    }];
    
}
//未付款、货到付款——取消订单
- (void)cancelOrder1:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要取消订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetCancleOrder1ByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
            }];
        }
    }];
}
//已付款、待安装——取消订单
- (void)cancelOrder2:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要取消订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetCancleOrder2ByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"cancelOrder"};
                [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
            }];
        }
    }];
}
//评价
- (void)evaluate:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSDictionary *detail = self.orderList[indexPath.row];
        NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
        GroupCommentListVC*vc = [GroupCommentListVC new];
        vc.commentGroupID = orderID;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
        
    }
}
//删除订单
- (void)deleteOrder:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    [SupportingClass showAlertViewWithTitle:nil message:@"确定要删除订单吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetDelOrderByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"deleteOrder"};
                [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"deleteOrder"};
                [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
            }];
        }
    }];
}
//确认收货
- (void)confirmReceipt:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    [SupportingClass showAlertViewWithTitle:nil message:@"您要确认收货？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsGetConfirmReceiveByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
                operation.userInfo = @{@"ident":@"ConfirmReceive"};
                [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                operation.userInfo = @{@"ident":@"ConfirmReceive"};
                [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
            }];
        }
    }];
}
//退款进度——返修/退换
- (void)repairOrReplacement:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetRefundScheduleByaccessToken:self.accessToken keyID:orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"repairOrReplacement"};
        [self actionRequestResultHandle:operation responseObject:responseObject withError:nil withSourceIndex:indexPath];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"repairOrReplacement"};
        [self actionRequestResultHandle:operation responseObject:nil withError:error withSourceIndex:indexPath];
    }];
    
    
}


- (void)actionRequestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error withSourceIndex:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.orderList[indexPath.row];
    NSString *orderType = detail[@"order_type"];
    BOOL isSpecRepairProduct = (![orderType isEqualToString:@"M"]&&
                                ![orderType isEqualToString:@"O"]&&
                                ![orderType isEqualToString:@"P"]&&
                                ![orderType isEqualToString:@""]);
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
            [ProgressHUDHandler dismissHUD];
            PaymentCenterVC *vc = [PaymentCenterVC new];
            vc.paymentDetail = responseObject[CDZKeyOfResultKey];
            vc.orderClearanceType = isSpecRepairProduct?CDZOrderPaymentClearanceTypeOfSpecRepair:CDZOrderPaymentClearanceTypeOfMaintainExpress;
//            if ([[SupportingClass verifyAndConvertDataToString:self.contentDetail[@"cost_credits"]] isEqualToString:@"0.00"]) {
//                vc.isUseCredit = NO;
//            }
            if ([orderType isEqualToString:@""]||[orderType isEqualToString:@"O"]||[orderType isEqualToString:@"P"]){
                vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRegularParts;
            }
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"cancelOrder"]) {
            [self getOrderStatusListWithRefreshView:nil isAllReload:YES wasReloadForRowData:YES];
            
        }
        
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"repairOrReplacement"]) {
            [ProgressHUDHandler dismissHUD];
            NSArray*resultArr = [responseObject objectForKey:CDZKeyOfResultKey];
            RepairOrReplacementVC *vc=[RepairOrReplacementVC new];
            vc.commentArr = resultArr;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"deleteOrder"]) {
            [self getOrderStatusListWithRefreshView:nil isAllReload:YES wasReloadForRowData:YES];
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"ConfirmReceive"]) {
            [self getOrderStatusListWithRefreshView:nil isAllReload:YES wasReloadForRowData:YES];
        }
        
    }
    
}

#pragma mark- Data Receive Handle
- (void)handleReceivedData:(id)responseObject withRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload wasReloadForRowData:(BOOL)reloadForRowData {
    if(!refreshView){
        [ProgressHUDHandler dismissHUD];
    }else{
        [self stopRefresh:refreshView];
    }
    if (!responseObject||![responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Data Error!");
        return;
    }
    
    @autoreleasepool {
        if (isAllReload){
            [_orderList removeAllObjects];
        }
        [_orderList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        if (!reloadForRowData) {
            self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
            self.pageNums = responseObject[CDZKeyOfPageNumsKey];
            self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        }
        _tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [_tableView reloadData];
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getOrderStatusListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getOrderStatusListWithRefreshView:refresh isAllReload:NO];
        }
    }
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
}

#pragma mark- API Access Code Section
//订单列表（全部、待付款、待收货、待安装、待评价
- (void)getOrderStatusListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    [self getOrderStatusListWithRefreshView:refreshView isAllReload:isAllReload wasReloadForRowData:NO];
}

- (void)getOrderStatusListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload wasReloadForRowData:(BOOL)reloadForRowData {

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    if (isAllReload&&!reloadForRowData) {
        [self pageObjectToDefault];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(isAllReload) forKey:@"isAllReload"];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    if (reloadForRowData) {
        [userInfo addEntriesFromDictionary:@{@"reloadForRowData":@(reloadForRowData)}];
    }
    NSNumber *pageNums = self.pageNums;
    NSNumber *pageSizes = self.pageSizes;
    if (reloadForRowData) {
        pageNums = @1;
        pageSizes = @(pageSizes.integerValue*pageNums.integerValue);
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetOrderListByStatusType:self.stateNumber accessToken:self.accessToken pageNums:pageNums pageSizes:pageSizes keyWords:@"" success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
/* 订单详情 */
- (void)getOrderDetail:(NSIndexPath *)indexPath {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    NSDictionary *detail = _orderList[indexPath.row];
    NSString *orderID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    NSString *orderType = detail[@"order_type"];
    NSString *orderBack = detail[@"order_back"];
    NSNumber *regTag = detail[@"reg_tag"];
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

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    BOOL isAllReload = [operation.userInfo[@"isAllReload"] boolValue];
    BOOL reloadForRowData = NO;
    reloadForRowData = (operation.userInfo[@"reloadForRowData"]&&[operation.userInfo[@"reloadForRowData"] boolValue]);
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
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
        [_orderList removeAllObjects];
        [_tableView reloadData];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@",message,operation.currentRequest.URL.absoluteString);
        
        if (errorCode!=0) {
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
            }
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {
                return;
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [self handleReceivedData:responseObject withRefreshView:refreshView isAllReload:isAllReload wasReloadForRowData:reloadForRowData];
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
