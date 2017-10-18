//
//  GPSElectricFencingVC.m
//  cdzer
//
//  Created by KEns0n on 6/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "GPSElectricFencingVC.h"
#import "ElectronicDialog.h"
#import "PositionDto.h"
#import "CarPointAnnotation.h"
#import "JsonElementUtils.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface GPSElectricFencingVC ()<BMKMapViewDelegate, DialogViewDelegate>
{
    BMKMapView *_mapView;
    BMKCircle *_circle;
    BMKPointAnnotation *_tagAnnotation;
}



@property (nonatomic, strong) UIButton *mapZoomInButton;

@property (nonatomic, strong) UIButton *mapZoomOutButton;

@property (nonatomic, strong) UIButton *locatePositionButton;

@property (nonatomic, strong) NSDictionary *elecFenDetail;

@property (nonatomic, assign) float zoomLevel ;
@property (nonatomic, strong) ElectronicDialog *eleDialog ;
@property (nonatomic, assign) float distance ;
@property (nonatomic, strong) PositionDto *poDto ;
@property (nonatomic, assign) BOOL isMoveSet ;
@property (nonatomic, assign) BOOL isShow ;
@property (nonatomic, assign) CLLocationCoordinate2D clickCoordinate ;
@property (nonatomic, strong) UIButton *setOpenBtn ;

@end

@implementation GPSElectricFencingVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [_mapView removeFromSuperview];
    _mapView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电子围栏";
    [self addNavigationBarRightItem];
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfManualUpdateAutoGPSInfo object:nil];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    if (!self.elecFenDetail) {
        [self getElectricFencingDetialWithShowHUD:YES];
    }
    [self updateGeoLocationByCoordinates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAutoLocation:) name:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kRunUpdateAutoRTData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    [_mapView removeAnnotations:_mapView.annotations];
    _mapView.delegate = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:kRunUpdateAutoRTData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearCircleTagAnnotation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    
}

- (void)componentSetting {
    self.isShow = NO;
}

#pragma mark 添加报警信息的右设置按钮视图
- (void)addNavigationBarRightItem {
    self.setOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.setOpenBtn.frame = CGRectMake(0, 0, 40, 40);
    [self.setOpenBtn setImage:[UIImage imageNamed:@"w_warn_set"] forState:UIControlStateNormal];
    [self.setOpenBtn setImage:[UIImage imageNamed:@"w_warn_set_p"] forState:UIControlStateSelected];
    [self.setOpenBtn addTarget:self action:@selector(setElectronicScope) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.setOpenBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)initializationUI {
    
    //百度地图初始化
    _mapView = [[BMKMapView alloc] initWithFrame:self.contentView.bounds];
    _mapView.compassPosition = CGPointMake(10.0f, 10.0f);
    _mapView.zoomLevel=16;
    [self.contentView addSubview:_mapView];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.locatePositionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _locatePositionButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.82,
                                             CGRectGetHeight(self.contentView.frame)*0.6304347826087,
                                             30.0f, 30.0f);
    [_locatePositionButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nav_btn_loc_center_normal@2x" ofType:@"png"]]
                           forState:UIControlStateNormal];
    [_locatePositionButton addTarget:self action:@selector(locateAutosPosition) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_locatePositionButton];
    
    
    
    self.mapZoomInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mapZoomInButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.8,
                                        CGRectGetHeight(self.contentView.frame)*0.73,
                                        28.0f, 30.0f);
    _mapZoomInButton.center = CGPointMake(_locatePositionButton.center.x, _mapZoomInButton.center.y);
    [_mapZoomInButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomin_normal@2x" ofType:@"png"]]
                      forState:UIControlStateNormal];
    [_mapZoomInButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomin_disable@2x" ofType:@"png"]]
                      forState:UIControlStateDisabled];
    [_mapZoomInButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomin_press@2x" ofType:@"png"]]
                      forState:UIControlStateHighlighted];
    [_mapZoomInButton addTarget:self action:@selector(mapZoomInOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_mapZoomInButton];
    
    
    
    self.mapZoomOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mapZoomOutButton.frame = CGRectMake(CGRectGetMinX(self.mapZoomInButton.frame),
                                         CGRectGetMaxY(self.mapZoomInButton.frame),
                                         28.0f, 30.0f);
    [_mapZoomOutButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomout_normal@2x" ofType:@"png"]]
                       forState:UIControlStateNormal];
    [_mapZoomOutButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomout_disable@2x" ofType:@"png"]]
                       forState:UIControlStateDisabled];
    [_mapZoomOutButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zoomout_press@2x" ofType:@"png"]]
                       forState:UIControlStateHighlighted];
    [_mapZoomOutButton addTarget:self action:@selector(mapZoomInOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_mapZoomOutButton];


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}

#pragma mark- private function
//更新车辆位置
- (void)updateGeoLocationByCoordinates {
    @autoreleasepool {
        self.poDto =  [JsonElementUtils jsonPositionDto:[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:1]];
        if (!self.poDto) return;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = _poDto.latitude;
        coordinate.longitude = _poDto.longitude;
        _tagAnnotation.coordinate = coordinate;
        [_mapView setCenterCoordinate:coordinate];
        [self addCarAnnotation:coordinate];
    }
}
//接收已更新车辆位置的信号
- (void)updateUserAutoLocation:(NSNotification *)notiObject {
    [self updateGeoLocationByCoordinates];
}

#pragma mark- Map Control Action
#pragma mark 放大，缩小的按钮事件方法
- (void)mapZoomInOut:(UIButton *)button {
    float level = _mapView.zoomLevel;
    NSLog(@"%f",level);
    if ([button isEqual:_mapZoomInButton]) {
        if (level==19) return;
        _mapView.zoomLevel += 0.3 ;
    }
    
    if ([button isEqual:_mapZoomOutButton]) {
        if (level==3) return;
        _mapView.zoomLevel -= 0.3;
    }
}

#pragma mark 地图定位按钮事件方法
- (void)locateAutosPosition {
    if (_poDto) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = _poDto.latitude;
        coordinate.longitude = _poDto.longitude;
        [_mapView setCenterCoordinate:coordinate];
    }
    
}

