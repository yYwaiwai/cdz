//
//  ShopNServiceSearchListVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kTireSpecRecordAutosModelID @"autosModelID"
#define kTireSpecRecordAutosModelName @"autosModelName"
#define kTireSpecRecordSpecName @"tireSpecName"

#import "ShopNServiceSearchListVC.h"
#import "SNSSLViewFilterComponent.h"
#import "UserLocationHandler.h"
#import "RepairShopCell.h"
#import "RepairItemCell.h"
#import "UserSelectedAutosInfoDTO.h"
#import "TireSpecificationsVC.h"
#import "UISearchBarWithReturnKey.h"
#import "ShopNServiceDetailVC.h"
#import "SpecAutosPartsDetailVC.h"
#import "OtherTireSpecificationsVC.h"
#import "UserAutosSelectonVC.h"
#import "SpecAutosPartsDetailVC.h"
#import "ShopNServiceMapSearchVC.h"
#import "EServiceSelectLocationVC.h"
#import "ShopMechanicSearchListVC.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ShopNServiceSearchListVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarWithReturnKeyDelegate, UIScrollViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet SNSSLViewFilterView *filterView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *optionViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIControl *singleSpecSelectionView;

@property (nonatomic, weak) IBOutlet UIView *specSelectionContainerView;

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *autosSpecSelContainerViewHeightConstraint;


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@property (nonatomic, strong) UISearchBarWithReturnKey *searchBar;


@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) SNSSLVFilterType lastFilterTypeIdx;

@property (nonatomic, strong) NSString *mainFilterSelectedID;

//@property (nonatomic, strong) NSMutableDictionary *tireSpecRecord;

@property (nonatomic, strong) NSString *tireDefaultSpec;

@property (nonatomic) BOOL tireCancelSelection;

@property (nonatomic) BOOL dataLoading;

@end

