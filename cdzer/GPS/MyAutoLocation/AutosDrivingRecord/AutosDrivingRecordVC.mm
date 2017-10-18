//
//  AutosDrivingRecordVC.m
//  cdzer
//
//  Created by KEns0n on 5/28/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "AutosDrivingRecordVC.h"
#import "DrivingRecordInfoView.h"
#import "DateTimeSelectionView.h"
#import "JsonElementUtils.h"
#import "ParkView.h"
#import "UIImage+rotateByDegrees.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <CoreLocation/CoreLocation.h>
#import "YDSlider.h"

#define ANNOTATION_VIEW_NAME @ "view"
#define ANNOTATION_START_NAME @ "start"
#define ANNOTATION_PARK_NAME @"park"
#define ANNOTATION_END_NAME @ "end"

#define LOOP_PLAY_TIME 2.0f

@interface StopPointAnnotation : BMKPointAnnotation

@property (nonatomic) NSInteger tag ;
@property (nonatomic) PositionDto *posDto;

@end

@implementation StopPointAnnotation

@end



@interface AutosDrivingRecordVC () <BMKMapViewDelegate, BMKGeoCodeSearchDelegate>
{
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_geoSearcher;
    BMKPolyline *_polyline;
}

@property (nonatomic, strong) DateTimeSelectionView *dateTimeSelView;

@property (nonatomic, strong) DrivingRecordInfoView *theInfoView;

@property (nonatomic, strong) ParkView *pointDescriptionView;

@property (nonatomic, strong) UIButton *mapZoomInButton;

@property (nonatomic, strong) UIButton *mapZoomOutButton;

@property (nonatomic, strong) UIButton *cleanRecordButton;

@property (nonatomic, strong) UIImage *carImg;

@property (nonatomic, strong) NSArray *stopPointList;

@property (nonatomic, strong) NSArray *passingPointList;

@property (nonatomic, strong) StopPointAnnotation *startAnnotation;

@property (nonatomic, strong) StopPointAnnotation *endAnnotation;

@property (nonatomic, strong) BMKPointAnnotation* annotation;

@property (nonatomic, strong) PositionDto *carPosition;

@property (nonatomic, strong) NSTimer *loopPlayTimer;

@property (nonatomic, assign) NSInteger progressIndex;

@property (nonatomic, assign) BOOL isFinishToPlay;

@property (nonatomic, assign) BOOL isSelectDateTime;

@property (nonatomic, assign) BOOL didSelectedPoint;

@property (nonatomic, assign) BOOL wasPausePlayRecord;



@end

@implementation AutosDrivingRecordVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [_mapView removeFromSuperview];
    _mapView = nil;
    _startAnnotation = nil;
    _endAnnotation = nil;
    _annotation = nil;
    _geoSearcher = nil;
    _polyline = nil;
    [_dateTimeSelView removeFromSuperview];
    _dateTimeSelView = nil;
    [_theInfoView releaseInternalObjects];
    [_theInfoView removeFromSuperview];
    _theInfoView = nil;
    [_pointDescriptionView removeFromSuperview];
    _pointDescriptionView = nil;
    [_mapZoomInButton removeFromSuperview];
    _mapZoomInButton = nil;
    [_mapZoomOutButton removeFromSuperview];
    _mapZoomOutButton = nil;
    [_cleanRecordButton removeFromSuperview];
    _cleanRecordButton = nil;
    _carImg = nil;
    _passingPointList = nil;
    _startAnnotation = nil;
    _endAnnotation = nil;
    _annotation = nil;
    _carPosition = nil;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = getLocalizationString(@"my_auto_driving_record");
    self.progressIndex = 0;
    self.isFinishToPlay = NO;
    self.wasPausePlayRecord = NO;
    self.didSelectedPoint = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setRightNavButtonWithTitleOrImage:[UIImage imageNamed:@"ic_nav_timechoose.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showDateTimeSelView) titleColor:nil isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = !(_dateTimeSelView.alpha);
    self.tabBarController.title = self.title;
    [super viewWillAppear:animated];
    if (_mapView) {
        [_mapView viewWillAppear];
    }
    if (_passingPointList.count>0) {
        [self hiddenDateTimeSelView];
        [self startSetupMap];
    }else {
        [self showDateTimeSelView];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _geoSearcher.delegate = nil;
    if ([_loopPlayTimer isValid]){
        if (_loopPlayTimer) {
            [_loopPlayTimer invalidate];
            _loopPlayTimer = nil;
        }
    }
    [self cleanMapData];
    self.theInfoView.sliderValue = 0;
    self.theInfoView.alpha = 0;
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, dateTimeSelView.alpha) subscribeNext:^(NSNumber *alpha) {
        @strongify(self);
        self.navigationItem.rightBarButtonItem.enabled = (alpha.doubleValue==0);
        self.wasPausePlayRecord = (alpha.doubleValue==1);
    }];
}

