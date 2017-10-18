//
//  MyEnquiryVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyEnquiryVC.h"
#import "MyEnquiryCell.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MyEnquiryVC () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// 询价数据列表
@property (nonatomic, strong) NSMutableArray *enquiryList;

/// 提醒视图
@property (nonatomic, strong) UIControl *reminderView;

@end

@implementation MyEnquiryVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getGetSelfEnquireProductsPriceListWithRefreshView:nil isAllReload:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"我的询价列表";
    
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.enquiryList = [NSMutableArray array];
    
    self.tableView.tableFooterView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 167.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"MyEnquiryCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyEnquiryCell"];
}

- (void)initializationUI {
    @autoreleasepool {
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
    }
}

- (void)componentSetting {
    self.navShouldPopOtherVC = YES;
    [self pageObjectToDefault];
}

- (void)reloadDataForReminderView {
    [self getGetSelfEnquireProductsPriceListWithRefreshView:NO isAllReload:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"MyEnquiryCell";
    MyEnquiryCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    if (_enquiryList.count>0) {
        NSDictionary*detail=_enquiryList[indexPath.section];
        NSString *imgURL = [detail objectForKey:@"imgurl"];
        if ([imgURL containsString:@"http"]) {
            [ cell.productPortraitIV sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.statusLabel.text=detail[@"state_name"];
        cell.dateTimeLabel.text=detail[@"add_time"];
        cell.productNameLabel.text=detail[@"product_name"];
        cell.userDetailLabel.text=detail[@"centerName"];
        if ([detail[@"reply_content"] isEqualToString:@""]) {
            cell.inquiryReplyLabel.text=@"询价回复:没有回复";
        }else{
            cell.inquiryReplyLabel.text=[NSString stringWithFormat:@"询价回复:%@",detail[@"reply_content"]];
        }
    }
    return cell;
}

#pragma -mark UITableViewDelgate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉！暂无更多询价信息"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _enquiryList.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footBgView=[UIView new];
    footBgView.backgroundColor=[UIColor colorWithHexString:@"f5f5f5"];
    return footBgView;
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
        if (isAllReload) [_enquiryList removeAllObjects];
        [_enquiryList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        
        _reminderView.hidden = (self.totalPageSizes.integerValue!=0);
        self.tableView.bounces = (self.totalPageSizes.integerValue!=0);
       
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [self.tableView reloadData];
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getGetSelfEnquireProductsPriceListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getGetSelfEnquireProductsPriceListWithRefreshView:refresh isAllReload:NO];
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
- (void)getGetSelfEnquireProductsPriceListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(isAllReload) forKey:@"isAllReload"];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    
    [[APIsConnection shareConnection] personalCenterAPIsGetSelfEnquireProductsPriceWithAccessToken:self.accessToken
                                                                                          pageNums:self.pageNums.stringValue
                                                                                          pageSizes:self.pageSizes.stringValue
                                                                                           success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                                                               operation.userInfo = userInfo;
                                                                                               [self requestResultHandle:operation responseObject:responseObject withError:nil];
                                                                                           } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                                                                                               operation.userInfo = userInfo;
                                                                                               [self requestResultHandle:operation responseObject:nil withError:error];
                                                                                           }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    BOOL isAllReload = [operation.userInfo[@"isAllReload"] boolValue];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        @weakify(self);
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                [self.enquiryList removeAllObjects];
                [self.tableView reloadData];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {@strongify(self)
                [self.enquiryList removeAllObjects];
                [self.tableView reloadData];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {@strongify(self)
            [self.enquiryList removeAllObjects];
            [self.tableView reloadData];
        }];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        switch (errorCode) {
            case 0:{
                
                [self handleReceivedData:responseObject withRefreshView:refreshView isAllReload:isAllReload];
            }
                break;
            case 1:
            case 2:
                if(!refreshView){
                    [ProgressHUDHandler dismissHUD];
                }else{
                    [self stopRefresh:refreshView];
                }
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
                break;
                
            default:
                break;
        }
        
    }
    
}

- (void)handleNavBackBtnPopOtherAction {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(BaseTabBarController *)result.lastObject setSelectedIndex:3];
    }
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