@implementation ShopNServiceSearchListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [UserLocationHandler.shareInstance stopUserLocationService];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"快速维修";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.selelctedSpecShopIndexPath) {
        [self.filterView setToItemSpecShopFilterTypeWithItemIdx:self.selelctedSpecShopIndexPath specShopServiceTypeList:self.specShopServiceTypeList];
        self.selelctedSpecShopIndexPath = nil;
    }else {
        if (self.filterView.itemBrandType!=SNSSLVFItemBrandTypeOfNone) {
            UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
            self.autosData = autosData;
            [self updateDataFromFilterSelection:nil isReloadAll:YES];

        }else {
            if (self.coordinate.latitude!=0&&self.coordinate.longitude!=0&&
                self.cityName&&![self.cityName isEqualToString:@""]&&
                self.dataList.count!=0) {
                [self updateDataFromFilterSelection:nil isReloadAll:YES];
            }
        }
    }
    [self updateAutosUIData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.specSelectionContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.autosData = [DBHandler.shareInstance getSelectedAutoData];
        [self updateAutosUIData];
        
//        self.tireSpecRecord = [NSMutableDictionary dictionary];
//        NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
//        NSDictionary *tireSpecRecord = [userDefaults objectForKey:CDZKeyOfSelectedTireSpecRecord];
//        if (tireSpecRecord&&tireSpecRecord.count>=3&&self.autosData) {
//            NSString *modelID = tireSpecRecord[kTireSpecRecordAutosModelID];
//            NSString *modelName = tireSpecRecord[kTireSpecRecordAutosModelName];
//            if ([self.autosData.modelName isEqualToString:modelName]&&
//                [self.autosData.modelID isEqualToString:modelID]) {
//                [self.tireSpecRecord addEntriesFromDictionary:tireSpecRecord];
//            }
//        }
        
        BorderOffsetObject *offset = [BorderOffsetObject new];
        offset.rightUpperOffset = 8;
        offset.rightBottomOffset = offset.rightUpperOffset;
        [[self.specSelectionContainerView viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:offset];
        
        self.dataList = [NSMutableArray array];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 200.0f;
        [self.tableView registerNib:[UINib nibWithNibName:@"RepairShopCell" bundle:nil] forCellReuseIdentifier:@"rscell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"RepairItemCell" bundle:nil] forCellReuseIdentifier:@"riCell"];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        [[UINib nibWithNibName:@"SNSSLViewFilterComponent" bundle:nil] instantiateWithOwner:self options:nil];
        [self.filterView addSelfByFourMarginToSuperview:self.view];
        [self setRightNavButtonWithTitleOrImage:@"地图列表" style:UIBarButtonItemStylePlain target:self action:@selector(showMapView) titleColor:CDZColorOfDefaultSubColor isNeedToSet:YES];
        
        
        [self pageObjectToDefault];
        
        @weakify(self);
        self.filterView.resultBlock = ^() {
            @strongify(self);
            [self updateDataFromFilterSelection:nil isReloadAll:YES];
        };
        
        self.lastFilterTypeIdx = SNSSLVFilterTypeOfAll;
        [self updateUserLocation];
    }
}

- (void)updateAutosUIData {
    [self.specSelectionContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.tag==1||view.tag==3) {
            UILabel *modelTypeLabel = [(UILabel *)[view viewWithTag:20] viewWithTag:30];
            if (self.autosData&&
                self.autosData.modelName&&![self.autosData.modelName isEqualToString:@""]) {
                modelTypeLabel.text = self.autosData.modelName;
            }else {
                if (self.accessToken) {
                    modelTypeLabel.text = @"请选择车辆车型";
                }else {
                    modelTypeLabel.text = @"请登录";
                }
            }
        }
        if (view.tag==2) {
            UILabel *modelTypeLabel = [(UILabel *)[view viewWithTag:20] viewWithTag:30];
            if (self.autosData&&
                self.autosData.selectedTireSpec&&![self.autosData.selectedTireSpec isEqualToString:@""]) {
                modelTypeLabel.text = self.autosData.selectedTireSpec;
            }else {
                modelTypeLabel.text = @"请选择轮胎规格";
                return;
                if (self.accessToken) {
                    modelTypeLabel.text = @"请选择轮胎规格";
                }else {
                    modelTypeLabel.text = @"请登录";
                }
            }
        }
    }];
    
}

- (void)showMapView {
    @autoreleasepool {
        @autoreleasepool {
            ShopNServiceMapSearchVC *vc = [ShopNServiceMapSearchVC new];
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
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
                    self.addressLabel.text = result.address;
                }else {
                    self.cityName = @"长沙市";
                    
                }
                [self updateDataFromFilterSelection:nil isReloadAll:YES];
            }];
        }else {
            self.cityName = @"长沙市";
            self.coordinate = CLLocationCoordinate2DMake(28.224610, 112.893959);
            [self updateDataFromFilterSelection:nil isReloadAll:YES];
        }
    }];
}

- (IBAction)pushToSelectLocation {
    @autoreleasepool {
        EServiceSelectLocationVC *vc = [EServiceSelectLocationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self);
        vc.responsBlock = ^(BMKPoiInfo *addressPoiInfo) {
            @strongify(self);
            self.coordinate = addressPoiInfo.pt;
            self.cityName = addressPoiInfo.city;
            self.addressLabel.text = addressPoiInfo.address;
            [self updateDataFromFilterSelection:nil isReloadAll:YES];
        };
    }
}

- (void)updateDataFromFilterSelection:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if (!self.cityName||[self.cityName isEqualToString:@""]||
        self.coordinate.latitude==0||self.coordinate.longitude==0) {
        self.dataLoading = NO;
        return;
    }
    
    self.specSelectionContainerView.hidden = YES;
    self.autosSpecSelContainerViewHeightConstraint.constant = 0;
