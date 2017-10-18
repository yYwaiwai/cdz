//
//  GPSAutosDrivingRecordVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define YDIMG(__name) [UIImage imageNamed:__name]
#import "GPSAutosDrivingRecordVC.h"
#import "YDSlider.h"
#import "GPSADRComponent.h"
#import "PositionDto.h"
#import "ParkView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "JsonElementUtils.h"
#import "GPSAutosDrivingBMKAnnotationView.h"
#define ANNOTATION_VIEW_NAME @ "view"
#define ANNOTATION_START_NAME @ "start"
#define ANNOTATION_PARK_NAME @"park"
#define ANNOTATION_END_NAME @ "end"

#define LOOP_PLAY_TIME 2.0f

@interface RoutePointAnnotation : BMKPointAnnotation

@property (nonatomic) NSInteger tag ;
@property (nonatomic) PositionDto *posDto;

@end

@implementation RoutePointAnnotation

@end

@interface GPSAutosDrivingRecordVC ()<BMKMapViewDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, weak) IBOutlet BMKMapView *mapView;

@property (nonatomic, weak) IBOutlet UILabel *startDateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *endDateTimeLabel;

@property (nonatomic, weak) IBOutlet UIButton *backwardButton;

@property (nonatomic, weak) IBOutlet UIButton *playButton;

@property (nonatomic, weak) IBOutlet UIButton *forwardButton;

@property (nonatomic, strong) IBOutlet YDSlider *timeSlider;

@property (nonatomic, strong) IBOutlet GPSADRDateTimeSelectionView *dateTimeSelView;

@property (nonatomic, strong) BMKGeoCodeSearch *geoSearcher;

@property (nonatomic, strong) BMKPolyline *polyline;

@property (nonatomic, strong) RoutePointAnnotation *startAnnotation;

@property (nonatomic, strong) RoutePointAnnotation *endAnnotation;

@property (nonatomic, strong) BMKPointAnnotation* annotation;

@property (nonatomic, strong) PositionDto *carPosition;

@property (nonatomic, strong) ParkView *pointDescriptionView;

@property (nonatomic, strong) NSArray *stopPointList;

@property (nonatomic, strong) NSArray *passingPointList;

@property (nonatomic, strong) NSTimer *loopPlayTimer;

@property (nonatomic, assign) NSInteger progressIndex;

@property (nonatomic, assign) BOOL isFinishToPlay;

@property (nonatomic, assign) BOOL isSelectDateTime;

@property (nonatomic, assign) BOOL didSelectedPoint;

@property (nonatomic, assign) BOOL wasPausePlayRecord;

@property (nonatomic, assign) BOOL wasLastPoint;

@property (nonatomic, assign) CGFloat autosHeadingDegree;

@end

@implementation GPSAutosDrivingRecordVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    _startAnnotation = nil;
    _endAnnotation = nil;
    _annotation = nil;
    self.geoSearcher = nil;
    self.polyline = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"行车记录";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.mapView) {
        [self.mapView viewWillAppear];
    }
    if (self.mapView.delegate!=self) {
        self.mapView.delegate = nil;
        self.mapView.delegate = self;
    }
    if (self.geoSearcher.delegate!=self) {
        self.geoSearcher.delegate = nil;
        self.geoSearcher.delegate = self;
    }
    if (self.passingPointList.count>0) {
        [self hiddenDateTimeSelView];
        [self startSetupMap];
    }else {
        [self showDateTimeSelView];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cleanMapData];
    if (self.mapView) {
        [self.mapView viewWillDisappear];
    }
    self.mapView.delegate = nil;
    self.geoSearcher.delegate = nil;
    
    if (self.loopPlayTimer){
        if ([self.loopPlayTimer isValid]){
            [self.loopPlayTimer invalidate];
        }
    }
    self.loopPlayTimer = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.dateTimeSelView setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        UIImage *imageStateNormal = [ImageHandler getCircleColorImage:[UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00] imageSize:CGSizeMake(16, 16) setborder:YES borderWithColor:CDZColorOfLightGray borderWidth:0.5];
        
        UIImage *imageStateHighlighted = [ImageHandler getCircleColorImage:[UIColor colorWithRed:0.965 green:0.682 blue:0.251 alpha:1.00] imageSize:CGSizeMake(16, 16) setborder:YES borderWithColor:CDZColorOfLightGray borderWidth:0.5];
        
        [self.timeSlider setThumbImage:imageStateNormal forState:UIControlStateNormal];
        [self.timeSlider setThumbImage:imageStateHighlighted forState:UIControlStateHighlighted];
        
        UIImage *minProgrssImage = [ImageHandler getLineColorImage:[UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.0f] imageSize:CGSizeMake(4, 3) setborder:NO borderWithColor:nil borderWidth:0];
        [self.timeSlider setMinimumTrackImage:[minProgrssImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.5, 0, 1.5) resizingMode:UIImageResizingModeStretch]];
        
        UIImage *maxProgrssImage = [ImageHandler getLineColorImage:[UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:0.4f] imageSize:CGSizeMake(4, 3) setborder:NO borderWithColor:nil borderWidth:0];
        [self.timeSlider setMaximumTrackImage:[maxProgrssImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.5, 0, 1.5) resizingMode:UIImageResizingModeStretch]];
        
        UINib *nib = [UINib nibWithNibName:@"GPSADRComponent" bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        self.dateTimeSelView.frame = self.view.bounds;
        [self.dateTimeSelView addSelfByFourMarginToSuperview:self.view];

        @weakify(self);
        self.dateTimeSelView.responseBlock = ^(NSString *startDateTime, NSString *endDateTime){
            if (![startDateTime isEqualToString:@""]&&![endDateTime isEqualToString:@""]) {
                @strongify(self);
                [self getDrivingHistoryListWithStartDateTime:startDateTime andEndDateTime:endDateTime];
            }
        };
        
        if (!self.geoSearcher) {
            self.geoSearcher = [[BMKGeoCodeSearch alloc] init];
        }
        [self.mapView setZoomLevel:21];
        if (self.mapView) {
            [self.mapView viewWillAppear];
        }
        self.mapView.delegate = self;
        self.geoSearcher.delegate = self;
    }
    
    
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (IBAction)stopPlayer:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.wasPausePlayRecord = !sender.selected;
    self.isFinishToPlay = NO;
}

- (IBAction)showDateTimeSelView {
    self.wasPausePlayRecord = YES;
    self.dateTimeSelView.alpha = 1;
}

- (void)hiddenDateTimeSelView {
    self.dateTimeSelView.alpha = 0;
}

- (void)startSetupMap {
    self.mapView.zoomLevel=21;
    self.isFinishToPlay = NO;
    self.wasPausePlayRecord = NO;
    self.didSelectedPoint = NO;
    if (self.passingPointList.count>0) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([(PositionDto *) self.passingPointList.firstObject latitude], [(PositionDto *) self.passingPointList.firstObject longitude]);
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    }
    [self drawDrivingLine];
    //    self.theInfoView.alpha = 1;
    
    [self addStopPointAnnotationView];
    [self addStartEndPointAnnotation];
    if (self.loopPlayTimer){
        if ([self.loopPlayTimer isValid]){
            [self.loopPlayTimer invalidate];
        }
        self.loopPlayTimer = nil;
    }
    self.loopPlayTimer = [NSTimer scheduledTimerWithTimeInterval:LOOP_PLAY_TIME target:self selector:@selector(getCarLocatAndAnnota) userInfo:nil repeats:YES];
    [self.loopPlayTimer fire];
    
}

- (IBAction)timeSliderValueChange:(YDSlider *)timeSlider {
    if (self.passingPointList && self.passingPointList.count>2) {
        float num = (float)(self.passingPointList.count*timeSlider.value);
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
        if (![self.loopPlayTimer isValid]) {
            self.loopPlayTimer = nil;
            self.loopPlayTimer = [NSTimer scheduledTimerWithTimeInterval:LOOP_PLAY_TIME target:self selector:@selector(getCarLocatAndAnnota) userInfo:nil repeats:YES];
        }
        [self.loopPlayTimer fire];
    }
}

#pragma mark- Map Control Action

