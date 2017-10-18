

//
//  HighViolationLocationVC.m
//  cdzer
//
//  Created by KEns0n on 1/6/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "HighViolationLocationVC.h"
#import "HVLocationDetailView.h"
#import <GPXParser/GPXParser.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import "PeripheralHighIncidenceScaleDiagramView.h"

@interface HVLPointAnnotation : BMKPointAnnotation

@property (nonatomic, strong) NSDictionary *dataDetail;

@end

@implementation HVLPointAnnotation
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.dataDetail = nil;
}
@end

@interface HVLPinAnnotationView : BMKPinAnnotationView

@property (strong ,nonatomic) NSString *address;

@end

@implementation HVLPinAnnotationView
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.address = nil;
}
@end

@interface HighViolationLocationVC () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    BMKMapView* _mapView;
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_geoCodeSearch;
}

@property (nonatomic, strong) UIImage *mapPinImage;

@property (nonatomic, strong) NSMutableArray *hvList;

@property (nonatomic, assign) CLLocationCoordinate2D userCoordinate;

@property (strong, nonatomic)  PeripheralHighIncidenceScaleDiagramView *peripheralHighIncidenceScaleDiagramView;


@property (nonatomic, strong) BMKReverseGeoCodeResult *reverseGeoCodeResult;

@end

@implementation HighViolationLocationVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"周边高发";
    self.peripheralHighIncidenceScaleDiagramView=[[UINib nibWithNibName:@"PeripheralHighIncidenceScaleDiagramView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locService.delegate = self;
    _geoCodeSearch.delegate = self;
    [self startLocation];
    self.tabBarController.title = self.title;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopLocation];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
    UIView *peripheralHighIncidenceScaleDiagramViewControl = (UIView *)[self.view viewWithTag:100];
    peripheralHighIncidenceScaleDiagramViewControl.hidden=YES ;
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.hvList = [@[] mutableCopy];
        if (!_mapPinImage) {
            self.mapPinImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"zhoubiangaofa-weizhangLoc@3x" type:FMImageTypeOfPNG  needToUpdate:YES];
        }
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
        
        _locService = BMKLocationService.new;
        _geoCodeSearch = BMKGeoCodeSearch.new;
        _mapView = [[BMKMapView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_mapView];
        _mapView.showsUserLocation = YES;
        
        UIImage *btnImageBKG = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"nav_loc_bkg" type:FMImageTypeOfPNG
                                                                            scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        
        UIImage *btnImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"nav_loc_off" type:FMImageTypeOfPNG
                                                                         scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        UIImage *btnImageSelected = [btnImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        locationBtn.imageView.tintColor = CDZColorOfDefaultColor;
        [locationBtn setImage:btnImage forState:UIControlStateNormal];
        [locationBtn setImage:btnImageSelected forState:UIControlStateSelected];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateNormal];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateSelected];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateHighlighted];
        [locationBtn sizeToFit];
        [locationBtn addTarget:self action:@selector(locateUserPosition) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:locationBtn];
        CGRect btnRect = locationBtn.frame;
        btnRect.origin.x = CGRectGetWidth(self.contentView.frame)*0.8;
        btnRect.origin.y = CGRectGetHeight(self.contentView.frame)*0.75;
        locationBtn.frame = btnRect;
        
        
//    ///////////////////////
                   
        UIView *peripheralHighIncidenceScaleDiagramViewContain=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100)];
        peripheralHighIncidenceScaleDiagramViewContain.tag=100;
        self.peripheralHighIncidenceScaleDiagramView.frame=peripheralHighIncidenceScaleDiagramViewContain.frame;
        [self.view insertSubview:peripheralHighIncidenceScaleDiagramViewContain atIndex:10];
        [peripheralHighIncidenceScaleDiagramViewContain addSubview:self.peripheralHighIncidenceScaleDiagramView];
        self.peripheralHighIncidenceScaleDiagramView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.peripheralHighIncidenceScaleDiagramView.translatesAutoresizingMaskIntoConstraints = YES;
        [self.peripheralHighIncidenceScaleDiagramView setNeedsUpdateConstraints];
        [self.peripheralHighIncidenceScaleDiagramView setNeedsDisplay];
        [self.peripheralHighIncidenceScaleDiagramView setNeedsLayout];
        peripheralHighIncidenceScaleDiagramViewContain.hidden=YES;
        

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locateUserPosition {
    [self updateUserLocation:_userCoordinate];
}