//    if (self.filterView.currentFilterTypeIdx==2||self.filterView.currentFilterTypeIdx==3) {
//        if ([self.filterView.mainFilterSelectedID isEqualToString:@""]&&self.searchBar.text.length>0) {
//            self.lastFilterTypeIdx = SNSSLVFilterTypeOfAll;
//            self.filterView.currentFilterTypeIdx==  SNSSLVFilterTypeOfAll;
//            self.mainFilterSelectedID = self.filterView.mainFilterSelectedID;
//        }
//    }
    if (self.lastFilterTypeIdx!=self.filterView.currentFilterTypeIdx||
        self.mainFilterSelectedID!=self.filterView.mainFilterSelectedID) {
        self.searchBar.text = @"";
    }
    self.lastFilterTypeIdx = self.filterView.currentFilterTypeIdx;
    self.mainFilterSelectedID = self.filterView.mainFilterSelectedID;
    [self shouldShowSeachBar];
    switch (self.filterView.currentFilterTypeIdx) {
        case SNSSLVFilterTypeOfBrandOption:
            if (self.dataLoading) return;
            self.dataLoading = YES;
            [self getRepairShopBrandNSpecServiceList:refreshView isReloadAll:isReloadAll];
            break;
            
        case SNSSLVFilterTypeOfSpecRepairOption:
            if (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfNone) {
                if (self.dataLoading) return;
                self.dataLoading = YES;
                [self getRepairShopBrandNSpecServiceList:refreshView isReloadAll:isReloadAll];
            }else {
                self.singleSpecSelectionView.hidden = (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfTire);
                self.specSelectionContainerView.hidden = NO;
                self.autosSpecSelContainerViewHeightConstraint.constant = 36.0f;
                CGRect frame = self.specSelectionContainerView.frame;
                frame.size.height = self.autosSpecSelContainerViewHeightConstraint.constant;
                self.specSelectionContainerView.frame = frame;
                if (self.dataLoading) return;
                self.dataLoading = YES;
                [self getRepairSpecItemServiceList:refreshView isReloadAll:isReloadAll];
            }
            break;
            
        case SNSSLVFilterTypeOfAll:
            if (self.dataLoading) return;
            self.dataLoading = YES;
            [self getRepairShopCombinationList:refreshView isReloadAll:isReloadAll];
        default:
            break;
    }
    
}

