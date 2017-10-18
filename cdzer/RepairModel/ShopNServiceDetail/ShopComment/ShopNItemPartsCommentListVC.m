//
//  ShopNItemPartsCommentListVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopNItemPartsCommentListVC.h"
#import "ShopNItemPartsCommentListCell.h"
#import "SimpleRatingChartView.h"
#import "HCSStarRatingView.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ShopNItemPartsCommentListVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, weak) IBOutlet SimpleRatingChartView *chartView;

@property (weak, nonatomic) IBOutlet UILabel *totalRatingLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *totalRatingStarView;

@property (weak, nonatomic) IBOutlet UILabel *totalRatingCountLabel;

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSDictionary *commentDetail;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *commentList;

@end

@implementation ShopNItemPartsCommentListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"技师评价";
    if (self.commentType==SNIPCLCommentTypeOfShop) {
        self.title = @"商家评价";
    }else if (self.commentType==SNIPCLCommentTypeOfParts) {
        self.title = @"商品评价";
    }
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.commentList = [NSMutableArray array];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        [self.tableView registerNib:[UINib nibWithNibName:@"ShopNItemPartsCommentListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        [self getCommentList:nil isReloadAll:YES];
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        self.tableView.tableFooterView = [UIView new];
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
#pragma mark - UITableViewDelegate, UITableViewDataSource && DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多评价信息！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopNItemPartsCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell updateUIData:self.commentList[indexPath.row]];
    return cell;
}

- (void)handleData:(id)refresh {
    [self getCommentList:refresh isReloadAll:[refresh isKindOfClass:ODRefreshControl.class]];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.integerValue+1);
}

- (void)stopRefresh:(id)refresh {
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

- (void)getCommentList:(id)refreshView isReloadAll:(BOOL)isReloadAll  {
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    NSString *commentTypeID = self.commentTypeID;
    @weakify(self);
    if (self.commentType==SNIPCLCommentTypeOfShop) {
        [APIsConnection.shareConnection maintenanceShopsAPIsGetMaintenanceShopsCommentListWithShopID:commentTypeID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:responseObject andError:nil withRefreshView:refreshView isReloadAll:isReloadAll];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:nil andError:error withRefreshView:refreshView isReloadAll:isReloadAll];
        }];
    }else if (self.commentType==SNIPCLCommentTypeOfParts){
        
        [APIsConnection.shareConnection maintenanceShopsAPIsGetProductionCommentListWithProductionID:commentTypeID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:responseObject andError:nil withRefreshView:refreshView isReloadAll:isReloadAll];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:nil andError:error withRefreshView:refreshView isReloadAll:isReloadAll];
        }];
    }else {
        
        [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicCommentListWithMechanicID:commentTypeID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:responseObject andError:nil withRefreshView:refreshView isReloadAll:isReloadAll];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            @strongify(self);
            [self handleAPIResultWithRequestOperation:operation resultObject:nil andError:error withRefreshView:refreshView isReloadAll:isReloadAll];
        }];
    }
}

- (void)handleAPIResultWithRequestOperation:(NSURLSessionDataTask *)operation resultObject:(id)responseObject  andError:(NSError *)error withRefreshView:(id)refreshView isReloadAll:(BOOL)isReloadAll  {
    NSLog(@"Request URL: %@", operation.currentRequest.URL.absoluteString);
    if (responseObject&&!error) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!= 0) {
            
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
            [self.commentList removeAllObjects];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>= self.totalPageSizes.intValue);
        
        self.commentDetail = responseObject[CDZKeyOfResultKey];
//        wxs_star										评论总分
//        all_comment_len								总评论条数
//        five_comment_len								5星评论条数
//        four_comment_len								4星评论条数
//        three_comment_len								3星评论条数
//        two_comment_len								2星评论条数
//        one_comment_len
//        ratingName
//        totalRating
//        numberOfRating
        NSString *totalRating = [SupportingClass verifyAndConvertDataToString:self.commentDetail[@"wxs_star"]];
        NSNumber *totalCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"all_comment_len"]];
        NSNumber *firstLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"one_comment_len"]];
        NSNumber *secondLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"two_comment_len"]];
        NSNumber *thirdLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"three_comment_len"]];
        NSNumber *fourthCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"four_comment_len"]];
        NSNumber *fifthCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"five_comment_len"]];
        
        if (self.commentType==SNIPCLCommentTypeOfMechanic) {
            totalRating = [SupportingClass verifyAndConvertDataToString:self.commentDetail[@"avg_star"]];
            totalCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len"]];
            firstLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len1"]];
            secondLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len2"]];
            thirdLen = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len3"]];
            fourthCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len4"]];
            fifthCount = [SupportingClass verifyAndConvertDataToNumber:self.commentDetail[@"len5"]];
        }
        
        self.totalRatingStarView.value = totalRating.floatValue;
        self.totalRatingLabel.text = totalRating;
        self.totalRatingCountLabel.text = totalCount.stringValue;
        
        [self.chartView
         initializationUIWithData:@[@{@"ratingName":@"5星", @"totalRating":totalCount, @"numberOfRating":fifthCount},
                                    @{@"ratingName":@"4星", @"totalRating":totalCount, @"numberOfRating":fourthCount},
                                    @{@"ratingName":@"3星", @"totalRating":totalCount, @"numberOfRating":thirdLen},
                                    @{@"ratingName":@"2星", @"totalRating":totalCount, @"numberOfRating":secondLen},
                                    @{@"ratingName":@"1星", @"totalRating":totalCount, @"numberOfRating":firstLen},]];
        
        [self.commentList addObjectsFromArray:self.commentDetail[@"comment_info"]];
        [self.tableView reloadData];
    }else {
        if(isReloadAll&&!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
            self.pageNums = @(self.pageNums.integerValue-1);
        }
        if (error.code == -1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code == -1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }

}

@end
