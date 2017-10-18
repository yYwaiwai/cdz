//
//  RepairShopSearchResultVC.m
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairShopSearchResultVC.h"
#import "SearchFilterView.h"
#import "RepairShopResultCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import "MJRefresh.h"
#import "KeyCityDTO.h"
#import "UserSelectedAutosInfoDTO.h"
#import "RepairShopDetailVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "ShopMapDetailView.h"
#import "UserLocationHandler.h"

@interface CustomizePointAnnotation : BMKPointAnnotation

@property (nonatomic, strong) NSDictionary *dataDetail;

@end

@implementation CustomizePointAnnotation
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.dataDetail = nil;
}
@end

@interface CustomizePinAnnotationView : BMKPinAnnotationView

@property (strong ,nonatomic) NSString *shopID;

@end

@implementation CustomizePinAnnotationView
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.shopID = nil;
}
@end

@interface RepairShopSearchResultVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, BMKMapViewDelegate>
{
    BMKMapView *_mapView;
}
@property (nonatomic, strong) UIView *mapContainerView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) SearchFilterView *searchFilter;

@property (nonatomic, strong) UITableView *resultTableView;

@property (nonatomic, strong) NSMutableArray *repairShopList;

@property (nonatomic, strong) NSNumber *totalPageNum;

@property (nonatomic, strong) NSNumber *pageNum;

@property (nonatomic, strong) NSNumber *pageSize;

@property (nonatomic, strong) UIImage *mapPinImage;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autoData;

@property (nonatomic, assign) BOOL searchBarIsEditting;

@property (nonatomic, assign) BOOL isShowMapView;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end

@implementation RepairShopSearchResultVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (_mapView) {
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView removeFromSuperview];
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setRightNavButtonWithTitleOrImage:[ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                                fileName:@"map_search"
                                                                                                    type:FMImageTypeOfPNG
                                                                                         scaleWithPhone4:NO
                                                                                             offsetRatioForP4:1.0f
                                                                                            needToUpdate:YES]
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(initialAndShowHiddenMapView)
                                 titleColor:nil
                                isNeedToSet:YES];
    self.repairShopList = [NSMutableArray array];
    [self initializationUI];
    [self componentSetting];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_mapView) {
        [_mapView viewWillAppear];
        _mapView.delegate = nil;
        _mapView.delegate = self;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignSearchBarFirstResponder) name:@"resignSearchBarFirstResponder" object:nil];
    if (_totalPageNum.intValue == 0) {
        
        NSString *cityID = @"";
        if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
            cityID = self.selectedCity.cityID.stringValue;
        }
        [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:nil
                                                                pageSize:nil
                                                                 ranking:nil
                                                               serviceID:_searchFilter.shopServiceTypeID
                                                                shopType:_searchFilter.shopTypeID
                                                                shopName:_searchBar.text
                                                                  cityID:cityID
                                                                 address:nil
                                                               autoBrand:_autoData.brandName
                                                                latitude:@(self.coordinate.latitude).stringValue
                                                               longitude:@(self.coordinate.longitude).stringValue
                                                             isCertified:_searchFilter.isValid.boolValue
                                                             refreshView:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_mapView) {
        [_mapView viewWillDisappear];
        _mapView.delegate = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resignSearchBarFirstResponder" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGRect searchBarRect = CGRectZero;
        searchBarRect.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), 40.0f);
        self.searchBar = [[UISearchBar alloc] initWithFrame:searchBarRect];
        _searchBar.barTintColor = CDZColorOfDefaultColor;
        _searchBar.text = _keywordString;
        _searchBar.placeholder = getLocalizationString(@"store_name");
        _searchBar.contentMode = UIViewContentModeLeft;
        _searchBar.delegate = self;
        [_searchBar setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:CDZColorOfDefaultColor withBroderOffset:nil];
        [self.navigationItem setTitleView:_searchBar];
        
        UIButton *maskBtnView = [UIButton buttonWithType:UIButtonTypeCustom];
        [maskBtnView setFrame:self.contentView.bounds];
        [maskBtnView setAlpha:0];
        [maskBtnView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4]];
        [self.contentView addSubview:maskBtnView];
        
        [self setSearchFilter:[[SearchFilterView alloc] initWithOrigin:CGPointMake(0.0, 0.0)]];
        if (_shopTypeID&&![_shopTypeID isEqualToString:@""]) {
            _searchFilter.shopTypeID = _shopTypeID;
        }
        if (_shopServiceTypeID&&![_shopServiceTypeID isEqualToString:@""]) {
            _searchFilter.shopServiceTypeID = _shopServiceTypeID;
        }
        [_searchFilter initializationUIWithMaskView:maskBtnView];
        [self.contentView addSubview:_searchFilter];
        
        CGRect resultTVRect = CGRectZero;
        resultTVRect.origin.y = CGRectGetMaxY(_searchFilter.frame);
        resultTVRect.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(_searchFilter.frame));
        [self setResultTableView:[[UITableView alloc] initWithFrame:resultTVRect style:UITableViewStylePlain]];
        [_resultTableView setDelegate:self];
        [_resultTableView setRowHeight:90.0f];
        [_resultTableView setDataSource:self];
        [_resultTableView setBounces:YES];
        [_resultTableView setScrollsToTop:YES];
        [self.contentView insertSubview:_resultTableView belowSubview:maskBtnView];
        
