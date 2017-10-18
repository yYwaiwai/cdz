//
//  SpecProductCenterVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/21/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SpecProductCenterVC.h"
#import "SNSSLViewFilterComponent.h"
#import "RepairItemCell.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UserAutosSelectonVC.h"
#import "OtherTireSpecificationsVC.h"
#import "SpecAutosPartsDetailVC.h"
#import "UserLocationHandler.h"
#import "TireSpecificationsVC.h"

@interface SpecProductCenterVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet SNSSLViewFilterView *filterView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIControl *singleSpecSelectionView;

@property (nonatomic, weak) IBOutlet UIView *specSelectionContainerView;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@property (nonatomic, assign) BOOL tireCancelSelection;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation SpecProductCenterVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"产品中心";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    self.autosData = autosData;
    [self updateAutosUIData];
    [self getSpecServiceShopProductList:nil isReloadAll:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.specSelectionContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 8;
    offset.rightBottomOffset = offset.rightUpperOffset;
    [[self.specSelectionContainerView viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:offset];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        [[UINib nibWithNibName:@"SPCViewFilterComponent" bundle:nil] instantiateWithOwner:self options:nil];
        [self.filterView addSelfByFourMarginToSuperview:self.view];
        [self.filterView setToItemBrandFilterTypeOnlyWith:self.itemBrandType];
        self.singleSpecSelectionView.hidden = (self.itemBrandType==SNSSLVFItemBrandTypeOfTire);
        
        
        [self pageObjectToDefault];

        self.dataList = [NSMutableArray array];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0f;
        self.tableView.tableFooterView = [UIView new];
        [self.tableView registerNib:[UINib nibWithNibName:@"RepairItemCell" bundle:nil] forCellReuseIdentifier:@"riCell"];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        @weakify(self);
        self.filterView.resultBlock = ^() {
            @strongify(self);
            [self getSpecServiceShopProductList:nil isReloadAll:YES];
        };
        
        [self updateUserLocation];
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

- (IBAction)pushToTireSpecSelectionView {
    if (!self.accessToken) {
        [self presentLoginViewWithBackTitle:@"" animated:YES completion:^{
            
        }];
        return;
    }
    @autoreleasepool {
        TireSpecificationsVC *vc = [TireSpecificationsVC new];
        vc.popBackProductCenter = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self);
        vc.returnSpecificationTextBlock = ^(NSString *specificationText) {
            @strongify(self);
            if (!specificationText) {
                self.tireCancelSelection = YES;
            }
        };
    }
}

- (IBAction)pushToAutoSelectionView {
    if (!self.accessToken) {
        [self presentLoginViewWithBackTitle:@"" animated:YES completion:^{
            
        }];
        return;
    }
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateUserLocation {
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
        if(!error) {
            [UserLocationHandler.shareInstance stopUserLocationService];
            self.coordinate = userLocation.location.coordinate;
        }else {
            self.coordinate = CLLocationCoordinate2DMake(28.224610, 112.893959);
        }
    }];
}

- (void)updateAutosUIData {
    [self.specSelectionContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.tag==1||view.tag==3) {
            UILabel *modelTypeLabel = [(UILabel *)[view viewWithTag:20] viewWithTag:30];
            if (self.autosData&&
                self.autosData.modelName&&![self.autosData.modelName isEqualToString:@""]) {
                modelTypeLabel.text = self.autosData.modelName;
            }else {
//                modelTypeLabel.text = @"请添加车辆车";
            }
        }
        if (view.tag==2) {
            UILabel *modelTypeLabel = [(UILabel *)[view viewWithTag:20] viewWithTag:30];
            if (self.autosData&&
                self.autosData.tireDefaultSpec&&![self.autosData.tireDefaultSpec isEqualToString:@""]) {
                modelTypeLabel.text = self.autosData.tireDefaultSpec;
            }else {
                modelTypeLabel.text = @"请选择轮胎规格";
                
            }
        }
    }];
    
}

- (void)handleData:(id)refresh {
    [self getSpecServiceShopProductList:refresh isReloadAll:[refresh isKindOfClass:[ODRefreshControl class]]];
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

- (void)getSpecServiceShopProductList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
    }
    
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    if (!self.autosData.tireDefaultSpec||[self.autosData.tireDefaultSpec isEqualToString:@""]) {
        [self pushToTireSpecSelectionView];
        return;
    }
    @weakify(self);
    [APIsConnection.shareConnection maintenanceShopsAPIsGetSpecServiceShopsProductListWithShopID:self.shopOrServiceID modelID:self.autosData.modelID pageNums:self.pageNums pageSizes:self.pageSizes filterOption:self.filterView.subTypeFilterSequence productBrandName:self.filterView.itemBrandName tireSpecModel:self.autosData.tireDefaultSpec success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
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

#pragma mark - UITableViewDelegate, UITableViewDataSource && DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多产品信息！";
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
    static NSString *ident = @"riCell";
    RepairItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.hiddenDistanceNShopNameView = YES;
    [cell updateUIData:self.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSDictionary *detail = self.dataList[indexPath.row];
        SpecAutosPartsDetailVC *vc = [SpecAutosPartsDetailVC new];
        vc.specProductID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
        vc.coordinate = self.coordinate;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
