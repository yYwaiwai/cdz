//
//  ShopMechanicDetailVC.m
//  cdzer
//
//  Created by KEns0n on 16/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicDetailVC.h"
#import "ShopNItemPartsCommentListCell.h"
#import "SMDHeaderBezierView.h"
#import "SMSLCellIndicatorBarView.h"
#import "SMDBGBezierAnimationView.h"
#import "ShopMechanicUpgradeDetailVC.h"
#import "ShopMechanicExpNCertsDetailVC.h"
#import "HCSStarRatingView.h"
#import "ShopNItemPartsCommentListVC.h"
#import "RepairAppiontmentVC.h"
#import "RepairServiceItemSelectionVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>



@interface ShopMechanicDetailVC ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;

@property (weak, nonatomic) IBOutlet SMDBGBezierAnimationView *headerBGView;

@property (weak, nonatomic) IBOutlet SMDHeaderBezierView *headerInfoView;

@property (weak, nonatomic) IBOutlet UIImageView *mechanicPortrait;

@property (weak, nonatomic) IBOutlet UILabel *mechanicNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *skillsNameListLabel;

@property (weak, nonatomic) IBOutlet UILabel *workingYearLabel;

@property (weak, nonatomic) IBOutlet UIImageView *typeGradeIV;

@property (weak, nonatomic) IBOutlet UILabel *currentExpLabel;

@property (weak, nonatomic) IBOutlet UILabel *maxExpLabel;

@property (weak, nonatomic) IBOutlet SMSLCellIndicatorBarView *indicatorBar;

@property (weak, nonatomic) IBOutlet UIView *commentCountView;

@property (weak, nonatomic) IBOutlet UILabel *totalCommentCountLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *commentAvgMakingView;

@property (weak, nonatomic) IBOutlet UILabel *commentAvgMakingLabel;

@property (strong, nonatomic) NSDictionary *shopDetail;

@property (strong, nonatomic) UIButton *collctionBtn;

@end

@implementation ShopMechanicDetailVC