//        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
//        refresh.tintColor = [UIColor lightGrayColor];
//        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉更新"];
//        [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
//        [_resultTableView addSubview:refresh];
//        [_resultTableView sendSubviewToBack:refresh];

        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_resultTableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        _resultTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _resultTableView.mj_footer.automaticallyHidden = NO;
        _resultTableView.mj_footer.hidden = YES;
        
        
        self.mapContainerView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.view insertSubview:_mapContainerView belowSubview:self.contentView];
        
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayRequestData:(id)refresh {
    NSString *cityID = @"";
    if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
        cityID = self.selectedCity.cityID.stringValue;
    }
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self componentSetting];
            [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:nil
                                                                    pageSize:nil
                                                                     ranking:nil
                                                                   serviceID:_searchFilter.shopServiceTypeID
                                                                    shopType:_searchFilter.shopTypeID
                                                                    shopName:_searchBar.text
                                                                      cityID:cityID
                                                                     address:nil
                                                                   autoBrand:_autoData.brandName
                                                                    latitude:@(self.coordinate.latitude).stringValue
                                                                   longitude:@(self.coordinate.longitude).stringValue
                                                                 isCertified:_searchFilter.isValid.boolValue
                                                                 refreshView:refresh];
        }
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]&&_totalPageNum.intValue>(_pageNum.intValue*_pageSize.intValue)) {
            NSString *pageNum = [NSString stringWithFormat:@"%d",_pageNum.intValue+1];
            [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:pageNum
                                                                    pageSize:_pageSize.stringValue
                                                                     ranking:nil
                                                                   serviceID:_searchFilter.shopServiceTypeID
                                                                    shopType:_searchFilter.shopTypeID
                                                                    shopName:_searchBar.text
                                                                      cityID:cityID
                                                                     address:nil
                                                                   autoBrand:_autoData.brandName
                                                                    latitude:@(self.coordinate.latitude).stringValue
                                                                   longitude:@(self.coordinate.longitude).stringValue
                                                                 isCertified:_searchFilter.isValid.boolValue
                                                                 refreshView:refresh];
        }
    }

    
    
}

