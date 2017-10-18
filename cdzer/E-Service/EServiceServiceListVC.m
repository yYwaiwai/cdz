//
//  EServiceServiceListVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/8/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceServiceListVC.h"
#import "EServiceServiceListCell.h"
#import "EServicePaymentVC.h"
#import "EServiceServiceDetailVC.h"
#import "MyEServiceComment.h"
#import "EServiceServiceListOptionView.h"
#import "EServiceAutoCancelApointmentObject.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
@interface EServiceServiceListVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSString *currentStatusTypeStr;

@property (nonatomic, strong) NSString *currentServiceTypeStr;

@property (nonatomic, strong) IBOutlet EServiceServiceListOptionView *optionView;

@property (nonatomic, strong) UILabel *optionLabel;

@property (nonatomic, assign) BOOL showServiceDeactiveList;

@end

@implementation EServiceServiceListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    if (self.dataList.count==0) {
        [self getEServiceListWithRefreshView:nil andReloadAll:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initializationUI {
    @autoreleasepool {
        self.navigationItem.titleView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 36.0f)];
        [(UIControl *)self.navigationItem.titleView addTarget:self action:@selector(showOptionView) forControlEvents:UIControlEventTouchUpInside];
        
        self.optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 36)];
        self.optionLabel.textColor = [UIColor colorWithHexString:@"323232"];
        self.optionLabel.text = @"服务记录";
        self.optionLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightMedium];
        [self.navigationItem.titleView addSubview:self.optionLabel];
        
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(74, 13.5, 16, 9)];
        arrowImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_arrow@3x" ofType:@"png"]];
        [self.navigationItem.titleView addSubview:arrowImageView];
    }
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.navShouldPopOtherVC = YES;
        self.loginAfterShouldPopToRoot = NO;
        
        self.dataList = [NSMutableArray array];
        self.currentStatusTypeStr = @"全部";
        self.currentServiceTypeStr = @"全部";
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        [[UINib nibWithNibName:@"EServiceServiceListOptionView" bundle:nil] instantiateWithOwner:self options:nil];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 194.0f;
        UINib *nib = [UINib nibWithNibName:@"EServiceServiceListCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        self.tableView.tableFooterView = [UIView new];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        [self setRightNavButtonWithTitleOrImage:@"已完成" style:UIBarButtonItemStylePlain target:self action:@selector(changeServiceaActiveOrDeactiveList) titleColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.00] isNeedToSet:YES];
    }
    
}

- (void)changeServiceaActiveOrDeactiveList {
    self.showServiceDeactiveList = !self.showServiceDeactiveList;
    self.currentStatusTypeStr = self.showServiceDeactiveList?@"已完成":@"全部";
    self.navigationItem.rightBarButtonItem.title = self.showServiceDeactiveList?@"服务中":@"已完成";
    [self getEServiceListWithRefreshView:nil andReloadAll:YES];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, optionView.serviceType) subscribeNext:^(NSNumber *wasViewAppear) {
        @strongify(self);
        NSString *serviceTypeStr = @"全部";
        switch (self.optionView.serviceType) {
            case EServiceTypeOfERepair:
                serviceTypeStr = @"e代修";
                break;
            case EServiceTypeOfEInspect:
                serviceTypeStr = @"e代检";
                break;
            case EServiceTypeOfEInsurance:
                serviceTypeStr = @"e代赔";
                break;
            case EServiceTypeOfAllService:
            default:
                serviceTypeStr = @"全部";
                break;
        }
        self.currentServiceTypeStr = serviceTypeStr;
        [self getEServiceListWithRefreshView:nil andReloadAll:YES];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showOptionView {
    [self.optionView showOptionView];
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.intValue+1);
}