- (void)updateUserLocation:(CLLocationCoordinate2D)coordinate {
    [_mapView setCenterCoordinate:coordinate];
    _mapView.zoomLevel = 12;
}

- (void)startLocation {
    NSLog(@"进入普通定位态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

- (void)stopLocation {
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}


#pragma mark BMKMapViewDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    @autoreleasepool {
        if (error==BMK_SEARCH_NO_ERROR) {
            [self getCityViolationEnquiryListWithCityName:result.addressDetail.city withShowHub:NO];
        }else {
            [ProgressHUDHandler dismissHUD];
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
//    @autoreleasepool {
//        if (_userCoordinate.latitude==0||_userCoordinate.longitude==0) {
//            BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
//            reverseGeoOption.reverseGeoPoint = userLocation.location.coordinate;
//            if ([_geoCodeSearch reverseGeoCode:reverseGeoOption]) {
//                [ProgressHUDHandler showHUD];
//            }
//            [self updateUserLocation:userLocation.location.coordinate];
//        }
//        self.userCoordinate = userLocation.location.coordinate;
//        [_mapView updateLocationData:userLocation];
//        NSLog(@"heading is %@",userLocation.heading);
//    }
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    @autoreleasepool {
        NSValue *value = [NSValue valueWithMKCoordinate:userLocation.location.coordinate];
        NSLog(@"%@", value);
        if (_userCoordinate.latitude==0||_userCoordinate.longitude==0||userLocation.location.coordinate.longitude==0||userLocation.location.coordinate.latitude==0) {
            BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
            reverseGeoOption.reverseGeoPoint = userLocation.location.coordinate;
            if ([_geoCodeSearch reverseGeoCode:reverseGeoOption]) {
                [ProgressHUDHandler showHUD];
            }
            [self updateUserLocation:userLocation.location.coordinate];
        }
        //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        self.userCoordinate = userLocation.location.coordinate;
        [_mapView updateLocationData:userLocation];
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
    @autoreleasepool {
        if (_userCoordinate.latitude==0||_userCoordinate.longitude==0) {
            
            NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Changsha_China" ofType:@"gpx"]];
            @weakify(self);
            [GPXParser parse:fileData completion:^(BOOL success, GPX *gpx) {
                @strongify(self);
                if (success) {
                    Waypoint *wayPoint = gpx.waypoints[0];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@,%@",
                                                                      [NSDecimalNumber numberWithDouble:wayPoint.coordinate.latitude],
                                                                      [NSDecimalNumber numberWithDouble:wayPoint.coordinate.longitude]]
                                                              forKey:@"lastLocation"];
                    self.userCoordinate = wayPoint.coordinate;
                    BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
                    reverseGeoOption.reverseGeoPoint = self.userCoordinate;
                    if ([self->_geoCodeSearch reverseGeoCode:reverseGeoOption]) {
                        [ProgressHUDHandler showHUD];
                    }
                    [self->_mapView setCenterCoordinate:self.userCoordinate];
                    self->_mapView.zoomLevel = 12;
                    
                }
            }];
        }
    }
}
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
        newAnnotationView = [[HVLPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
        newAnnotationView.canShowCallout = YES;
        newAnnotationView.image = self.mapPinImage;
        newAnnotationView.centerOffset = CGPointMake(1, -(newAnnotationView.frame.size.height * 0.5));
        newAnnotationView.canShowCallout = YES;
    }
    if ([annotation isKindOfClass:[HVLPointAnnotation class]]) {
        @autoreleasepool {
            HVLocationDetailView *pointDescriptionView = [[[NSBundle mainBundle] loadNibNamed:@"HVLocationDetailView" owner:self options:nil]objectAtIndex:0];
            pointDescriptionView.owner=self;
            [pointDescriptionView setShopDetailWithData:[(HVLPointAnnotation *)annotation dataDetail]];
            if ([newAnnotationView isKindOfClass:[HVLPinAnnotationView class]]) {
                [(HVLPinAnnotationView *)newAnnotationView setAddress:[[(HVLPointAnnotation *)annotation dataDetail] objectForKey:@"place_name"]];
//                //////
                [pointDescriptionView.shareBtn addTarget:self action:@selector(showShareSDKView) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            BMKActionPaopaoView* paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:pointDescriptionView];
            newAnnotationView.paopaoView = paopaoView;
            [newAnnotationView setAnnotation:annotation];
        }
    }
    
    return newAnnotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:HVLPointAnnotation.class]) {
        mapView.centerCoordinate = view.annotation.coordinate;
        HVLPointAnnotation *annotation = (HVLPointAnnotation *)view.annotation;
        [self.peripheralHighIncidenceScaleDiagramView upDataWithPercent:annotation.dataDetail];
//        if ([view isKindOfClass:[HVLPinAnnotationView class]]) {
//        [self getHVDetailDataWithAddress:[(HVLPinAnnotationView *)view address]];
//        }
        UIEdgeInsets mapPadding = UIEdgeInsetsZero;
        mapPadding.top = 100;
        mapView.mapPadding = mapPadding;
        
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            UIView *peripheralHighIncidenceScaleDiagramViewControl = (UIView *)[self.view viewWithTag:100];
            peripheralHighIncidenceScaleDiagramViewControl.hidden=NO;
        }];
    }
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    @weakify(self);
    mapView.mapPadding = UIEdgeInsetsZero;
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        UIView *peripheralHighIncidenceScaleDiagramViewControl = (UIView *)[self.view viewWithTag:100];
        peripheralHighIncidenceScaleDiagramViewControl.hidden=YES;
    }];
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
//    if ([view isKindOfClass:[HVLPinAnnotationView class]]) {
//        [self getHVDetailDataWithAddress:[(HVLPinAnnotationView *)view address]];
//    }
}