- (void)cleanMapData {
    if (self.polyline ) {
        [self.mapView removeOverlay:self.polyline];
        self.polyline = nil;
    }
    if (_annotation) {
        [self.mapView removeAnnotation:_annotation];
        _annotation = nil;
    }
    
    if (self.startAnnotation) {
        [self.mapView removeAnnotation:self.startAnnotation];
        self.startAnnotation = nil;
    }
    
    if (self.endAnnotation) {
        [self.mapView removeAnnotation:self.endAnnotation];
        self.endAnnotation = nil;
    }
}

#pragma mark 连线
- (void)drawDrivingLine {
    @autoreleasepool {
        NSUInteger count = self.passingPointList.count;
        CLLocationCoordinate2D coordinate[count], *coordinatePoints;
        coordinatePoints = coordinate;
        [self.passingPointList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            coordinatePoints[idx].latitude = [(PositionDto *)obj latitude];
            coordinatePoints[idx].longitude = [(PositionDto *)obj longitude];
        }];
        if (!self.polyline) {
            self.polyline = [BMKPolyline polylineWithCoordinates:coordinatePoints count:count textureIndex:@[@1]];
        }else {
            [self.polyline setPolylineWithCoordinates:coordinatePoints count:count textureIndex:@[@1]];
        }
        [self.mapView addOverlay:self.polyline];
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
            RoutePointAnnotation *annotation = [[RoutePointAnnotation alloc] init];
            annotation.posDto = obj ;
            annotation.coordinate = coordinate ;
            annotation.tag = idx ;
            annotation.title = ANNOTATION_PARK_NAME ;
            [self.mapView addAnnotation:annotation];
            if ([self.stopPointList.lastObject isEqual:obj]) {
                [self.pointDescriptionView setParkViewData:obj];
                BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
                reverseGeoOption.reverseGeoPoint = annotation.coordinate;
                [self.geoSearcher reverseGeoCode:reverseGeoOption];
            }
            
        }];
    }
}

#pragma mark 添加起始点
- (void)addStartEndPointAnnotation {
    if (!self.passingPointList||self.passingPointList.count==0) return;
    @autoreleasepool {
        //起点
        self.startAnnotation = [[RoutePointAnnotation alloc]init];
        PositionDto* startDto = [self.passingPointList firstObject];
        self.startAnnotation.posDto = startDto ;
        CLLocationCoordinate2D coor;
        self.startAnnotation.title = ANNOTATION_START_NAME;
        coor.latitude = startDto.latitude;
        coor.longitude = startDto.longitude;
        self.startAnnotation.coordinate = coor;
        [self.mapView addAnnotation:self.startAnnotation];
        
        //终点
        self.endAnnotation = [[RoutePointAnnotation alloc]init];
        PositionDto* sendDto = [self.passingPointList lastObject];
        self.endAnnotation.posDto = sendDto ;
        CLLocationCoordinate2D endCoor;
        endCoor.latitude = sendDto.latitude;
        endCoor.longitude = sendDto.longitude;
        self.endAnnotation.coordinate = endCoor;
        self.endAnnotation.title = ANNOTATION_END_NAME;
        [self.mapView addAnnotation:self.endAnnotation];
    }
}