- (void)handleData:(id)refresh {
    [self getEServiceListWithRefreshView:refresh andReloadAll:[refresh isKindOfClass:ODRefreshControl.class]];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
        self.totalPageSizes = @0;
        self.pageNums = @1;
        self.pageSizes = @10;
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无服务记录";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellWithIdentifier = @"cell";
    EServiceServiceListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(NSIndexPath *indexPath, EServiceSLCActionType actionType) {
            @strongify(self);
            NSLog(@"%d", actionType);
            NSDictionary *configDetail = self.dataList[indexPath.row];
            NSString *serviceID = configDetail[@"pid"];
            switch (actionType) {
                case EServiceSLCActionTypeOfCancel:
                    [self cancelEService:serviceID];
                    break;
                    
                case EServiceSLCActionTypeOfPayment:{
                    NSString *serviceTypeStr = configDetail[@"type"];
                    NSString *creditsRatio = [SupportingClass verifyAndConvertDataToString:configDetail[@"proportion"]];
                    EServiceType serviceType = EServiceTypeOfERepair;
                    if ([serviceTypeStr isEqualToString:@"e代检"]) serviceType = EServiceTypeOfEInspect;
                    if ([serviceTypeStr isEqualToString:@"e代赔"]) serviceType = EServiceTypeOfEInsurance;
                    [self pushToPaymentVCWithEServiceID:serviceID andServiceType:serviceType creditsRatio:creditsRatio];
                }
                    break;
                    
                case EServiceSLCActionTypeOfConfirnReturn:
                    [self confirmVehiceDropOff:serviceID];
                    break;
                    
                case EServiceSLCActionTypeOfToComment:{
                    NSString *carImgStr = configDetail[@"face_img"];
                    [self pushToCommentViewAndCommentDisplayOnly:NO withEServiceID:serviceID withCarImg:carImgStr];
                    
                }
                    break;
                    
                case EServiceSLCActionTypeOfReviewComment:{
                    NSString *carImgStr = configDetail[@"face_img"];
                    [self pushToCommentViewAndCommentDisplayOnly:YES withEServiceID:serviceID withCarImg:carImgStr];
                    
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
    if (self.dataList.count>0) {
        NSDictionary *configDetail = self.dataList[indexPath.row];
        [cell updateCellConfig:configDetail];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSDictionary *configDetail = self.dataList[indexPath.row];
        NSString *serviceID = configDetail[@"pid"];
        NSString *serviceTypeStr = configDetail[@"type"];
        NSString *creditsRatio = [SupportingClass verifyAndConvertDataToString:configDetail[@"proportion"]];
        EServiceType serviceType = EServiceTypeOfERepair;
        if ([serviceTypeStr isEqualToString:@"e代检"]) serviceType = EServiceTypeOfEInspect;
        if ([serviceTypeStr isEqualToString:@"e代赔"]) serviceType = EServiceTypeOfEInsurance;
        [self getEServiceDetail:serviceID withServiceType:serviceType creditsRatio:(NSString *)creditsRatio ];
    }
}

- (void)pushToPaymentVCWithEServiceID:(NSString *)eServiceID andServiceType:(EServiceType)serviceType creditsRatio:(NSString *)creditsRatio {
    @autoreleasepool {
        EServicePaymentVC *vc = [EServicePaymentVC new];
        vc.serviceType = serviceType;
        vc.eServiceID = eServiceID;
        vc.creditsRatio = creditsRatio;
        vc.showPushBackLastView = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToCommentViewAndCommentDisplayOnly:(BOOL)commentDisplayOnly withEServiceID:(NSString *)eServiceID withCarImg:(NSString *)carImgStr{
    @autoreleasepool {
        MyEServiceComment *vc = [MyEServiceComment new];
        vc.commentDisplayOnly = commentDisplayOnly;
        vc.eServiceID = eServiceID;
        vc.carImagString=carImgStr;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)getEServiceListWithRefreshView:(id)refreshView andReloadAll:(BOOL)reloadAll {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    if (reloadAll) {
        self.pageNums = @(1);
        self.pageSizes = @(10);
    }
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes statusType:self.currentStatusTypeStr serviceType:self.currentServiceTypeStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:(!refreshView)]) {return;};
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (reloadAll) {
            self.pageNums = @(1);
            self.pageSizes = @(10);
            [self.dataList removeAllObjects];
        }
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        
        NSArray *filterList = responseObject[CDZKeyOfResultKey];
        NSMutableArray *resultList = [NSMutableArray array];
        if (filterList.count>0) {
            [filterList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *payStatus = detail[@"order_state"];
                NSString *orderStatus = detail[@"state"];
                if ([payStatus isContainsString:@"未付款"]&&[orderStatus isContainsString:@"取消"]) {
                    NSString *eServiceID = detail[@"pid"];
                    EServiceCancelRecordDTO *dto = [DBHandler.shareInstance getEServiceCancelRecordByEServiceID:eServiceID];
                    NSTimeInterval maxTime = kMaxTime;
                    NSDate *date = [NSDate date];
                    if (dto) {
                        NSTimeInterval timeGap = round([date timeIntervalSinceDate:dto.createdDateTime]);
                        if (timeGap>maxTime) {
                            [self autoCancelEService:eServiceID];
                            [EServiceAutoCancelApointmentObject cancelServiceCancelRecordWithDto:dto];
                        }else {
                            [resultList addObject:detail];
                        }
                    }else {
                        
                        dto = [EServiceCancelRecordDTO createDataToObjectWithEServiceType:self.serviceType dbUID:nil eServiceID:eServiceID userID:vGetUserID createdDateTime:[[NSDate date] timeIntervalSince1970]];
                        NSLog(@"%f",[[NSDate date] timeIntervalSince1970]);
                        if (dto) {
                            [EServiceAutoCancelApointmentObject addServiceCancelRecordWithDto:dto];
                        }
                        [resultList addObject:detail];
                    }
                }else {
                    [resultList addObject:detail];
                }
            }];
            
        }else {
            [resultList addObjectsFromArray:filterList];
        }
        
        [self.dataList addObjectsFromArray:resultList];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        if (!reloadAll) {
            if (self.pageNums.integerValue>1) {
                self.pageNums = @(self.pageNums.integerValue-1);
            }
        }
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

- (void)cancelEService:(NSString *)eServiceID {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:self.accessToken eServiceID:eServiceID isAutoCancel:NO success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        [self getEServiceListWithRefreshView:nil andReloadAll:YES];
        
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

- (void)autoCancelEService:(NSString *)eServiceID {
    if (!self.accessToken) {
        return;
    }
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:self.accessToken eServiceID:eServiceID isAutoCancel:YES success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [self getEServiceListWithRefreshView:nil andReloadAll:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

- (void)confirmVehiceDropOff:(NSString *)eServiceID {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceConfirmVehicleWasReturnWithAccessToken:self.accessToken eServiceID:eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        [self getEServiceListWithRefreshView:nil andReloadAll:YES];
        
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

- (void)getEServiceDetail:(NSString *)eServiceID withServiceType:(EServiceType)serviceType creditsRatio:(NSString *)creditsRatio {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceDetailWithAccessToken:self.accessToken eServiceID:eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        EServiceServiceDetailVC *vc = [EServiceServiceDetailVC new];
        vc.serviceType = serviceType;
        vc.serviceDetail = responseObject[CDZKeyOfResultKey];
        vc.eServiceID = eServiceID;
        vc.creditsRatio = creditsRatio;        
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (!isSuccess) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)handleNavBackBtnPopOtherAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
