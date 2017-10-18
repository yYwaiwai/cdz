//
//  ShopNServiceDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopNServiceDetailVC.h"
#import "AdvertisingScrollView.h"
#import "SNSDCouponView.h"
#import "SNSDShopServiceView.h"
#import "HCSStarRatingView.h"
#import "ShopNServiceMoreDetailVC.h"
#import "ShopMechanicSearchListVC.h"
#import "ShopNItemPartsCommentListVC.h"
#import "RepairShopMembershipTnCVC.h"
#import "RepairServiceItemImage.h"
#import "RepairAppiontmentVC.h"
#import "RepairServiceItemSelectionVC.h"
#import "SpecProductCenterVC.h"
#import "MaintenanceExpressVC.h"

@interface ShopNServiceDetailVC ()
@property (nonatomic, weak) IBOutlet AdvertisingScrollView *shopAdvertisingScrollView;

@property (nonatomic, weak) IBOutlet UILabel *shopNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *shopTypeLabel;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *serviceTypeTrailingConstraint;

@property (nonatomic, weak) IBOutlet UILabel *rightBusinessHoursLabel;
@property (nonatomic, weak) IBOutlet UILabel *leftBusinessHoursLabel;

@property (nonatomic, weak) IBOutlet UILabel *nonMemberPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *memberPriceLabel;
@property (nonatomic, weak) IBOutlet UIView *memberPriceContainerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *priceContainerViewTopConstraint;

@property (nonatomic, weak) IBOutlet UILabel *totalCollectionCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalSalesCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *shopAddressLabel;
@property (nonatomic, strong) NSString *shopTelNumber;
@property (nonatomic, weak) IBOutlet SNSDCouponView *couponView;

//主修区域
@property (nonatomic, weak) IBOutlet UIImageView *brandLogoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *serviceIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *serviceNameLabel;
@property (nonatomic, strong) IBOutlet UIView *specServiceInfoContainer;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *serviceInfoHeightConstraint;

//评价区域
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;
@property (nonatomic, weak) IBOutlet HCSStarRatingView *commentStarRatingView;
@property (nonatomic, weak) IBOutlet UILabel *commentRatingCountLabel;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *productionCenterTopConstraint;
@property (nonatomic, weak) IBOutlet UIView *shopInfoContainerView;

@property (nonatomic, weak) IBOutlet SNSDShopServiceView *shopServiceView;

@property (nonatomic, strong) NSDictionary *shopDetail;

@property (nonatomic) BOOL isSpecServiceShop;
@property (nonatomic) BOOL noNeedRecoverNavBarSetting;

@property (nonatomic, weak) IBOutlet UIButton *backIndicatorBtn;

@property (nonatomic, weak) IBOutlet UIButton *collectionBtnOnLeft;
@property (nonatomic, weak) IBOutlet UIButton *memberJoinBtn;

@property (nonatomic, weak) IBOutlet UIButton *collectionBtnOnRight;

@property (nonatomic, weak) IBOutlet UIView *appointmentBtnContainView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *scrollViewContentBottomOffsetConstraint;

@property (weak, nonatomic) IBOutlet UIButton *submitAppointmentButton;

@end