- (void)updateMapAnnotations {
    if (_mapView.annotations.count>0) {
         [_mapView removeAnnotations:_mapView.annotations];
    }
    @weakify(self);
    [_hvList enumerateObjectsUsingBlock:^(NSDictionary *dataDetail, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        CGFloat latitude = [dataDetail[@"latitude"] doubleValue];
        CGFloat longitude = [dataDetail[@"longitude"] doubleValue];
        if (latitude>0&&longitude>0) {
            HVLPointAnnotation *annotation = [[HVLPointAnnotation alloc]init];
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            annotation.dataDetail = dataDetail;
            [self->_mapView addAnnotation:annotation];
        }
    }];
}

- (void)getCityViolationEnquiryListWithCityName:(NSString *)cityName withShowHub:(BOOL)showHub {
    if (!cityName||[cityName isEqualToString:@""]) {
        return ;
    }
    if (showHub) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetCityViolationEnquiryListWithCityName:cityName success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@----%@",message,operation);
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [self.hvList removeAllObjects];
            if ([message isContainsString:@"没有数据"]) {
                message = @"你所在的城市暂无违章信息！";
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.hvList removeAllObjects];
        [self.hvList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self updateMapAnnotations];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self.hvList removeAllObjects];

        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];

    }];
}

- (void)getHVDetailDataWithAddress:(NSString *)address {
    if (!address||[address isEqualToString:@""]) {
        return ;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetViolationDetailWithBlacksiteAddress:address success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
       NSLog(@"%@----%@",message,operation);
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.peripheralHighIncidenceScaleDiagramView upDataWithPercent:responseObject[CDZKeyOfResultKey]];
        
//        TrafficViolationDetailVC *vc = TrafficViolationDetailVC.new;
//        vc.tvDetail = responseObject[CDZKeyOfResultKey];
//        vc.address = address;
//        [self setNavBarBackButtonTitleOrImage:nil titleColor:nil];
//        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];

    }];
}
////////////////////////////////