#pragma mark 拿到当前电子围栏信息的方法
- (void)getElentroincInfo {
    if(_elecFenDetail != nil){
        CLLocationCoordinate2D coordinate ;
        coordinate.latitude = [_elecFenDetail[@"latitude"] floatValue];
        coordinate.longitude = [_elecFenDetail[@"longitude"] floatValue];
        [self addOverlayView:coordinate AndDistance:[_elecFenDetail[@"radius"] floatValue]];
    }
}

#pragma mark -设置电子围栏信息
- (void)setElectronicScope{
    
    if(!_elecFenDetail){
        [self showSetViewDialog:@(self.poDto.latitude).stringValue AndLon:@(self.poDto.longitude).stringValue];
    }else{
        [self shutdownElectricFencing];
    }
}

#pragma mark -添加圆形覆盖物
- (void)addOverlayView:(CLLocationCoordinate2D) coordinate AndDistance:(float) distance {
    @autoreleasepool {
        if (!_circle) {
            [self clearCircleTagAnnotation];
            _circle = nil ;
            _tagAnnotation = nil ;
        }
        _circle = [BMKCircle circleWithCenterCoordinate:coordinate radius:distance * 1000];
        [_mapView addOverlay:_circle];
        [self addCurrentAnnotation:coordinate];
        [_mapView setCenterCoordinate:coordinate];
    }
    
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [UIColor colorWithRed:0.024 green:0.675 blue:0.937 alpha:0.5];
    circleView.strokeColor = [UIColor colorWithRed:0.024 green:0.675 blue:0.937 alpha:0.2];
    return circleView;
}

#pragma mark -添加当前车辆位置的标识图标
- (void)addCarAnnotation:(CLLocationCoordinate2D) coordinate{
    CarPointAnnotation *carAnnotation = [[CarPointAnnotation alloc] init];
    carAnnotation.tag = 10 ;
    carAnnotation.coordinate = coordinate ;
    [_mapView addAnnotation:carAnnotation];
}

#pragma mark -添加当前选择位置的标识图标
- (void)addCurrentAnnotation:(CLLocationCoordinate2D) coordinate{
    _tagAnnotation = [[BMKPointAnnotation alloc] init];
    _tagAnnotation.coordinate = coordinate ;
    [_mapView addAnnotation:_tagAnnotation];
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    BMKAnnotationView *annotationView = [mapView viewForAnnotation:annotation];
    if(annotationView == nil){
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sdf"];
        [annotationView.paopaoView removeFromSuperview];
        annotationView.canShowCallout = NO ;
    }
    if([annotation isKindOfClass:[CarPointAnnotation class]]){
        annotationView.image = [UIImage imageNamed:@"loc_car"];
    }else{
        annotationView.image = [UIImage imageNamed:@"w_start"];
    }
    return annotationView ;
}