- (void)shouldShowSeachBar {
    NSLog(@"%d",self.filterView.itemBrandType);
    if (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfNone) {
        if (!self.navigationItem.titleView||self.navigationItem.titleView!=self.searchBar) {
            self.navigationItem.titleView = self.searchBar;
        }
    }else {
        self.navigationItem.titleView = nil;
    }
    [self.filterView setNeedsLayout];
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
        if (!self.selelctedSpecShopIndexPath) {
            self.navigationItem.titleView = self.searchBar;
        }
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (self.lastFilterTypeIdx != SNSSLVFilterTypeOfAll) {
        if ([self.filterView.mainFilterSelectedID isEqualToString:@""]) {
            return NO;
        }
        
    }
    return YES;
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

- (IBAction)pushToTireSpecSelectionView {
    if (!self.accessToken) {
        [self presentLoginViewWithBackTitle:@"" animated:YES completion:^{
            
        }];
        return;
    }
    @autoreleasepool {
        TireSpecificationsVC *vc = [TireSpecificationsVC new];
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

- (IBAction)pushToShopMechanicSearchList {
    @autoreleasepool {
        ShopMechanicSearchListVC *vc = [ShopMechanicSearchListVC new];
        vc.showShopSearchBtn = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairShopListWithAccessToken:self.accessToken cityName:self.cityName coordinate:self.coordinate pageNums:self.pageNums pageSizes:self.pageSizes filterOption:self.filterView.subTypeFilterSequence eSerProject:@"" searchKeyword:self.searchBar.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        self.dataLoading = NO;
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@===%@",message,operation.currentRequest);
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
        self.dataLoading = NO;
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

- (void)getRepairShopBrandNSpecServiceList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairBrandNSpecServiceListWithAccessToken:self.accessToken cityName:self.cityName coordinate:self.coordinate pageNums:self.pageNums pageSizes:self.pageSizes brandOrServiceID:self.filterView.mainFilterSelectedID filterOption:self.filterView.subTypeFilterSequence searchKeyword:self.searchBar.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        self.dataLoading = NO;
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@,%@",message,operation.currentRequest);
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
        self.dataLoading = NO;
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

- (void)getRepairSpecItemServiceList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    
    if (!self.accessToken) {
        self.dataLoading = NO;
        [self.dataList removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
        [self.tableView reloadData];
        [self handleMissingTokenAction];
        return;
    }
    
    
    if (!self.autosData.modelID||[self.autosData.modelID isEqualToString:@""]) {
        [self.dataList removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
        [self.tableView reloadData];
        if (refreshView) {
            [self stopRefresh:refreshView];
        }
        [self pushToAutoSelectionView];
        self.dataLoading = NO;
        return;
    }
    
    if (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfTire&&
        (!self.autosData.selectedTireSpec||[self.autosData.selectedTireSpec isEqualToString:@""])) {
        [self.dataList removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
        [self.tableView reloadData];
        if (self.tireCancelSelection) {
            self.tireCancelSelection = NO;
            return;
        }
        [self pushToTireSpecSelectionView];
        self.dataLoading = NO;
        return;
    }
    
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairSpecItemServiceListWithItemBrandType:self.filterView.itemBrandType tireSpecModel:self.autosData.selectedTireSpec cityName:self.cityName coordinate:self.coordinate pageNums:self.pageNums pageSizes:self.pageSizes filterOption:self.filterView.subTypeFilterSequence modelID:self.autosData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        self.dataLoading = NO;
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
        self.dataLoading = NO;
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
    
    if (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfNone) {
        if (self.filterView.currentFilterTypeIdx==SNSSLVFilterTypeOfBrandOption) {
            text = @"暂无更多品牌店信息！";
        }else if (self.filterView.currentFilterTypeIdx==SNSSLVFilterTypeOfSpecRepairOption) {
            text = @"暂无更多专修店信息！";
        }
    }else {
        
        if (!self.autosData.modelID||[self.autosData.modelID isEqualToString:@""]) {
            text = @"请选择车辆型号！";
        }else{
            switch (self.filterView.itemBrandType) {
                case SNSSLVFItemBrandTypeOfTire:
                    text = @"暂无更多轮胎专修信息！";
                    if (!self.autosData.selectedTireSpec||[self.autosData.selectedTireSpec isEqualToString:@""]) {
                        text = @"请选择轮胎型号！";
                    }
                    break;
                case SNSSLVFItemBrandTypeOfWindshield:
                    text = @"暂无更多玻璃专修信息！";
                    break;
                case SNSSLVFItemBrandTypeOfStorageBattery:
                    text = @"暂无更多电瓶专修信息！";
                    break;
                case SNSSLVFItemBrandTypeOfNone:
                default:
                    break;
            }
        }
    }
    
    if (self.filterView.itemBrandType!=SNSSLVFItemBrandTypeOfNone&&
        !self.accessToken) {
        text = @"请登录以获得更多维修信息！";
    }
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
    if (self.filterView.itemBrandType!=SNSSLVFItemBrandTypeOfNone) {
        static NSString *ident = @"riCell";
        RepairItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        [cell updateUIData:self.dataList[indexPath.row]];
        return cell;
    }
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
        if (self.filterView.itemBrandType==SNSSLVFItemBrandTypeOfNone) {
            NSDictionary *detail = self.dataList[indexPath.row];
            NSString *majorService = detail[@"major_service"];
            NSArray *specCheckList = @[@"轮胎", @"玻璃", @"电瓶"];
            ShopNServiceDetailVC *vc = [ShopNServiceDetailVC new];
            vc.shopOrServiceID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            vc.wasSpecItemService = [specCheckList containsObject:majorService];
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            NSDictionary *detail = self.dataList[indexPath.row];
            SpecAutosPartsDetailVC *vc = [SpecAutosPartsDetailVC new];
            vc.specProductID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            vc.coordinate = self.coordinate;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
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
