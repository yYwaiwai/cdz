//
//  ViolationDetailsVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ViolationDetailsVC.h"
#import "UserLocationHandler.h"
#import <GPXParser/GPXParser.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "PeripheralHighIncidenceScaleDiagramView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import "PositionErrorCorrectionVC.h"

@interface ViolationDetailsVC ()<BMKMapViewDelegate>
{
    BMKMapView* _mapView;
}

@property (weak, nonatomic) IBOutlet UIView *violationTimeBGView;

@property (weak, nonatomic) IBOutlet UILabel *violationTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *violationPlaceBGView;

@property (weak, nonatomic) IBOutlet UILabel *violationPlaceLabel;

@property (weak, nonatomic) IBOutlet UIView *mapBGView;

@property (weak, nonatomic) IBOutlet UIView *violationContentBGView;

@property (weak, nonatomic) IBOutlet UILabel *violationContentLabel;

@property (weak, nonatomic) IBOutlet UIView *violationPriceBGView;

@property (weak, nonatomic) IBOutlet UILabel *violationPriceLabel;

@property (weak, nonatomic) IBOutlet UIView *violationPointBGView;

@property (weak, nonatomic) IBOutlet UILabel *violationPointLabel;

@property (weak, nonatomic) IBOutlet UIView *treatmentSituationBGView;

@property (weak, nonatomic) IBOutlet UILabel *treatmentSituationLabel;

@property (weak, nonatomic) IBOutlet UIView *percentBGView;

@property (nonatomic, strong) PeripheralHighIncidenceScaleDiagramView *peripheralHighIncidenceScaleDiagramView;

@property (nonatomic, strong) NSNumber *latitude;

@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) UIBarButtonItem *rightButton;


@end

@implementation ViolationDetailsVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_mapView) {
        [_mapView viewWillAppear];
        _mapView.delegate = self;
        if (_mapView.annotations.count==0) {
            [_mapView removeAnnotations:_mapView.annotations];
            if (_latitude.doubleValue>0&&_longitude.doubleValue>0) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_latitude.doubleValue, _longitude.doubleValue);
                BMKPointAnnotation *annotation = BMKPointAnnotation.new;
                annotation.coordinate = coordinate;
                [_mapView addAnnotation:annotation];
                [_mapView setCenterCoordinate:coordinate animated:YES];
                _mapView.zoomLevel = 16;
            }
        }
    }
self.tabBarController.navigationItem.rightBarButtonItem =_rightButton;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_mapView) {
        [_mapView viewWillDisappear];
        _mapView.delegate = nil;
    }
    self.tabBarController.navigationItem.rightBarButtonItem =nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"违章详情";
    self.peripheralHighIncidenceScaleDiagramView=[[UINib nibWithNibName:@"PeripheralHighIncidenceScaleDiagramView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
     self.peripheralHighIncidenceScaleDiagramView.backgroundColor=[UIColor colorWithHexString:@"f5f5f5" alpha:1.0];
    [self initializationUI];
    [self componentSetting];
    
    
    
}
- (void)componentSetting {
    
    [self.violationTimeBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
        [self.violationPriceBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.violationPointBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.treatmentSituationBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
//    NSString*lon=@" 112.905903";
//    NSString*lat=@"28.22746";
    self.longitude = [SupportingClass verifyAndConvertDataToNumber:_tvDetail[@"longitude"]];
    self.latitude = [SupportingClass verifyAndConvertDataToNumber:_tvDetail[@"latitude"]];
    @weakify(self);
    if (self.latitude.integerValue<=0||self.longitude.integerValue<=0) {
        [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
            if (userLocation&&!error) {
                @strongify(self);
                self.latitude = @(userLocation.location.coordinate.latitude);
                self.longitude = @(userLocation.location.coordinate.longitude);
//                [self reverseGeoCodeSearchWithCoordinate];
            }else {
                NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Changsha_China" ofType:@"gpx"]];
                [GPXParser parse:fileData completion:^(BOOL success, GPX *gpx) {
                    @strongify(self);
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(28.22746, 112.905903);
                    if (success) {
                        Waypoint *wayPoint = gpx.waypoints[0];
                        coordinate = wayPoint.coordinate;
                    }
                    //转换GPS坐标至百度坐标(加密后的坐标)
                    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coordinate,BMK_COORDTYPE_GPS);
                    NSLog(@"x=%@,y=%@",[testdic objectForKey:@"x"],[testdic objectForKey:@"y"]);
                    //解密加密后的坐标字典
                    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
                    self.latitude = @(baiduCoor.latitude);
                    self.longitude = @(baiduCoor.longitude);
//                    [self reverseGeoCodeSearchWithCoordinate];
                }];
            }
            [UserLocationHandler.shareInstance stopUserLocationService];
        }];
    }else {
//        [self reverseGeoCodeSearchWithCoordinate];
    }
    
    UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"weizhangxiangqing-share@3x" type:FMImageTypeOfPNG needToUpdate:YES];
    self.rightButton = [self setRightNavButtonWithTitleOrImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showShareSDKView) titleColor:nil isNeedToSet:YES];

}

