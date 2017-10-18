//
//  EServiceSelectLocationVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/6/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceSelectLocationVC.h"
#import "EServiceLocatePinView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface EServiceSelectLocationVC ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoCodeSearch;
    BMKPoiSearch *_bmkSearch;
}

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet BMKMapView *mapView;

@property (nonatomic, strong) EServiceLocatePinView *locatePinView;

@property (nonatomic, strong) BMKReverseGeoCodeResult *userPointReverseGeoCode;

@property (nonatomic, strong) NSMutableArray *addressNearbyPoiList;

@property (nonatomic, strong) NSMutableArray *searchList;

@property (nonatomic, assign) BOOL firesUpdatePoint;

@property (nonatomic, assign) BOOL searchBarWasFirstResponder;

@property (nonatomic, assign) CLLocationCoordinate2D userCurrentCoordinate;

@property (nonatomic, assign) UIEdgeInsets mapPadding;

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, assign) CGRect srtvDefaultFrame;

@property (nonatomic, assign) NSTimeInterval keyboardShowDuration;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mapViewWithSRTVHeightRatioConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mapViewWithSuperViewHeightRatioConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *superViewWithSRTVBottomConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *searchResultSRTVHeightConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *searchBarActiveSRTVConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *searchBarNonActiveSRTVConstraint;

@property (nonatomic, strong) BMKPoiInfo *selectedPointInfo;


@end

@implementation EServiceSelectLocationVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"更换地点";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.mapPadding = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.frame), 0.0f, 0.0f, 0.0f);
//    _mapView.mapPadding = self.mapPadding;
//    self.locatePinView.centerPointOffset = UIOffsetMake(0.0f, self.mapPadding.top-self.mapPadding.bottom);
    [self.locatePinView layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
    _bmkSearch.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    if (self.mapView.delegate != self) {
        if (!self.mapView.delegate) self.mapView.delegate = nil;
        self.mapView.delegate = self;
    }
    if (_locService.delegate != self) {
        if (!_locService.delegate) _locService.delegate = nil;
        _locService.delegate = self;
    }
    if (_geoCodeSearch.delegate != self) {
        if (!_geoCodeSearch.delegate) _geoCodeSearch.delegate = nil;
        _geoCodeSearch.delegate = self;
    }
    if (_bmkSearch.delegate != self) {
        if (!_bmkSearch.delegate) _geoCodeSearch.delegate = nil;
        _bmkSearch.delegate = self;
    }
}

- (void)initializationUI {
    @autoreleasepool {
        [self setupLocatePinView];
    }
}

- (void)setupLocatePinView {
    @autoreleasepool {
        
        UINib *nib = [UINib nibWithNibName:@"EServiceLocatePinView" bundle:nil];
        NSArray *viewList = [nib instantiateWithOwner:self options:nil];
        self.locatePinView = viewList.lastObject;
        self.locatePinView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.mapView.superview addSubview:self.locatePinView];
    }
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.addressNearbyPoiList = [NSMutableArray array];
        self.searchList = [NSMutableArray array];
        
        self.searchBarActiveSRTVConstraint.active = NO;
        self.searchResultSRTVHeightConstraint.active = NO;
        self.mapViewWithSuperViewHeightRatioConstraint.active = NO;
        self.superViewWithSRTVBottomConstraint.active = YES;
        self.searchBarNonActiveSRTVConstraint.active = YES;
        self.mapViewWithSRTVHeightRatioConstraint.active = YES;
        self.keyboardShowDuration = 0.25;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [self.searchBar setBarTintColor:[UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00]];
        [self.searchBar setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5f];
        
        _bmkSearch = BMKPoiSearch.new;
        
        if (_bmkSearch&&_bmkSearch.delegate!=self) {
            _bmkSearch.delegate = nil;
            _bmkSearch.delegate = self;
        }
        
        _geoCodeSearch = [BMKGeoCodeSearch new];
        _geoCodeSearch.delegate = self;
        
        _mapView.delegate = self;
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        [_locService startUserLocationService];
        _mapView.showsUserLocation = NO;
        _mapView.zoomLevel = 15;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;

        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0f;
        self.tableView.tableFooterView = [UIView new];
        
    }
    
}

