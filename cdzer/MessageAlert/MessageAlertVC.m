//
//  MessageAlertVC.m
//  cdzer
//
//  Created by KEns0n on 6/25/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//  消息列表VC

#import "MessageAlertVC.h"
#import "MessageAlertCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import "MessageAlertDetailView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MessageAlertVC () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) BOOL isShowAlertView;
/// 数据数组
@property (nonatomic, strong) NSMutableArray *dataArray;
/// 重新载入按钮
@property (nonatomic, strong) UIButton *retryButton;
/// 是否已经阅读
@property (nonatomic, assign) BOOL wasReaded;
/// 信息详情数据视图
@property (nonatomic, strong) MessageAlertDetailView *messageDetailView;

@property (nonatomic) UILongPressGestureRecognizer *longPressGR;

@end

@implementation MessageAlertVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = getLocalizationString(@"message_alert_vc");
    if (!self.isNormalAlertMessage) {
        
        self.title = @"报警消息";
    }
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_dataArray.count==0) {
        if (!_isNormalAlertMessage) {
            [self getGPSMessageAlertListWithRefreshView:nil isRelaodAll:YES];
        }else {
            [self getMessageAlertListWithRefreshView:nil isRelaodAll:YES];
        }
    }
}

- (void)setReactiveRules {
//    @weakify(self);
//    [RACObserve(self, titleList) subscribeNext:^(NSArray *titleList) {
//        @strongify(self);
//    }];
}

- (void)componentSetting {
    [self pageObjectToDefault];
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    [_dataArray removeAllObjects];
    self.wasReaded = YES;
    
    
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    self.longPressGR.minimumPressDuration = 0.8;
    self.longPressGR.allowableMovement = 0;
}

- (void)switchMessageStatus {
    if (!_isNormalAlertMessage) {
        [self getGPSMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }else {
        [self getMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        self.tableView.emptyDataSetDelegate = self;
        self.tableView.emptyDataSetDelegate = self;
        self.tableView.tableFooterView = UIView.new;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00];
        self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryButton.frame = self.view.bounds;
        _retryButton.hidden = YES;
        [_retryButton setTitle:@"没有更多消息，点此重新载入！" forState:UIControlStateNormal];
        [_retryButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retryReload) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_retryButton];
        
        self.messageDetailView = [MessageAlertDetailView new];
        UINib *nib = [UINib nibWithNibName:@"MessageAlertCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    }
    
}

- (void)retryReload {
    if (!_isNormalAlertMessage) {
        [self getGPSMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }else {
        [self getMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
    }
    if (isRefreshing) {
        [self performSelector:@selector(delayUpdateList:) withObject:refresh afterDelay:1];
    }
}

- (void)delayUpdateList:(id)refresh {
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        [self pageObjectToDefault];
        if (!_isNormalAlertMessage) {
            [self getGPSMessageAlertListWithRefreshView:refresh isRelaodAll:YES];
        }else {
            [self getMessageAlertListWithRefreshView:refresh isRelaodAll:YES];
        }
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        self.pageNums = @(self.pageNums.integerValue+1);
        if (!_isNormalAlertMessage) {
            [self getGPSMessageAlertListWithRefreshView:refresh isRelaodAll:NO];
        }else {
            [self getMessageAlertListWithRefreshView:refresh isRelaodAll:NO];
        }
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark UITableViewDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉，暂无更多%@信息", _isNormalAlertMessage?@"系统":@"GPS报警"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    if (!_isNormalAlertMessage) {
        [self getGPSMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }else {
        [self getMessageAlertListWithRefreshView:nil isRelaodAll:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // NSInteger the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    if (![cell.gestureRecognizers containsObject:self.longPressGR]) {
        [cell addGestureRecognizer:self.longPressGR];
    }
    // Configure the cell...
    cell.userInteractionEnabled = YES;
    [cell updateUIDataWithData:_dataArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)longPressGR {
    if (_isShowAlertView) {
        return;
    }
    self.isShowAlertView = YES;
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:nil message:@"你确定要删除该信息吗？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (btnIdx.integerValue>0) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:(MessageAlertCell *)longPressGR.view];
            NSString *messageID = [self.dataArray[indexPath.row] objectForKey:@"id"];
            [self deleteMessageWithMessageID:messageID andIndexPath:indexPath];
        }
        self.isShowAlertView = NO;
    }];
}

#pragma mark - 用户点击列表事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateStatusWith:indexPath];
}

- (void)updateStatusWith:(NSIndexPath *)indexPath {
    
    //content: "亲爱的用户，百城1已经接受了您的预约，请您在2015-06-30 09前去维修！【车队长】",
    //msg_type: "维修消息",
    //create_time: "2015-06-06 09:24:08 ",
    //state_name: "未读"
    NSMutableDictionary *detail = [_dataArray[indexPath.row] mutableCopy];
    if ([detail[@"state_name"] isContainsString:@"未读"]) {
        detail[@"state_name"] = @"已读";
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:detail];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateMessagStatusWithMessageID:detail[@"id"]];
        [self updateApplicationIconBadgeNumber];
    }
    NSString *content = [_dataArray[indexPath.row] objectForKey:@"content"];
    [_messageDetailView showMessageViewWith:content];
}