- (void)refreshView:(id)refresh {
    [self performSelector:@selector(delayRequestData:) withObject:refresh afterDelay:1.5f];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (_searchBarIsEditting && [touch view] != _searchBar)
    {
        [self resignSearchBarFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)componentSetting {
    self.totalPageNum = @0;
    self.pageNum = @0;
    self.pageSize = @0;
    self.isShowMapView = NO;
    self.autoData = DBHandler.shareInstance.getSelectedAutoData;
    CLLocation *zeroLocation = [[CLLocation alloc]initWithLatitude:0.0f longitude:0.0f];
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
    CLLocationDistance dist = [currentLocation distanceFromLocation:zeroLocation];
    
    
    if (dist==0) {
        _coordinate = UserLocationHandler.shareInstance.coordinate;
    }
    
    @weakify(self)
    [_searchFilter setSelectedResponseBlock:^{
        @strongify(self)
        self.totalPageNum = @0;
        self.pageNum = @0;
        self.pageSize = @0;
        NSString *cityID = @"";
        if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
            cityID = self.selectedCity.cityID.stringValue;
        }
        [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:nil
                                                                pageSize:nil
                                                                 ranking:nil
                                                               serviceID:self.searchFilter.shopServiceTypeID
                                                                shopType:self.searchFilter.shopTypeID
                                                                shopName:self.searchBar.text
                                                                  cityID:cityID
                                                                 address:nil
                                                               autoBrand:self.autoData.brandName
                                                                latitude:@(self.coordinate.latitude).stringValue
                                                               longitude:@(self.coordinate.longitude).stringValue
                                                             isCertified:self.searchFilter.isValid.boolValue
                                                             refreshView:nil];
    }];
}

- (void)setReactiveRules {
    @weakify(self)
    [RACObserve(self, repairShopList) subscribeNext:^(id x) {
        @strongify(self)
        [self.resultTableView reloadData];
    }];
}

- (void)initialAndShowHiddenMapView {
    @autoreleasepool {
        if (!_mapView) {
            _mapView = [[BMKMapView alloc] initWithFrame:_mapContainerView.bounds];
            _mapView.compassPosition = CGPointMake(10.0f, 10.0f);
            _mapView.zoomLevel=16;
            _mapView.delegate = self;
            [_mapContainerView addSubview:_mapView];
        }
        
        if (!_mapPinImage) {
            self.mapPinImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"map_pin" type:FMImageTypeOfPNG  needToUpdate:YES];
        }
        
        if (_isShowMapView) {
            
            if (_mapView.annotations&&_mapView.annotations.count>0) {
                NSArray *annotations = _mapView.annotations;
                [_mapView removeAnnotations:annotations];
            }
            
            if (_mapView.superview) {
                [_mapView removeFromSuperview];
            }
            @weakify(self)
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self)
                self.contentView.alpha = 1;
            }];
        }else {
            if (_mapView.superview) {
                [_mapView removeFromSuperview];
            }
            [_mapContainerView addSubview:_mapView];
            
            @weakify(self)
            [_repairShopList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self)
                CGFloat latitude = [obj[@"lat"] doubleValue];
                CGFloat longitude = [obj[@"lng"] doubleValue];
                if (latitude>0&&longitude>0) {
                    CustomizePointAnnotation *annotation = [[CustomizePointAnnotation alloc]init];
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    NSDictionary *dataDetail = @{@"id":obj[@"id"],
                                                 @"wxs_name":obj[@"wxs_name"],
                                                 @"address":obj[@"address"],
                                                 @"distance": obj[@"distance"]};
                    
                    annotation.dataDetail = dataDetail;
                    [self->_mapView addAnnotation:annotation];
                }
            }];
            
            BMKMapRect inMap = [_mapView visibleMapRect];
            BMKMapPoint coorPoint = BMKMapPointForCoordinate(_coordinate);
            NSLog(@"coorPointx=%f,coorPoint.y=%f",coorPoint.x,coorPoint.y);
            NSLog(@"inMap.x=%f,inMap.y=%f",inMap.origin.x,inMap.origin.y);
            // 在可视范围内不设置中心点
            if (coorPoint.x < inMap.origin.x || coorPoint.x > (inMap.origin.x+inMap.size.width)
                ||coorPoint.y<inMap.origin.y || coorPoint.y > (inMap.origin.y+inMap.size.height)) {
                [_mapView setCenterCoordinate:_coordinate];
            }
            
            
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self)
                self.contentView.alpha = 0;
            }];
        }
        self.isShowMapView = !_isShowMapView;
    }
}

#pragma -mark UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resignSearchBarFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_repairShopList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"cell";
    RepairShopResultCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[RepairShopResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        [cell initializationUI];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.contentView.backgroundColor = CDZColorOfWhite;
    }
    // Configure the cell...
    NSDictionary *shopDetail = _repairShopList[indexPath.row];
    [cell setUIDataWithDetailData:shopDetail];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignSearchBarFirstResponder];
    [ProgressHUDHandler showHUD];
    [self getShopDetailDataWithShopID:[_repairShopList[indexPath.row] objectForKey:@"id"]];
}

#pragma mark- UISearchBarDelegate
- (void)resignSearchBarFirstResponder {
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    _searchBarIsEditting = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [_searchFilter unfoldingFilterView];
    _searchBarIsEditting = YES;
    for (UIView *view in [searchBar subviews]) {
        for (UIView *subview in [view subviews]) {
            if ([subview isKindOfClass:[UIButton class]] && [[(UIButton *)subview currentTitle] isEqualToString:@"Cancel"] ) {
                [(UIButton*)subview setTitle:getLocalizationString(@"cancel") forState:UIControlStateNormal];
            }
        }
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resignSearchBarFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self resignSearchBarFirstResponder];
    [self componentSetting];
    NSString *cityID = @"";
    if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
        cityID = self.selectedCity.cityID.stringValue;
    }
    [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:nil
                                                            pageSize:nil
                                                             ranking:nil
                                                           serviceID:_searchFilter.shopServiceTypeID
                                                            shopType:_searchFilter.shopTypeID
                                                            shopName:_searchBar.text
                                                              cityID:cityID
                                                             address:nil
                                                           autoBrand:_autoData.brandName
                                                            latitude:@(self.coordinate.latitude).stringValue
                                                           longitude:@(self.coordinate.longitude).stringValue
                                                         isCertified:_searchFilter.isValid.boolValue
                                                         refreshView:nil];
};

