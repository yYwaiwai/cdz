//
//  MyCarInsuranceVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/29.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCarInsuranceVC.h"
#import "MyCarInsuranceCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FillInInformationVC.h"
#import "InsuranceDetailsVC.h"
#import "MyCarInsuranceApplyFormVC.h"
#import "PaymentCenterVC.h"
#import "PersonalCenterVC.h"

@interface MyCarInsuranceVC ()<UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *allButton;//全部

@property (weak, nonatomic) IBOutlet UIButton *noOfferButton;//待报价

@property (weak, nonatomic) IBOutlet UIButton *pendingPaymentButton;//待付款

@property (weak, nonatomic) IBOutlet UIButton *notOutOfOrderButton;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;//一键报案按钮


@property (nonatomic, strong) NSNumber *type;
/// 保险单数据
@property (nonatomic, strong) NSMutableArray *insuranceList;

@property (nonatomic, strong) NSDictionary *insuranceDetail;

@property (nonatomic, strong) NSString *telNum;

@end

@implementation MyCarInsuranceVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self getAutosInsuranceAppShowInsuranceAppWithRefreshView:nil isReloadAll:YES];
}

- (void)handleNavBackBtnPopOtherAction {
    
    if ([self.fromStr isEqualToString:@"我的车辆"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(BaseTabBarController *)result.lastObject setSelectedIndex:3];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"我的保险";
    
    
    [self initializationUI];
    [self componentSetting];
}

- (void)componentSetting {

    self.type = @(0);
    [self pageObjectToDefault];
    self.insuranceList = [NSMutableArray array];
    [self setRightNavButtonWithTitleOrImage:@"添加预约" style:UIBarButtonItemStyleDone target:self action:@selector(showMAIDViewController) titleColor:nil isNeedToSet:YES];
    self.navShouldPopOtherVC = YES;

}

- (void)initializationUI
{
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.allButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 158.0f;
    self.tableView.tableFooterView=[UIView new];
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib=[UINib nibWithNibName:@"MyCarInsuranceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyCarInsuranceCell"];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    _tableView.mj_footer.automaticallyHidden = NO;
    _tableView.mj_footer.hidden = YES;
    
}
//一键报案按钮
- (IBAction)reportButtonClick:(id)sender {
    [self checkUserInsuranceInfoExsit];
}

- (void)showMAIDViewController {
    
    @autoreleasepool {
        FillInInformationVC *vc = [FillInInformationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self pageObjectToDefault];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
        }
    }
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
}
- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getAutosInsuranceAppShowInsuranceAppWithRefreshView:refresh isReloadAll:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getAutosInsuranceAppShowInsuranceAppWithRefreshView:refresh isReloadAll:NO];
        }
    }
    
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)hiddenRefreshView:(id)refreshView {
    [refreshView endRefreshing];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident=@"MyCarInsuranceCell";
    MyCarInsuranceCell*cell=(MyCarInsuranceCell*)[tableView dequeueReusableCellWithIdentifier:ident];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    if (self.insuranceList.count>0) {
        NSDictionary *dic=self.insuranceList[indexPath.row];
        [cell upUIdataWith:dic];
        
        if (!cell.btnActionBlock) {
            @weakify(self);
            cell.btnActionBlock = ^(NSIndexPath *indexPath, NSString *btnType) {
                @strongify(self);
                NSDictionary *sourceData = self.insuranceList[indexPath.row];
                    if ([sourceData[@"state"] isEqualToString:@"预约成功"]) {
                        [self payImmediatelyClickWith:indexPath];
                        
                    }
                    if ([sourceData[@"state"] isEqualToString:@"预约失败"]) {
                        [self reAppointmentClickWith:indexPath];
                    }
                    
            };
            
        }
        
    
    }
    
    return cell;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多我的保险！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self getAutosInsuranceAppShowInsuranceAppWithRefreshView:nil isReloadAll:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    self.tableView.separatorStyle = (_insuranceList.count==0)?UITableViewCellSeparatorStyleNone:UITableViewCellSeparatorStyleSingleLine;
    return _insuranceList.count;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getAppInsuranceAppBuyListWith:[self.insuranceList[indexPath.row] objectForKey:@"pid"]];
}

- (IBAction)buttonClick:(UIButton *)sender {
    self.type=@(sender.tag);
    [self removeAllButtonRectBorder];
    [sender setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
    [sender setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"f8af30"] withBroderOffset:nil];
    [self getAutosInsuranceAppShowInsuranceAppWithRefreshView:nil isReloadAll:YES];
}

