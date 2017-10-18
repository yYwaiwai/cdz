//
//  ShopNServiceMapSearchVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/28/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#import "ShopNServiceMapSearchVC.h"
#import "ShopMapPointDetailInfoComponents.h"
#import "EServiceSelectLocationVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "EServiceLocatePinView.h"

typedef NS_ENUM(NSUInteger, MapSearchDisplayState) {
    MapSearchDisplayStateOfNormal,
    MapSearchDisplayStateOfSearchShow,
    MapSearchDisplayStateOfRoutePath,
};

@interface UIImage (RotateImage)

- (UIImage*)imageRotationByDegrees:(CGFloat)degrees;

@end

@implementation UIImage (RotateImage)

- (UIImage*)imageRotationByDegrees:(CGFloat)degrees {
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end


@interface RouteAnnotation : BMKPointAnnotation

@property (nonatomic) int type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点

@property (nonatomic) int degree;

@end
@implementation RouteAnnotation

@end

@interface ShopNServiceMapSearchVC ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRouteSearchDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoCodeSearch;
}

@property (nonatomic, weak) IBOutlet BMKMapView *mapView;

@property (nonatomic, assign) CLLocationCoordinate2D lastUserCurrentCoordinate;

@property (nonatomic, assign) CLLocationCoordinate2D userCurrentCoordinate;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) BMKReverseGeoCodeResult *userPointReverseGeoCode;

@property (nonatomic, strong) NSArray <NSDictionary *> *shopMapPointList;

@property (nonatomic, assign) MapSearchDisplayState currentState;


@property (weak, nonatomic) IBOutlet UIButton *backLastStateBtn;

@property (weak, nonatomic) IBOutlet UIView *locateSearchView;

@property (nonatomic, strong) BMKPoiInfo *startPointPoiInfo;
@property (weak, nonatomic) IBOutlet UILabel *startPointLabel;

@property (weak, nonatomic) IBOutlet UIImageView *pathPatternImageView;

@property (nonatomic, assign) CLLocationCoordinate2D endPointCoordinate;
@property (nonatomic, assign) NSUInteger endPointDataIdx;
@property (nonatomic, strong) NSString *endPointName;
@property (weak, nonatomic) IBOutlet UILabel *endPointLabel;
@property (weak, nonatomic) IBOutlet UITableView *shopSelectionTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shopSelectionTableViewHeightConstraint;
@property (assign, nonatomic) BOOL showShopSelectionTableView;

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;



@property (nonatomic, assign) CGFloat userLocateBtnCenterYConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userLocateBtnCenterYConstraint;
@property (weak, nonatomic) IBOutlet UIButton *userLocateBtn;



@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rpDisplayViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *routePathDisplayContainerView;

@property (weak, nonatomic) IBOutlet UIButton *routePathDisplayBtn;

@property (weak, nonatomic) IBOutlet UILabel *timeNDistanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *startNavBtn;

@property (weak, nonatomic) IBOutlet UITableView *routePathTableView;

@property (strong, nonatomic) BMKDrivingRouteResult *routeResult;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *routePointList;

@property (nonatomic, strong) EServiceLocatePinView *locatePinView;

@property (nonatomic, assign) BOOL firesUpdatePoint;

@end

@implementation ShopNServiceMapSearchVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"商家地图";
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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.locateSearchView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.locateSearchView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    
    [self.startPointLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.endPointLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"snsms_points_icon@3x" ofType:@"png"]]];
    self.pathPatternImageView.backgroundColor = color;
    
    [self.startNavBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.startNavBtn.frame)/2.0f];
    [self.startNavBtn.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];

}

