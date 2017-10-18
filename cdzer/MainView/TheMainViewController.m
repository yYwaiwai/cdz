//
//  TheMainViewController.m
//  cdzer
//
//  Created by KEns0nLau on 6/15/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "TheMainViewController.h"
#import "MainViewTopViewComponent.h"
#import "MainViewEServiceViewComponent.h"
#import "MPAdvertisingView.h"
#import "MainViewGPSButtonComponent.h"
#import "MainViewEDRButtonComponent.h"
#import "DBHandler.h"
#import <SDWebImage/UIImage+GIF.h>

#import "FindAccessoriesVC.h"
#import "IllegalQueryMainVC.h"
#import "MyAutoInsuranceApplyFormVC.h"
#import "ShopNServiceSearchListVC.h"
#import "SelfDiagnosisModuleVC.h"
#import "EServiceMainMapVC.h"
#import "EServiceServiceListVC.h"
#import "MaintenanceExpressVC.h"
#import "ObtainCaseVC.h"



#import "MyCarInsuranceVC.h"
#import "FillInInformationVC.h"


@interface TheMainViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIView *topViewComponentContainer;

@property (nonatomic, strong) IBOutlet MainViewTopViewComponent *topViewComponent;

@property (nonatomic, weak) IBOutlet UIView *repairBtnsViewComponentContainer;

@property (nonatomic, weak) IBOutlet UIView *eServiceViewComponentContainer;

@property (nonatomic, strong) IBOutlet MainViewEServiceViewComponent *eServiceViewComponent;

@property (nonatomic, weak) IBOutlet UIView *advertisingViewComponentContainer;

@property (nonatomic, weak) IBOutlet UIView *partsOtherBtnsViewComponentContainer;

@property (nonatomic, weak) IBOutlet UIView *otherServiceBtnsViewComponentContainer;

@property (nonatomic, strong) IBOutlet MPAdvertisingView *advertSrollView;

@property (nonatomic, strong) IBOutlet MainViewGPSButtonComponent *GPSButton;

@property (nonatomic, strong) IBOutlet MainViewEDRButtonComponent *EDRButton;

@property (nonatomic, strong) NSArray <NSDictionary *> *specShopServiceTypeList;


@end

@implementation TheMainViewController

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getSpecServiceList];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    [self.advertSrollView viewWillAppear];
    [self.topViewComponent viewWillAppear];
    
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
    [self.advertSrollView viewWillDisappear];
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
        
        self.viewWillDisappearShoulPassIt = YES;
        self.loginAfterShouldPopToRoot = NO;
        
        [[UINib nibWithNibName:@"TheMainViewController" bundle:nil] instantiateWithOwner:self options:nil];
        [[UINib nibWithNibName:@"MainVCComponent" bundle:nil] instantiateWithOwner:self options:nil];
        [[UINib nibWithNibName:@"MPAdvertisingView" bundle:nil] instantiateWithOwner:self options:nil];
        [self setAllContainerBorder];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        [self.topViewComponentContainer addSubview:self.topViewComponent];
        self.topViewComponent.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.topViewComponent.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        [self.eServiceViewComponentContainer addSubview:self.eServiceViewComponent];
        self.eServiceViewComponent.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.eServiceViewComponent.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        self.advertSrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.advertSrollView.frame = self.advertisingViewComponentContainer.bounds;
        [self.advertisingViewComponentContainer addSubview:self.advertSrollView];
        NSLayoutConstraint * advertSrollViewTopMargin = [NSLayoutConstraint constraintWithItem:self.advertSrollView
                                                                                     attribute:NSLayoutAttributeTop
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.advertisingViewComponentContainer
                                                                                     attribute:NSLayoutAttributeTop
                                                                                    multiplier:1
                                                                                      constant:0];
        
        
        NSLayoutConstraint *advertSrollViewBottomMargin = [NSLayoutConstraint constraintWithItem:self.advertisingViewComponentContainer
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.advertSrollView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1
                                                                                        constant:0];
        
        
        NSLayoutConstraint *advertSrollViewLeftMargin = [NSLayoutConstraint constraintWithItem:self.advertSrollView
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.advertisingViewComponentContainer
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1
                                                                                      constant:0];
        
        NSLayoutConstraint *advertSrollViewRightMargin = [NSLayoutConstraint constraintWithItem:self.advertisingViewComponentContainer
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.advertSrollView
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1
                                                                                       constant:0];
        [self.advertisingViewComponentContainer addConstraints:@[advertSrollViewTopMargin,
                                                                 advertSrollViewBottomMargin,
                                                                 advertSrollViewLeftMargin,
                                                                 advertSrollViewRightMargin]];
        
        CGFloat screenWidth = SCREEN_WIDTH;
        CGFloat screenHeight = SCREEN_HEIGHT;
        if (UIApplication.sharedApplication.statusBarOrientation!=UIInterfaceOrientationPortrait) {
            screenWidth = SCREEN_HEIGHT;
            screenHeight = SCREEN_WIDTH;
        }
        [self.EDRButton addSelfToSuperView:self.view];
        CGRect EDRButtonFrame = self.EDRButton.frame;
        EDRButtonFrame.origin.x = screenWidth-EDRButtonFrame.size.width;
        EDRButtonFrame.origin.y = screenHeight-52-EDRButtonFrame.size.height;
        self.EDRButton.frame = EDRButtonFrame;
        
        
        [self.GPSButton addSelfToSuperView:self.view];
        CGRect GPSButtonFrame = self.GPSButton.frame;
        GPSButtonFrame.origin.x = screenWidth-GPSButtonFrame.size.width;
        GPSButtonFrame.origin.y = screenHeight-52-GPSButtonFrame.size.height-EDRButtonFrame.size.height;
        self.GPSButton.frame = GPSButtonFrame;
    }
}