- (void)dealloc {
    self.headerBGView.scrollView = nil;
    self.headerInfoView.scrollView = nil;
    [self.headerBGView stopWave];
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startWave];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    UIColor *barBKC = CDZColorOfWhite;
    UIColor *barForeC = CDZColorOfClearColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:barBKC};
    self.navigationController.navigationBar.barTintColor = barForeC;
    self.navigationController.navigationBar.backgroundColor = barForeC;
    self.navigationController.navigationBar.tintColor = barBKC;
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    UIColor *barBKC = [UIColor colorWithHexString:@"FAFAFA"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"]};
    self.navigationController.navigationBar.barTintColor = barBKC;
    self.navigationController.navigationBar.backgroundColor = barBKC;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"323232"];
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.mechanicPortrait setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.mechanicPortrait.frame)/2.0f];
    
    [self.commentCountView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        [self getShopOrServiceDetail];
        
        self.collctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collctionBtn.frame = CGRectMake(0, 0, 40, 30);
        self.collctionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.collctionBtn setImage:[UIImage imageNamed:@"snsd_uncollected_icon@3x.png"] forState:UIControlStateNormal];
        [self.collctionBtn setImage:[UIImage imageNamed:@"snsd_collected_icon@3x.png"] forState:UIControlStateSelected];
        [self.collctionBtn addTarget:self action:@selector(mechanicCollectAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:self.collctionBtn];
        self.navigationItem.rightBarButtonItem = barItem;
        
        UIEdgeInsets contentInset = UIEdgeInsetsZero;
        contentInset.top = roundf(SCREEN_WIDTH/3.833333333333333);
        //1.848214285714286
        //3.833333333333333
        self.tableView.contentInset = contentInset;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        [self.tableView registerNib:[UINib nibWithNibName:@"ShopNItemPartsCommentListCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        CGRect bounds = self.tableView.tableHeaderView.bounds;
        bounds.size.height = 300+self.headerInfoView.theHeight+3;
        self.tableView.tableHeaderView.bounds = bounds;
        [self.tableView reloadInputViews];
        [self.tableView beginUpdates];
        self.tableView.tableHeaderView = self.tableHeaderView;
        [self.tableView endUpdates];
        
        self.headerInfoView.scrollView = self.tableView;
        self.headerBGView.scrollView = self.tableView;
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.whiteColor;
        self.tableView.tableFooterView = view;
        [self updateUIData];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多技师评论信息";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return self.detailData.commentDetailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopNItemPartsCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    ShopMechanicCommentDetailDTO *dto = self.detailData.commentDetailList[indexPath.row];
    [cell updateUIDataByDto:dto];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.bounces = YES;
    if (scrollView.contentSize.height>CGRectGetHeight(scrollView.frame)) {
        CGFloat bottomOffset = scrollView.contentSize.height-CGRectGetHeight(scrollView.frame)-10;
        scrollView.bounces = !(scrollView.contentOffset.y>=bottomOffset);
    }
}

- (void)startWave {
    [self.headerBGView startWave];
}

- (void)stopWave {
    [self.headerBGView stopWave];
}

- (void)resetWave {
    [self.headerBGView reset];
}

- (IBAction)pushToShopMechanicUpgradeDetailVC {
    @autoreleasepool {
        ShopMechanicUpgradeDetailVC *vc = [ShopMechanicUpgradeDetailVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToShopMechanicExpNCertsDetailVC {
    @autoreleasepool {
        ShopMechanicExpNCertsDetailVC *vc = [ShopMechanicExpNCertsDetailVC new];
        vc.mechanicID = self.mechanicID;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToMechanicCommentListVC {
    @autoreleasepool {
        ShopNItemPartsCommentListVC *vc = [ShopNItemPartsCommentListVC new];
        vc.commentTypeID = self.mechanicID;
        vc.commentType = SNIPCLCommentTypeOfMechanic;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)submitAppointment {
    if (self.onlyForSelection) {
        if (self.resultBlock) {
            self.resultBlock(self.selectedMechanicDetail);
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", NSClassFromString(@"RepairAppiontmentVC")];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            BaseViewController *vc = result.lastObject;
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    @autoreleasepool {
        if (self.shopDetail&&self.shopDetail.count>0&&self.selectedMechanicDetail) {
            BOOL isSpecServiceShop = [self.detailData.repairShopType isContainsString:@"专修"];
            if (isSpecServiceShop) {
                RepairAppiontmentVC *vc = [RepairAppiontmentVC new];
                vc.shopDetail = self.shopDetail;
                vc.selectedMechanicDetail = self.selectedMechanicDetail;
                vc.isSpecServiceShop = isSpecServiceShop;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                RepairServiceItemSelectionVC *vc = [RepairServiceItemSelectionVC new];
                vc.shopDetail = self.shopDetail;
                vc.selectedMechanicDetail = self.selectedMechanicDetail;
                vc.isSpecServiceShop = isSpecServiceShop;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }
}

- (IBAction)mechanicCollectAction {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self updateMechanicCollectionStatus];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    [self getMechanicDetail];
}

- (void)updateUIData {
    if (!self.detailData) {
        [self getMechanicDetail];
    }else {
        self.mechanicPortrait.image = [ImageHandler getWhiteLogo];
        if ([self.detailData.mechanicPortrait isContainsString:@"http"]) {
            [self.mechanicPortrait sd_setImageWithURL:[NSURL URLWithString:self.detailData.mechanicPortrait]];
        }
        self.mechanicNameLabel.text = self.detailData.mechanicName;
        self.shopNameLabel.text = [self.detailData.repairShopName stringByAppendingFormat:@"(%@)", self.detailData.repairShopType];
        self.skillsNameListLabel.text = self.detailData.specialism;
        self.workingYearLabel.text = self.detailData.workingYrs;
        self.mechanicNameLabel.text = self.detailData.mechanicName;
        self.mechanicNameLabel.text = self.detailData.mechanicName;
        self.currentExpLabel.text = self.detailData.currentScore;
        self.maxExpLabel.text = self.detailData.totalScore;
        self.indicatorBar.currentValue = self.detailData.scorePercentage.floatValue;
        
        NSString *gradeStr = @"";
        NSString *typeStr = @"";
        if ([self.detailData.workingGrade isContainsString:@"初级"]) {
            gradeStr = @"junior";
        }else if ([self.detailData.workingGrade isContainsString:@"中级"]) {
            gradeStr = @"intermediate";
        }else if ([self.detailData.workingGrade isContainsString:@"高级"]) {
            gradeStr = @"senior";
        }
        
        if ([self.detailData.workingGrade isContainsString:@"技工"]) {
            typeStr = @"mechanic";
        }else if ([self.detailData.workingGrade isContainsString:@"技师"]) {
            typeStr = @"technician";
        }
        
        
        if (![gradeStr isEqualToString:@""]&&![typeStr isEqualToString:@""]) {
            NSString *imgName = [NSString stringWithFormat:@"smsl_%@_%@_icon@3x", gradeStr, typeStr];
            UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"png"]];
            self.typeGradeIV.image = image;
        }
        
        self.collctionBtn.selected = self.detailData.mechanicWasCollected;
        
        self.totalCommentCountLabel.text = self.detailData.totalCommentCount;
        self.commentAvgMakingView.value = self.detailData.totalCommentAvgValue.floatValue;
        self.commentAvgMakingLabel.text = self.detailData.totalCommentAvgValue;

    }
}

- (void)getMechanicDetail {
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicDetailWithAccessToken:self.accessToken mechanicID:self.mechanicID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest.URL.absoluteString);
        
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.detailData = [ShopMechanicDetailDTO createMechanicDetailFromSourceData:responseObject[CDZKeyOfResultKey]];
        [self updateUIData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
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

- (void)getShopOrServiceDetail {
    if (!self.detailData.repairShopID||[self.detailData.repairShopID isEqualToString:@""]) {
        NSLog(@"Missing shopOrServiceID");
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairShopOrServiceDetailWithAccessToken:self.accessToken shopOrServiceID:self.detailData.repairShopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        [ProgressHUDHandler dismissHUD];
        self.shopDetail = responseObject[CDZKeyOfResultKey];
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

- (void)updateMechanicCollectionStatus {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsPostMechanicCollectionStatustWithAccessToken:self.accessToken mechanicID:self.mechanicID toCollection:!self.detailData.mechanicWasCollected success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) return;
        if (errorCode!=0) {
            NSString *title = self.detailData.mechanicWasCollected?@"取消收藏失败，请稍后再试！":@"收藏失败，请稍后再试！";
            [ProgressHUDHandler showErrorWithStatus:title onView:nil completion:^{
                [self getMechanicDetail];
            }];
            return;
        }
        NSString *title = self.detailData.mechanicWasCollected?@"收藏取消":@"收藏成功";
        [ProgressHUDHandler showSuccessWithStatus:title onView:nil completion:^{
            [self getMechanicDetail];
        }];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSString *title = self.detailData.mechanicWasCollected?@"取消收藏失败，请稍后再试！":@"收藏失败，请稍后再试！";
        [ProgressHUDHandler showErrorWithStatus:title onView:nil completion:^{
            [self getMechanicDetail];
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