- (void)componentSetting {
    _carImg = [UIImage imageNamed:@"ic_car_horizontal.png"];
}

- (void)showDateTimeSelView {
    self.dateTimeSelView.alpha = 1;
}

- (void)hiddenDateTimeSelView {
    self.dateTimeSelView.alpha = 0;
}

- (void)initializationUI {
    self.pointDescriptionView = [[[NSBundle mainBundle] loadNibNamed:@"ParkView" owner:self options:nil]objectAtIndex:0];;

    
    self.theInfoView = [[DrivingRecordInfoView alloc] init];
    _theInfoView.sliderValue = 0;
    self.theInfoView.alpha = 0.0f;
    [self.contentView addSubview:_theInfoView];

    
    self.cleanRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cleanRecordButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.82,
                                             CGRectGetHeight(self.contentView.frame)*0.6304347826087,
                                             30.0f, 30.0f);
    [_cleanRecordButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nav_btn_loc_center_normal@2x" ofType:@"png"]]
                           forState:UIControlStateNormal];
    [_cleanRecordButton addTarget:self action:@selector(cleanDrivingRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_cleanRecordButton];
    
    
    
    self.mapZoomInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mapZoomInButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame)*0.8,
                                        CGRectGetHeight(self.contentView.frame)*0.73,
                                        28.0f, 30.0f);
    _mapZoomInButton.center = CGPointMake(_cleanRecordButton.center.x, _mapZoomInButton.center.y);
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
    
    self.dateTimeSelView = [[DateTimeSelectionView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_dateTimeSelView];
    
    @weakify(self);
    [_dateTimeSelView setDateSelectedResponseBlock:^(NSString *startDateTime, NSString *endDateTime) {
        if (![startDateTime isEqualToString:@""]&&![endDateTime isEqualToString:@""]) {
            @strongify(self);
            [self getDrivingHistoryListWithStartDateTime:startDateTime andEndDateTime:endDateTime];
        }
    }];
    
    [_theInfoView setSliderResponseBlock:^(YDSlider *timeSlider, CGFloat value) {
        @strongify(self);
        if (self.passingPointList && self.passingPointList.count>2) {
            float num = (float)(self.passingPointList.count*value);
            int count = (int)(num);
            NSLog(@"count = %d, num = %f",count,num);
            self.progressIndex = count;
            NSLog(@"------------>>>>>count = %d",count);
            timeSlider.value = ((float)count)/self.passingPointList.count;
            self.isFinishToPlay = false;
            NSLog(@"Slider value=%f, middleValue=%f,_arr_postion.count = %d", timeSlider.value, timeSlider.middleValue,self.passingPointList.count);
            if (self.progressIndex==self.passingPointList.count) {
                self.progressIndex=0;
                self.isFinishToPlay = true;
            }
            if (!self.loopPlayTimer) {
                self.loopPlayTimer = [NSTimer scheduledTimerWithTimeInterval:LOOP_PLAY_TIME target:self selector:@selector(getCarLocatAndAnnota) userInfo:nil repeats:YES];
            }
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanDrivingRecord {
    UIAlertView *alertViews = [SupportingClass showAlertViewWithTitle:@"清除行车记录"
                                                              message:@"(该操作会永久清除历史记录，请谨慎操作)"
                                                      isShowImmediate:NO
                                                    cancelButtonTitle:@"cancel"
                                                    otherButtonTitles:@"ok"
                                        clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                                            
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

- (void)startSetupMap {
    if (!_mapView) {
        //百度地图初始化
        _mapView = [[BMKMapView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView insertSubview:_mapView atIndex:0];
        [_mapView viewWillAppear];
    }
    if (!_geoSearcher) {
        _geoSearcher = [[BMKGeoCodeSearch alloc] init];
    }
    _mapView.delegate = self;
    _geoSearcher.delegate = self;
    _mapView.zoomLevel=16;
    _isFinishToPlay = NO;
    [self drawDrivingLine];
    self.theInfoView.alpha = 1;

    [self addStopPointAnnotationView];
    [self addStartEndPointAnnotation];
    self.loopPlayTimer = [NSTimer scheduledTimerWithTimeInterval:LOOP_PLAY_TIME target:self selector:@selector(getCarLocatAndAnnota) userInfo:nil repeats:YES];
    [_loopPlayTimer fire];
  
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

- (void)cleanMapData {
    if (_polyline ) {
        [_mapView removeOverlay:_polyline];
        _polyline = nil;
    }
    if (_annotation) {
        [_mapView removeAnnotation:_annotation];
        _annotation = nil;
    }
    
    if (self.startAnnotation) {
        [_mapView removeAnnotation:self.startAnnotation];
        self.startAnnotation = nil;
    }
    
    if (self.endAnnotation) {
        [_mapView removeAnnotation:self.endAnnotation];
        self.endAnnotation = nil;
    }
}

#pragma mark 连线
- (void)drawDrivingLine {
    @autoreleasepool {
        NSUInteger count = _passingPointList.count;
        CLLocationCoordinate2D coordinate[count], *coordinatePoint;
        coordinatePoint = coordinate;
        [_passingPointList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            coordinatePoint[idx].latitude = [(PositionDto *)obj latitude];
            coordinatePoint[idx].longitude = [(PositionDto *)obj longitude];
        }];
        
        _polyline = [BMKPolyline polylineWithCoordinates:coordinatePoint count:count];
        [_mapView addOverlay:_polyline];
    }
}

#pragma mark 添加行车记录的停车记录点
- (void)addStopPointAnnotationView {
    if (!_stopPointList||_stopPointList.count==0) return;
    @autoreleasepool {
        @weakify(self);
        [_stopPointList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            CLLocationCoordinate2D coordinate ;
            coordinate.longitude = [(PositionDto *)obj latitude];
            coordinate.latitude = [(PositionDto *)obj longitude];
            StopPointAnnotation *annotation = [[StopPointAnnotation alloc] init];
            annotation.posDto = obj ;
            annotation.coordinate = coordinate ;
            annotation.tag = idx ;
            annotation.title = ANNOTATION_PARK_NAME ;
            [self->_mapView addAnnotation:annotation];
            if ([self.stopPointList.lastObject isEqual:obj]) {
                [self.pointDescriptionView setParkViewData:obj];
                BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
                reverseGeoOption.reverseGeoPoint = annotation.coordinate;
                [self->_geoSearcher reverseGeoCode:reverseGeoOption];
            }
            
        }];
    }
}

#pragma mark 添加起始点
- (void)addStartEndPointAnnotation {
    if (!_passingPointList||_passingPointList.count==0) return;
    @autoreleasepool {
        //起点
        self.startAnnotation = [[StopPointAnnotation alloc]init];
        PositionDto* startDto = [_passingPointList firstObject];
        self.startAnnotation.posDto = startDto ;
        CLLocationCoordinate2D coor;
        self.startAnnotation.title = ANNOTATION_START_NAME;
        coor.latitude = startDto.latitude;
        coor.longitude = startDto.longitude;
        self.startAnnotation.coordinate = coor;
        [_mapView addAnnotation:self.startAnnotation];

        //终点
        self.endAnnotation = [[StopPointAnnotation alloc]init];
        PositionDto* sendDto = [_passingPointList lastObject];
        self.endAnnotation.posDto = sendDto ;
        CLLocationCoordinate2D endCoor;
        endCoor.latitude = sendDto.latitude;
        endCoor.longitude = sendDto.longitude;
        self.endAnnotation.coordinate = endCoor;
        self.endAnnotation.title = ANNOTATION_END_NAME;
        [_mapView addAnnotation:self.endAnnotation];
    }
}

#pragma mark 历史轨迹
- (void)getCarLocatAndAnnota {
    if (self.wasPausePlayRecord) {
        return;
    }
    CGFloat baseCount = 1.0f/(CGFloat)_passingPointList.count;
    [self getCarLocation];
    [self addPointAnnotation];
    if (_progressIndex==0 && _isFinishToPlay) {
        if ([_loopPlayTimer isValid]){
            [_loopPlayTimer invalidate];
            _loopPlayTimer = nil;
        }
        _theInfoView.sliderValue = 0;
    }
    if(_progressIndex!=0){
        _theInfoView.sliderValue = _theInfoView.sliderValue+baseCount;
    }
    
    _progressIndex++;
    if (_progressIndex==_passingPointList.count) {
        _progressIndex = 0;
        _isFinishToPlay = true;
    }
}

#pragma mark 2点计算角度
- (CGFloat)twoPointangle:(CGPoint)p0 point2:(CGPoint)p1 {
    double result = atan2(p1.y - p0.y, p1.x - p0.x)* 180.0 / M_PI;
    return result;
    
}

#pragma mark 历史轨迹，获取车辆位置信息
- (void)getCarLocation {
    @try {
        if (_passingPointList.count==0) {
            return;
        }
        _carPosition = _passingPointList[_progressIndex];
        
        // ACC状态描述
        // [self carAccStateDesc:[_carPosition acc]];
        
        // 车辆图片旋转
        
        CLLocationCoordinate2D coor = {0};
        coor.latitude = _carPosition.latitude;
        coor.longitude = _carPosition.longitude;
        CGPoint point = [_mapView convertCoordinate:coor toPointToView:self.view];
        
        if (_progressIndex==_passingPointList.count-1 ) {
            //_carImg = [UIImage imageNamed:@"ic_car_horizontal.png"];
        }else{
            PositionDto* dto = _passingPointList[_progressIndex+1];
            CLLocationCoordinate2D coor1 = {0};
            coor1.latitude = dto.latitude;
            coor1.longitude = dto.longitude;
            CGPoint point1 = [_mapView convertCoordinate:coor1 toPointToView:self.view];
            CGFloat rotate = [self twoPointangle:point point2:point1];
            CGFloat f = (rotate/360)*2*M_PI;
            _carImg = [[UIImage imageNamed:@"ic_car_horizontal.png"] rotateImageWithRadian:f cropMode:enSvCropClip];
        }
        
        // 位置信息
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){_carPosition.latitude, _carPosition.longitude};
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = pt;
        [_geoSearcher reverseGeoCode:reverseGeoOption];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark 历史轨迹，添加Annotation到mapView
- (void)addPointAnnotation {
    @try {
        if (_annotation) {
            [_mapView removeAnnotation:(_annotation)];
            _annotation = nil;
        }
        if (_passingPointList.count==0) {
            return;
        }
        PositionDto* dto = _passingPointList[_progressIndex];
        // 添加一个PointAnnotation
        _annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        _carPosition = dto;
        coor.latitude = _carPosition.latitude;
        coor.longitude = _carPosition.longitude;
        _annotation.coordinate = coor;
        if (_progressIndex==0 && _isFinishToPlay) {
            _annotation.title =@"";
        }
        [_mapView addAnnotation:_annotation];
        BMKMapRect inMap = [_mapView visibleMapRect];
        BMKMapPoint coorPoint = BMKMapPointForCoordinate(coor);
        NSLog(@"coorPointx=%f,coorPoint.y=%f",coorPoint.x,coorPoint.y);
        NSLog(@"inMap.x=%f,inMap.y=%f",inMap.origin.x,inMap.origin.y);
        // 在可视范围内不设置中心点
        if (coorPoint.x < inMap.origin.x || coorPoint.x > (inMap.origin.x+inMap.size.width)
            ||coorPoint.y<inMap.origin.y || coorPoint.y > (inMap.origin.y+inMap.size.height)) {
            [_mapView setCenterCoordinate:coor];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
}

#pragma mark- Baidu Map Delegate
#pragma mark BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (_didSelectedPoint) {
        self.pointDescriptionView.address.text = [@"地址：" stringByAppendingString:result.address];
        self.didSelectedPoint = NO;
        return;
    }
    
    [_theInfoView setAutoLocaleInfoWithMilesString:nil dateTime:nil
                                         startTime:nil endTime:nil localtion:result.address];
}

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
        //根据title 区分 annotion类型
        if ([ANNOTATION_START_NAME isEqualToString:[annotation title]]) {
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carStartAnnotation"];
            newAnnotationView.image = [UIImage imageNamed:@"ic_nav_start"];
            newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
            newAnnotationView.canShowCallout = NO;
            
        }else if ([ANNOTATION_END_NAME isEqualToString:[annotation title]]){
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carEndAnnotation"];
            newAnnotationView.image = [UIImage imageNamed:@"ic_nav_end"];
            if (_passingPointList.count>1) {
                newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
            }else{
                newAnnotationView.centerOffset = CGPointMake(-(newAnnotationView.frame.size.width * 0.5),0);
            }
            newAnnotationView.canShowCallout = NO;
            self.pointDescriptionView.center = CGPointMake(10, -35);
        }else if([ANNOTATION_PARK_NAME isEqualToString:[annotation title]]){
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"parkAnnotation"];
            newAnnotationView.image = [UIImage imageNamed:@"icon_nav_park.png"];
            NSLog(@"\nLog:::%f \nLat:::%f",annotation.coordinate.longitude, annotation.coordinate.latitude);
            newAnnotationView.canShowCallout = NO ;
            
        }else{
            
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carHisAnnotation"];
            newAnnotationView.centerOffset = CGPointMake(0, -2);
            newAnnotationView.image = _carImg;
            newAnnotationView.selected = YES;
            newAnnotationView.canShowCallout = NO;
            newAnnotationView.draggable = NO;
            
            if (_carPosition) {
                [_theInfoView setAutoLocaleInfoWithMilesString:[@(_carPosition.moveSpeed) stringValue]
                                                      dateTime:_carPosition.time
                                                     startTime:nil
                                                       endTime:nil
                                                     localtion:nil];
            }
        }
    }
    return newAnnotationView;
}

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    [view addSubview:self.pointDescriptionView];
    
    if([[view annotation] isKindOfClass:[StopPointAnnotation class]]){
        StopPointAnnotation *parkAnnotation = (StopPointAnnotation *)[view annotation] ;
        [self.pointDescriptionView setParkViewData:parkAnnotation.posDto];
        [_mapView setCenterCoordinate:parkAnnotation.coordinate animated:YES];
        
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = parkAnnotation.coordinate;
        [_geoSearcher reverseGeoCode:reverseGeoOption];
        self.didSelectedPoint = YES;
        
    }
}

/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay] ;
        //polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 2.5;
        return polylineView;
    }
    return nil;
}

