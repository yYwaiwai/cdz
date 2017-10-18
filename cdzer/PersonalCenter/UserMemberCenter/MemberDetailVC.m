//
//  MemberDetailVC.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberDetailVC.h"
#import "MemberDetailRightsCell.h"
#import "MemberDetailRulesCell.h"
#import "UserMemberCenterConfig.h"
#import "MyCarVC.h"
#import "FillInInformationVC.h"
#import "AddVehicleVC.h"
#import "MemberOrderClearanceVC.h"
#import "PaymentCenterVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MemberDetailVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topBkgImageView;

@property (weak, nonatomic) IBOutlet UITableView *rightsDetailTV;

@property (strong, nonatomic) NSMutableArray <MDRDataModel *> *userRightsDetailList;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightsDetailTVHeightConstraint;


@property (weak, nonatomic) IBOutlet UITableView *lvUpDetailTV;

@property (strong, nonatomic) NSArray <NSString *> *lvUpDetailList;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lvUpDetailTVHeightConstraint;


@property (weak, nonatomic) IBOutlet UITableView *lvDownDetailTV;

@property (strong, nonatomic) NSArray <NSString *> *lvDownDetailList;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lvDownDetailTVHeightConstraint;


@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;

@property (assign, nonatomic) BOOL showApplyBtn;

@property (strong, nonatomic) NSDictionary *memberTypeDetail;

@property (strong, nonatomic) NSString *orderID;
@end