@implementation ShopNServiceDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = NO;
    self.title = @"";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationController.navigationBar.translucent = YES;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    UIColor *barBKC = CDZColorOfWhite;
    UIColor *barForeC = CDZColorOfClearColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:barBKC};
    self.navigationController.navigationBar.barTintColor = barForeC;
    self.navigationController.navigationBar.backgroundColor = barForeC;
    self.navigationController.navigationBar.tintColor = barBKC;
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
    if (self.shouldReloadData) {
        self.shouldReloadData = NO;
        [self getShopOrServiceDetail];
    }
    [self.shopAdvertisingScrollView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (!self.noNeedRecoverNavBarSetting) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.navigationController.navigationBar.translucent = NO;
        [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        UIColor *barBKC = [UIColor colorWithHexString:@"FAFAFA"];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"]};
        self.navigationController.navigationBar.barTintColor = barBKC;
        self.navigationController.navigationBar.backgroundColor = barBKC;
        self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"323232"];
        [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
    }
    self.noNeedRecoverNavBarSetting = NO;
    [self.shopAdvertisingScrollView viewWillDisappear];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    BorderOffsetObject *shopAddressBorderOffset = [BorderOffsetObject new];
    shopAddressBorderOffset.upperLeftOffset = 12.0f;
    [self.shopAddressLabel.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:shopAddressBorderOffset];
    
    
    [self.brandLogoImageView.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.serviceNameLabel.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.specServiceInfoContainer setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.shopInfoContainerView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    for (int i=1; i<5; i++) {
        [[self.shopInfoContainerView viewWithTag:i] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    }

    [[self.appointmentBtnContainView viewWithTag:1] setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"BackIndicatorDefault@3x" ofType:@"png"]];
        [self.backIndicatorBtn setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.backIndicatorBtn.tintColor = CDZColorOfWhite;
        [self getShopOrServiceDetail];
        @weakify(self);
        self.couponView.reloadBlock = ^{
            @strongify(self);
            [self getShopOrServiceDetail];
        };
        
        self.appointmentBtnContainView.hidden = self.wasSpecItemService;
        self.scrollViewContentBottomOffsetConstraint.constant = (12+(self.wasSpecItemService?0:CGRectGetHeight(self.appointmentBtnContainView.frame)));
    }
}

- (void)initializationUI {
    @autoreleasepool {
    }
}

- (void)updateUIData {
    BOOL isPhone5OrBlowWidth = (SCREEN_WIDTH==320);
    [self.shopAdvertisingScrollView setupDataSourcesArray:[self.shopDetail[@"shop_img"] valueForKey:@"imgurl"]];
    
    NSString *shopTypeString = self.shopDetail[@"wxs_kind"];
    self.shopNameLabel.text = self.shopDetail[@"wxs_name"];
    self.shopTypeLabel.text = shopTypeString;
    self.isSpecServiceShop = [shopTypeString isEqualToString:@"专修店"];
    
    if ([shopTypeString isEqualToString:@"专修店"]) {
        self.shopTypeLabel.backgroundColor = [UIColor colorWithHexString:@"F8AF30"];
        self.shopTypeLabel.text = @"专 修 店";
    }else if ([shopTypeString isEqualToString:@"品牌店"]) {
        self.shopTypeLabel.backgroundColor = [UIColor colorWithHexString:@"49C7F5"];
        self.shopTypeLabel.text = @"品 牌 店";
    }
    
    self.memberPriceContainerView.hidden = self.wasSpecItemService;
    self.priceContainerViewTopConstraint.constant = self.wasSpecItemService?-CGRectGetHeight(self.memberPriceContainerView.frame):8;
    if (self.wasSpecItemService) {
        self.memberPriceLabel.text = @"0";
        self.nonMemberPriceLabel.text = @"0";
    }else {
        self.memberPriceLabel.text = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"member_price"]];
        self.nonMemberPriceLabel.text = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"public_price"]];
    }
    
    self.leftBusinessHoursLabel.text = @"";
    self.rightBusinessHoursLabel.text = @"";
    NSString *businessHours = [self.shopDetail[@"service_time"] stringByReplacingOccurrencesOfString:@"——" withString:@"-"];
    if (isPhone5OrBlowWidth||self.wasSpecItemService) {
        self.leftBusinessHoursLabel.text = businessHours;
    }else {
        self.rightBusinessHoursLabel.text = businessHours;
    }
    
    self.shopAddressLabel.text = self.shopDetail[@"wxs_address"];
    self.shopTelNumber = self.shopDetail[@"wxs_tel"];
    
    //shopTypeLabel 尾部距离约束
    self.serviceTypeTrailingConstraint.constant = isPhone5OrBlowWidth?12:100;
    
    self.couponView.couponList = self.shopDetail[@"prefer_info"];
    NSMutableArray *itemList = [NSMutableArray arrayWithArray:self.shopDetail[@"repair_item"]];
    [itemList addObjectsFromArray:self.shopDetail[@"maintain_item"]];
    self.shopServiceView.repairItemList = itemList;
    [self updateBrandInfoNShopInfo];
    
    BOOL isCollected = [[SupportingClass verifyAndConvertDataToString:self.shopDetail[@"is_favorite"]] isEqualToString:@"yes"];
    BOOL isMember = [[SupportingClass verifyAndConvertDataToString:self.shopDetail[@"is_member"]] isEqualToString:@"yes"];
    self.collectionBtnOnRight.selected = isCollected;
    self.collectionBtnOnLeft.selected = isCollected;
    self.memberJoinBtn.selected = isMember;
    self.collectionBtnOnRight.hidden = YES;//!self.wasSpecItemService;
    self.collectionBtnOnLeft.hidden = NO;//self.wasSpecItemService;
    self.memberJoinBtn.hidden = NO;//self.wasSpecItemService;
    if ([self.shopDetail[@"major_item"] isContainsString:@"保养"]) {
        [self.submitAppointmentButton setTitle:@"立即保养" forState:UIControlStateNormal];
    }else{
        [self.submitAppointmentButton setTitle:@"立即预约" forState:UIControlStateNormal];
    }
}