- (void)initializationUI {
    @autoreleasepool {
        [self.shopSelectionTableView registerClass:UITableViewCell.class forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.shopSelectionTableView.rowHeight = 30;
        self.shopSelectionTableView.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        
        [self.routePathTableView registerClass:UITableViewCell.class forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.routePathTableView.rowHeight = UITableViewAutomaticDimension;
        self.routePathTableView.estimatedRowHeight = 44.0f;
        
        
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
        self.routePointList = [@[] mutableCopy];
        self.currentState = MapSearchDisplayStateOfNormal;
        self.userLocateBtnCenterYConstant = self.userLocateBtnCenterYConstraint.constant;
        
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
        
    }
    
}

- (void)setReactiveRules {
        @weakify(self);
    [RACObserve(self, showShopSelectionTableView) subscribeNext:^(NSNumber *showShopSelectionTableView) {
        @strongify(self);
        if (showShopSelectionTableView.boolValue) {
            [self.shopSelectionTableView reloadData];
            CGFloat height = self.shopSelectionTableView.contentSize.height;
            if (height>110) {
                height = 110;
            }
            self.shopSelectionTableViewHeightConstraint.constant = height;
            self.shopSelectionTableView.hidden = NO;
            [self.shopSelectionTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.endPointDataIdx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }else {
            self.shopSelectionTableViewHeightConstraint.constant = 0;
            self.shopSelectionTableView.hidden = YES;
        }
    }];
}

- (void)reloadRepairShopLocation {
    NSArray* array = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeOverlays:array];
    if (self.shopMapPointList.count>0) {
        NSMutableArray *pointList = [@[] mutableCopy];
        @weakify(self);
        [self.shopMapPointList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            CLLocationDegrees latitude = [SupportingClass verifyAndConvertDataToString:detail[@"lat"]].doubleValue;
            CLLocationDegrees longitude = [SupportingClass verifyAndConvertDataToString:detail[@"lng"]].doubleValue;
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            ShopInfoPointAnnotation *pointAnnotation = [ShopInfoPointAnnotation new];
            pointAnnotation.coordinate = coordinate;
            pointAnnotation.objectIdx = idx;
            pointAnnotation.shopName = detail[@"wxs_name"];
            pointAnnotation.shopMajorService = detail[@"major_service"];
            pointAnnotation.starValue = [SupportingClass verifyAndConvertDataToString:detail[@"star"]].floatValue;
            pointAnnotation.isTypeOfSpecShop = [detail[@"wxs_kind"] isEqualToString:@"专修店"];
            [pointList addObject:pointAnnotation];
        }];
        [self.mapView addAnnotations:pointList];
    }
}

- (IBAction)pushToSelectStartPoint:(id)sender {
    @autoreleasepool {
        EServiceSelectLocationVC *vc = [EServiceSelectLocationVC new];
        @weakify(self);
        vc.responsBlock = ^(BMKPoiInfo *addressPoiInfo) {
            @strongify(self);
            self.startPointPoiInfo = addressPoiInfo;
            [self updateStartEndPointUI];
        };
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)locateCurrentView {
    
    [self.mapView setCenterCoordinate:self.userCurrentCoordinate animated:YES];
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
    reverseGeoCodeOption.reverseGeoPoint = self.userCurrentCoordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

- (IBAction)pushToBaiDuMapApp:(id)sender {
    [self openNativeNavi];
}
- (void)openNativeNavi {
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    NSLog(@"%@", [NSValue valueWithMKCoordinate:self.userCurrentCoordinate]);
    if (self.startPointPoiInfo!=nil) {
        start.pt = self.startPointPoiInfo.pt;
    }else{
        start.pt = self.userCurrentCoordinate;
    }
    
    //指定起点名称
    start.name = self.cityName;
    //指定起点
    para.startPoint = start;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //指定终点经纬度
    end.pt = self.endPointCoordinate;
    //指定终点名称
    end.name = self.endPointName;
    //指定终点
    para.endPoint = end;
    
    //指定返回自定义scheme
    para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    
    BMKOpenErrorCode errorCode = [BMKNavigation openBaiduMapNavigation:para];
    NSLog(@"%d", errorCode);
}

- (void)setCurrentState:(MapSearchDisplayState)currentState {
    _currentState = currentState;
    switch (currentState) {
        case MapSearchDisplayStateOfNormal:
            self.routeResult = nil;
            self.showShopSelectionTableView = NO;
            self.backLastStateBtn.hidden = YES;
            self.locateSearchView.hidden = YES;
            self.searchBtn.hidden = YES;
            self.routePathDisplayContainerView.hidden = YES;
            self.rpDisplayViewTopConstraint.constant = 0;
            break;
            
        case MapSearchDisplayStateOfSearchShow:
            self.routeResult = nil;
            self.showShopSelectionTableView = NO;
            self.backLastStateBtn.hidden = NO;
            self.locateSearchView.hidden = NO;
            self.searchBtn.hidden = NO;
            self.routePathDisplayContainerView.hidden = YES;
            self.rpDisplayViewTopConstraint.constant = 0;
            [self updateStartEndPointUI];
            [self reloadRepairShopLocation];
            break;
            
        case MapSearchDisplayStateOfRoutePath:
            self.routePathDisplayBtn.selected = YES;
            self.backLastStateBtn.hidden = NO;
            self.locateSearchView.hidden = YES;
            self.searchBtn.hidden = YES;
            self.routePathDisplayContainerView.hidden = NO;
            self.rpDisplayViewTopConstraint.constant = -CGRectGetHeight(self.routePathDisplayContainerView.frame);
            [self updateRoutePathUIInfo];
            break;
            
        default:
            break;
    }
    
}

- (IBAction)showHideRoutePathDisplayView:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.routePathDisplayContainerView.hidden = !sender.selected;
    self.rpDisplayViewTopConstraint.constant = sender.selected?(-CGRectGetHeight(self.routePathDisplayContainerView.frame)):-18;
}

- (void)updateStartEndPointUI {
    if (self.startPointPoiInfo) {
        self.startPointLabel.text = self.startPointPoiInfo.address;
    }else {
        self.startPointLabel.text = @"我的位置";
    }
}

- (void)showSearchView {
    self.currentState = MapSearchDisplayStateOfSearchShow;
}

- (void)updateRoutePathUIInfo {
    BMKDrivingRouteLine *routeLine = self.routeResult.routes.firstObject;
    BMKTime *time = routeLine.duration;
    int distance = routeLine.distance;
    NSString *timeString = @"";
    if (time.dates>0) {
        timeString = [timeString stringByAppendingFormat:@"%d天",time.dates];
    }
    if (time.hours>0) {
        timeString = [timeString stringByAppendingFormat:@"%d小时",time.hours];
    }
    if (time.minutes>0) {
        timeString = [timeString stringByAppendingFormat:@"%d分钟",time.minutes];
    }
    if ([timeString isEqualToString:@""]) {
        timeString = @"小于1分钟";
    }
    
    NSString *distanceString = @"";
    
    if ([NSString stringWithFormat:@"%d",distance].length>=4) {
        distanceString = [NSString stringWithFormat:@"%.02f公里", (roundf(distance/10)/100)];
    }else {
        distanceString = [NSString stringWithFormat:@"%d米",distance];
    }
    self.timeNDistanceLabel.text = [NSString stringWithFormat:@"%@/%@",timeString, distanceString];
    [self.routePointList removeAllObjects];
    if (routeLine.steps.count==1) {
        BMKDrivingStep *drivingStep = routeLine.steps.lastObject;
        NSString *instruction = drivingStep.instruction;
        NSString *distanceString = [NSString stringWithFormat:@"%d米", drivingStep.distance];
        if (drivingStep.distance>999) {
            distanceString = [NSString stringWithFormat:@"%0.2f公里", (CGFloat)drivingStep.distance/1000];
        }
        instruction = [instruction stringByReplacingOccurrencesOfString:@"," withString:[NSString stringWithFormat:@"，%@后", distanceString]];
        NSDictionary *routeDetail = @{@"instruction":instruction,
                                      @"directionImg":@""};
        [self.routePointList addObject:routeDetail];
    }else if (routeLine.steps.count>1) {
        [routeLine.steps enumerateObjectsUsingBlock:^(BMKDrivingStep * _Nonnull drivingStep, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==0) {
                NSString *startInstruction = [NSString stringWithFormat:@"起点(%@)", drivingStep.entraceInstruction];
                NSString *distanceString = [NSString stringWithFormat:@"%d米", drivingStep.distance];
                if (drivingStep.distance>999) {
                    distanceString = [NSString stringWithFormat:@"%0.2f公里", (CGFloat)drivingStep.distance/1000];
                }
                NSString *nextInstruction = [NSString stringWithFormat:@"%@后，%@", distanceString, drivingStep.exitInstruction];
                [self.routePointList addObjectsFromArray:@[@{@"instruction":startInstruction,
                                                             @"directionImg":@""},
                                                           @{@"instruction":nextInstruction,
                                                             @"directionImg":@""},]];
            }else {
                
                NSString *distanceString = [NSString stringWithFormat:@"%d米", drivingStep.distance];
                if (drivingStep.distance>999) {
                    distanceString = [NSString stringWithFormat:@"%0.2f公里", (CGFloat)drivingStep.distance/1000];
                }
                NSString *nextInstruction = [NSString stringWithFormat:@"%@后，%@", distanceString, drivingStep.exitInstruction];
                [self.routePointList addObject:@{@"instruction":nextInstruction,
                                                 @"directionImg":@""}];
            }
        }];
    }
    [self.routePathTableView reloadData];
}

- (IBAction)hideSearchView {
    if (self.currentState==MapSearchDisplayStateOfSearchShow) {
        self.currentState = MapSearchDisplayStateOfNormal;
    }else if (self.currentState==MapSearchDisplayStateOfRoutePath) {
        self.currentState = MapSearchDisplayStateOfSearchShow;
    }
    
}

- (IBAction)showShopSelection {
    self.showShopSelectionTableView = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.shopSelectionTableView) {
        return self.shopMapPointList.count;
    }
    return self.routePointList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.shopSelectionTableView) {
        NSDictionary *detail = self.shopMapPointList[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        cell.backgroundColor = CDZColorOfClearColor;
        cell.contentView.backgroundColor = CDZColorOfClearColor;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:@"50c7f3"];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"323232"];
        cell.textLabel.text = detail[@"wxs_name"];
        return cell;
    }
    
