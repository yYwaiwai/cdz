//
//  MyAutoLocationVC.m
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define refreshPosInterval      15

#import "MyAutoLocationVC.h"
#import "InfoView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <CoreLocation/CoreLocation.h>
@interface MyAutoLocationVC ()<BMKMapViewDelegate, BMKGeoCodeSearchDelegate>
{
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_geoSearcher;
}

@property (nonatomic, strong) InfoView *theInfoView;

@property (nonatomic, strong) NSNumber *remindStatus;

@property (nonatomic, strong) NSNumber *gpsUploadSettingStatus;

@property (nonatomic, strong) UIButton *gpsUploadSettingButton;

@property (nonatomic, strong) UIButton *mapZoomInButton;

@property (nonatomic, strong) UIButton *mapZoomOutButton;

@property (nonatomic, strong) UIButton *locatePositionButton;

@property (nonatomic, strong) UIImage *carImg;

@property (nonatomic, strong) BMKPointAnnotation *carAnnotation;


@end

@implementation MyAutoLocationVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    _mapView.delegate = nil;
    [_mapView removeFromSuperview];
    _mapView = nil;
    _geoSearcher.delegate = nil;
    _geoSearcher = nil;
    self.carAnnotation = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = getLocalizationString(@"my_favorite_auto");
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.title = self.title;
    [super viewWillAppear:animated];
    _geoSearcher.delegate = self;
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    if ([self compareLocationCoordinateDistance:_carAnnotation.coordinate withSecondCoordinate:coordinate] != 0) {
        [_mapView setCenterCoordinate:_carAnnotation.coordinate];
    }
    [self getGPSUploadSettingStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAutoLocation:) name:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kRunUpdateAutoRTData];
    [self updateGeoLocationByCoordinates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    [_mapView removeAnnotations:_mapView.annotations];
    _geoSearcher.delegate = nil;
    _mapView.delegate = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:kRunUpdateAutoRTData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, gpsUploadSettingStatus) subscribeNext:^(NSNumber *status) {
        @strongify(self);
        self.gpsUploadSettingButton.selected = status.boolValue;
    }];
}

- (void)componentSetting {
    @autoreleasepool {
        _geoSearcher = [[BMKGeoCodeSearch alloc] init];
        self.carAnnotation = [[BMKPointAnnotation alloc] init];
        self.carImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"loc_car@2x" ofType:@"png"]];
    }
}

- (double)compareLocationCoordinateDistance:(CLLocationCoordinate2D)firstCoordinate withSecondCoordinate:(CLLocationCoordinate2D)secondCoordinate {
    @autoreleasepool {
        CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstCoordinate.latitude longitude:firstCoordinate.longitude];
        CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondCoordinate.latitude longitude:secondCoordinate.longitude];
        
        return [firstLocation distanceFromLocation:secondLocation];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        //百度地图初始化
        _mapView = [[BMKMapView alloc] initWithFrame:self.contentView.bounds];
        _mapView.compassPosition = CGPointMake(10.0f, 10.0f);
        _mapView.zoomLevel=16;
        [self.contentView addSubview:_mapView];
        
        
        self.theInfoView = [[InfoView alloc] init];
        [self.contentView addSubview:_theInfoView];
        
        //初始化 GPS 自动上传按钮
        UIImage *disselectedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_map_closeposition" ofType:@"png"]];
        UIImage *selectedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_map_openposition" ofType:@"png"]];
        self.gpsUploadSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _gpsUploadSettingButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.0625f, CGRectGetHeight(self.contentView.frame)*0.70f, 50.0f, 56.0f);
        [_gpsUploadSettingButton setImage:disselectedImage forState:UIControlStateNormal];
        [_gpsUploadSettingButton setImage:selectedImage forState:UIControlStateSelected];
        [_gpsUploadSettingButton addTarget:self action:@selector(updateGPSUpdateStatus) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_gpsUploadSettingButton];
        _gpsUploadSettingButton.hidden = YES;
        
        self.locatePositionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _locatePositionButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.82,
                                                 CGRectGetHeight(self.contentView.frame)*0.6,
                                                 30.0f, 30.0f);
        [_locatePositionButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nav_btn_loc_center_normal@2x" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_locatePositionButton addTarget:self action:@selector(locateAutosPosition) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_locatePositionButton];
        
        
        
        self.mapZoomInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mapZoomInButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.8,
                                            CGRectGetHeight(self.contentView.frame)*0.70,
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
    }
}

#pragma mark- private function
- (void)updateGeoLocationByCoordinates {
    @autoreleasepool {
        NSDictionary * autoGPSDetail = [[DBHandler shareInstance] getAutoRealtimeDataWithDataID:1];
        if (!autoGPSDetail) return;
        
        [_theInfoView setAutoLocaleInfoWithMilesString:[autoGPSDetail[@"speed"] stringValue] dateTime:autoGPSDetail[@"time"]
                                             gpsSignal:[autoGPSDetail[@"gpsNum"] stringValue] gsmSignal:[autoGPSDetail[@"gsm"] stringValue] localtion:nil];
        
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [autoGPSDetail[@"lat"] doubleValue];
        coordinate.longitude = [autoGPSDetail[@"lon"] doubleValue];
        _carAnnotation.coordinate = coordinate;
        [self addPointAnnotation];
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = coordinate;
        [_geoSearcher reverseGeoCode:reverseGeoOption];
    }
}

