//
//  MyMaintenanceManagementVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyMaintenanceManagementVC.h"
#import "RepairCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import "MaintenancePaymentVC.h"
#import "MaintenanceDetailsVC.h"
#import "GroupCommentListVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


@interface MyMaintenanceManagementVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIButton *maintenanceAppointmentButton;//维修预约

@property (weak, nonatomic) IBOutlet UIButton *maintenanceAndDiagnosisButton;//维修诊断

@property (weak, nonatomic) IBOutlet UIButton *maintainEntrustButton;//维修委托

@property (weak, nonatomic) IBOutlet UIButton *maintainSettleUpButton;//维修结算

/// 维修订单列表
@property (nonatomic, strong) NSMutableArray *repairOrderList;



@property (nonatomic,strong) NSDictionary *confirmPayResultDic;


@end

@implementation MyMaintenanceManagementVC
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_repairOrderList.count==0||self.shouldReloadData) {
        self.shouldReloadData = NO;
        [self getMaintenanceStatusListWithRefreshView:nil isAllReload:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"我的维修管理";
    self.navShouldPopOtherVC = YES;
    [self.buttonView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self componentSetting];

    if (self.currentStatusType<1) {
        self.currentStatusType = 1;
    }
    
    self.tableView.tableFooterView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 167.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"RepairCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RepairCell"];
    
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    _tableView.mj_footer.automaticallyHidden = NO;
    _tableView.mj_footer.hidden = YES;
    
    self.maintenanceAppointmentButton.tag=1;
    self.maintenanceAndDiagnosisButton.tag=2;
    self.maintainEntrustButton.tag=3;
    self.maintainSettleUpButton.tag=4;
    [self.maintenanceAppointmentButton addTarget:self action:@selector(maintenanceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintenanceAndDiagnosisButton addTarget:self action:@selector(maintenanceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintainEntrustButton addTarget:self action:@selector(maintenanceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintainSettleUpButton addTarget:self action:@selector(maintenanceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintenanceAppointmentButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateBtnsBottomLine];
}

- (void)componentSetting {
    self.repairOrderList = [NSMutableArray array];
    [self pageObjectToDefault];
}

- (void)maintenanceClick:(UIButton*)button {
    self.currentStatusType = button.tag;
    [self updateBtnsBottomLine];
    [self getMaintenanceStatusListWithRefreshView:nil isAllReload:YES];
}

- (void)updateBtnsBottomLine {
    self.maintenanceAppointmentButton.selected = NO;
    self.maintenanceAndDiagnosisButton.selected = NO;
    self.maintainEntrustButton.selected = NO;
    self.maintainSettleUpButton.selected = NO;
    
    [self.maintenanceAppointmentButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.maintenanceAndDiagnosisButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.maintainEntrustButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.maintainSettleUpButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.0f withColor:nil withBroderOffset:nil];
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:self.currentStatusType];
    button.selected = YES;
    [button setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉，暂无更多维修信息"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"RepairCell";
    RepairCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.brandShopLabel.layer.masksToBounds=YES;
    cell.brandShopLabel.layer.cornerRadius=3.0;
    cell.leftButton.layer.masksToBounds=YES;
    cell.leftButton.layer.cornerRadius=3.0;
    cell.rightButton.layer.masksToBounds=YES;
    cell.rightButton.layer.cornerRadius=3.0;
    
    
    [cell.cellButtonView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.25 withColor:nil withBroderOffset:nil];
    [cell.bgView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.25 withColor:nil withBroderOffset:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dataDetail = self.repairOrderList[indexPath.row];
    
    cell.rightButton.tag = indexPath.row;
    [cell updateUIDataWithData:dataDetail withStatusType:_currentStatusType];
    cell.rightButton.userInteractionEnabled = NO;
    NSString *process = [SupportingClass verifyAndConvertDataToString:dataDetail[@"process"]];
    if ([process isEqualToString:@"9"]||[process isEqualToString:@"10"]) {
        cell.rightButton.userInteractionEnabled = YES;
    }
    
    if (!cell.btnActionBlock) {
        @weakify(self);
        cell.btnActionBlock = ^(NSIndexPath *indexPath) {
            @strongify(self);
            [self cellBtnActionWithIndexPath:indexPath];
        };
    }
    
    return cell;
}

- (void)cellBtnActionWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDetail = self.repairOrderList[indexPath.row];
    NSString *process = [SupportingClass verifyAndConvertDataToString:dataDetail[@"process"]];
    NSString *repairID =  [SupportingClass verifyAndConvertDataToString:dataDetail[@"id"]];
     if ([process isEqualToString:@"9"]) {
         [self commentWithRepairID:repairID];
     }else  if ([process isEqualToString:@"10"]) {
         [self viewCommentsWithRepairID:repairID];
     }
}

//评论
- (void)commentWithRepairID:(NSString *)repairID {
    GroupCommentListVC *vc = [GroupCommentListVC new];
    vc.commentGroupID = repairID;
    vc.commentForRepair = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}
//查看评论
- (void)viewCommentsWithRepairID:(NSString *)repairID {
    GroupCommentListVC *vc = [GroupCommentListVC new];
    vc.commentGroupID = repairID;
    vc.commentForRepair = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self getMaintenanceStatusDetail:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _repairOrderList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


#pragma mark- Data Receive Handle
- (void)handleReceivedData:(id)responseObject withRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
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
            [_repairOrderList removeAllObjects];
        }
        [_repairOrderList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
//        _reminderView.hidden = (self.totalPageSizes.integerValue!=0);
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
            [self getMaintenanceStatusListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getMaintenanceStatusListWithRefreshView:refresh isAllReload:NO];
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
/* 查询维修列表由维修类型 */
- (void)getMaintenanceStatusListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
//    [_searchTextField resignFirstResponder];
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    if (isAllReload) {
        [self pageObjectToDefault];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"isAllReload":@(isAllReload),
                                                                                    @"MaintenanceStatusType":@(self.currentStatusType)}];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    
    [[APIsConnection shareConnection] personalCenterAPIsGetMaintenanceListByStatusType:self.currentStatusType accessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes shopNameOrKeyID:@"" success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

/* 查询维修详情由维修类型 */
- (void)getMaintenanceStatusDetail:(NSIndexPath *)indexPath {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    NSDictionary *detail = _repairOrderList[indexPath.row];
    NSString *repairID =  [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    NSString *processID = [SupportingClass verifyAndConvertDataToString:detail[@"process"]];
    
    [[APIsConnection shareConnection] personalCenterAPIsGetrepairOrderDetailByStatusType:self.currentStatusType accessToken:self.accessToken keyID:repairID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        
        MaintenanceDetailsVC *vc = [MaintenanceDetailsVC new];
        vc.repairID = repairID;
        vc.currentStatusType = self.currentStatusType;
        vc.processID = processID;
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
    //    CDZMaintenanceStatusType currentStatusType = [operation.userInfo[@"MaintenanceStatusType"] integerValue];
    
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
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接超时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        [_repairOrderList removeAllObjects];
        [_tableView reloadData];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {
            return;
        }
        
        if (errorCode!=0) {
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"confirmPay"]) {
            self.confirmPayResultDic=[responseObject objectForKey:CDZKeyOfResultKey];
            MaintenancePaymentVC*vc=[MaintenancePaymentVC new];
            vc.repairID=self.repairID;
            vc.contentDetail=self.confirmPayResultDic;
            [self.navigationController pushViewController:vc animated:YES];
            [self setDefaultNavBackButtonWithoutTitle];
            [ProgressHUDHandler dismissHUD];
        }
        [self handleReceivedData:responseObject withRefreshView:refreshView isAllReload:isAllReload];
    }
    
}

- (void)handleNavBackBtnPopOtherAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
