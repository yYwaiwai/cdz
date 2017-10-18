//
//  PersonalCenterVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PersonalCenterVC.h"
#import "PersonalCenterTVCell.h"
//#import "PersonalDataVC.h"
#import "AppSetUpVC.h"
#import "MyAddressesVC.h"
#import "MyOrdersVC.h"
#import "MyMaintenanceManagementVC.h"
#import "MYCumulativeScoringVC.h"
#import "MyCarVC.h"
#import "BasicInformationVC.h"
#import "UserBehaviorHandler.h"
#import "UserMemberCenterVC.h"
#import <M13BadgeView/M13BadgeView.h>
#import "MyCarInsuranceVC.h"


@interface PersonalCenterVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *currentMemberTypeIV;

@property (weak, nonatomic) IBOutlet UIButton *memberCenterBtn;

@property (nonatomic, strong) NSArray *menuList;
/// 用户信息
@property (nonatomic, strong) UserInfosDTO *userInfo;
/// 设置列表
@property (nonatomic, strong) NSArray *settingList;
/// 延迟索引路径
@property (nonatomic, weak) UIButton *delayOrderBtn;
/// 延迟索引路径
@property (nonatomic, strong) NSIndexPath *delayIndexPath;
/// 是否登录
@property (nonatomic, assign) BOOL isShowLogin;
/// 是否显示用户详细资料
@property (nonatomic, assign) BOOL isShowUserDetail;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userPortraitIVCenterX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userPortraitIVCenterY;
@property (nonatomic, weak) IBOutlet UIImageView *userPortraitIV;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *creditLabel;

@property (nonatomic, weak) IBOutlet UILabel *userAutosModelLabel;

@property (nonatomic, weak) IBOutlet UIView *orderSectionContainerView;

@property (nonatomic, weak) IBOutlet UIView *repairSectionContainerView;

@property (nonatomic, strong) NSString *shoppingCartCount;

@property (nonatomic, strong) NSString *memberShopCount;

@end