#pragma mark- Baidu Map Delegate 
#pragma mark BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    
    BMKAnnotationView *newAnnotationView = nil;
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carAnnotation"];
        newAnnotationView.image = _carImg;
        newAnnotationView.selected = YES;
        newAnnotationView.canShowCallout = YES;
        newAnnotationView.draggable = NO;
    }
    return newAnnotationView;
}
#pragma mark BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    [_theInfoView setAutoLocaleInfoWithMilesString:nil dateTime:nil
                                         gpsSignal:nil gsmSignal:nil localtion:result.address];
}

#pragma mark- Map Control Action 
- (void)mapZoomInOut:(UIButton *)button {
    float level = _mapView.zoomLevel;
    NSLog(@"%f",level);
    if ([button isEqual:_mapZoomInButton]) {
        if (level==19) return;
        _mapView.zoomLevel += 1;
    }
    
    if ([button isEqual:_mapZoomOutButton]) {
        if (level==3) return;
        _mapView.zoomLevel -= 1;
    }
}

- (void)locateAutosPosition {
    if (_carAnnotation) {
        [_mapView setCenterCoordinate:_carAnnotation.coordinate];
    }
    
}

- (void)addPointAnnotation {
    @try {
        
        //添加一个PointAnnotation
        [_mapView addAnnotation:_carAnnotation];
        BMKMapRect inMap = [_mapView visibleMapRect];
        BMKMapPoint coorPoint = BMKMapPointForCoordinate(_carAnnotation.coordinate);
        
        // 在可视范围内不设置中心点
        if (coorPoint.x < inMap.origin.x || coorPoint.x > (inMap.origin.x+inMap.size.width)
            ||coorPoint.y<inMap.origin.y || coorPoint.y > (inMap.origin.y+inMap.size.height)) {
            [_mapView setCenterCoordinate:_carAnnotation.coordinate];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
}

//更改GPS自动更新配置
- (void)updateGPSUpdateStatus {
    @weakify(self);
    UIAlertView *alertViews = [SupportingClass showAlertViewWithTitle:@"开启车辆定位服务"
                                                             message:@"(为了保护您的个人隐私，需要输入服务密码)"
                                                     isShowImmediate:NO
                                                   cancelButtonTitle:@"cancel"
                                                   otherButtonTitles:@"ok"
                                       clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                                           @strongify(self);
                                           NSLog(@"%@",btnIdx);
                                           if(btnIdx.integerValue==1){
                                               UITextField* textField = [alertView textFieldAtIndex:0];
                                               [self validServerSecurityPwd:textField.text];
                                           }
                                           
                                       }];
    alertViews.alertViewStyle=UIAlertViewStyleSecureTextInput;
    UITextField* textField = [alertViews textFieldAtIndex:0];
    textField.placeholder = @"请输入服务密码";
    [alertViews show];
}

//接收已更新车辆位置的信号
- (void)updateUserAutoLocation:(NSNotification *)notiObject {
    [self updateGeoLocationByCoordinates];
}

#pragma mark- Data Handle Request
- (void)handleResponseData:(id)responseObject {
    if (!responseObject||![responseObject isKindOfClass:NSDictionary.class]) {
        NSLog(@"data Error");
        return;
    }
    
    if ([responseObject count]==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"没有更多数据！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
}

#pragma mark- APIs Access Request

- (void)getGPSUploadSettingStatus {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    NSDictionary *userInfo = @{@"ident":@0};
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsGetUploadSettingStatusWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)validServerSecurityPwd:(NSString *)passwd {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    if (!self.accessToken||!passwd||[passwd isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入操作密码" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    };
    [ProgressHUDHandler showHUD];
    NSDictionary *userInfo = @{@"ident":@1};
        @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAuthorizeServerSecurityPWWithAccessToken:self.accessToken serPwd:passwd success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)updateGPSUploadSettingStatus:(NSNumber *)status {
    if (!self.accessToken||!status) return;
    NSDictionary *userInfo = @{@"ident":@2};
        @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostUpdateGPSUploadSettingWithAccessToken:self.accessToken localinfoStatus:status remindStatus:self.remindStatus success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSNumber *ident = operation.userInfo[@"ident"];
    if (error&&!responseObject) {
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

    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:(ident.integerValue==0)]) {
            return;
        }
        if (ident.integerValue==0) {
            [ProgressHUDHandler dismissHUD];
        }
        switch (errorCode) {
            case 0:
                NSLog(@"%@",responseObject);
                switch (ident.integerValue) {
                    case 0:{
                        NSInteger status = [[responseObject[CDZKeyOfResultKey] objectForKey:@"locainfoStatus"] integerValue];
                        NSInteger remindStatus = [[responseObject[CDZKeyOfResultKey] objectForKey:@"remindStatus"] integerValue];
                        self.gpsUploadSettingStatus = @(status);
                        self.remindStatus = @(remindStatus);
                    }
                        break;
                        
                    case 1:
                        [self updateGPSUploadSettingStatus:@((_gpsUploadSettingStatus.boolValue)?NO:YES)];
                        break;
                        
                    case 2:{
                        @weakify(self);
                        [ProgressHUDHandler showSuccessWithStatus:getLocalizationString(@"update_success") onView:nil completion:^{
                            @strongify(self);
                            self.gpsUploadSettingStatus = @((self.gpsUploadSettingStatus.boolValue)?NO:YES);
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
            case 1:
            case 2:{
                [ProgressHUDHandler dismissHUD];
                NSString *title = getLocalizationString(@"error");
                if (ident.integerValue == 1) {
                    title = getLocalizationString(@"alert_remind");
                }
//                @weakify(self);
                [SupportingClass showAlertViewWithTitle:title message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;}
                }];
            }
                break;
                
            default:
                break;
        }
        
    }
    
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
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
