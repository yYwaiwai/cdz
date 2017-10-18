//
//  GPSAutosLocationVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "GPSAutosLocationVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <CoreLocation/CoreLocation.h>
#import "GPSAutosLocationBMKAnnotationView.h"

@interface GPSAutosLocationVC ()<BMKMapViewDelegate>

@property (nonatomic, weak) IBOutlet BMKMapView *mapView;

@property (nonatomic, strong) BMKPointAnnotation *carAnnotation;

@property (nonatomic, strong) NSNumber *remindStatus;

@property (nonatomic, strong) NSNumber *gpsUploadSettingStatus;

@property (nonatomic, strong) UIImage *carImg;

@property (nonatomic, strong) NSTimer *reloadTimer;


@end

@implementation GPSAutosLocationVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    _mapView.delegate = nil;
    [_mapView removeFromSuperview];
    _mapView = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UserAutosInfoDTO *dto = DBHandler.shareInstance.getUserAutosDetail;
    self.title = dto.licensePlate;
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mapView.delegate = self;
    [_mapView viewWillAppear];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    if ([self compareLocationCoordinateDistance:_carAnnotation.coordinate withSecondCoordinate:coordinate] != 0) {
        [_mapView setCenterCoordinate:_carAnnotation.coordinate];
    }
    if (self.reloadTimer) {
        if (self.reloadTimer.isValid) {
            [self.reloadTimer invalidate];
        }
        self.reloadTimer = nil;
    }
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(updateUserAutoGPSRealtimeData) userInfo:nil repeats:YES];
    [self updateUserAutoGPSRealtimeData];


}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    [_mapView removeAnnotations:_mapView.annotations];
    _mapView.delegate = nil;
    
    if (self.reloadTimer) {
        if (self.reloadTimer.isValid) {
            [self.reloadTimer invalidate];
        }
        self.reloadTimer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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
        self.carAnnotation = [[BMKPointAnnotation alloc] init];
        
        _mapView.compassPosition = CGPointMake(10.0f, 10.0f);
        _mapView.delegate = self;
        _mapView.zoomLevel = 16;
    }
}

- (void)initializationUI {
    @autoreleasepool {
    }
}

- (double)compareLocationCoordinateDistance:(CLLocationCoordinate2D)firstCoordinate withSecondCoordinate:(CLLocationCoordinate2D)secondCoordinate {
    @autoreleasepool {
        CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstCoordinate.latitude longitude:firstCoordinate.longitude];
        CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondCoordinate.latitude longitude:secondCoordinate.longitude];
        
        return [firstLocation distanceFromLocation:secondLocation];
    }
}

#pragma mark- private function
- (void)updateGeoLocationByCoordinates {
    @autoreleasepool {
        NSDictionary * autoGPSDetail = [[DBHandler shareInstance] getAutoRealtimeDataWithDataID:1];
        if (!autoGPSDetail) return;
//        
//        [_theInfoView setAutoLocaleInfoWithMilesString:[autoGPSDetail[@"speed"] stringValue]
//                                              dateTime:autoGPSDetail[@"time"]
//                                             gpsSignal:[autoGPSDetail[@"gpsNum"] stringValue]
//                                             gsmSignal:[autoGPSDetail[@"gsm"] stringValue] localtion:nil];
        
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [autoGPSDetail[@"lat"] doubleValue];
        coordinate.longitude = [autoGPSDetail[@"lon"] doubleValue];
        _carAnnotation.coordinate = coordinate;
        [self addPointAnnotation];
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
    
    GPSAutosLocationBMKAnnotationView *newAnnotationView = nil;
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        newAnnotationView = [[GPSAutosLocationBMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carAnnotation"];
//        newAnnotationView.image = _carImg;
        newAnnotationView.selected = NO;
        newAnnotationView.canShowCallout = NO;
        newAnnotationView.draggable = NO;
    }
    return newAnnotationView;
}


#pragma mark- Map Control Action

- (IBAction)locateAutosPosition {
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
- (void)updateUserAutoGPSRealtimeData {
    if (vGetUserType==CDZUserTypeOfGPSUser||vGetUserType==CDZUserTypeOfGPSWithODBUser) {
        NSString *token = vGetUserToken;
        if (!self.accessToken) return;
        [[APIsConnection shareConnection] personalGPSAPIsGetAutoGPSRealtimeInfoWithAccessToken:token success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode==0) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObject:@(1) forKey:@"id"];
                [data addEntriesFromDictionary:responseObject[CDZKeyOfResultKey]];
                BOOL isDone = [[DBHandler shareInstance] updateAutoRealtimeData:data];
                NSLog(@"GPSRealtimeInfoUpdateOK?:::%d", isDone);
                if (isDone) {
                    [self updateGeoLocationByCoordinates];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
                }
            }
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"get data error");
        }];
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