@implementation PersonalCenterVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setAllContainerBorder];
    self.tabBarController.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.extendedLayoutIncludesOpaqueBars = YES;
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = @"";
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.extendedLayoutIncludesOpaqueBars = YES;
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    
    [self.tabBarController.view setNeedsLayout];
    [self.navigationController.view setNeedsLayout];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
    NSLog(@"%@", self.accessToken);
    [self reLoadAllView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.viewWillDisappearShoulPassIt) {
        [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
        self.tabBarController.automaticallyAdjustsScrollViewInsets = YES;
        self.tabBarController.extendedLayoutIncludesOpaqueBars = NO;
        self.navigationController.navigationBar.hidden = NO;
        [self.tabBarController.view setNeedsLayout];
        [self.navigationController.view setNeedsLayout];
    }
    self.viewWillDisappearShoulPassIt = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.userPortraitIVCenterX.constant = 0.7;
        self.userPortraitIVCenterY.constant = 0.7;
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"pcmvc_setting_icon@3x" ofType:@"png"]];
        [self setRightNavButtonWithTitleOrImage:image style:UIBarButtonItemStyleDone target:self action:@selector(pushToAppSetup) titleColor:nil isNeedToSet:YES];
        
        [[UINib nibWithNibName:@"PersonalCenterVC" bundle:nil] instantiateWithOwner:self options:nil];
        self.menuList = @[@{@"title":@"我的购物车", @"class":@"MyShoppingCartVC",
                            @"border":@(UIRectBorderTop|UIRectBorderBottom),
                            @"image":@"pcmvc_my_shopping_cart_icon@3x.png"},
                          
                          @{@"title":@"我的收藏", @"class":@"MyCollectionVC",
                            @"border":@(UIRectBorderBottom),
                            @"image":@"pcmvc_my_collection_icon@3x.png"},
                          
                          @{@"title":@"我的优惠劵", @"class":@"MyCouponVC",
                            @"border":@(UIRectBorderBottom),
                            @"image":@"pcmvc_my_coupon_icon@3x.png"},
                          
                          @{@"title":@"我的案例", @"class":@"MyCaseVC",
                            @"border":@(UIRectBorderBottom),
                            @"image":@"pcmvc_my_case_icon@3x.png"},
                          
                          @{@"title":@"收货地址", @"class":@"MyAddressesVC",
                            @"border":@(UIRectBorderNone),
                            @"image":@"pcmvc_my_address_icon@3x.png"},
                          
                          
                          
                          @{@"title":@"o2o_space", @"height":@10,
                            @"border":@(UIRectBorderTop|UIRectBorderBottom),},
                          @{@"title":@"我的询价列表", @"class":@"MyEnquiryVC",
                            @"border":@(UIRectBorderBottom),
                            @"image":@"pcmvc_my_enquiry_icon@3x.png"},
//      MyAutoInsuranceVC                    MyCarInsuranceVC
                          @{@"title":@"我的保险", @"class":@"MyCarInsuranceVC",
                            @"border":@(UIRectBorderBottom),
                            @"image":@"pcmvc_my_insurance_icon@3x.png"},
                          
                          @{@"title":@"我的E服务", @"class":@"EServiceServiceListVC",
                            @"border":@(UIRectBorderNone),
                            @"image":@"pcmvc_my_e_service_icon@3x.png"},
                          
                          
                          
                          @{@"title":@"o2o_space", @"height":@10,
                            @"border":@(UIRectBorderTop|UIRectBorderBottom),},
                          @{@"title":@"会员商家", @"class":@"MyRepairShopMemberVC",
                            @"border":@(UIRectBorderNone),
                            @"image":@"pcmvc_my_repairshop_member_icon@3x.png",
                            @"moreInfoKey":@"memberShopCount"},
                    
                          @{@"title":@"o2o_space", @"height":@10,
                            @"border":@(UIRectBorderTop|UIRectBorderBottom),},
                          @{@"title":@"问卷调查", @"class":@"CDZAppSurveyVC",
                            @"border":@(UIRectBorderNone),
                            @"image":@"pcmvc_my_questionnaire_survey_icon@3x.png"},
                          @{@"title":@"o2o_space", @"height":@20,
                            @"border":@(UIRectBorderTop|UIRectBorderBottom),},];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"PersonalCenterTVCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        for (int idx=2; idx<6; idx++) {
            UIView *view = [[self.orderSectionContainerView viewWithTag:idx] viewWithTag:10];
            M13BadgeView *badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 14.0, 14.0)];
            badgeView.tag = 11;
            badgeView.text = @"0";
            badgeView.font = [UIFont systemFontOfSize:11.0];
            badgeView.textColor = [UIColor colorWithRed:0.961 green:0.404 blue:0.412 alpha:1.00];
            badgeView.badgeBackgroundColor = CDZColorOfClearColor;
            badgeView.borderColor = badgeView.textColor;
            badgeView.hidesWhenZero = YES;
            badgeView.borderWidth = 1.0f;
            badgeView.alignmentShift = CGSizeMake(-3, 0);
            badgeView.cornerRadius = ceilf(CGRectGetHeight(badgeView.frame)/2.0f);
            badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
            badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
            [view addSubview:badgeView];
            badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
            badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
            badgeView.text = @"0";
        }
    }
}

