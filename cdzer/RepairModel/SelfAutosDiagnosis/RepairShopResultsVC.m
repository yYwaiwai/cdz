//
//  RepairShopResultsVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kTireSpecRecordAutosModelID @"autosModelID"
#define kTireSpecRecordAutosModelName @"autosModelName"
#define kTireSpecRecordSpecName @"tireSpecName"

#import "RepairShopResultsVC.h"
#import "RSRVCViewFilterComponent.h"
#import "UserLocationHandler.h"
#import "RepairShopCell.h"
#import "RepairItemCell.h"
#import "UserSelectedAutosInfoDTO.h"
#import "UISearchBarWithReturnKey.h"
#import "ShopNServiceDetailVC.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface RepairShopResultsVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarWithReturnKeyDelegate, UIScrollViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet RSRVCViewFilterComponent *filterView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@property (nonatomic, strong) UISearchBarWithReturnKey *searchBar;


@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation RepairShopResultsVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [UserLocationHandler.shareInstance stopUserLocationService];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商家选择";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.coordinate.latitude!=0&&self.coordinate.longitude!=0&&
        self.cityName&&![self.cityName isEqualToString:@""]&&
        self.dataList.count!=0) {
        [self updateDataFromFilterSelection:nil isReloadAll:YES];
    }
    
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
        self.autosData = [DBHandler.shareInstance getSelectedAutoData];
        
        self.dataList = [NSMutableArray array];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0f;
        [self.tableView registerNib:[UINib nibWithNibName:@"RepairShopCell" bundle:nil] forCellReuseIdentifier:@"rscell"];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        [[UINib nibWithNibName:@"RSRVCViewFilterComponent" bundle:nil] instantiateWithOwner:self options:nil];
        [self.filterView addSelfByFourMarginToSuperview:self.view];
        
        [self pageObjectToDefault];
        
        @weakify(self);
        self.filterView.resultBlock = ^() {
            @strongify(self);
            [self updateDataFromFilterSelection:nil isReloadAll:YES];
        };
        
        [self updateUserLocation];
        self.filterView.suitableTypeName.text = self.repairItem;
        if ([self.repairItem isEqualToString:@""]) {
            self.filterView.suitableTypeName.text = self.autosData.brandName;
        }
    }
}

- (void)updateUserLocation {
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
        if(!error) {
            [UserLocationHandler.shareInstance stopUserLocationService];
            self.coordinate = userLocation.location.coordinate;
            [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:self.coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
                @strongify(self);
                if (!error) {
                    self.cityName = result.addressDetail.city;
                }
                [self updateDataFromFilterSelection:nil isReloadAll:YES];
            }];
        }else {
            self.cityName = @"长沙市";
            self.coordinate = CLLocationCoordinate2DMake(28.22725, 112.905806);
            [self updateDataFromFilterSelection:nil isReloadAll:YES];
        }
    }];
}

- (void)updateDataFromFilterSelection:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    [self getRepairShopCombinationList:refreshView isReloadAll:isReloadAll];
    
}

- (void)initializationUI {
    @autoreleasepool {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem * spaceButton = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:self
                                                                                      action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:getLocalizationString(@"cancel")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolBar setItems:buttonsArray];

        
        self.searchBar = [[UISearchBarWithReturnKey alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)*0.8, 30.0f)];
        self.searchBar.backgroundColor = CDZColorOfClearColor;
        self.searchBar.placeholder = @"输入关键词/维修商名称";
        self.searchBar.delegate = self;
        self.searchBar.inputAccessoryView = toolBar;
        self.searchBar.enablesReturnKeyAutomatically = NO;
        self.navigationItem.titleView = self.searchBar;
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleData:(id)refresh {
    [self updateDataFromFilterSelection:refresh isReloadAll:[refresh isKindOfClass:[ODRefreshControl class]]];
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

- (void)getRepairShopCombinationList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    
    @weakify(self);
    
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    [APIsConnection.shareConnection selfDiagnoseAPIsGetDiagnoseResultListWithAccessToken:self.accessToken brandId:autosData.brandID serviceID:self.repairItem filterOption:self.filterView.subTypeFilterSequence cityName:self.cityName pageNums:self.pageNums pageSizes:self.pageSizes searchKeyword:self.searchBar.text coordinate:self.coordinate success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSLog(@"operation.request.URL:::%@", operation.currentRequest.URL);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
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
        [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (!isSuccess) {
        [self.tableView reloadData];
    }else {
        [self updateDataFromFilterSelection:nil isReloadAll:YES];
    }
}


#pragma mark - UISearchBarWithReturnKeyDelegate
- (void)searchBarReturnKey:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self updateDataFromFilterSelection:nil isReloadAll:YES];
}

- (void)hiddenKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource && DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多维修商家信息！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"rscell";
    RepairShopCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    [cell updateUIData:self.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (self.searchBar.isFirstResponder) {
            [self.searchBar resignFirstResponder];
        }
        NSDictionary *detail = self.dataList[indexPath.row];
        NSString *majorService = detail[@"major_service"];
        NSArray *specCheckList = @[@"轮胎", @"玻璃", @"电瓶"];
        ShopNServiceDetailVC *vc = [ShopNServiceDetailVC new];
        vc.shopOrServiceID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
        vc.wasSpecItemService = [specCheckList containsObject:majorService];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
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

@end