- (void)updateBrandInfoNShopInfo {
    NSString *shopTypeString = self.shopDetail[@"wxs_kind"];
    self.isSpecServiceShop = [shopTypeString isEqualToString:@"专修店"];
    self.serviceInfoHeightConstraint.constant = self.isSpecServiceShop?78:48;
    self.specServiceInfoContainer.hidden = !self.isSpecServiceShop;
    if (self.isSpecServiceShop) {
        self.serviceNameLabel.text = self.shopDetail[@"major_item"];
        self.serviceIconImageView.image = [RepairServiceItemImage specRepairIcon:self.serviceNameLabel.text wasSelected:NO];
    }else {
        NSString *brandLogoURL = self.shopDetail[@"major_brand"];
        if ([brandLogoURL isContainsString:@"http"]) {
            [self.brandLogoImageView setImageWithURL:[NSURL URLWithString:brandLogoURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    
    UIView *productionCenterView = [self.shopInfoContainerView viewWithTag:4];
    productionCenterView.hidden = !self.wasSpecItemService;
    self.productionCenterTopConstraint.constant = (self.wasSpecItemService?0:-CGRectGetHeight(productionCenterView.frame));
    
    self.commentCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"wxs_comment_len"]];
    NSString *ratingValue = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"wxs_star"]];
    self.commentStarRatingView.value = ratingValue.floatValue;
    self.commentRatingCountLabel.text = ratingValue ;
}