- (UIImage *)getResultScreenShot {
    UIWindow *widows = UIApplication.sharedApplication.keyWindow;
    CGFloat scale = UIScreen.mainScreen.scale;
    CGFloat width = CGRectGetWidth(widows.frame)*scale;
    CGFloat height = CGRectGetHeight(widows.frame)*scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, scale);
    //设置截屏大小
    [[widows layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = CGRectMake(0, 0, width, height);//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    return sendImage;
    //    //以下为图片保存代码
    //    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);//保存图片到照片库
    //    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *pictureName= @"screenShow.png";
    //    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
    //    [imageViewData writeToFile:savedImagePath atomically:YES];//保存照片到沙盒目录
    //    CGImageRelease(imageRefRect);
    //    //从手机本地加载图片
    //    UIImage *bgImage2 = [[UIImage alloc]initWithContentsOfFile:savedImagePath];
}

- (void)showShareSDKView {
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *view = self.view;
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    UIImage *image = [self getResultScreenShot];
    //1、创建分享参数（必要）
    NSString *text = [@"车队长" stringByAppendingString:shareUrl];
    NSString *title = @"车队长";
    NSURL *url = [NSURL URLWithString:shareUrl];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKEnableUseClientShare];
    [shareParams SSDKSetupShareParamsByText:text
                                     images:image
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupSinaWeiboShareParamsByText:title
                                               title:title
                                               image:image
                                                 url:url
                                            latitude:0.0f
                                           longitude:0.0f
                                            objectID:nil
                                                type:SSDKContentTypeImage];
    
    [shareParams SSDKSetupWeChatParamsByText:text
                                       title:title
                                         url:url
                                  thumbImage:nil
                                       image:image
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeImage
                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [shareParams SSDKSetupWeChatParamsByText:text
                                       title:title
                                         url:url
                                  thumbImage:nil
                                       image:image
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeImage
                          forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    [shareParams SSDKSetupWeChatParamsByText:text
                                       title:title
                                         url:url
                                  thumbImage:nil
                                       image:image
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeImage
                          forPlatformSubType:SSDKPlatformSubTypeWechatFav];
    
    //1.2、自定义分享平台（非必要）
    //    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:[ShareSDK activePlatforms]];
    NSMutableArray *activePlatforms = [@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformTypeWechat),
                                         @(SSDKPlatformSubTypeWechatTimeline), @(SSDKPlatformSubTypeWechatFav),] mutableCopy];
    NSLog(@"%@", activePlatforms);
    //添加一个自定义的平台（非必要）
    //    SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"Icon.png"]
    //                                                                                  label:@"自定义"
    //                                                                                onClick:^{
    //
    //                                                                                    //自定义item被点击的处理逻辑
    //                                                                                    NSLog(@"=== 自定义item被点击 ===");
    //                                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"自定义item被点击"
    //                                                                                                                                        message:nil
    //                                                                                                                                       delegate:nil
    //                                                                                                                              cancelButtonTitle:@"确定"
    //                                                                                                                              otherButtonTitles:nil];
    //                                                                                    [alertView show];
    //                                                                                }];
    //    [activePlatforms addObject:item];
    
    //设置分享菜单栏样式（非必要）
    //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
    //        [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    //        [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:[UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0]];
    
    //2、分享
    [ShareSDK showShareActionSheet:view
                             items:activePlatforms
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
//                           [ProgressHUDHandler showHUD];
                           [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           //Facebook Messenger、WhatsApp等平台捕获不到分享成功或失败的状态，最合适的方式就是对这些平台区别对待
                           if (platformType == SSDKPlatformTypeFacebookMessenger)
                           {
                               break;
                           }
                           
//                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                               message:nil
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"确定"
//                                                                     otherButtonTitles:nil];
//                           [alertView show];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
//                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
//                                                                               message:nil
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"确定"
//                                                                     otherButtonTitles:nil];
//                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                       [ProgressHUDHandler dismissHUD];
                       [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
                   }
                   
               }];
    
    //另附：设置跳过分享编辑页面，直接分享的平台。
    //        SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view
    //                                                                         items:nil
    //                                                                   shareParams:shareParams
    //                                                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
    //                                                           }];
    //
    //        //删除和添加平台示例
    //        [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
    //        [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    
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
