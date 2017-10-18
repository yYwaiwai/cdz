//
//  TrafficViolationDetailVC.m
//  cdzer
//
//  Created by KEns0n on 1/7/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "TrafficViolationDetailVC.h"
#import "InsetsLabel.h"
#import "HVLocationRemarkVC.h"
#import "UserLocationHandler.h"
#import "PNChart.h"
#import <GPXParser/GPXParser.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>


@interface TrafficViolationDetailVC () <BMKMapViewDelegate>
{
    BMKMapView* _mapView;
}

@property (nonatomic, strong) UIView *upperContentView;

@property (nonatomic, strong) NSMutableArray *chartList;

@property (nonatomic, strong) NSNumber *latitude;

@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) NSNumber *tvNum;

@property (nonatomic, strong) BMKReverseGeoCodeResult *reverseGeoCodeResult;

@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation TrafficViolationDetailVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"违章地详情";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_mapView) {
        [_mapView viewWillDisappear];
        _mapView.delegate = nil;
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        NSArray *tmpList = _tvDetail[@"listMap"];
        NSMutableArray *colorList = [@[PNRed, PNStarYellow, PNBlue, PNBlack, PNGreen, PNBrown, PNWeiboColor,
                                       PNBlack, PNPinkGrey, PNMauve, PNTitleColor, PNTwitterColor] mutableCopy];
        self.chartList = [@[] mutableCopy];
        @weakify(self);
        [tmpList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSNumber *value = [SupportingClass verifyAndConvertDataToNumber:detail[@"percent"]];
            UIColor *color = nil;
            if (idx+1>colorList.count) {
                NSUInteger randomNum = (arc4random() % colorList.count);
                color = colorList[randomNum];
            }else {
                color = colorList[idx];
            }
            PNPieChartDataItem *object = [PNPieChartDataItem dataItemWithValue:value.floatValue color:color description:detail[@"name"]];
            [self.chartList addObject:object];
        }];
        self.tvNum = [SupportingClass verifyAndConvertDataToNumber:_tvDetail[@"num"]];
        self.longitude = [SupportingClass verifyAndConvertDataToNumber:_tvDetail[@"longitude"]];
        self.latitude = [SupportingClass verifyAndConvertDataToNumber:_tvDetail[@"latitude"]];
        
        if (self.latitude.integerValue<=0||self.longitude.integerValue<=0) {
            [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
                if (userLocation&&!error) {
                    @strongify(self);
                    self.latitude = @(userLocation.location.coordinate.latitude);
                    self.longitude = @(userLocation.location.coordinate.longitude);
                    [self reverseGeoCodeSearchWithCoordinate];
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
                        [self reverseGeoCodeSearchWithCoordinate];
                    }];
                }
                [UserLocationHandler.shareInstance stopUserLocationService];
            }];
        }else {
            [self reverseGeoCodeSearchWithCoordinate];
        }
    }
}

- (void)reverseGeoCodeSearchWithCoordinate {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    @weakify(self);
    [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
        @strongify(self);
        if (BMK_SEARCH_NO_ERROR==error) {
            self.reverseGeoCodeResult = result;
            NSLog(@"Success!");
        }
    }];
}