//    instruction":instruction,
//    @"directionImg":@""};
        NSDictionary *detail = self.routePointList[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        cell.backgroundColor = CDZColorOfClearColor;
        cell.contentView.backgroundColor = CDZColorOfClearColor;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"323232"];
        cell.textLabel.text = detail[@"instruction"];
        return cell;
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (self.shopSelectionTableView==tableView) {
            NSDictionary *detail = self.shopMapPointList[indexPath.row];
            CLLocationDegrees latitude = [SupportingClass verifyAndConvertDataToString:detail[@"lat"]].doubleValue;
            CLLocationDegrees longitude = [SupportingClass verifyAndConvertDataToString:detail[@"lng"]].doubleValue;
            self.endPointCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            self.endPointDataIdx = indexPath.row;
            self.endPointName = detail[@"wxs_name"];
            self.endPointLabel.text = self.endPointName;
            self.showShopSelectionTableView = NO;
        }
    }
}

- (IBAction)searchRoutePath {
    @autoreleasepool {
        BMKPlanNode* startNode = [[BMKPlanNode alloc]init];
        if (self.startPointPoiInfo) {
            startNode.name = self.startPointPoiInfo.address;
            startNode.cityName = self.startPointPoiInfo.city;
            startNode.pt = self.startPointPoiInfo.pt;
        }else {
            startNode.cityName = self.cityName;
            startNode.pt = self.userCurrentCoordinate;
        }
        
        BMKPlanNode* endNode = [[BMKPlanNode alloc]init];
        endNode.cityName = self.cityName;
        endNode.pt = self.endPointCoordinate;
        
        
        
        BMKDrivingRoutePlanOption *timeRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
        timeRouteSearchOption.from = startNode;
        timeRouteSearchOption.to = endNode;
        timeRouteSearchOption.drivingPolicy = BMK_DRIVING_TIME_FIRST;
        timeRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_PATH_AND_TRAFFICE;
        
        BMKRouteSearch *timeRouteSearch = [BMKRouteSearch new];
        timeRouteSearch.delegate = self;
        [timeRouteSearch drivingSearch:timeRouteSearchOption];
        
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


#pragma mark - BMKRouteSearchDelegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    
    if (error==BMK_SEARCH_NO_ERROR) {
        self.routeResult = result;
        [self redrawDrivingRouteWithResult:result];
        
    }
    searcher.delegate = nil;
    searcher = nil;
    
}

- (void)redrawDrivingRouteWithResult:(BMKDrivingRouteResult*)result {
    self.currentState = MapSearchDisplayStateOfRoutePath;
    @autoreleasepool {
        NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        array = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:array];
        if (result&&result.routes.count>0) {
            BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
            // 计算路线方案中的路段数目
            NSInteger size = [plan.steps count];
            int planPointCounts = 0;
            for (int i = 0; i < size; i++) {
                BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
                if(i==0){
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = plan.starting.location;
                    item.title = @"起点";
                    item.type = 0;
                    [_mapView addAnnotation:item]; // 添加起点标注
                    
                    
                }else if(i==size-1){
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = plan.terminal.location;
                    item.title = @"终点";
                    item.type = 1;
                    [_mapView addAnnotation:item]; // 添加起点标注
                    
                }
                //添加annotation节点
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = transitStep.entrace.location;
                item.title = transitStep.entraceInstruction;
                item.degree = transitStep.direction * 30;
                item.type = 4;
                [_mapView addAnnotation:item];
                
                //轨迹点总数累计
                planPointCounts += transitStep.pointsCount;
            }
            // 添加途经点
            if (plan.wayPoints) {
                for (BMKPlanNode* tempNode in plan.wayPoints) {
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item = [[RouteAnnotation alloc]init];
                    item.coordinate = tempNode.pt;
                    item.type = 5;
                    item.title = tempNode.name;
                    [_mapView addAnnotation:item];
                }
            }
            //轨迹点
            BMKMapPoint theTempPoints[planPointCounts], *tempPoints;
            tempPoints = theTempPoints;
            int i = 0;
            for (int j = 0; j < size; j++) {
                BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
                int k=0;
                for(k=0;k<transitStep.pointsCount;k++) {
                    tempPoints[i].x = transitStep.points[k].x;
                    tempPoints[i].y = transitStep.points[k].y;
                    i++;
                }
                
            }
            // 通过points构建BMKPolyline
            BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:tempPoints count:planPointCounts];
            [_mapView addOverlay:polyLine]; // 添加路线overlay
            [self mapViewFitPolyLine:polyLine];
        }
        
    }
}

