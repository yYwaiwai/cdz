//
//  ViolationRankingVC.m
//  cdzer
//
//  Created by KEns0n on 1/5/16.
//  Copyright © 2016 CDZER. All rights reserved.
//  违章排行榜VC

#import "ViolationRankingVC.h"
#import "InsetsLabel.h"
#import "VRUVTableViewCell.h"
#import "VRLVTableViewCell.h"
#import "TrafficViolationDetailVC.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>

@interface ViolationRankingVC ()<UITableViewDataSource, UITableViewDelegate>
/// 所在视图排名的类型
@property (nonatomic, assign) BOOL isSecondTypeRanking;
/// 所展示的列表tableView
@property (nonatomic, strong) UITableView *tableView;
/// 杀手榜名称
@property (nonatomic, strong) UIButton *uvRankingListBtn;
/// 神坑榜名称
@property (nonatomic, strong) UIButton *lvRankingListBtn;
/// 数据列表
@property (nonatomic, strong) NSMutableArray *rankingList;
/// 空的消息
@property (nonatomic, strong) NSString *emtpyMessage;

@property (nonatomic, strong) UIBarButtonItem *rightButton;
@end

@implementation ViolationRankingVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"违章排行榜";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.rankingList.count==0) {
        [self handlerankingList:_uvRankingListBtn];
    }
    self.tabBarController.title = self.title;
    self.tabBarController.navigationItem.rightBarButtonItem = _isSecondTypeRanking?_rightButton:nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.rankingList = [@[] mutableCopy];
        self.emtpyMessage = @"";
        UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"share" type:FMImageTypeOfPNG needToUpdate:YES];
        self.rightButton = [self setRightNavButtonWithTitleOrImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showShareSDKView) titleColor:nil isNeedToSet:NO];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
        
        self.uvRankingListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _uvRankingListBtn.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame)/2.0f, 40.0f);
        _uvRankingListBtn.enabled = NO;
        _uvRankingListBtn.backgroundColor = CDZColorOfWhite;
        _uvRankingListBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17, NO);
        [_uvRankingListBtn setTitle:@"杀手榜" forState:UIControlStateNormal];
        [_uvRankingListBtn setTitleColor:CDZColorOfDefaultColor forState:UIControlStateDisabled];
        [_uvRankingListBtn setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [_uvRankingListBtn addTarget:self action:@selector(handlerankingList:) forControlEvents:UIControlEventTouchUpInside];
        [_uvRankingListBtn setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderRight borderSize:0.5 withColor:CDZColorOfDeepGray withBroderOffset:nil];
        [self.contentView addSubview:_uvRankingListBtn];
        
        self.lvRankingListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _lvRankingListBtn.backgroundColor = CDZColorOfWhite;
        _lvRankingListBtn.frame = CGRectMake(CGRectGetMaxX(_uvRankingListBtn.frame), 0.0f, CGRectGetWidth(self.contentView.frame)/2.0f, 40.0f);
        _lvRankingListBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17, NO);
        [_lvRankingListBtn setTitle:@"神坑榜" forState:UIControlStateNormal];
        [_lvRankingListBtn setTitleColor:CDZColorOfDefaultColor forState:UIControlStateDisabled];
        [_lvRankingListBtn setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [_lvRankingListBtn addTarget:self action:@selector(handlerankingList:) forControlEvents:UIControlEventTouchUpInside];
        [_lvRankingListBtn setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderLeft borderSize:0.5 withColor:CDZColorOfDeepGray withBroderOffset:nil];
        [self.contentView addSubview:_lvRankingListBtn];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_uvRankingListBtn.frame), CGRectGetWidth(self.contentView.frame),
                                                                       CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_uvRankingListBtn.frame))];
        _tableView.backgroundColor = self.contentView.backgroundColor;
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_tableView];
        
    }
}

- (void)handlerankingList:(UIButton *)button {
    _uvRankingListBtn.enabled = YES;
    _lvRankingListBtn.enabled = YES;
    button.enabled = NO;
    if (button==_uvRankingListBtn) {
        self.isSecondTypeRanking = NO;
        [self getUserViolationRankingList];
    }
    if (button==_lvRankingListBtn) {
        self.isSecondTypeRanking = YES;
        [self getLocationViolationRankingList];
    }
    self.tabBarController.navigationItem.rightBarButtonItem = _isSecondTypeRanking?_rightButton:nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  UITableViewDelegate 、 UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_rankingList.count==0) return 1;
    return _rankingList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident2 = @"cell2";
    if (_isSecondTypeRanking) {
        VRLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident2];
        if (!cell) {
            cell = [[VRLVTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        if (_rankingList.count==0) {
            [cell updateUIData:nil withWarningLabel:self.emtpyMessage fullSzie:@(CGRectGetHeight(tableView.frame))];
        }else {
            NSDictionary *detail = _rankingList[indexPath.row];
            [cell updateUIData:detail withWarningLabel:self.emtpyMessage fullSzie:nil];
        }
        return cell;
    }
    VRUVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[VRUVTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (_rankingList.count==0) {
        [cell updateUIData:nil withWarningLabel:self.emtpyMessage fullSzie:@(CGRectGetHeight(tableView.frame))];
    }else {
        NSDictionary *detail = _rankingList[indexPath.row];
        [cell updateUIData:detail withWarningLabel:self.emtpyMessage fullSzie:nil];
    }
    // Configure the cell...
    
    return cell;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
//at least iOS 8 code here
#else
//lower than iOS 8 code here
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_rankingList.count==0) {
        return CGRectGetHeight(tableView.frame);
    }
    return 100;
}
#endif

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_rankingList.count==0) {
        return CGRectGetHeight(tableView.frame);
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (_rankingList.count>0&&_isSecondTypeRanking) {
            NSString *address = [_rankingList[indexPath.row] objectForKey:@"place_name"];
            [self getHVDetailDataWithAddress:address];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)getHVDetailDataWithAddress:(NSString *)address {
    if (!address||[address isEqualToString:@""]) {
        return ;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetViolationDetailWithBlacksiteAddress:address success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        TrafficViolationDetailVC *vc = TrafficViolationDetailVC.new;
        vc.tvDetail = responseObject[CDZKeyOfResultKey];
        vc.address = address;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)getUserViolationRankingList {
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    self.emtpyMessage = @"";
    [[APIsConnection shareConnection] personalCenterAPIsGetUserHighViolationListWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            self.emtpyMessage = @"数据加载失败！";

            [self.rankingList removeAllObjects];
            [self.tableView reloadData];
//            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.rankingList removeAllObjects];
        [self.rankingList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        NSLog(@"%@",error.domain);
        [self.rankingList removeAllObjects];
        [self.tableView reloadData];
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

- (void)getLocationViolationRankingList {
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    self.emtpyMessage = @"";
    [[APIsConnection shareConnection] personalCenterAPIsGetHighViolationLocationListWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            self.emtpyMessage = @"数据加载失败！";
            [self.rankingList removeAllObjects];
            [self.tableView reloadData];
            //            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.rankingList removeAllObjects];
        [self.rankingList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        NSLog(@"%@",error.domain);
        [self.rankingList removeAllObjects];
        [self.tableView reloadData];
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
