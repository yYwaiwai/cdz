//
//  ShopMechanicSearchListVC.m
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicSearchListVC.h"
#import "SMSLFilterView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "UISearchBarWithReturnKey.h"
#import "ShopMechanicSearchListCell.h"
#import "SMSLResultDTO.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ShopMechanicSearchListVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarWithReturnKeyDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) IBOutlet SMSLFilterView *filterView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISearchBarWithReturnKey *searchBar;

@property (nonatomic, strong) NSString *keyWords;

@property (nonatomic, strong) NSMutableArray <SMSLResultDTO *> *dataList;

@property (weak, nonatomic) IBOutlet UIButton *shopSeachButton;

@end

@implementation ShopMechanicSearchListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"快速维修";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
    [self getMechanicListWithRefreshView:nil isAllReload:YES];
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
        self.keyWords = @"";
        self.dataList = [@[] mutableCopy];
        [[UINib nibWithNibName:@"SMSLFilterView" bundle:nil] instantiateWithOwner:self options:nil];
        [self.filterView addSelfByFourMarginToSuperview:self.view withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
        if (!self.filterView.responseBlock) {
            @weakify(self);
            self.filterView.responseBlock = ^() {
                @strongify(self);
                [self getMechanicListWithRefreshView:nil isAllReload:YES];
            };
        }
        
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 150;
        [self.tableView registerNib:[UINib nibWithNibName:@"ShopMechanicSearchListCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        [self pageObjectToDefault];
    }
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
        self.searchBar.placeholder = @"输入技师名称搜索";
        self.searchBar.delegate = self;
        self.searchBar.inputAccessoryView = toolBar;
        self.searchBar.enablesReturnKeyAutomatically = NO;
        self.navigationItem.titleView = self.searchBar;
        
        if ([self.fromStr isEqualToString:@"店铺详情"]) {
            self.shopSeachButton.hidden=YES;
        }
    }
}

- (void)setReactiveRules {
    
}

- (void)setShowShopSearchBtn:(BOOL)showShopSearchBtn {
    _showShopSearchBtn = showShopSearchBtn;
    [self.view viewWithTag:101].hidden = !showShopSearchBtn;
}

- (IBAction)pushBackShopSearchListVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getMechanicListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            [self pageObjectPlusOne];
            [self getMechanicListWithRefreshView:refresh isAllReload:NO];
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

#pragma mark - UISearchBarWithReturnKeyDelegate
- (void)searchBarReturnKey:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.keyWords = self.searchBar.text;
    [self getMechanicListWithRefreshView:nil isAllReload:YES];
}

- (void)hiddenKeyboard {
    [self.searchBar resignFirstResponder];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多技师/技工信息";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
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
    ShopMechanicSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    if ([self.fromStr isEqualToString:@"立即预约"]) {
        cell.showSelection=YES;
    }else{
        cell.showSelection=NO;
    }
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(NSIndexPath *indexPath) {
            @strongify(self);
            if (self.resultBlock) {
                SMSLResultDTO *selectedMechanicDetail = self.dataList[indexPath.row];
                self.resultBlock(selectedMechanicDetail);
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
    }
    [cell updateUIData:self.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        [self getMechanicDetail:indexPath];
    }
}

- (void)getMechanicListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    
    if(!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicListWithFilterOption:@(self.filterView.filterType) pageNums:self.pageNums pageSizes:self.pageSizes searchKeyword:self.keyWords mechanicSpecialfilter:self.filterView.otherFilterString listFromRepairShop:(self.repairShopID&&![self.repairShopID isEqualToString:@""]) repairShopID:self.repairShopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:(!refreshView)]) {
            return;
        }
        
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        if (errorCode!=0) {
            if ([refreshView isKindOfClass:MJRefreshFooter.class]) {
                [self pageObjectMinusOne];
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        if (isAllReload){
            [self.dataList removeAllObjects];
        }
        
        NSArray <SMSLResultDTO *> *dataList = [SMSLResultDTO createSMSLResultDataObjectFromSourceList:responseObject[CDZKeyOfResultKey]];
        
        [self.dataList addObjectsFromArray:dataList];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
        if (isAllReload) {
            [self.dataList removeAllObjects];
            [self.tableView reloadData];
        }
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            if ([refreshView isKindOfClass:MJRefreshFooter.class]) {
                [self pageObjectMinusOne];
            }
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

    }];
}

- (void)getMechanicDetail:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    SMSLResultDTO *dto = self.dataList[indexPath.row];
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicDetailWithAccessToken:self.accessToken mechanicID:dto.mechanicID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest.URL.absoluteString);
        
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        ShopMechanicDetailVC *vc = [ShopMechanicDetailVC new];
        vc.mechanicID = dto.mechanicID;
        vc.detailData = [ShopMechanicDetailDTO createMechanicDetailFromSourceData:responseObject[CDZKeyOfResultKey]];
        vc.selectedMechanicDetail = dto;
        vc.onlyForSelection = self.onlyForSelection;
        if (self.onlyForSelection) {
            vc.resultBlock = self.resultBlock;
        }
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