#pragma mark-地图的单击方法
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    if(!self.isShow){
        self.isMoveSet = YES;
        self.clickCoordinate = coordinate ;
        NSString *lan = [NSString stringWithFormat:@"%f",coordinate.latitude] ;
        NSString *lon = [NSString stringWithFormat:@"%f",coordinate.longitude] ;
        [self showSetViewDialog:lan AndLon:lon];
    }
}

#pragma mark -添加电子围栏对话框事件协议方法
- (void)dialogViewSubmit:(EnectronicElement *) element{
    NSString *lat = @"";
    NSString *lon = @"";
    if(self.isMoveSet){
        lat = [NSString stringWithFormat:@"%f",self.clickCoordinate.latitude] ;
        lon = [NSString stringWithFormat:@"%f",self.clickCoordinate.longitude] ;
        self.isMoveSet = NO ;
    }else{
        lat = [NSString stringWithFormat:@"%f",self.poDto.latitude] ;
        lon = [NSString stringWithFormat:@"%f",self.poDto.longitude] ;
    }
    
    self.distance = [element.radius floatValue];
    [self addElectricFencingWithType:element.type radius:@(self.distance).stringValue longitude:lon latitude:lat];
    self.setOpenBtn.enabled = YES ;
    //发起广播消息的通知更改设置页面的状态
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"WarnStatue" object:nil];
    
}

- (void)dialogViewCancel{
    self.isMoveSet = NO;
    self.setOpenBtn.enabled = YES;
    self.setOpenBtn.selected = (_elecFenDetail!=nil);
    self.isShow = NO;
}

#pragma mark -清除电子围栏视图的方法
- (void)clearCircleTagAnnotation{
    [_mapView removeAnnotation:_tagAnnotation];
    [_mapView removeOverlay:_circle];
}

#pragma mark -电子围栏设置对话框的显示
- (void)showSetViewDialog:(NSString *) lan AndLon:(NSString *) lon{
    self.setOpenBtn.enabled = NO;
    self.setOpenBtn.selected = NO;
    self.isShow = YES;
    self.eleDialog = [[[NSBundle mainBundle] loadNibNamed:@"ElectronicDialog" owner:self options:nil] objectAtIndex:0];
    self.eleDialog.frame = self.contentView.bounds;
    self.eleDialog.delegate = self ;
    [self.view addSubview:self.eleDialog];
    if((lan!=nil && ![lan isEqualToString:@""]) && (lon!=nil && ![lon isEqualToString:@""])){
        [self.eleDialog setScopeData:lan AndLon:lon];
    }else{
        [self.eleDialog setScopeData:@"39.915" AndLon:@"116.404"];
    }
}

#pragma mark- APIs Access Request

/* 查询个人电子围栏 */
- (void)getElectricFencingDetialWithShowHUD:(BOOL)isShowHUD{
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (isShowHUD) [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    @weakify(self);
    self.setOpenBtn.selected = NO;
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoElectricFencingDetialWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            self.elecFenDetail = responseObject[CDZKeyOfResultKey];
            self.setOpenBtn.selected = YES;
            [self getElentroincInfo];
        }
        if (isShowHUD) [ProgressHUDHandler dismissHUD];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (isShowHUD) [ProgressHUDHandler dismissHUD];
    }];
}

/* 增加电子围栏 */
- (void)addElectricFencingWithType:(NSString *)type radius:(NSString *)radius longitude:(NSString*)longitude latitude:(NSString*)latitude {
    self.isShow = NO;
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"电子围栏设置中...." onView:nil];
        @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoAddElectricFencingWithAccessToken:self.accessToken type:type radius:radius longitude:longitude latitude:latitude success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:@"系统繁忙,请重新尝试！" onView:nil completion:nil];
            return;
        }
        
        @strongify(self);
        self.setOpenBtn.selected = YES;
//        [self addOverlayView:CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue) AndDistance:self.distance];
        [ProgressHUDHandler showSuccessWithStatus:@"设置电子围栏成功！" onView:nil completion:^{
            [self getElectricFencingDetialWithShowHUD:NO];
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"系统繁忙,请重新尝试！" onView:nil completion:nil];
    }];
}

/* 删除电子围栏 */
- (void)shutdownElectricFencing {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"电子围栏关闭中...." onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoRemoveElectricFencingWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:@"系统繁忙,请稍后尝试！" onView:nil completion:nil];
            return;
        }
        self.setOpenBtn.enabled = YES;
        self.setOpenBtn.selected = NO;
        [self clearCircleTagAnnotation];
        self.elecFenDetail = nil;
        [ProgressHUDHandler showSuccessWithStatus:@"电子围栏功能关闭成功"onView:nil completion:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler showErrorWithStatus:@"系统繁忙,请稍后尝试！" onView:nil completion:nil];
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