#pragma mark- Data Handle Request
- (void)handleResponseData:(id)responseObject {
    if (!responseObject||![responseObject isKindOfClass:NSDictionary.class]) {
        NSLog(@"data Error");
        return;
    }
    
    if ([responseObject count]==0||[responseObject[@"historyresult"] count]==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"没有更多数据！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    @autoreleasepool {
        NSMutableArray* passingPointArray = [NSMutableArray arrayWithCapacity:[responseObject[@"historyresult"] count]];
        for (NSDictionary* tmp in responseObject[@"historyresult"]) {
            PositionDto* dto= [JsonElementUtils jsonPositionDto:tmp];
            [passingPointArray addObject:dto];
        }
        
        NSMutableArray *stopPointArray = [NSMutableArray arrayWithCapacity:[responseObject[@"parkresult"] count]];
        for (NSDictionary *poDic in responseObject[@"parkresult"]) {
            PositionDto *dto = [JsonElementUtils jsonPositionDto:poDic];
            [stopPointArray addObject:dto];
        }
        
        self.stopPointList = stopPointArray;
        self.passingPointList = passingPointArray;
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            [self hiddenDateTimeSelView];
        } completion:^(BOOL finished) {
            [self startSetupMap];
        }];
    }

}

#pragma mark- APIs Access Request