- (void)updateApplicationIconBadgeNumber {
    if (self.dataArray.count>0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.state_name LIKE[cd] %@", @"未读"];
        NSArray *result = [_dataArray filteredArrayUsingPredicate:predicate];
        [UIApplication.sharedApplication setApplicationIconBadgeNumber:result.count];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)getGPSMessageAlertListWithRefreshView:(id)refresh isRelaodAll:(BOOL)reloadAll {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refresh) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalMessageAPIsGetMessageAlertListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes plateName:@"0" typeName:nil isMessWasReaded:_wasReaded  success:^(NSURLSessionDataTask *operation, id responseObject) {
        if(!refresh){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refresh];
        }
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        
        if(errorCode!=0){
            self.retryButton.hidden = NO;
            self.tableView.bounces = NO;
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        @strongify(self);
        if (reloadAll) [self.dataArray removeAllObjects];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
//        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        [self.dataArray addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        self.retryButton.hidden = YES;
        self.tableView.bounces = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self updateApplicationIconBadgeNumber];;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if(!refresh){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refresh];
        }
        self.retryButton.hidden = NO;
        self.tableView.bounces = NO;
        
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
        
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"信息更新失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
    }];
    
}

#pragma -mark Address List Request functions
- (void)getMessageAlertListWithRefreshView:(id)refresh isRelaodAll:(BOOL)reloadAll {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refresh) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalMessageAPIsGetMessageAlertListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes plateName:@"1" typeName:nil isMessWasReaded:_wasReaded  success:^(NSURLSessionDataTask *operation, id responseObject) {
        if(!refresh){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refresh];
        }
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        
        if(errorCode!=0){
            self.retryButton.hidden = NO;
            self.tableView.bounces = NO;
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        @strongify(self);
        if (reloadAll) [self.dataArray removeAllObjects];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
//        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        [self.dataArray addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        self.retryButton.hidden = YES;
        self.tableView.bounces = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self updateApplicationIconBadgeNumber];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if(!refresh){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refresh];
            self.pageNums = @(self.pageNums.intValue-1);
        }
        self.retryButton.hidden = NO;
        self.tableView.bounces = NO;
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"信息更新失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
    }];
}

- (void)updateTableViewAndDeleteMessageWithIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)deleteMessageWithMessageID:(NSString *)messageID andIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if ([messageID isEqualToString:@""]||!messageID||!indexPath) {
        [SupportingClass showAlertViewWithTitle:@"error" message:@"信息删除失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
        NSLog(@"Message ID Missing");
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalMessageAPIsPostMessageAlertMessageDeleteWithAccessToken:self.accessToken messageID:messageID success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"信息删除成功！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [self updateTableViewAndDeleteMessageWithIndexPath:indexPath];
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        self.retryButton.hidden = NO;
        self.tableView.bounces = NO;
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"信息删除失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)updateMessagStatusWithMessageID:(NSString* )messageID {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!messageID||[messageID isEqualToString:@""]) {
        return;
    }
    
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalMessageAPIsPostMessageAlertStatusUpdateWithAccessToken:self.accessToken messageID:messageID success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"Mess:%@, eCode:%ld",message, (long)errorCode);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@", error.domain);
    }];
}

@end