@implementation MemberDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [UserMemberCenterConfig getMemberTypeNameByType:self.memberType];
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self getMemberTypeDetail];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)setAllContainerBorder {
    BorderOffsetObject *bottomLeftOffset = [BorderOffsetObject new];
    bottomLeftOffset.bottomLeftOffset = 12;
    [[self.rightsDetailTV.superview viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
    
    [[self.lvUpDetailTV.superview viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
    
    [[self.lvDownDetailTV.superview viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
    
    
    [self.bottomView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [[self.bottomView viewWithTag:1] setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, rightsDetailTV.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            self.rightsDetailTVHeightConstraint.constant = contentSize.height;
        }];
        
        [RACObserve(self, lvUpDetailTV.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            self.lvUpDetailTVHeightConstraint.constant = contentSize.height;
        }];
        
        [RACObserve(self, lvDownDetailTV.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            self.lvDownDetailTVHeightConstraint.constant = contentSize.height;
        }];
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.rightsDetailTV.rowHeight = UITableViewAutomaticDimension;
        self.rightsDetailTV.estimatedRowHeight = 100.0f;
        [self.rightsDetailTV registerNib:[UINib nibWithNibName:@"MemberDetailRightsCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        self.lvUpDetailTV.rowHeight = UITableViewAutomaticDimension;
        self.lvUpDetailTV.estimatedRowHeight = 100.0f;
        [self.lvUpDetailTV registerNib:[UINib nibWithNibName:@"MemberDetailRulesCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        self.lvDownDetailTV.rowHeight = UITableViewAutomaticDimension;
        self.lvDownDetailTV.estimatedRowHeight = 100.0f;
        [self.lvDownDetailTV registerNib:[UINib nibWithNibName:@"MemberDetailRulesCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.showApplyBtn = NO;
        [self setMemberTopBkgImg];
    }
}

- (void)setMemberTopBkgImg {
    NSString *imgName = @"md_bronze_medal_bkg_img@3x";
    switch (self.memberType) {
        case UserMemberTypeOfSilverMedal:
            imgName = @"md_silver_medal_bkg_img@3x";
            break;
        case UserMemberTypeOfGoldMedal:
            imgName = @"md_gold_medal_bkg_img@3x";
            break;
        case UserMemberTypeOfPlatinum:
            imgName = @"md_platinum_bkg_img@3x";
            break;
        case UserMemberTypeOfDiamond:
            imgName = @"md_diamond_bkg_img@3x";
            break;
        default:
            break;
    }
    self.topBkgImageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"jpg"]];
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setShowApplyBtn:(BOOL)showApplyBtn {
    _showApplyBtn = showApplyBtn;
    self.bottomView.hidden = !showApplyBtn;
    self.contentBottomConstraint.constant = showApplyBtn?80.f:14.f;
}

- (void)setMemberTypeDetail:(NSDictionary *)memberTypeDetail {
    _memberTypeDetail = memberTypeDetail;
    [self updateUIData];
}

- (void)updateUIData {
//level_name: "银牌会员",
//level: "2",
//right_list: [
//    {
//    img: "http://tes.cdzer.net/imgUpload/uploads/member/member_right_02.png",
//    right: "GPS一年使用权",
//    detail_info: "送“车队长”GPS-北斗设备，免流量和服务费（每台车第一年享受 一次，不重复）"
//    },
//    {
//    img: "http://tes.cdzer.net/imgUpload/uploads/member/member_right_01.png",
//    right: "会员折扣",
//    detail_info: "享受会员折扣"
//    }
//             ],
//up_list: [
//    {
//    des: "注册成为“车队长”会员"
//    },
//    {
//    des: "通过“车队长”平台仅购买交强险或三责"
//    }
//          ],
//down_list: [
//    {
//    des: "通过“车队长”平台仅购买交强险或三责到期会降级为铜牌会员"
//    }
//            ],
//show: "show"
//}
    
    self.userRightsDetailList = [MDRDataModel createDataModelWithSourceList:self.memberTypeDetail[@"right_list"]];
    [self.rightsDetailTV reloadData];

////////////////////////////////////////////////////////////////////////////////
    
    self.lvUpDetailList = self.memberTypeDetail[@"up_list"];
    if (![self.lvUpDetailList isKindOfClass:NSArray.class]) self.lvUpDetailList = @[];
    if (self.lvUpDetailList.count>0) {
        self.lvUpDetailList = [self.lvUpDetailList valueForKey:@"des"];
    }
    [self.lvUpDetailTV reloadData];

////////////////////////////////////////////////////////////////////////////////
    
    self.lvDownDetailList = self.memberTypeDetail[@"down_list"];
    if (![self.lvDownDetailList isKindOfClass:NSArray.class]) self.lvDownDetailList = @[];
    if (self.lvDownDetailList.count>0) {
        self.lvDownDetailList = [self.lvDownDetailList valueForKey:@"des"];
    }
    [self.lvDownDetailTV reloadData];
    
    NSString *showIdentKey = self.memberTypeDetail[@"show"];
    self.showApplyBtn = (showIdentKey&&
                         ([showIdentKey isContainsString:@"yes"]||
                          [showIdentKey isContainsString:@"show"]));
    self.lvDownDetailTV.superview.hidden = (self.memberType<=1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.rightsDetailTV==tableView) return self.userRightsDetailList.count;
    if (self.lvUpDetailTV==tableView) return self.lvUpDetailList.count;
    return self.lvDownDetailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.rightsDetailTV==tableView) {
        MemberDetailRightsCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        cell.isLastCell = (indexPath.row+1==self.userRightsDetailList.count);
        MDRDataModel *dataModel = self.userRightsDetailList[indexPath.row];
        [cell updateUIDataWithDataModel:dataModel];
        return cell;
    }
    
    MemberDetailRulesCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    if (self.lvUpDetailTV==tableView) {
        cell.isLastCell = (indexPath.row+1==self.lvUpDetailList.count);
        NSString *content = self.lvUpDetailList[indexPath.row];
        [cell updateUIDataWithIndex:indexPath.row andContent:content];
    }else if (self.lvDownDetailTV==tableView) {
        cell.isLastCell = (indexPath.row+1==self.lvDownDetailList.count);
        NSString *content = self.lvDownDetailList[indexPath.row];
        [cell updateUIDataWithIndex:indexPath.row andContent:content];
    }
    return cell;
}

- (void)getMemberTypeDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetMemberTypeDetailWithAccessToken:self.accessToken memberTypeID:@(self.memberType) success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.memberTypeDetail = responseObject[CDZKeyOfResultKey];
        
        
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

- (void)pushToMyAutoInsuranceApplyFormVC {
    @autoreleasepool {
        FillInInformationVC *vc = [FillInInformationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)submitApplication {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostMemberApplicationSubmitWithAccessToken:self.accessToken applyMemberTypeID:@(self.memberType) success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            if ([message isContainsString:@"个人中心车辆"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue>0) {
                        @autoreleasepool {
                            MyCarVC *vc = [MyCarVC new];
                            vc.wasBackRootView = NO;
                            vc.wasSubmitAfterLeave = YES;
                            [self setDefaultNavBackButtonWithoutTitle];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }
                }];
                return;
            }
            
            if ([message isContainsString:@"保险车辆"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:@"请添加保险车辆信息！是否现在立即添加？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue>0) {
                        @autoreleasepool {
                            AddVehicleVC *vc = [AddVehicleVC new];
                            vc.isShowCancelBtn = YES;
//                            vc.isFirstTime = YES;
                            [self setDefaultNavBackButtonWithoutTitle];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }
                }];
                return;
            }
            
            if ([message isContainsString:@"购买保险"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:@"请根据成为条件购买车辆保险！是否立即预约购买？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue>0) {
                        [self pushToMyAutoInsuranceApplyFormVC];
                    }
                }];
                return;
            }
            
            if ([message isContainsString:@"请支付"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:@"您还有一条已申请的会员订单尚未支付！是否立即去支付？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue>0) {
                        self.orderID = [[responseObject[@"order_info"] valueForKey:@"id"] lastObject];
                        [self payImmediately];
                    }
                }];
                return;
            }
            
            if ([message isContainsString:@"审核中"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
                return;
            }
            
            
            
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        if (self.memberType==UserMemberTypeOfSilverMedal||self.memberType==UserMemberTypeOfGoldMedal) {
            [self pushToMyAutoInsuranceApplyFormVC];
        }else if (self.memberType==UserMemberTypeOfPlatinum||self.memberType==UserMemberTypeOfDiamond) {
            NSDictionary *memberOrderDetail = responseObject[CDZKeyOfResultKey];
            MemberOrderClearanceVC *vc = [MemberOrderClearanceVC new];
            vc.memberOrderDetail = memberOrderDetail;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
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

- (void)payImmediately {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetPayNowByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"payImmediately::%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        PaymentCenterVC *vc = [PaymentCenterVC new];
        vc.paymentDetail = responseObject[CDZKeyOfResultKey];
        vc.pushFromDetail = YES;
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfUserMember;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
