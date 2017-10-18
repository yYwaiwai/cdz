//
//  RepairShopSearchResultVC.m
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairShopSearchResultVC.h"
#import "RepairShopResultVCComponent.h"
#import "RepairShopResultCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import "KeyCityDTO.h"
#import "UserSelectedAutosInfoDTO.h"
#import "RepairShopDetailVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "ShopMapDetailView.h"
#import "UserLocationHandler.h"

@interface RSSPointAnnotation : BMKPointAnnotation

@property (nonatomic, strong) NSDictionary *dataDetail;

@end

@implementation RSSPointAnnotation
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.dataDetail = nil;
}
@end

@interface RSSPinAnnotationView : BMKPinAnnotationView

@property (strong ,nonatomic) NSString *shopID;

@end

@implementation RSSPinAnnotationView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.shopID = nil;
}

@end

@interface RepairShopSearchResultVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, BMKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *mapContainerView;

@property (nonatomic, strong) IBOutlet RepairShopResultFilterView *searchFilter;

@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *repairShopList;



@property (nonatomic, strong) UIImage *mapPinImage;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autoData;

@property (nonatomic, assign) BOOL searchBarIsEditting;

@property (nonatomic, assign) BOOL isShowMapView;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end

@implementation RepairShopSearchResultVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (self.mapView) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeFromSuperview];
        self.mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.mapView) {
        [self.mapView viewWillAppear];
        self.mapView.delegate = nil;
        self.mapView.delegate = self;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignSearchBarFirstResponder) name:@"resignSearchBarFirstResponder" object:nil];
    if (self.totalPageSizes.intValue == 0) {
        
        NSString *cityID = @"";
        if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
            cityID = self.selectedCity.cityID.stringValue;
        }
        [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:nil
                                                                pageSizes:nil
                                                                 ranking:nil
                                                               serviceID:self.searchFilter.shopServiceTypeID
                                                                shopType:self.searchFilter.shopTypeID
                                                                shopName:self.searchBar.text
                                                                  cityID:cityID
                                                                 address:nil
                                                               autoBrand:self.autoData.brandID
                                                                latitude:@(self.coordinate.latitude).stringValue
                                                               longitude:@(self.coordinate.longitude).stringValue
                                                             isCertified:self.searchFilter.isValid.boolValue
                                                             refreshView:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.mapView) {
        [self.mapView viewWillDisappear];
        self.mapView.delegate = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGRect searchBarRect = CGRectZero;
        searchBarRect.size = CGSizeMake(CGRectGetWidth(self.view.frame), 40.0f);
        self.searchBar = [[UISearchBar alloc] initWithFrame:searchBarRect];
        self.searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        self.searchBar.text = self.keywordString;
        self.searchBar.placeholder = getLocalizationString(@"store_name");
        self.searchBar.contentMode = UIViewContentModeLeft;
        self.searchBar.delegate = self;
        [self.searchBar setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:self.searchBar.barTintColor withBroderOffset:nil];
        [self.navigationItem setTitleView:self.searchBar];
        
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
            [self pageObjectToDefault];
            [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:nil
                                                                    pageSizes:nil
                                                                     ranking:nil
                                                                   serviceID:self.searchFilter.shopServiceTypeID
                                                                    shopType:self.searchFilter.shopTypeID
                                                                    shopName:self.searchBar.text
                                                                      cityID:cityID
                                                                     address:nil
                                                                   autoBrand:self.autoData.brandID
                                                                    latitude:@(self.coordinate.latitude).stringValue
                                                                   longitude:@(self.coordinate.longitude).stringValue
                                                                 isCertified:self.searchFilter.isValid.boolValue
                                                                 refreshView:refresh];
        }
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]&&self.totalPageSizes.intValue>(self.pageNums.intValue*self.pageSizes.intValue)) {
            NSString *pageNums = [NSString stringWithFormat:@"%d",self.pageNums.intValue+1];
            [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:pageNums
                                                                    pageSizes:self.pageSizes.stringValue
                                                                     ranking:nil
                                                                   serviceID:self.searchFilter.shopServiceTypeID
                                                                    shopType:self.searchFilter.shopTypeID
                                                                    shopName:self.searchBar.text
                                                                      cityID:cityID
                                                                     address:nil
                                                                   autoBrand:self.autoData.brandID
                                                                    latitude:@(self.coordinate.latitude).stringValue
                                                                   longitude:@(self.coordinate.longitude).stringValue
                                                                 isCertified:self.searchFilter.isValid.boolValue
                                                                 refreshView:refresh];
        }
    }

    
    
}