#pragma mark 历史轨迹
- (void)getCarLocatAndAnnota {
    if (self.wasPausePlayRecord) {
        return;
    }
    CGFloat baseCount = 1.0f/(CGFloat)self.passingPointList.count;
    [self getCarLocation];
    [self addPointAnnotation];
    NSMutableArray *textureIndex = [@[] mutableCopy];
    NSUInteger count = self.passingPointList.count;
    CLLocationCoordinate2D coordinate[count], *coordinatePoints;
    coordinatePoints = coordinate;
    @weakify(self);
    [self.passingPointList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        coordinatePoints[idx].latitude = [(PositionDto *)obj latitude];
        coordinatePoints[idx].longitude = [(PositionDto *)obj longitude];
        if (idx<self.progressIndex-1) {
            if (idx==0) {
                [textureIndex addObject:@1];
            }else {
                [textureIndex insertObject:@0 atIndex:0];
            }
        }
    }];
    if (!self.polyline) {
        self.polyline = [BMKPolyline polylineWithCoordinates:coordinatePoints count:count textureIndex:textureIndex];
    }else {
        [self.polyline setPolylineWithCoordinates:coordinatePoints count:count textureIndex:textureIndex];
    }
    if (self.mapView.overlays.count>0) {
        [self.mapView removeOverlays:self.mapView.overlays];
    }
    [self.mapView addOverlay:self.polyline];
    
    if (self.progressIndex==0 && self.isFinishToPlay) {
        if (self.loopPlayTimer){
            if ([self.loopPlayTimer isValid]){
                [self.loopPlayTimer invalidate];
            }
            self.loopPlayTimer = nil;
        }
        self.timeSlider.value = 0;
    }
    if(self.progressIndex!=0){
        self.timeSlider.value = self.timeSlider.value+baseCount;
    }
    
    self.progressIndex++;
    if (self.progressIndex==self.passingPointList.count) {
        self.playButton.selected = YES;
        self.progressIndex = 0;
        self.isFinishToPlay = true;
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
        if (self.passingPointList.count==0) {
            return;
        }
        _carPosition = self.passingPointList[self.progressIndex];
        
        // ACC状态描述
        // [self carAccStateDesc:[_carPosition acc]];
        
        // 车辆图片旋转
        
        CLLocationCoordinate2D coor = {0};
        coor.latitude = _carPosition.latitude;
        coor.longitude = _carPosition.longitude;
        CGPoint point = [self.mapView convertCoordinate:coor toPointToView:self.view];
        
        if (self.progressIndex==self.passingPointList.count-1 ) {
//            _carImg = [UIImage imageNamed:@"ic_car_horizontal.png"];
            self.wasLastPoint = YES;
        }else{
            self.wasLastPoint = NO;
            PositionDto* dto = self.passingPointList[self.progressIndex+1];
            CLLocationCoordinate2D coor1 = {0};
            coor1.latitude = dto.latitude;
            coor1.longitude = dto.longitude;
            CGPoint point1 = [self.mapView convertCoordinate:coor1 toPointToView:self.view];
            self.autosHeadingDegree = [self twoPointangle:point point2:point1];
            CGFloat rotate = [self twoPointangle:point point2:point1];
            CGFloat f = (rotate/360)*2*M_PI;
//            self.autosHeadingDegree = f;
        }
        
        // 位置信息
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){_carPosition.latitude, _carPosition.longitude};
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = pt;
        [self.geoSearcher reverseGeoCode:reverseGeoOption];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark 历史轨迹，添加Annotation到mapView
