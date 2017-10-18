//
//  CaseResultsVC.m
//  cdzer
//
//  Created by 车队长 on 16/11/16.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CaseResultsVC.h"
#import "CasesCell.h"
#import "AllCommentsVC.h"
#import "NoBusinessView.h"
#import "AddCaseVC.h"
#import "MyCaseVC.h"
#import "RepairCaseResultDTO.h"
#import "CaseResultTitleView.h"
#import "PublishedCaseCommentVC.h"
#import "ShopNServiceDetailVC.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface CaseResultsVC ()<UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NoBusinessView *noBusinessView;

@property (strong, nonatomic) CaseResultTitleView *titleView;

@property (strong, nonatomic) NSMutableArray <RepairCaseResultDTO *> *dataList;

@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (nonatomic, strong) IBOutlet UIView *addCaseHintView;

@property (nonatomic, assign) NSUInteger verticalOffset;

@property (nonatomic, strong) PublishedCaseCommentVC *commentVC;

@end

@implementation CaseResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.loginAfterShouldPopToRoot = NO;
    self.title = @"案例结果";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.dataList.count==0||self.shouldReloadData) {
        self.shouldReloadData = NO;
        [self getCasesResultListWithRefreshView:nil isReloadAll:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)componentSetting {
    @autoreleasepool {
        [self setRightNavButtonWithTitleOrImage:@"添加案例" style:UIBarButtonItemStylePlain
                                         target:self action:@selector(pushToAddCaseVC)
                                     titleColor:nil isNeedToSet:YES];
        
        if (!self.mainTitleKeyword) self.mainTitleKeyword = @"";
        self.dataList = [@[] mutableCopy];
        
        
        self.commentVC = [PublishedCaseCommentVC new];
        NSArray *nibList = [[UINib nibWithNibName:@"NoBusinessView" bundle:nil] instantiateWithOwner:self options:nil];
        self.noBusinessView = nibList.firstObject;
        BOOL isMainTitle = (self.mainTitleKeyword&&![self.mainTitleKeyword isEqualToString:@""]);
        if (isMainTitle) {
            self.titleView = [CaseResultTitleView setTitleViewWithMainTitle:self.mainTitleKeyword subTitle:self.subTitleKeyword andSuperView:self.view scrollView:self.tableView];
        }else {
            self.titleView = [CaseResultTitleView setTitleViewWithSearchTitle:self.subTitleKeyword andSuperView:self.view];
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 200.0f;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        self.tableView.backgroundColor = self.view.backgroundColor;
        [self.tableView registerNib:[UINib nibWithNibName:@"CasesCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;

        [self pageObjectToDefault];
    }
}

- (void)updateTitleViewTitle {
    BOOL isMainTitle = (self.mainTitleKeyword&&![self.mainTitleKeyword isEqualToString:@""]);
    if (isMainTitle) {
        [self.titleView updateTitleWithMainTitle:self.mainTitleKeyword subTitle:self.subTitleKeyword];
    }else {
        [self.titleView updateTitleWithSearchTitle:self.subTitleKeyword];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, titleView.frame) subscribeNext:^(id rect) {
        @strongify(self);
        CGRect frame = [rect CGRectValue];
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.top = CGRectGetHeight(frame);
        self.tableView.contentInset = contentInset;
        if (self.refreshControl) {
            [self.refreshControl removeFromSuperview];
            self.refreshControl = nil;
        }
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
//        self.refreshControl.frame = CGRectMake(0, -408, self.tableView.frame.size.width, 400);

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushToAddCaseVC {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @autoreleasepool {
        AddCaseVC *vc = [AddCaseVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        [self getCasesResultListWithRefreshView:nil isReloadAll:YES];
    }
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.addCaseHintView.superview==self.view) {
        [self.addCaseHintView removeFromSuperview];
    }
    return self.addCaseHintView;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    NSInteger verticalOffset = 0;
    NSInteger halfHeight = roundf(CGRectGetHeight(scrollView.frame)/2.0f);
    NSInteger hintViewHalfHeight = roundf(CGRectGetHeight(self.addCaseHintView.frame)/2.0f);
    NSInteger finalVerticalOffset = (hintViewHalfHeight+roundf(CGRectGetHeight(self.titleView.frame)
                                                               +verticalOffset))-halfHeight;
    NSLog(@"%d", finalVerticalOffset);
    return finalVerticalOffset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CasesCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell updateUIData:self.dataList[indexPath.row]];
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(RCCellAction action, NSIndexPath *indexPath) {
            @strongify(self);
            RepairCaseResultDTO *dataObject = self.dataList[indexPath.row];
            switch (action) {
                case RCCellActionOfWriteAComment:
                    [self evaluationCase:indexPath];
                    break;
                case RCCellActionOfRepairDetailDisplay:
                    dataObject.isExpandPriceDetail=!dataObject.isExpandPriceDetail;
                    [self.tableView reloadData];
                    break;
                case RCCellActionOfCommentDisplay:
                    dataObject.isExpandCommentDetail=!dataObject.isExpandCommentDetail;
                    [self.tableView reloadData];
                    break;
                case RCCellActionOfPushCommentList:
                    [self viewMoreEvaluation:indexPath];
                    break;
                case RCCellActionOfPushToRepairShop:
                    [self pushToRepairShop:indexPath];
                    break;
                    
                default:
                    break;
            }
        };
    }
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

//评价此案例
- (void)evaluationCase:(NSIndexPath *)indexPath {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    RepairCaseResultDTO *dto = self.dataList[indexPath.row];
    [self.commentVC showViewWithCaseID:dto.theCaseID];
    
}

//查看更多评价
- (void)viewMoreEvaluation:(NSIndexPath *)indexPath {
    RepairCaseResultDTO *dto = self.dataList[indexPath.row];
    AllCommentsVC *vc = [AllCommentsVC new];
    vc.theCaseID = dto.theCaseID;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

- (void)pushToRepairShop:(NSIndexPath *)indexPath {
    RepairCaseResultDTO *dto = self.dataList[indexPath.row];
    if (!dto.repairShopID||[dto.repairShopID isEqualToString:@""]) {
        [self.noBusinessView showView];
        return;
    }
//    NSString *majorService = detail[@"major_service"];
//    NSArray *specCheckList = @[@"轮胎", @"玻璃", @"电瓶"];
    ShopNServiceDetailVC *vc = [ShopNServiceDetailVC new];
    vc.shopOrServiceID = dto.repairShopID;
    vc.wasSpecItemService = NO;//[specCheckList containsObject:majorService];
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleData:(id)refresh {
    [self getCasesResultListWithRefreshView:refresh isReloadAll:[refresh isKindOfClass:[ODRefreshControl class]]];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.integerValue+1);
}

- (void)stopRefresh:(id)refresh  {
    if (refresh&&[refresh respondsToSelector:@selector(endRefreshing)]) {
        [refresh endRefreshing];
    }
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}

- (void)getCasesResultListWithRefreshView:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    UserSelectedAutosInfoDTO *autoData = [[DBHandler shareInstance]getSelectedAutoData];
    NSString *brandID = autoData.brandID;
    NSString *brandDealershipID = autoData.dealershipID;
    NSString *seriesID = autoData.seriesID;
    NSString *modelID = autoData.modelID;
    
    
    if(!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll) {
        [self pageObjectToDefault];
    }
    
    @weakify(self);
    [APIsConnection.shareConnection casesHistoryAPIsGetHistoryCasesResultListWithAccessToken:self.accessToken resultKeyword:self.subTitleKeyword brandID:brandID brandDealershipID:brandDealershipID seriesID:seriesID modelID:modelID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        NSLog(@"%@",operation);
        if (errorCode!=0) {
            
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {return;};
            if(isReloadAll&&!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
                if (![message isContainsString:@"数据"]) {
                    self.pageNums = @(self.pageNums.integerValue-1);
                }
            }
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        if (isReloadAll&&!refreshView) {
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        
        if (isReloadAll) {
            [self.dataList removeAllObjects];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        NSDictionary *detail = responseObject[CDZKeyOfResultKey];
        NSArray <RepairCaseResultDTO *> *dataList = [RepairCaseResultDTO createCaseDataObjectWithCaseSourceList:detail[@"list"]];
        if (![self.mainTitleKeyword isEqualToString:@""]) {
            self.mainTitleKeyword = detail[@"selectText1"];
            self.subTitleKeyword = detail[@"selectText2"];
        }
        [self updateTitleViewTitle];
        [self.dataList addObjectsFromArray:dataList];
        [self.tableView reloadData];
        NSLog(@"%@", self.navigationItem.rightBarButtonItem.customView);
        self.navigationItem.rightBarButtonItem.customView.hidden = (self.dataList.count==0);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if(isReloadAll&&!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
            self.pageNums = @(self.pageNums.integerValue-1);
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