- (void)refreshView:(id)refresh {
    [self performSelector:@selector(delayRequestData:) withObject:refresh afterDelay:1.5f];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (self.searchBarIsEditting && [touch view] != self.searchBar)
    {
        [self resignSearchBarFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)componentSetting {
    @autoreleasepool {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0f;
        UINib *nib = [UINib nibWithNibName:@"RepairShopResultCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        self.repairShopList = [NSMutableArray array];
        [self pageObjectToDefault];
        self.isShowMapView = NO;
        self.autoData = DBHandler.shareInstance.getSelectedAutoData;
        CLLocation *zeroLocation = [[CLLocation alloc]initWithLatitude:0.0f longitude:0.0f];
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        CLLocationDistance dist = [currentLocation distanceFromLocation:zeroLocation];
        if (dist==0) {
            self.coordinate = UserLocationHandler.shareInstance.coordinate;
        }
        
        if (!self.wasSelectionMode) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                 fileName:@"map_search"
                                                                                     type:FMImageTypeOfPNG
                                                                          scaleWithPhone4:NO
                                                                         offsetRatioForP4:1.0f
                                                                             needToUpdate:YES];
            
            [self setRightNavButtonWithTitleOrImage:image
                                              style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(initialAndShowHiddenMapView)
                                         titleColor:nil
                                        isNeedToSet:YES];
        }
        [self setupFilterView];
    }
}

- (void)setupFilterView {
    [[UINib nibWithNibName:@"RepairShopResultVCComponent" bundle:nil] instantiateWithOwner:self options:nil];
    self.searchFilter.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.shopTypeID&&![self.shopTypeID isEqualToString:@""]) {
        self.searchFilter.shopTypeID = self.shopTypeID;
    }
    if (self.shopServiceTypeID&&![self.shopServiceTypeID isEqualToString:@""]) {
        self.searchFilter.shopServiceTypeID = self.shopServiceTypeID;
    }
    
    
    @weakify(self);
    [self.searchFilter setSelectedResponseBlock:^{
        @strongify(self);
        [self pageObjectToDefault];
        NSString *cityID = @"";
        if (self.selectedCity&&self.selectedCity.cityID&&self.selectedCity.cityID<=0) {
            cityID = self.selectedCity.cityID.stringValue;
        }
        
        [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:nil
                                                                pageSizes:nil
                                                                 ranking:nil
                                                               serviceID:self.searchFilter.shopServiceTypeID
                                                                shopType:self.searchFilter.shopTypeID
                                                                shopName:self.searchBar.text
                                                                  cityID:cityID
                                                                 address:nil
                                                               autoBrand:self.autoData.brandID
                                                                latitude:@(self.coordinate.latitude).stringValue
                                                               longitude:@(self.coordinate.longitude).stringValue
                                                             isCertified:self.searchFilter.isValid.boolValue
                                                             refreshView:nil];
    }];
    
    [self.view addSubview:self.searchFilter];
    
    NSLayoutConstraint *searchFilterLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.searchFilter
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.view
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1
                                                                                      constant:0];
    
    NSLayoutConstraint *searchFilterTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchFilter
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.view
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1
                                                                                  constant:0];
    
    NSLayoutConstraint *searchFilterTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.searchFilter
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1
                                                                                       constant:0];
    [self.view addConstraints:@[searchFilterLeadingConstraint, searchFilterTopConstraint, searchFilterTrailingConstraint]];
    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, repairShopList) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)initialAndShowHiddenMapView {
    @autoreleasepool {
        if (!self.mapView) {
            self.mapView = [[BMKMapView alloc] initWithFrame:self.mapContainerView.bounds];
            self.mapView.compassPosition = CGPointMake(10.0f, 10.0f);
            self.mapView.zoomLevel=16;
            self.mapView.delegate = self;
            [self.mapContainerView addSubview:self.mapView];
        }
        
        if (!self.mapPinImage) {
            self.mapPinImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"map_pin" type:FMImageTypeOfPNG  needToUpdate:YES];
        }
        
        if (self.isShowMapView) {
            
            if (self.mapView.annotations&&self.mapView.annotations.count>0) {
                NSArray *annotations = self.mapView.annotations;
                [self.mapView removeAnnotations:annotations];
            }
            
            if (self.mapView.superview) {
                [self.mapView removeFromSuperview];
            }
            @weakify(self);
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                self.tableView.alpha = 1;
            }];
        }else {
            if (self.mapView.superview) {
                [self.mapView removeFromSuperview];
            }
            [self.mapContainerView addSubview:self.mapView];
            
            if (self.mapView.annotations&&self.mapView.annotations.count>0) {
                NSArray *annotations = self.mapView.annotations;
                [self.mapView removeAnnotations:annotations];
            }
            
            @weakify(self);
            [self.repairShopList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self);
                CGFloat latitude = [obj[@"lat"] doubleValue];
                CGFloat longitude = [obj[@"lng"] doubleValue];
                if (latitude>0&&longitude>0) {
                    RSSPointAnnotation *annotation = [[RSSPointAnnotation alloc]init];
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    NSDictionary *dataDetail = @{@"id":obj[@"id"],
                                                 @"wxs_name":obj[@"wxs_name"],
                                                 @"address":obj[@"address"],
                                                 @"distance": obj[@"distance"]};
                    
                    annotation.dataDetail = dataDetail;
                    [self.mapView addAnnotation:annotation];
                }
            }];
            
            BMKMapRect inMap = [self.mapView visibleMapRect];
            BMKMapPoint coorPoint = BMKMapPointForCoordinate(self.coordinate);
            NSLog(@"coorPointx=%f,coorPoint.y=%f",coorPoint.x,coorPoint.y);
            NSLog(@"inMap.x=%f,inMap.y=%f",inMap.origin.x,inMap.origin.y);
            // 在可视范围内不设置中心点
            if (coorPoint.x < inMap.origin.x || coorPoint.x > (inMap.origin.x+inMap.size.width)
                ||coorPoint.y<inMap.origin.y || coorPoint.y > (inMap.origin.y+inMap.size.height)) {
                [self.mapView setCenterCoordinate:self.coordinate];
            }
            
            
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                self.tableView.alpha = 0;
            }];
        }
        self.isShowMapView = !self.isShowMapView;
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
    return [self.repairShopList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepairShopResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *shopDetail = self.repairShopList[indexPath.row];
    if (shopDetail) {
        [cell setUIDataWithDetailData:shopDetail];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignSearchBarFirstResponder];
    if (self.resultBlock&&self.wasSelectionMode) {
        NSString *shopID = [self.repairShopList[indexPath.row] objectForKey:@"id"];
        NSString *shopName = [self.repairShopList[indexPath.row] objectForKey:@"wxs_name"];
        self.resultBlock(shopID, shopName);
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [ProgressHUDHandler showHUD];
        [self getShopDetailDataWithShopID:[self.repairShopList[indexPath.row] objectForKey:@"id"]];
    }
}