#pragma mark- Data Receive Handle
- (void)handleReceivedData:(id)responseObject withRefreshView:(id)refreshView{
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Data Error!");
        return;
    }
    @autoreleasepool {
        NSMutableArray *dataArray = [self mutableArrayValueForKey:@"repairShopList"];
        if (_totalPageNum.intValue==0) [dataArray removeAllObjects];
        [dataArray addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
//        [dataArray addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
//        NSUInteger index = 4;
//        if (dataArray.count>index) {
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, dataArray.count-index)];
//            [dataArray removeObjectsAtIndexes:indexSet];
//        }
        self.pageNum = responseObject[CDZKeyOfPageNumKey];
        self.pageSize = responseObject[CDZKeyOfPageSizeKey];
        self.totalPageNum = @([responseObject[CDZKeyOfTotalPageSizeKey] integerValue]);
        _resultTableView.mj_footer.hidden = ((_pageNum.intValue*_pageSize.intValue)>_totalPageNum.intValue);
        
    }
}

#pragma mark- API Access Code Section
- (void)getShopDetailDataWithShopID:(NSString *)shopID {
    if (!shopID) return;
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:shopID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return ;
        }
        
        @autoreleasepool {
            RepairShopDetailVC *rsdvc = [[RepairShopDetailVC alloc] init];
            rsdvc.detailData = responseObject[CDZKeyOfResultKey];
            rsdvc.diagnosisResultReason = self.diagnosisResultReason;
            [self setNavBarBackButtonTitleOrImage:nil titleColor:nil];
            [[self navigationController] pushViewController:rsdvc animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
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

- (void)getMaintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:(NSString *)pageNums
                                                          pageSize:(NSString *)pageSize
                                                           ranking:(NSString *)rankValue
                                                         serviceID:(NSString *)serviceID
                                                          shopType:(NSString *)shopType
                                                          shopName:(NSString *)shopName
                                                            cityID:(NSString *)cityID
                                                           address:(NSString *)address
                                                         autoBrand:(NSString *)autoBrand
                                                          latitude:(NSString *)latitude
                                                         longitude:(NSString *)longitude
                                                       isCertified:(BOOL)isCertified
                                                       refreshView:(id)refreshView {
   
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsListWithPageNums:pageNums
                                                                                     pageSize:pageSize
                                                                                      ranking:rankValue
                                                                                    serviceID:serviceID
                                                                                     shopType:shopType
                                                                                     shopName:shopName
                                                                                       cityID:cityID
                                                                                      address:address
                                                                                    autoBrand:autoBrand
                                                                                    longitude:longitude
                                                                                     latitude:latitude
                                                                                  isCertified:isCertified
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
        
    }];
}

- (void)requestResultHandle:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
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
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        if (![message isContainsString:@"返回"]) {
            [SupportingClass showToast:message];
        }
        [self handleReceivedData:responseObject withRefreshView:refreshView];
    }
    
}

#pragma mark BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    static NSString * showShopInfoPinIdentifier = @"shopAnnotation";
    BMKAnnotationView *newAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:showShopInfoPinIdentifier];
    if (newAnnotationView == nil) {
        newAnnotationView = [[CustomizePinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
        newAnnotationView.canShowCallout = YES;
        newAnnotationView.image = self.mapPinImage;
        newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
        newAnnotationView.canShowCallout = YES;
    }
    if ([annotation isKindOfClass:[CustomizePointAnnotation class]]) {
        @autoreleasepool {
            ShopMapDetailView *pointDescriptionView = [[[NSBundle mainBundle] loadNibNamed:@"ShopMapDetailView" owner:self options:nil]objectAtIndex:0];
            [pointDescriptionView setShopDetailWithData:[(CustomizePointAnnotation *)annotation dataDetail]];
            if ([newAnnotationView isKindOfClass:[CustomizePinAnnotationView class]]) {
                [(CustomizePinAnnotationView *)newAnnotationView setShopID:[[(CustomizePointAnnotation *)annotation dataDetail] objectForKey:@"id"]];
            }
            
            BMKActionPaopaoView* paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:pointDescriptionView];
            newAnnotationView.paopaoView = paopaoView;
            [newAnnotationView setAnnotation:annotation];
        }
    }
    
    return newAnnotationView;
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    if ([view isKindOfClass:[CustomizePinAnnotationView class]]) {
        [self resignSearchBarFirstResponder];
        [ProgressHUDHandler showHUD];
        [self getShopDetailDataWithShopID:[(CustomizePinAnnotationView *)view shopID]];
    }
}

@end