- (void)setAllContainerBorder {
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 8;
    offset.rightBottomOffset = 8;
    [self.creditLabel.superview.superview setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:CDZColorOfWhite withBroderOffset:offset];

    [self.orderSectionContainerView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [[self.orderSectionContainerView viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    [self.repairSectionContainerView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [[self.repairSectionContainerView viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    [self.userPortraitIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.userPortraitIV.frame)/2.0f];
//
//    [self.eServiceViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
//    
//    [self.advertisingViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
//    
//    [self.partsOtherBtnsViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
//    
//    [self.otherServiceBtnsViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
    
    [self.memberCenterBtn setViewCornerWithRectCorner:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerSize:CGRectGetHeight(self.memberCenterBtn.frame)/2.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reLoadAllView {
    @autoreleasepool {
        
        self.creditLabel.text = @"--";
        self.userNameLabel.text = @"请登录";
        self.userPortraitIV.image = nil;
        self.userAutosModelLabel.text = @"--";
        self.currentMemberTypeIV.hidden = YES;
        if (self.accessToken) {
            self.currentMemberTypeIV.hidden = NO;
               self.currentMemberTypeIV.image = [UserMemberCenterConfig getMemberStateImageByType:UserBehaviorHandler.shareInstance.getUserMemberType wasInReview:NO];
            if (UserBehaviorHandler.shareInstance.pcIndicateInfo.userCreditRemainCount) {
                self.creditLabel.text = UserBehaviorHandler.shareInstance.pcIndicateInfo.userCreditRemainCount;
            }
            
            UserAutosInfoDTO *userAutosData = [DBHandler.shareInstance getUserAutosDetail];
            if (userAutosData&&![userAutosData.seriesName isEqualToString:@""]) {
                self.userAutosModelLabel.text = userAutosData.seriesName;
            }
            UserInfosDTO *userInfo = [DBHandler.shareInstance getUserInfo];
            BOOL userInfoIsSame = (self.userInfo&&userInfo&&
                                   [userInfo.nichen isEqualToString:self.userInfo.nichen]&&
                                   [userInfo.realname isEqualToString:self.userInfo.realname]&&
                                   [userInfo.telphone isEqualToString:self.userInfo.telphone]);
            
            if (userInfoIsSame) {
                if (userInfo.realname&&![userInfo.realname isEqualToString:@""]) {
                    self.userNameLabel.text = userInfo.realname;
                }else if (userInfo.nichen&&![userInfo.nichen isEqualToString:@""]) {
                    self.userNameLabel.text = userInfo.nichen;
                }else {
                    self.userNameLabel.text = userInfo.telphone;
                }
                
                if ([userInfo.portrait isContainsString:@"http"]) {
                    [self.userPortraitIV setImageWithURL:[NSURL URLWithString:userInfo.portrait] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                }
            }else {
                self.userNameLabel.text = @"--";
                [self getUserDetail];
            }
        }
        
        [self updateAllOrderSatatusCount];
        [self.tableView reloadData];
    }
}

- (void)pushToUserDetail {
    @autoreleasepool {
        if (!self.accessToken || !_userInfo) {
            self.isShowUserDetail = YES;
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        
//        PersonalDataVC *vc = [PersonalDataVC new];
//        [self setDefaultNavBackButtonWithoutTitle];
//        [self.tabBarController.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)showLoginView {
    @autoreleasepool {
        [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
    }
}

- (void)updateAllOrderSatatusCount {
    
    for (int idx=2; idx<6; idx++) {
        UIView *view = [[self.orderSectionContainerView viewWithTag:idx] viewWithTag:10];
        M13BadgeView *badgeView = (M13BadgeView *)[view viewWithTag:11];
        NSString *count = @"0";
        if (self.accessToken) {
            if (idx==2) {
                count = UserBehaviorHandler.shareInstance.pcIndicateInfo.orderUnpayCount;
            }else if (idx==3) {
                count = UserBehaviorHandler.shareInstance.pcIndicateInfo.orderDeliveringCount;
            }else if (idx==4) {
                count = UserBehaviorHandler.shareInstance.pcIndicateInfo.orderNotInstallCount;
            }else if (idx==5) {
                count = UserBehaviorHandler.shareInstance.pcIndicateInfo.orderUncommentCount;
            }
        }
        if (!count) count = @"0";
        badgeView.text = count;
    }
}

- (NSString *)memberShopCount {
    NSString *memberShopCount = UserBehaviorHandler.shareInstance.pcIndicateInfo.joinedMemberShopCount;
    NSString *finalString = @"";
    if (memberShopCount&&memberShopCount.integerValue>0) {
        finalString = [NSString stringWithFormat:@"%d家", memberShopCount.integerValue];
    }
    return finalString;
}

- (IBAction)pushToMemberCenterVC {
    @autoreleasepool {
        if (!self.accessToken) {
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        self.viewWillDisappearShoulPassIt = YES;
        UserMemberCenterVC *vc = [UserMemberCenterVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToAppSetup {
    @autoreleasepool {
        self.viewWillDisappearShoulPassIt = YES;
        AppSetUpVC *vc = [AppSetUpVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToCreditVC {
    @autoreleasepool {
        if (!self.accessToken) {
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        self.viewWillDisappearShoulPassIt = YES;
        MYCumulativeScoringVC *vc = [MYCumulativeScoringVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToMyAutosInfo {
    @autoreleasepool {
        if (!self.accessToken) {
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        self.viewWillDisappearShoulPassIt = YES;
        MyCarVC *vc = [MyCarVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToUserInfo {
    @autoreleasepool {
        if (!self.accessToken) {
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        self.viewWillDisappearShoulPassIt = YES;
        BasicInformationVC *vc = [BasicInformationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToOrderManagement:(UIControl *)sender {
    @autoreleasepool {
        if (!self.accessToken) {
            _isShowLogin = YES;
            [self showLoginView];
            return;
        }
        self.viewWillDisappearShoulPassIt = YES;
        MyOrdersVC *vc = [MyOrdersVC new];
        vc.stateNumber = @(sender.tag-1);
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToRepairManagement:(UIControl *)sender {
    @autoreleasepool {
        self.viewWillDisappearShoulPassIt = YES;
        MyMaintenanceManagementVC *vc = [MyMaintenanceManagementVC new];
        vc.currentStatusType = sender.tag;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *configDetail = self.menuList[indexPath.row];
    if ([configDetail[@"title"] isEqualToString:@"o2o_space"]) {
//        NSLog(@"%f", [configDetail[@"height"] floatValue]);
        return [configDetail[@"height"] floatValue];
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonalCenterTVCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.rectBorder = UIRectBorderNone;
    NSDictionary *configDetail = self.menuList[indexPath.row];
    BOOL isSpaceOnly = [configDetail[@"title"] isEqualToString:@"o2o_space"];
    cell.isSpaceOnly = isSpaceOnly;
    cell.rectBorder = [configDetail[@"border"] unsignedIntegerValue];
    cell.moreInfoLabel.text = @"";
    if (!isSpaceOnly) {
        NSString *valueKey = configDetail[@"moreInfoKey"];
        if (valueKey&&![valueKey isEqualToString:@""]) {
            NSLog(@"%@", [self valueForKey:valueKey]);
            cell.moreInfoLabel.text = [self valueForKey:valueKey];
        }
        cell.iconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:configDetail[@"image"] ofType:nil]];
        cell.titleLabel.text = configDetail[@"title"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.viewWillDisappearShoulPassIt = YES;
    NSDictionary *configDetail = self.menuList[indexPath.row];
    BOOL isSpaceOnly = [configDetail[@"title"] isEqualToString:@"o2o_space"];
    if (!isSpaceOnly) {
        if (!self.accessToken) {
            _isShowLogin = YES;
            if (!_delayIndexPath) {
                self.delayIndexPath = indexPath;
            }
            [self showLoginView];
            return;
        }
        id vc = nil;
        NSDictionary *detail = self.menuList[indexPath.row];
        NSString *class = detail[@"class"];
        if (!class||[class isEqualToString:@""]) {
            return;
        }
        vc = [NSClassFromString(class) new];
        if (vc) {
            self.delayIndexPath = nil;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.tabBarController.navigationController pushViewController:vc animated:YES];
        }

    }
}

#pragma mark- Access User Info Section
- (void)getUserDetail {
    if (!self.accessToken) {
        if(_userInfo){
            self.userInfo = nil;
        }
        [self reLoadAllView];
        return;
    }
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetPersonalInformationWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            return;
        }
        self.userInfo = [UserInfosDTO new];
        [_userInfo processDataToObjectWithData:[responseObject objectForKey:CDZKeyOfResultKey] isFromDB:NO];
        [self reLoadAllView];
        if (self.isShowUserDetail) {
            [self pushToUserDetail];
        }
    }
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    [self reLoadAllView];

}
@end
