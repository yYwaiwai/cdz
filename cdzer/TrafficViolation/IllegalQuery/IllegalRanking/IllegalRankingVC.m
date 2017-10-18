//
//  IllegalRankingVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "IllegalRankingVC.h"
#import "KillerListCell.h"
#import "SinkholeListCell.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>

@interface IllegalRankingVC ()<UITableViewDelegate,UITableViewDataSource>
/// 杀手榜名称
@property (weak, nonatomic) IBOutlet UIControl *uvRankingListControl;

@property (weak, nonatomic) IBOutlet UILabel *uvRankingListLabel;
/// 天坑榜名称
@property (weak, nonatomic) IBOutlet UIControl *lvRankingListControl;

@property (weak, nonatomic) IBOutlet UILabel *lvRankingListLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 数据列表
@property (nonatomic, strong) NSMutableArray *rankingList;

@property (nonatomic, assign) BOOL type;

@property (nonatomic, strong) UIBarButtonItem *rightButton;

@end

@implementation IllegalRankingVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = self.rightButton;
    if (self.rankingList.count==0) {
        [self handlerankingList:self.uvRankingListControl];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tabBarController.title=@"违章排行";
    
    [self componentSetting];
    [self initializationUI];
}


- (void)initializationUI {
    @autoreleasepool {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = self.view.backgroundColor;
        UINib * killNib = [UINib nibWithNibName:@"KillerListCell" bundle:nil];
        [self.tableView registerNib:killNib forCellReuseIdentifier:@"killCell"];
        UINib * nib = [UINib nibWithNibName:@"SinkholeListCell" bundle:nil];
        
            [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.rankingList = [@[] mutableCopy];
        UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"weizhangxiangqing-share@3x" type:FMImageTypeOfPNG needToUpdate:YES];
        self.rightButton = [self setRightNavButtonWithTitleOrImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showShareSDKView) titleColor:nil isNeedToSet:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.type==YES) {
        SinkholeListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        if (_rankingList.count!=0) {
            
            NSDictionary *detail = _rankingList[indexPath.row];
            [cell updateUIData:detail];
        }
        return cell;
    }else{
        KillerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"killCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        if (_rankingList.count!=0&&self.type==NO) {
            
            NSDictionary *detail = _rankingList[indexPath.row];
            [cell updateUIData:detail];
        }
        return cell;
    }
    
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.self.rankingList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)handlerankingList:(UIControl *)sender {
    [self removewAllhandleControlEdges];
    if (sender.tag==1) {
        [self getUserViolationRankingList];
        self.type=NO;
        [self.uvRankingListLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"f8af30" alpha:1.0] withBroderOffset:nil];
        self.uvRankingListLabel.textColor=[UIColor colorWithHexString:@"f8af30" alpha:1.0];
    }
    if (sender.tag==2) {
        [self getLocationViolationRankingList];
        self.type=YES;
        [self.lvRankingListLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"f8af30" alpha:1.0] withBroderOffset:nil];
        self.lvRankingListLabel.textColor=[UIColor colorWithHexString:@"f8af30" alpha:1.0];
    }
}

- (void)removewAllhandleControlEdges{
    [self.uvRankingListLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.lvRankingListLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    self.uvRankingListLabel.textColor=[UIColor colorWithHexString:@"646464" alpha:1.0];
    self.lvRankingListLabel.textColor=[UIColor colorWithHexString:@"646464" alpha:1.0];
}


- (void)getUserViolationRankingList {
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
//    self.emtpyMessage = @"";
    [[APIsConnection shareConnection] personalCenterAPIsGetUserHighViolationListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@----%@",message,operation.currentRequest);
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
//            self.emtpyMessage = @"数据加载失败！";
            
            [self.rankingList removeAllObjects];
            [self.tableView reloadData];
            //            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.rankingList removeAllObjects];
        [self.rankingList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
//    self.emtpyMessage = @"";
    [[APIsConnection shareConnection] personalCenterAPIsGetHighViolationLocationListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@----%@",message,operation.currentRequest);
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
//            self.emtpyMessage = @"数据加载失败！";
            [self.rankingList removeAllObjects];
            [self.tableView reloadData];
            //            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.rankingList removeAllObjects];
        [self.rankingList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