- (void)addPointAnnotation {
    @try {
        if (_annotation) {
            [self.mapView removeAnnotation:(_annotation)];
            _annotation = nil;
        }
        if (self.passingPointList.count==0) {
            return;
        }
        PositionDto* dto = self.passingPointList[self.progressIndex];
        // 添加一个PointAnnotation
        _annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        _carPosition = dto;
        coor.latitude = _carPosition.latitude;
        coor.longitude = _carPosition.longitude;
        _annotation.coordinate = coor;
        if (self.progressIndex==0 && self.isFinishToPlay) {
            _annotation.title =@"";
        }
        [self.mapView addAnnotation:_annotation];
        BMKMapRect inMap = [self.mapView visibleMapRect];
        BMKMapPoint coorPoint = BMKMapPointForCoordinate(coor);
        NSLog(@"coorPointx=%f,coorPoint.y=%f",coorPoint.x,coorPoint.y);
        NSLog(@"inMap.x=%f,inMap.y=%f",inMap.origin.x,inMap.origin.y);
        // 在可视范围内不设置中心点
        if (coorPoint.x < inMap.origin.x || coorPoint.x > (inMap.origin.x+inMap.size.width)
            ||coorPoint.y<inMap.origin.y || coorPoint.y > (inMap.origin.y+inMap.size.height)) {
            [self.mapView setCenterCoordinate:coor];
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
//    if (_didSelectedPoint) {
//        self.pointDescriptionView.address.text = [@"地址：" stringByAppendingString:result.address];
//        self.didSelectedPoint = NO;
//        return;
//    }
//
//    [_theInfoView setAutoLocaleInfoWithMilesString:nil dateTime:nil
//                                         startTime:nil endTime:nil localtion:result.address];
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
            if (self.passingPointList.count>1) {
                newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
            }else{
                newAnnotationView.centerOffset = CGPointMake(-(newAnnotationView.frame.size.width * 0.5),0);
            }
            newAnnotationView.canShowCallout = NO;
            self.pointDescriptionView.center = CGPointMake(10, -35);
        }else if([ANNOTATION_PARK_NAME isEqualToString:[annotation title]]){
            newAnnotationView = [[GPSAutosDrivingBMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"parkAnnotation"];
            newAnnotationView.image = [UIImage imageNamed:@"icon_nav_park.png"];
            NSLog(@"\nLog:::%f \nLat:::%f",annotation.coordinate.longitude, annotation.coordinate.latitude);
            newAnnotationView.canShowCallout = NO ;
            
        }else{
            
            newAnnotationView = [[GPSAutosDrivingBMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carHisAnnotation"];
            newAnnotationView.canShowCallout = NO;
            newAnnotationView.draggable = NO;
            
            if (_carPosition) {
                [(GPSAutosDrivingBMKAnnotationView *)newAnnotationView updateCurrentCarPosition:_carPosition autosHeadingDegree:self.autosHeadingDegree andWasLastPoint:self.wasLastPoint];
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
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    [view addSubview:self.pointDescriptionView];
    
    if([[view annotation] isKindOfClass:[RoutePointAnnotation class]]){
        RoutePointAnnotation *parkAnnotation = (RoutePointAnnotation *)[view annotation] ;
        [self.pointDescriptionView setParkViewData:parkAnnotation.posDto];
        [self.mapView setCenterCoordinate:parkAnnotation.coordinate animated:YES];
        
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = parkAnnotation.coordinate;
        [self.geoSearcher reverseGeoCode:reverseGeoOption];
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
//        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
//        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];

        polylineView.colors = @[[UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00],
                                [UIColor colorWithRed:0.965 green:0.682 blue:0.251 alpha:1.00]];
        
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
        NSString *startDateString = [(PositionDto*)passingPointArray.firstObject time];
        NSRange startDateStrRange = [startDateString rangeOfString:@":" options:NSBackwardsSearch];
        startDateStrRange.length = startDateString.length-startDateStrRange.location;
        NSString *startDateHandledString = [startDateString stringByReplacingCharactersInRange:startDateStrRange withString:@""];
        
        NSString *endDateString = [(PositionDto*)passingPointArray.lastObject time];
        NSRange endDateStrRange = [endDateString rangeOfString:@":" options:NSBackwardsSearch];
        endDateStrRange.length = endDateString.length-endDateStrRange.location;
        NSString *endDateHandledString = [endDateString stringByReplacingCharactersInRange:startDateStrRange withString:@""];
        
        self.startDateTimeLabel.text = [startDateHandledString stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        self.endDateTimeLabel.text = [endDateHandledString stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        
        self.stopPointList = stopPointArray;
        self.passingPointList = passingPointArray;
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            [self hiddenDateTimeSelView];
        } completion:^(BOOL finished) {
            @strongify(self);
            self.timeSlider.value = 0;
            [self cleanMapData];
            [self startSetupMap];
        }];
    }
    
}

#pragma mark- APIs Access Request

- (void)getDrivingHistoryListWithStartDateTime:(NSString *)startDatetime andEndDateTime:(NSString *)endDatetime {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    NSDictionary *userInfo = @{@"ident":@0};
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalGPSAPIsGetDrivingHistoryListWithAccessToken:self.accessToken startDateTime:startDatetime endDateTime:endDatetime success:^(NSURLSessionDataTask *operation, id responseObject) {
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
    if (!passwd||[passwd isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入操作密码" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }
    [ProgressHUDHandler showHUD];
    NSDictionary *userInfo = @{@"ident":@1};
    [self setReloadFuncWithAction:_cmd parametersList:@[passwd]];
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

- (void)eraseDrivingHistory {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler updateProgressStatusWithTitle:@"正在清除数据"];
    NSDictionary *userInfo = @{@"ident":@2};
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostEraseDrivingHistoryWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        @weakify(self);
        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
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