- (IBAction)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showMoreShopDetail {
    @autoreleasepool {
        if (self.shopDetail.count==0||!self.shopDetail) return;
        self.noNeedRecoverNavBarSetting = YES;
        ShopNServiceMoreDetailVC *vc = [ShopNServiceMoreDetailVC new];
        vc.shopDetail = self.shopDetail;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)showUserComment {
    @autoreleasepool {
        ShopNItemPartsCommentListVC *vc = [ShopNItemPartsCommentListVC new];
        vc.commentTypeID = self.shopOrServiceID;
        vc.commentType = SNIPCLCommentTypeOfShop;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)showTechnicianList {
    if (self.shopDetail.count==0||!self.shopDetail) return;
    ShopMechanicSearchListVC *vc = [ShopMechanicSearchListVC new];
    vc.repairShopID = self.shopOrServiceID;
    vc.fromStr=@"店铺详情";
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showProductionCenter {
    @autoreleasepool {
        SpecProductCenterVC *vc = [SpecProductCenterVC new];
        vc.shopOrServiceID = self.shopOrServiceID;
        NSString *majorService = self.shopDetail[@"major_item"];
        SNSSLVFItemBrandType itemBrandType = SNSSLVFItemBrandTypeOfTire;
        if ([majorService isEqualToString:@"轮胎"]) {
            itemBrandType = SNSSLVFItemBrandTypeOfTire;
        }
        if ([majorService isEqualToString:@"玻璃"]) {
            itemBrandType = SNSSLVFItemBrandTypeOfWindshield;
        }
        if ([majorService isEqualToString:@"电瓶"]) {
            itemBrandType = SNSSLVFItemBrandTypeOfStorageBattery;
        }
        vc.itemBrandType = itemBrandType;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (IBAction)dailupTheTel {
    if (self.shopTelNumber&&![self.shopTelNumber isEqualToString:@""]) {
        [SupportingClass makeACall:self.shopTelNumber andContents:[@"系统将会拨打以下号码：\n" stringByAppendingString:self.shopTelNumber] withTitle:@"商家电话"];
    }
}

- (IBAction)submitAppointment {
    @autoreleasepool {
        if ([self.shopDetail[@"major_item"] isContainsString:@"保养"]) {
            MaintenanceExpressVC *vc = [MaintenanceExpressVC new];
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            if (self.isSpecServiceShop) {
                RepairAppiontmentVC *vc = [RepairAppiontmentVC new];
                vc.shopDetail = self.shopDetail;
                vc.isSpecServiceShop = self.isSpecServiceShop;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                RepairServiceItemSelectionVC *vc = [RepairServiceItemSelectionVC new];
                vc.shopDetail = self.shopDetail;
                vc.isSpecServiceShop = self.isSpecServiceShop;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (void)setReactiveRules {
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    [self getShopOrServiceDetail];
}

- (void)getShopOrServiceDetail {
    if (!self.shopOrServiceID||[self.shopOrServiceID isEqualToString:@""]) {
        NSLog(@"Missing shopOrServiceID");
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairShopOrServiceDetailWithAccessToken:self.accessToken shopOrServiceID:self.shopOrServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        [ProgressHUDHandler dismissHUD];
        self.shopDetail = responseObject[CDZKeyOfResultKey];
        [self updateUIData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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

- (IBAction)postChangeShopCollectionStatus:(UIButton *)sender {
    if (!self.accessToken) {
        [SupportingClass showAlertViewWithTitle:nil message:@"收藏店铺前请先登录" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
                    
                }];
            }
        }];
        return;
    }
    
    
    NSString *shopID = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"id"]];
    
    if (!shopID||[shopID isEqualToString:@""]) {
        NSLog(@"Missing shopOrServiceID");
        return;
    }
    @weakify(self);
    BOOL selected = sender.selected;
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsUpdateShopCollectionStatusWithAccessToken:self.accessToken shopID:shopID cancelShopCollection:selected success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
            self.collectionBtnOnLeft.selected = selected;
            self.collectionBtnOnRight.selected = selected;
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        [SupportingClass showAlertViewWithTitle:@"" message:!selected?@"收藏成功！":@"收藏取消！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        [ProgressHUDHandler dismissHUD];
        self.collectionBtnOnLeft.selected = !selected;
        self.collectionBtnOnRight.selected = !selected;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        self.collectionBtnOnLeft.selected = selected;
        self.collectionBtnOnRight.selected = selected;
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

- (IBAction)showTNCVC:(UIButton *)sender {
    if (!self.accessToken) {
        [SupportingClass showAlertViewWithTitle:nil message:@"加入前请先登录" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
                    
                }];
            }
        }];
        return;
    }
    if (sender.selected) {
        [SupportingClass showAlertViewWithTitle:nil message:@"你已加入会员" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    @autoreleasepool {
        RepairShopMembershipTnCVC *vc = [RepairShopMembershipTnCVC new];
        @weakify(self);
        vc.successBlock = ^(){
            @strongify(self);
            self.memberJoinBtn.selected = YES;
        };
        NSString *urlString = [kTNCURLPrefix stringByAppendingString:@"add_merber.html"];
        vc.url = [NSURL URLWithString:urlString];
        vc.shopID = self.shopDetail[@"id"];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