-(void)viewWillLayoutSubviews
{
    [self.violationContentBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.violationPlaceBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
}

- (void)initializationUI {
    @autoreleasepool {
        self.violationTimeLabel.text=self.violationDetail[@"violation_time"];
        self.violationPlaceLabel.text=self.violationDetail[@"violation_place"];
        self.violationContentLabel.text=self.violationDetail[@"violation_content"];
        self.violationPriceLabel.text=self.violationDetail[@"violation_price"];
        self.violationPointLabel.text=self.violationDetail[@"violation_point"];
        
        if (self.isType==1) {
            self.treatmentSituationLabel.text=@"未处理";
        }else{
            self.treatmentSituationLabel.text=@"已处理";
        }

        self.percentBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.percentBGView.frame=self.peripheralHighIncidenceScaleDiagramView.frame;
        
        [self.percentBGView addSubview:self.peripheralHighIncidenceScaleDiagramView];
       
        self.peripheralHighIncidenceScaleDiagramView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.peripheralHighIncidenceScaleDiagramView.translatesAutoresizingMaskIntoConstraints = YES;
        [self.peripheralHighIncidenceScaleDiagramView setNeedsUpdateConstraints];
        [self.peripheralHighIncidenceScaleDiagramView setNeedsDisplay];
        [self.peripheralHighIncidenceScaleDiagramView setNeedsLayout];
        [self.peripheralHighIncidenceScaleDiagramView upDataWithPercent:self.tvDetail];
        
//        if (_longitude.integerValue>0&&_longitude.integerValue>0) {
            _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0.0f, 0,
                                                                    CGRectGetWidth(self.violationTimeBGView.frame), CGRectGetHeight(self.mapBGView.frame))];
            [self.mapBGView addSubview:_mapView];
        self.mapBGView.frame=_mapView.frame;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _mapView.translatesAutoresizingMaskIntoConstraints = YES;
        
        UIButton *positionErrorCorrectionBtn=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_mapView.frame)-70, CGRectGetMaxY(_mapView.frame)-70, 60, 60)];
        [positionErrorCorrectionBtn setTitle:@"位置纠错" forState:UIControlStateNormal];
        positionErrorCorrectionBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [positionErrorCorrectionBtn.layer setCornerRadius:30];
        [positionErrorCorrectionBtn.layer setMasksToBounds:YES];
        positionErrorCorrectionBtn.backgroundColor=[UIColor colorWithHexString:@"49c7f5" alpha:1.0];
        [_mapView addSubview:positionErrorCorrectionBtn];
        [positionErrorCorrectionBtn addTarget:self action:@selector(positionErrorCorrectionBtnClick) forControlEvents:UIControlEventTouchUpInside];
        positionErrorCorrectionBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        positionErrorCorrectionBtn.translatesAutoresizingMaskIntoConstraints = YES;
        NSLog(@"_mapView----%@",NSStringFromCGRect(_mapView.frame));
        NSLog(@"positionErrorCorrectionBtn----%@",NSStringFromCGRect(positionErrorCorrectionBtn.frame));
//        }
    }
}

-(void)positionErrorCorrectionBtnClick
{
    PositionErrorCorrectionVC *vc = [PositionErrorCorrectionVC new];
    vc.address=self.violationDetail[@"violation_place"];
    vc.longitude=_longitude;
    vc.latitude=self.latitude;
    [self.navigationController  pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];

}
#pragma mark BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    @autoreleasepool {
        static NSString * showShopInfoPinIdentifier = @"shopAnnotation";
        BMKAnnotationView *newAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:showShopInfoPinIdentifier];
        if (newAnnotationView == nil) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"pin_lv3" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
            
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
            newAnnotationView.canShowCallout = YES;
            newAnnotationView.image = image;
            newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
            newAnnotationView.canShowCallout = YES;
        }
        
        return newAnnotationView;
    }
}
/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