-(void)removeAllButtonRectBorder{
    
    [self.allButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    [self.noOfferButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    [self.pendingPaymentButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    [self.notOutOfOrderButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    
    [self.allButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.noOfferButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.pendingPaymentButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.notOutOfOrderButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
}



- (void)getAutosInsuranceAppShowInsuranceAppWithRefreshView:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if(!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll){
        [self pageObjectToDefault];
        [self.insuranceList removeAllObjects];
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppShowInsuranceAppWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes type:self.type success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        if(refreshView){
            [self hiddenRefreshView:refreshView];
        }else {
            [ProgressHUDHandler dismissHUD];
        }
        self.tableView.bounces = YES;
        if(errorCode==0){
            [self.insuranceList addObjectsFromArray:responseObject[CDZKeyOfResultKey] ];
        }else {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            if (self.insuranceList.count!=0) self.tableView.bounces = NO;
        }
        
        if (self.totalPageSizes.integerValue==0) {
            self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        }

        
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        
        [self.tableView reloadData];
        
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (isReloadAll) {
            
            if (self.insuranceList.count==0) self.tableView.bounces = NO;
        }else {
            
            if (self.insuranceList.count!=0) self.tableView.bounces = NO;
        }
        [self.tableView reloadData];
        
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if(refreshView){
                    [self hiddenRefreshView:refreshView];
                }else {
                    [ProgressHUDHandler dismissHUD];
                }
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if(refreshView){
                    [self hiddenRefreshView:refreshView];
                }else {
                    [ProgressHUDHandler dismissHUD];
                }
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if(refreshView){
                [self hiddenRefreshView:refreshView];
            }else {
                [ProgressHUDHandler dismissHUD];
            }
        }];
    }];
}
//保险详情
-(void)getAppInsuranceAppBuyListWith:(NSString *)pid
{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceAppBuyListWithAccessToken:self.accessToken pid:pid success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            self.insuranceDetail=[responseObject objectForKey:CDZKeyOfResultKey];
            InsuranceDetailsVC *vc=[InsuranceDetailsVC new];
            vc.detailDic=self.insuranceDetail;
            vc.pidStr=pid;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
        }];
    }];
}

//重新预约
- (void)reAppointmentClickWith:(NSIndexPath *)indexPath {
    [self getAppInsuranceReAppointWith:indexPath];
}
//立即支付
- (void)payImmediatelyClickWith:(NSIndexPath *)indexPath {
    @weakify(self);
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *pid=[self.insuranceList[indexPath.row] objectForKey:@"pid"];
    [APIsConnection.shareConnection personalCenterAPIsPaymentMethodByAlipayWithAccessToken:self.accessToken orderMainID:pid success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        
        PaymentCenterVC *vc = [PaymentCenterVC new];
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfInsurance;
        vc.paymentDetail = responseObject[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
//重新预约
-(void)getAppInsuranceReAppointWith:(NSIndexPath *)indexPath
{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *pid=[self.insuranceList[indexPath.row] objectForKey:@"pid"];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceReAppointWithAccessToken:self.accessToken pid:pid success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            MyCarInsuranceApplyFormVC *vc=[MyCarInsuranceApplyFormVC new];
            vc.reAppoimtResultDic=responseObject;
            vc.fromStr=@"保险详情";
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@-",error);
        @strongify(self);
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
    }];
}

- (void)checkUserInsuranceInfoExsit {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self)
    [APIsConnection.shareConnection personalCenterAPIsGetUserInsuranceHotlineWithtAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            BOOL isNodata = (([message rangeOfString:@"您还没有购买任何保险"].location!=NSNotFound)||([message rangeOfString:@"没有数据"].location!=NSNotFound));
            NSString *cancelBtn = @"ok";
            NSString *confirmBtn = nil;
            if (isNodata) {
                message = @"由于您个人中心的车辆，没有购买过任何保险，不能报案，敬请谅解！";
                [ProgressHUDHandler dismissHUD];
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:cancelBtn otherButtonTitles:confirmBtn clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
                @strongify(self)
                if (isNodata) {
                    if (btnIdx.unsignedIntegerValue==0) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else {
                    [ProgressHUDHandler dismissHUD];
                }
            }];
            return;
        }
        NSString *tel = [SupportingClass verifyAndConvertDataToString:[responseObject objectForKey:@"telephone"]];
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            if (!tel||[tel isEqualToString:@""]) {
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"由于您个人中心的车辆，没有购买过任何保险，不能报案，敬请谅解！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
            }else {
                self.telNum = tel;
                [SupportingClass makeACall:tel andContents:@"紫金保险：\n%@" withTitle:@"温馨提示"];
            }
        }];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"不明错误" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
    }];
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