#pragma mark- UISearchBarDelegate
- (void)resignSearchBarFirstResponder {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBarIsEditting = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.searchFilter unfoldingFilterView];
    self.searchBarIsEditting = YES;
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
    [self getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:nil
                                                            pageSizes:nil
                                                             ranking:nil
                                                           serviceID:self.searchFilter.shopServiceTypeID
                                                            shopType:self.searchFilter.shopTypeID
                                                            shopName:self.searchBar.text
                                                              cityID:cityID
                                                             address:nil
                                                           autoBrand:self.autoData.brandID
                                                            latitude:@(self.coordinate.latitude).stringValue
                                                           longitude:@(self.coordinate.longitude).stringValue
                                                         isCertified:self.searchFilter.isValid.boolValue
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
        if (self.totalPageSizes.intValue==0) [dataArray removeAllObjects];
        [dataArray addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        if (self.isShowMapView) {
            self.isShowMapView = NO;
            [self initialAndShowHiddenMapView];
        }
    }
}

#pragma mark- API Access Code Section
- (void)getShopDetailDataWithShopID:(NSString *)shopID {
    if (!shopID) return;
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
            rsdvc.diagnosisResultReason = self.diagnosisResultReason;
            rsdvc.detailData = responseObject[CDZKeyOfResultKey];
            [self setDefaultNavBackButtonWithoutTitle];
            [[self navigationController] pushViewController:rsdvc animated:YES];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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

- (void)getMaintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:(NSString *)pageNums
                                                          pageSizes:(NSString *)pageSizes
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
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:pageNums
                                                                                     pageSizes:pageSizes
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
    success:^(NSURLSessionDataTask *operation, id responseObject) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
        
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
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
        newAnnotationView = [[RSSPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
        newAnnotationView.canShowCallout = YES;
        newAnnotationView.image = self.mapPinImage;
        newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
        newAnnotationView.canShowCallout = YES;
    }
    if ([annotation isKindOfClass:[RSSPointAnnotation class]]) {
        @autoreleasepool {
            ShopMapDetailView *pointDescriptionView = [[[NSBundle mainBundle] loadNibNamed:@"ShopMapDetailView" owner:self options:nil]objectAtIndex:0];
            [pointDescriptionView setShopDetailWithData:[(RSSPointAnnotation *)annotation dataDetail]];
            if ([newAnnotationView isKindOfClass:[RSSPinAnnotationView class]]) {
                [(RSSPinAnnotationView *)newAnnotationView setShopID:[[(RSSPointAnnotation *)annotation dataDetail] objectForKey:@"id"]];
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
    if ([view isKindOfClass:[RSSPinAnnotationView class]]) {
        [self resignSearchBarFirstResponder];
        [ProgressHUDHandler showHUD];
        [self getShopDetailDataWithShopID:[(RSSPinAnnotationView *)view shopID]];
    }
}

@end

