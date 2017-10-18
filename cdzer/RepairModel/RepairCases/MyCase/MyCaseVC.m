//
//  MyCaseVC.m
//  cdzer
//
//  Created by 车队长 on 16/11/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCaseVC.h"
#import "MyCaseCell.h"
#import "AddCaseVC.h"
#import "MyCaseResultDTO.h"
#import "ShopNServiceDetailVC.h"
#import "NoBusinessView.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


@interface MyCaseVC ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <MyCaseResultDTO *> *dataList;

@property (nonatomic, strong) IBOutlet UIButton *editButton;

@property (strong, nonatomic) NoBusinessView *noBusinessView;

@end

@implementation MyCaseVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.dataList.count==0||self.shouldReloadData) {
        self.shouldReloadData = NO;
        [self getMyCaseList:nil isReloadAll:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的案例";
    self.editButton.selected = NO;
    self.navShouldPopOtherVC = YES;
    [self initializationUI];
}

- (void)handleNavBackBtnPopOtherAction {
    
    NSPredicate *predicateTabBarVC = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *theResult = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicateTabBarVC];
    if (theResult&&theResult.count>0) {
        [(BaseTabBarController *)theResult.lastObject setSelectedIndex:3];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initializationUI {
    @autoreleasepool {
        [self.editButton removeFromSuperview];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
        
        self.dataList = [@[] mutableCopy];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 30.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = self.view.backgroundColor;
        UINib *nib = [UINib nibWithNibName:@"MyCaseCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _tableView.mj_footer.automaticallyHidden = NO;
        _tableView.mj_footer.hidden = YES;
        NSArray *nibList = [[UINib nibWithNibName:@"NoBusinessView" bundle:nil] instantiateWithOwner:self options:nil];
        self.noBusinessView = nibList.firstObject;
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多信息！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.isEditMode = self.editButton.selected;
    cell.indexPath = indexPath;
    [cell updateUIData:self.dataList[indexPath.row]];
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(MCCellAction action, NSIndexPath *indexPath) {
            @strongify(self);
            MyCaseResultDTO *dataObject = self.dataList[indexPath.row];
            switch (action) {
                case MCCellActionOfRepairDetailDisplay:
                    dataObject.isExpandPriceDetail=!dataObject.isExpandPriceDetail;
                    [self.tableView reloadData];
                    break;
                case MCCellActionOfRepairReceiptsDisplay:
                    dataObject.isExpandRepairReceiptsDetail=!dataObject.isExpandRepairReceiptsDetail;
                    [self.tableView reloadData];
                    break;
                case MCCellActionOfEditCase:
                    [self editCaseWithResultData:self.dataList[indexPath.row]];
                    break;
                case MCCellActionOfDeleteCase:
                    [self deledeleteCaseWith:indexPath];
                    break;
                case MCCellActionOfPushToRepairShop:
                    [self pushToRepairShop:indexPath];
                    break;
                    
                default:
                    break;
            }
        };
    }

    return cell;
    
}

-(void)deledeleteCaseWith:(NSIndexPath*)indexPath{
    [SupportingClass showAlertViewWithTitle:@"" message:@"您是否要删除该案例？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>=1) {
            [self deleteCaseWithCaseID:self.dataList[indexPath.row].theCaseID];
        }
    }];
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

- (void)handleData:(id)refresh {
    [self getMyCaseList:refresh isReloadAll:[refresh isKindOfClass:ODRefreshControl.class]];
}

- (void)stopRefresh:(MJRefreshAutoNormalFooter *)refreshView  {
    [refreshView endRefreshing];
}
//编辑
- (IBAction)updateEditingStatus:(UIButton *)sender {
    self.editButton.selected = !self.editButton.selected;
    if (self.editButton.selected) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 20)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }else {
        self.tableView.tableHeaderView = nil;
    }
    [self.tableView reloadData];
}
//编辑
- (void)editCaseWithResultData:(MyCaseResultDTO *)resultData {
    if (resultData) {
        AddCaseVC *vc = [AddCaseVC new];
        vc.resultData = resultData;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    }
}

- (void)pushToRepairShop:(NSIndexPath *)indexPath {
    MyCaseResultDTO *dto = self.dataList[indexPath.row];
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


- (void)getMyCaseList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if (!self.accessToken) {
        [self.dataList removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
        [self.tableView reloadData];
        [self handleMissingTokenAction];
        return;
    }
    if (isReloadAll) {
        [self pageObjectToDefault];
        
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetMyCaseListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [self pageObjectMinusOne];
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {return;};
            if(isReloadAll&&!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
                if (![message isContainsString:@"数据"]) {
                    if ([refreshView isKindOfClass:[MJRefreshFooter class]]) {
                        self.pageNums = @(self.pageNums.integerValue-1);
                    }
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
        
        NSArray <MyCaseResultDTO *> *dataList = [MyCaseResultDTO createCaseDataObjectWithCaseSourceList:responseObject[CDZKeyOfResultKey]];
        [self.dataList addObjectsFromArray:dataList];
        [self.tableView reloadData];

    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if(isReloadAll&&!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
            if ([refreshView isKindOfClass:[MJRefreshFooter class]]) {
                self.pageNums = @(self.pageNums.integerValue-1);
            }
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

- (void)deleteCaseWithCaseID:(NSString *)theCaseID {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetDelCaseWithAccessToken:self.accessToken idStr:theCaseID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
        [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [self getMyCaseList:nil isReloadAll:YES];
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