- (void)mapViewFitPolyLine:(BMKPolyline *)polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}


#pragma mark BMKMapViewDelegate
/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor colorWithHexString:@"50c7f3"] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    
//    wxs_name					维修商名称
//    wxs_kind
//    star							评价星级
//    major_service					主修品牌/主修服务
//    lng							维修商所在经度
//    lat							维修商所在纬度

    if (self.currentState==MapSearchDisplayStateOfRoutePath) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
    }
    
    BMKAnnotationView *newAnnotationView = nil;
    if ([annotation isKindOfClass:ShopInfoPointAnnotation.class]) {
        ShopInfoPointAnnotation *theAnnotation = (ShopInfoPointAnnotation *)annotation;
        newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"shopPointAnnotation"];
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:theAnnotation.isTypeOfSpecShop?@"snsms_spec_shop_annotation_pin_icon@3x":@"snsms_brand_shop_annotation_pin_icon@3x" ofType:@"png"]];
        newAnnotationView.image = [ImageHandler imageWithImage:image convertToSize:CGSizeMake(20, 24)];
        newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
        newAnnotationView.canShowCallout = YES;
        ShopDetailInfoPaopaoView *thePaopaoView = [[ShopDetailInfoPaopaoView alloc] initWithSMPDIV];
        thePaopaoView.objectIdx = theAnnotation.objectIdx;
        thePaopaoView.infoView.shopNameLabel.text = theAnnotation.shopName;
        thePaopaoView.infoView.repairBrandLogoIV.image = nil;
        thePaopaoView.infoView.repairBrandLogoIV.hidden = YES;
        thePaopaoView.infoView.isTypeOfSpecShop = theAnnotation.isTypeOfSpecShop;
        thePaopaoView.infoView.mainRepairServiceLabel.hidden = YES;
        if ([theAnnotation.shopMajorService isContainsString:@"http"]) {
            thePaopaoView.infoView.repairBrandLogoIV.hidden = NO;
            [thePaopaoView.infoView.repairBrandLogoIV setImageWithURL:[NSURL URLWithString:theAnnotation.shopMajorService] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }else {
            thePaopaoView.infoView.mainRepairServiceLabel.hidden = NO;
            thePaopaoView.infoView.mainRepairServiceLabel.text = theAnnotation.shopMajorService;
        }
        thePaopaoView.infoView.ratingStarView.value = theAnnotation.starValue;
        newAnnotationView.paopaoView = thePaopaoView;
        newAnnotationView.calloutOffset = CGPointMake(10, 8);
        @weakify(self);
        thePaopaoView.btnAction = ^(NSUInteger objectIdx) {
            @strongify(self);
            NSDictionary *detail = self.shopMapPointList[objectIdx];
            CLLocationDegrees latitude = [SupportingClass verifyAndConvertDataToString:detail[@"lat"]].doubleValue;
            CLLocationDegrees longitude = [SupportingClass verifyAndConvertDataToString:detail[@"lng"]].doubleValue;
            self.endPointCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            self.endPointDataIdx = objectIdx;
            self.endPointName = detail[@"wxs_name"];
            self.endPointLabel.text = self.endPointName;
            [self showSearchView];
        };
    }
    return newAnnotationView;
}