- (void)setReactiveRules {
    //    @weakify(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateCurrentView {
    [self.mapView setCenterCoordinate:self.userCurrentCoordinate animated:YES];
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
    reverseGeoCodeOption.reverseGeoPoint = self.userCurrentCoordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = self.searchBarWasFirstResponder?@"没有找到相关地点！":@"暂无所在地址的邻近数据！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.searchBarWasFirstResponder?self.searchList.count:self.addressNearbyPoiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellWithIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellWithIdentifier];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#323232"];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#909090"];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:13.0f];
        cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:9.0f];
    }
    
    BMKPoiInfo *poiInfo = nil;
    if (self.searchBarWasFirstResponder) {
        poiInfo = self.searchList[indexPath.row];
    }else {
        poiInfo = self.addressNearbyPoiList[indexPath.row];
    }
    cell.textLabel.text = poiInfo.name;
    cell.detailTextLabel.text = poiInfo.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMKPoiInfo *poiInfo = nil;
    if (self.searchBarWasFirstResponder) {
        self.selectedPointInfo = poiInfo;
        poiInfo = self.searchList[indexPath.row];
        [self.mapView setCenterCoordinate:poiInfo.pt animated:YES];
        [self.searchBar resignFirstResponder];
    }else {
        if (self.responsBlock) {
            poiInfo = self.addressNearbyPoiList[indexPath.row];
            self.responsBlock (poiInfo);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - SearchBar Configs & UISearchBarDelegate

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [notifyObject.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShowDuration = [notifyObject.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardRect = keyboardRect;
    [self updateTableViewFrameWasSearchBarBecomeFirstResponder:YES];
}

- (void)searchConsultantByPhone {
    [self.searchBar resignFirstResponder];
//    [self getConsultantPostionListWithConsultantPhoneNum:self.searchBar.text];
    [self updateSearchCancelButton];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    self.searchBarWasFirstResponder = NO;
    [self.tableView reloadData];
    [self updateTableViewFrameWasSearchBarBecomeFirstResponder:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    self.searchBarWasFirstResponder = YES;
    [self.tableView reloadData];
    [self updateSearchCancelButton];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchBar.text||[searchBar.text isEqualToString:@""]){
        [self.searchList removeAllObjects];
        [self.tableView reloadData];
        self.selectedPointInfo = nil;
        return;
    }
    
        BMKCitySearchOption *searchOption = [[BMKCitySearchOption alloc] init];
        searchOption.keyword = searchBar.text;
        searchOption.city = @"长沙市";
        [_bmkSearch poiSearchInCity:searchOption];
    
}

- (void)updateSearchCancelButton {
    [self.searchBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view , NSUInteger idx, BOOL * _Nonnull stop) {
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subview isKindOfClass:UIButton.class]) {
                [(UIButton*)subview setTitle:@"取消" forState:UIControlStateNormal];
                [(UIButton*)subview setEnabled:YES];
                [(UIButton*)subview setUserInteractionEnabled:YES];
            }
        }];
    }];
}

- (void)updateTableViewFrameWasSearchBarBecomeFirstResponder:(BOOL)wasFirstResponder {
    @weakify(self);
    if (wasFirstResponder) {
        self.srtvDefaultFrame = self.tableView.frame;
        self.searchBarNonActiveSRTVConstraint.active = NO;
        self.mapViewWithSRTVHeightRatioConstraint.active = NO;
        self.superViewWithSRTVBottomConstraint.active = NO;
        self.searchBarActiveSRTVConstraint.active = YES;
        self.searchResultSRTVHeightConstraint.active = YES;
        self.mapViewWithSuperViewHeightRatioConstraint.active = YES;
        [UIView animateWithDuration:self.keyboardShowDuration animations:^{
            @strongify(self);
            self.searchBarActiveSRTVConstraint.constant = CGRectGetHeight(self.searchBar.frame);
            self.searchResultSRTVHeightConstraint.constant = CGRectGetMinY(self.keyboardRect)-CGRectGetHeight(self.searchBar.frame)-64.0f;
            [self.view setNeedsLayout];
            CGRect frame = self.tableView.frame;
            frame.origin.y = CGRectGetHeight(self.searchBar.frame);
            frame.size.height = CGRectGetMinY(self.keyboardRect)-CGRectGetHeight(self.searchBar.frame)-64.0f;
            self.tableView.frame = frame;
        }];
    }else {
        self.searchBarActiveSRTVConstraint.active = NO;
        self.searchResultSRTVHeightConstraint.active = NO;
        self.mapViewWithSuperViewHeightRatioConstraint.active = NO;
        self.superViewWithSRTVBottomConstraint.active = YES;
        self.searchBarNonActiveSRTVConstraint.active = YES;
        self.mapViewWithSRTVHeightRatioConstraint.active = YES;
        [UIView animateWithDuration:self.keyboardShowDuration animations:^{
            @strongify(self);
            self.tableView.frame = self.srtvDefaultFrame;
            [self.view setNeedsLayout];
        }];
    }
}
#pragma mark- BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    [self.searchList removeAllObjects];
    switch (errorCode) {
        case BMK_SEARCH_NO_ERROR:{
            if (poiResult.poiInfoList&&poiResult.poiInfoList.count!=0) {
                [self.searchList addObjectsFromArray:poiResult.poiInfoList];
            }
            break;
            
        default:
            break;
        }
    }
    if (self.searchBarWasFirstResponder) [self.tableView reloadData];
}

#pragma mark - MapView Configs & BMKMapViewDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error==BMK_SEARCH_NO_ERROR) {
        self.userPointReverseGeoCode = result;
        NSString *address = result.address;
        if (!address||[address isEqualToString:@""]) address = @"无法显示地址";
        self.locatePinView.addressLabel.text = address;
        [self.addressNearbyPoiList removeAllObjects];
        if (![address isEqualToString:@"无法显示地址"]) {
            BMKPoiInfo *poiInfo = [BMKPoiInfo new];
            poiInfo.name = @"目前所在地";
            poiInfo.address = address;
            poiInfo.city = result.addressDetail.city;
            poiInfo.pt = self.mapView.centerCoordinate;
            [self.addressNearbyPoiList addObject:poiInfo];
        }
        [self.addressNearbyPoiList addObjectsFromArray:result.poiList];
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointZero animated:YES];

    }
}


/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser {
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    self.userCurrentCoordinate = userLocation.location.coordinate;
    NSLog(@"%f , %f", userLocation.location.coordinate.latitude ,userLocation.location.coordinate.longitude);
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    self.userCurrentCoordinate = userLocation.location.coordinate;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    if (!self.firesUpdatePoint) {
        [self locateCurrentView];
        self.firesUpdatePoint = YES;
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser {
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
}

#pragma mark BMKMapViewDelegate

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
    reverseGeoCodeOption.reverseGeoPoint = mapView.centerCoordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
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