- (void)initializationUI {
    @autoreleasepool {
        self.scrollView.hidden = NO;
        self.scrollView.frame = self.scrollView.bounds;
        
        self.upperContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scrollView.frame), 300.0f)];
        [self.scrollView addSubview:_upperContentView];
        
        UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        titleView.userInteractionEnabled = NO;
        titleView.titleLabel.numberOfLines = 0;
        titleView.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        titleView.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 0.0f);
        titleView.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 15.0f);
        titleView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [titleView setTitle:_address forState:UIControlStateNormal];
        [titleView setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [titleView setImage:[ImageHandler getSKIcon] forState:UIControlStateNormal];
        [_upperContentView addSubview:titleView];
        [titleView sizeToFit];
        CGRect titleViewFrame = titleView.frame;
        titleViewFrame.origin.y = 5.0f;
        titleViewFrame.size.width = CGRectGetWidth(self.scrollView.frame);
        titleView.frame = titleViewFrame;
        
        InsetsLabel *tvNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(titleView.frame)+10.0f,
                                                                       CGRectGetWidth(self.scrollView.frame), 30.0f)
                                          andEdgeInsetsValue:DefaultEdgeInsets];
        tvNumLabel.textColor = CDZColorOfWeiboColor;
        tvNumLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15, NO);
        tvNumLabel.text = [NSString stringWithFormat:@"违章次数：%@次", _tvNum];
        [_upperContentView addSubview:tvNumLabel];
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(CGRectGetWidth(self.scrollView.frame)-95.0f, CGRectGetMaxY(titleView.frame)+10.0f, 80.0f, 30.0f);
        _shareButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO);
        [_shareButton setTitle:@"告诉朋友" forState:UIControlStateNormal];
        [_shareButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(showShareSDKView) forControlEvents:UIControlEventTouchUpInside];
        [_upperContentView addSubview:_shareButton];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        InsetsLabel *tvChartTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tvNumLabel.frame)+6.0f,
                                                                                CGRectGetWidth(self.scrollView.frame), 40.0f)
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        tvChartTitle.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.00];
        tvChartTitle.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17, NO);
        tvChartTitle.text = @"违章分析";
        [_upperContentView addSubview:tvChartTitle];
        
        
        CGFloat chartWidth = CGRectGetWidth(self.scrollView.frame)*0.76;
        CGFloat chartOffsetX = CGRectGetWidth(self.scrollView.frame)*0.12;
        CGFloat chartOffsetY = 20.0f;
        UIView *chartContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tvChartTitle.frame),
                                                                              CGRectGetWidth(self.scrollView.frame), chartWidth+chartOffsetY*2.0f)];
        chartContainerView.backgroundColor = [UIColor colorWithRed:0.871 green:0.867 blue:0.784 alpha:1.00];
        [_upperContentView addSubview:chartContainerView];
        
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(chartOffsetX, chartOffsetY, chartWidth, chartWidth) items:_chartList];
        pieChart.descriptionTextColor = [UIColor whiteColor];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [pieChart strokeChart];
        [chartContainerView addSubview:pieChart];
        
        
        CGRect upperViewFrame = self.upperContentView.frame;
        upperViewFrame.size.height = round(CGRectGetMaxY(chartContainerView.frame));
        self.upperContentView.frame = upperViewFrame;
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        InsetsLabel *tvMapTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_upperContentView.frame),
                                                                                  CGRectGetWidth(self.scrollView.frame), 40.0f)
                                                    andEdgeInsetsValue:DefaultEdgeInsets];
        tvMapTitle.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.00];
        tvMapTitle.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17, NO);
        tvMapTitle.text = @"违章地点";
        [self.scrollView addSubview:tvMapTitle];
        
        InsetsLabel *peccancyTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tvMapTitle.frame),
                                                                                   CGRectGetWidth(self.scrollView.frame), 40.0f)
                                                     andEdgeInsetsValue:DefaultEdgeInsets];
        peccancyTitle.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.00];
        peccancyTitle.hidden=YES;
        peccancyTitle.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16, NO);
        peccancyTitle.text = @"无法获取该违章地点";
        [self.scrollView addSubview:peccancyTitle];

        CGRect btnRect = tvMapTitle.frame;
        btnRect.size.width = 90.0f;
        btnRect.origin.x = CGRectGetWidth(self.scrollView.frame)-DefaultEdgeInsets.right-CGRectGetWidth(btnRect);
        UIButton *remarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        remarkBtn.frame = btnRect;
        remarkBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 18, NO);
        [remarkBtn setTitle:@"我来纠错" forState:UIControlStateNormal];
//
        [remarkBtn setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [remarkBtn addTarget:self action:@selector(pushToLocationRemarkVC) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:remarkBtn];

        if (_longitude.integerValue>0&&_longitude.integerValue>0) {
            _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tvMapTitle.frame),
                                                                    CGRectGetWidth(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame)*0.8)];
            [self.scrollView addSubview:_mapView];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(_mapView.frame)+20.0f);
        }else {
            [remarkBtn setTitle:@"我来提供" forState:UIControlStateNormal];
            remarkBtn.frame = CGRectMake(CGRectGetWidth(self.scrollView.frame)-DefaultEdgeInsets.right-CGRectGetWidth(btnRect), CGRectGetMaxY(tvMapTitle.frame), 90.0f, 40.0f);
            peccancyTitle.hidden=NO;
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(peccancyTitle.frame)+20.0f);
        }
    }
}

- (UIImage *)getResultScreenShot {
    self.shareButton.hidden = YES;
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
    self.shareButton.hidden = NO;
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
    UIView *view = self.contentView;
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
                           [ProgressHUDHandler showHUD];
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
                           
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
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
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                       [ProgressHUDHandler dismissHUD];
                       [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
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

- (void)pushToLocationRemarkVC {
    @autoreleasepool {
        HVLocationRemarkVC *vc = [HVLocationRemarkVC new];
        vc.address = self.address;
        vc.longitude = self.longitude;
        vc.latitude = self.latitude;
        vc.reverseGeoCodeResult = self.reverseGeoCodeResult;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