- (NSString*)getMyBundlePath1:(NSString *)filename {
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation {
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"snsms_nav_start_point_icon@3x" ofType:@"png"]];
                view.image = image;
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"snsms_nav_end_point_icon@3x" ofType:@"png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
            //        case 2:
            //        {
            //            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            //            if (view == nil) {
            //                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
            //                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
            //                view.canShowCallout = TRUE;
            //            }
            //            view.annotation = routeAnnotation;
            //        }
            //            break;
            //        case 3:
            //        {
            //            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            //            if (view == nil) {
            //                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
            //                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
            //                view.canShowCallout = TRUE;
            //            }
            //            view.annotation = routeAnnotation;
            //        }
            //            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            UIImage *aa = [image imageRotationByDegrees:routeAnnotation.degree];
            view.image = aa;
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"snsms_nav_way_point_icon@3x" ofType:@"png"]];
            view.image = [image imageRotationByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}


/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    NSLog(@"break");
    if (self.currentState==MapSearchDisplayStateOfSearchShow) {
        ShopInfoPointAnnotation *annotation = (ShopInfoPointAnnotation *)view.annotation;
        NSDictionary *detail = self.shopMapPointList[annotation.objectIdx];
        CLLocationDegrees latitude = [SupportingClass verifyAndConvertDataToString:detail[@"lat"]].doubleValue;
        CLLocationDegrees longitude = [SupportingClass verifyAndConvertDataToString:detail[@"lng"]].doubleValue;
        self.endPointCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.endPointDataIdx = annotation.objectIdx;
        self.endPointName = detail[@"wxs_name"];
        self.endPointLabel.text = self.endPointName;
    }
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
        BMKMapPoint consultantMapPoint = BMKMapPointForCoordinate(self.lastUserCurrentCoordinate);
        BMKMapPoint userMapPoint = BMKMapPointForCoordinate(self.userCurrentCoordinate);
        CLLocationDistance distance = BMKMetersBetweenMapPoints(userMapPoint, consultantMapPoint);
        
        if (self.lastUserCurrentCoordinate.latitude==0||
            self.lastUserCurrentCoordinate.longitude==0||distance>1000) {
            self.lastUserCurrentCoordinate = self.userCurrentCoordinate;
        }
        self.userPointReverseGeoCode = result;
        
        if (![self.cityName isEqualToString:@""]) self.cityName = result.addressDetail.city;
        if (![self.cityName isEqualToString:result.addressDetail.city]||
            distance>1000){
            NSString *address = result.address;
            if (!address||[address isEqualToString:@""]) address = @"无法显示地址";
            self.locatePinView.addressLabel.text = address;
            self.lastUserCurrentCoordinate=result.location;
            self.userCurrentCoordinate=result.location;
            if (self.currentState == MapSearchDisplayStateOfNormal) {
                [self getShopMapPointList];
            }
            
        }
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
    [self.mapView updateLocationData:userLocation];
    self.userCurrentCoordinate = userLocation.location.coordinate;
    if (self.mapView.userTrackingMode!=BMKUserTrackingModeNone) {
        self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    }
    if (!self.firesUpdatePoint) {
        [self locateCurrentView];
        self.firesUpdatePoint=YES;
    }
    
//    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
//    reverseGeoCodeOption.reverseGeoPoint = self.userCurrentCoordinate;
//    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
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
    self.lastUserCurrentCoordinate= mapView.centerCoordinate;
}


- (void)getShopMapPointList {
    if ([self.cityName isEqualToString:@""]||
        self.userCurrentCoordinate.latitude==0||self.userCurrentCoordinate.longitude==0) {
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairShopMapListWithCityName:self.cityName coordinate:self.lastUserCurrentCoordinate success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        self.shopMapPointList = responseObject[CDZKeyOfResultKey];
        if (self.shopMapPointList.count==0) {
            [SupportingClass showAlertViewWithTitle:nil message:@"抱歉！附近10公里以内暂无更多商家信息。" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        }
        [self reloadRepairShopLocation];
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

@end