- (void)getDrivingHistoryListWithStartDateTime:(NSString *)startDatetime andEndDateTime:(NSString *)endDatetime{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    NSDictionary *userInfo = @{@"ident":@0};
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalGPSAPIsGetDrivingHistoryListWithAccessToken:self.accessToken startDateTime:startDatetime endDateTime:endDatetime success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)validServerSecurityPwd:(NSString *)passwd {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!passwd||[passwd isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入操作密码" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }
    [ProgressHUDHandler showHUD];
    NSDictionary *userInfo = @{@"ident":@1};
    [self setReloadFuncWithAction:_cmd parametersList:@[passwd]];
    [[APIsConnection shareConnection] personalGPSAPIsPostAuthorizeServerSecurityPWWithAccessToken:self.accessToken serPwd:passwd success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)eraseDrivingHistory {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler updateProgressStatusWithTitle:@"正在清除数据"];
    NSDictionary *userInfo = @{@"ident":@2};
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalGPSAPIsPostEraseDrivingHistoryWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSNumber *ident = operation.userInfo[@"ident"];
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        if (ident.integerValue==0) {
            [ProgressHUDHandler dismissHUD];
        }
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:(ident.integerValue==0)]) {
                return;
            }
        
            [ProgressHUDHandler dismissHUD];
            NSString *title = getLocalizationString(@"error");
            if (ident.integerValue == 1) {
                title = getLocalizationString(@"alert_remind");
            }
            
            [SupportingClass showAlertViewWithTitle:title message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        switch (ident.integerValue) {
            case 0:{
                NSLog(@"%@",responseObject);
                [self handleResponseData:responseObject[CDZKeyOfResultKey]];
            }
                break;
                
            case 1:
                [self eraseDrivingHistory];
                break;
                
            case 2:{
                [ProgressHUDHandler showSuccessWithStatus:getLocalizationString(@"clear_success") onView:nil completion:^{
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
//        NSLog(@"success reload function %d", [self executeReloadFunction]);
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