- (void)setAllContainerBorder {
    
    [self.topViewComponentContainer setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    [self.repairBtnsViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
    
    [self.eServiceViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];

    [self.advertisingViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
    
    [self.partsOtherBtnsViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
    
    [self.otherServiceBtnsViewComponentContainer setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//配件
- (IBAction)pushToPartsSearchVC {
    @autoreleasepool {
        FindAccessoriesVC *vc = [FindAccessoriesVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//违章
- (IBAction)pushToTrafficViolationMainVC {
    @autoreleasepool {
        
        IllegalQueryMainVC *vc = [IllegalQueryMainVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//保险
- (IBAction)pushToInsuranceApplyFormVC {
    @autoreleasepool {
        FillInInformationVC*vc=[FillInInformationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//商家查找
- (IBAction)pushToRepairShopVC {
    @autoreleasepool {
        ShopNServiceSearchListVC *vc = [ShopNServiceSearchListVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//案例
- (IBAction)pushToRepairCases {
    @autoreleasepool {
        ObtainCaseVC *vc = [ObtainCaseVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//快捷保养
- (IBAction)pushToRepairExpressVC {
    @autoreleasepool {
        MaintenanceExpressVC *vc = [MaintenanceExpressVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//自助诊断
- (IBAction)pushToSelfDiagnosisVC {
    @autoreleasepool {
        SelfDiagnosisModuleVC *vc = [SelfDiagnosisModuleVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
           }
}

//E服务
- (IBAction)pushToEService:(UIButton *)sender {
    @autoreleasepool {
        if (sender.tag>=4) {
            EServiceServiceListVC *vc = [EServiceServiceListVC new];
            vc.serviceType = sender.tag;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        EServiceType serviceType = sender.tag;
        
        EServiceMainMapVC *vc = [EServiceMainMapVC new];
        vc.serviceType = serviceType;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (IBAction)pushToRapidRepairShop:(UIControl *)sender {
    @autoreleasepool {
        ShopNServiceSearchListVC *vc = [ShopNServiceSearchListVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        if (sender.tag!=8) {
            __block NSIndexPath *indexPath = nil;
            NSString *serviceTypeName = @"";
            switch (sender.tag) {
                case 1:
                    serviceTypeName = @"轮胎";
                    break;
                case 2:
                    serviceTypeName = @"钣金";
                    break;
                case 3:
                    serviceTypeName = @"空调";
                    break;
                case 4:
                    serviceTypeName = @"自动变速器";
                    break;
                case 5:
                    serviceTypeName = @"电瓶";
                    break;
                case 6:
                    serviceTypeName = @"四轮定位";
                    break;
                case 7:
                    serviceTypeName = @"玻璃";
                    break;
                    
                default:
                    break;
            }
            [self.specShopServiceTypeList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *compareServiceTypeName = [detail[@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([compareServiceTypeName isContainsString:serviceTypeName]) {
                    indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    *stop = YES;
                }
            }];
            if (indexPath) {
                vc.specShopServiceTypeList = self.specShopServiceTypeList;
                vc.selelctedSpecShopIndexPath = indexPath;
            }
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    [self.advertSrollView viewWillAppear];
    [self.topViewComponent viewWillAppear];
}

- (void)getSpecServiceList {
    @weakify(self);
    [APIsConnection.shareConnection rapidRepairSpecServiceListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode==0) {
            self.specShopServiceTypeList = responseObject[CDZKeyOfResultKey];
        }
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
