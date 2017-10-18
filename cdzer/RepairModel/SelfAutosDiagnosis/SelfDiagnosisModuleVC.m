//
//  SelfDiagnosisModuleVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kLiveDescribe @"live_describe"
#define kMajorDescribe @"major_describe"
#define kObjNameKey @"name"
#define kObjContentKey @"content"
#define kObjRepairGuideID @"relateId"
#define kObjIDKey @"id"
#define kObjParentIDKey @"parent_id"
#define kObjDetailContentKey @"detail_content"


#import "SelfDiagnosisModuleVC.h"
#import "SelfDiagnosisModuleCell.h"
#import "DiagnosticResultsVC.h"
#import "UserAutosSelectonVC.h"
#import "SelfDiagnosisModuleHeaderView.h"
#import "SelfDiagnosisModuleBottomView.h"
#import "UIView+LayoutConstraintHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface SelfDiagnosisModuleVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIControl *headViewControl;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *headLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *chooseTitleLabel;

@property (strong, nonatomic) IBOutlet SelfDiagnosisModuleBottomView *tableFooterView;

@property (nonatomic, assign) BOOL isType;

@property (nonatomic, strong) NSArray *currentDataList;

@property (nonatomic, strong) NSArray *majorDescribeList;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;

@property (nonatomic, strong) NSNumber *typeID;

@property (nonatomic, assign) BOOL wasLastResult;



@end

@implementation SelfDiagnosisModuleVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"自助诊断";
    self.navShouldPopOtherVC=YES;
    
    [self componentSetting];}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (!self.autosSelectedData||
        ![self.autosSelectedData.brandID isEqualToString:@""]||
        ![self.autosSelectedData.dealershipID isEqualToString:@""]||
        ![self.autosSelectedData.seriesID isEqualToString:@""]||
        ![self.autosSelectedData.modelID isEqualToString:@""]) {
        self.autosSelectedData = autosData;
    }
    if (self.stepIndex==SelfDiagnosisStepOne) {
        if (self.autosSelectedData.brandID&&self.autosSelectedData.dealershipID&&
            self.autosSelectedData.seriesID&&self.autosSelectedData.modelID&&
            ![self.autosSelectedData.brandID isEqualToString:@""]&&
            ![self.autosSelectedData.dealershipID isEqualToString:@""]&&
            ![self.autosSelectedData.seriesID isEqualToString:@""]&&
            ![self.autosSelectedData.modelID isEqualToString:@""]) {
            BOOL autosInfoWasChange = (![autosData.brandID isEqualToString:self.autosSelectedData.brandID]||
                             ![autosData.dealershipID isEqualToString:self.autosSelectedData.dealershipID]||
                             ![autosData.seriesID isEqualToString:self.autosSelectedData.seriesID]||
                             ![autosData.modelID isEqualToString:self.autosSelectedData.modelID]);
            if (self.currentDataList.count==0||autosInfoWasChange) {
                if (autosInfoWasChange) {
                    self.autosSelectedData = autosData;
                }
                [self getAutoSelfAnalyztionAPIsAccessRequestByID:nil requestIdx:self.stepIndex];
            }
        }
    }
    [self updateAutosInfoData];
    
    NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    
    
}

- (void)updateAutosInfoData {
    if (self.autosSelectedData.brandID&&self.autosSelectedData.dealershipID&&
        self.autosSelectedData.seriesID&&self.autosSelectedData.modelID&&
        ![self.autosSelectedData.brandID isEqualToString:@""]&&
        ![self.autosSelectedData.dealershipID isEqualToString:@""]&&
        ![self.autosSelectedData.seriesID isEqualToString:@""]&&
        ![self.autosSelectedData.modelID isEqualToString:@""]) {
        
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.autosSelectedData.brandImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        NSMutableString *string = [NSMutableString string];
        [string appendFormat:@"%@ %@",self.autosSelectedData.seriesName, self.autosSelectedData.modelName];
        self.headLabel.text = string;
        
        self.headImageView.hidden = NO;
        self.headLabel.hidden = NO;
        self.chooseTitleLabel.hidden = YES;
    }else {
        self.headImageView.hidden = YES;
        self.headLabel.hidden = YES;
        self.chooseTitleLabel.hidden = NO;
    }
    
    BOOL showArrow = (self.stepIndex==SelfDiagnosisStepOne);
    if (showArrow) {
        [self.headViewControl addTarget:self action:@selector(headViewControlClick) forControlEvents:UIControlEventTouchUpInside];
    }
    self.arrowImageView.hidden = !showArrow;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)componentSetting {
    if (!self.currentDataList) {
        self.currentDataList = @[];
    }
    
    [self.headImageView.layer setCornerRadius:22.5];
    [self.headImageView.layer setMasksToBounds:YES];
    [self.headImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    if (self.stepIndex==SelfDiagnosisStepOne) {
        //        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        //        [self.tableView registerNib:[UINib nibWithNibName:@"SelfDiagnosisModuleHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"headerView"];
        
        [[UINib nibWithNibName:@"SelfDiagnosisModuleBottomView" bundle:nil] instantiateWithOwner:self options:nil];
        
        SelfDiagnosisModuleHeaderView *headerView = [[UINib nibWithNibName:@"SelfDiagnosisModuleHeaderView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
        headerView.hintLabel.text = @"如果您不知道是什么问题，匹配一条符合以下描述的症状：";
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:SCREEN_WIDTH];
        [headerView addConstraint:widthConstraint];
        
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH==320)?44:34)];
        [headerView addSelfByFourMarginToSuperview:tableHeaderView];
        headerView.frame = tableHeaderView.frame;
        self.tableView.tableHeaderView = tableHeaderView;
        
        
        if (!self.tableFooterView.reponseBlock&&self.tableFooterView) {
            @weakify(self);
            self.tableFooterView.reponseBlock = ^(NSIndexPath *indexPath) {
                @strongify(self);
                NSString *theID = @"";
                [self.tableView reloadData];
                NSDictionary *detail = self.majorDescribeList[indexPath.row];
                theID = [detail objectForKey:kObjIDKey];
                self.typeID = [SupportingClass verifyAndConvertDataToNumber:detail[@"type"]];
                [self getAutoSelfAnalyztionAPIsAccessRequestByID:theID requestIdx:self.stepIndex+1];
            };
        }
        
    }else {
        self.tableView.sectionHeaderHeight = 0;
    }
    
    UINib * nib = [UINib nibWithNibName:@"SelfDiagnosisModuleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    
}

- (void)headViewControlClick {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"请先选择车系车型！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"323232"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.stepIndex==SelfDiagnosisStepOne) {
        if (self.currentDataList.count>0) {
            return self.currentDataList.count;
        }
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.stepIndex==SelfDiagnosisStepOne) {
        if (self.currentDataList.count==0) {
            return 0;
        }
        return [self.currentDataList[section] count];
    }
    return self.currentDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelfDiagnosisModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.labelOne.text = @"";
    cell.labelTwo.text = @"";
    if (self.stepIndex==SelfDiagnosisStepOne) {
        NSArray *dataList = self.currentDataList[indexPath.section];
        NSDictionary *detail = dataList[indexPath.row];
        cell.labelOne.text = detail[kObjNameKey];
        if ([[cell.labelOne.text substringToIndex:1] isEqualToString:@" "]) {
            cell.labelOne.text = [cell.labelOne.text substringFromIndex:1];
        }
        cell.labelTwo.text = detail[kObjContentKey];
    }else {
        cell.labelOne.text = [self.currentDataList[indexPath.row] objectForKey:kObjNameKey];
        if(_wasLastResult) {
            cell.labelTwo.text = [self.currentDataList[indexPath.row] objectForKey:kObjDetailContentKey];
        }
    }

    
    cell.labelTwo.text = [cell.labelTwo.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.labelTwo.text = [cell.labelTwo.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cell.labelOne.text = [cell.labelOne.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.labelOne.text = [cell.labelOne.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
//    return 50;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    SelfDiagnosisModuleHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
//    if (section==0) {
//        headerView.hintLabel.text = @"如果您不知道是什么问题，匹配一条符合以下描述的症状：";
//    }else{
//        headerView.hintLabel.text = @"如果您不知道您的车辆故障所处的部位，您可以直接选择它：";
//    }
//    return headerView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.stepIndex==SelfDiagnosisStepOne) {
        return 13;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.stepIndex==SelfDiagnosisStepOne) {
        UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 13)];
        footView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        return footView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (_wasLastResult) return;
        NSString *theID = @"";
        if (self.stepIndex==SelfDiagnosisStepOne) {
            [self.tableFooterView reloadCollectionView];
            NSArray *list = self.currentDataList[indexPath.section];
            theID = [list[indexPath.row] objectForKey:kObjIDKey];
            self.typeID = [SupportingClass verifyAndConvertDataToNumber:[list[indexPath.row] objectForKey:@"type"]];
        }else {
            theID = [self.currentDataList[indexPath.row] objectForKey:kObjIDKey];
            self.typeID = [SupportingClass verifyAndConvertDataToNumber:[self.currentDataList[indexPath.row] objectForKey:@"type"]];
        }
        [self getAutoSelfAnalyztionAPIsAccessRequestByID:theID requestIdx:self.stepIndex+1];
    }

    
}

- (void)showAletViewWhenSelectionDone {
    @autoreleasepool {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:getLocalizationString(@"alert_remind")
                                                        message:@"诊断步骤已经完成，点击确定生成结果，或者取消选择其他！"
                                                       delegate:self cancelButtonTitle:getLocalizationString(@"cancel")
                                              otherButtonTitles:getLocalizationString(@"ok") , nil];
        [alert show];
    }
}

// 处理结果
- (void)handleDataList:(id)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject) {
            NSLog(@"DataList Error at %@", NSStringFromClass(self.class));
            return;
        }
        if ([responseObject count]==0) {
            NSString *message = @"暂无更多选择";
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        if (ident==0) {
            self.majorDescribeList = responseObject[kMajorDescribe];
            responseObject = @[responseObject[kLiveDescribe]];
        }
        
        NSMutableArray *totalData=[NSMutableArray new];
        if (totalData.count>=ident&&totalData.count!=0) {
            [totalData removeObjectsInRange:NSMakeRange(ident, totalData.count-ident)];
            NSLog(@"%@ - totalData::%d", NSStringFromClass(self.class), totalData.count);
        }
        [totalData addObject:responseObject];
        
        if (ident==0) {
            [self.tableFooterView removeFromSuperview];
            self.tableView.tableFooterView = nil;
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableFooterView.frame))];
            [self.tableFooterView addSelfByFourMarginToSuperview:self.tableView.tableFooterView];
            self.currentDataList = responseObject;
            self.tableFooterView.dataSources = self.majorDescribeList;
            [self.tableView reloadData];
        }else {
            [self pushNextStepViewWithData:responseObject withIdent:ident];
        }
        
    }
}


- (void)pushNextStepViewWithData:(NSArray *)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||responseObject.count==0) {
            return;
        }
        SelfDiagnosisModuleVC *vc = SelfDiagnosisModuleVC.new;
        vc.stepIndex = ident;
        vc.typeID = self.typeID;
        vc.currentDataList = responseObject;
        vc.ignoreViewResize = YES;
        vc.wasLastResult = (responseObject.firstObject[kObjDetailContentKey]&&![responseObject.firstObject[kObjDetailContentKey] isEqualToString:@""]);
        if ((responseObject.firstObject[kObjDetailContentKey]&&![responseObject.firstObject[kObjDetailContentKey] isEqualToString:@""])) {
            DiagnosticResultsVC * vc = [DiagnosticResultsVC new];
            vc.resultList = responseObject;
            [self.navigationController pushViewController:vc animated:YES];
            [self setDefaultNavBackButtonWithoutTitle];

        }else{
            [self.navigationController pushViewController:vc animated:YES];
            [self setDefaultNavBackButtonWithoutTitle];
        }
        
    }
}

#pragma mark- APIs Access Request
- (void)getAutoSelfAnalyztionAPIsAccessRequestByID:(NSString *)theIDString requestIdx:(NSUInteger)currentIndex {
    switch (currentIndex) {
        case 0:
            // 请求故障种类
            NSLog(@"%@ accessing Autos failure type list request",NSStringFromClass(self.class));
            break;
        case 1:
            // 请求故障现象
            NSLog(@"%@ accessing Autos fault symptom list request",NSStringFromClass(self.class));
            break;
        case 2:
            // 请求故障架构
            NSLog(@"%@ accessing Autos fault structure list request",NSStringFromClass(self.class));
            break;
        case 3:
            // 请求原因分析
            NSLog(@"%@ accessing Diagnosis result list request",NSStringFromClass(self.class));
            break;
        case 4:
            // 请求故障解决方案
            NSLog(@"%@ accessing solution plan list request",NSStringFromClass(self.class));
            break;
            //        case 5:
            //            // 请求配件更换建议
            //            NSLog(@"%@ accessing proposed replacement parts list request",NSStringFromClass(self.class));
            break;
        default:
            NSLog(@"Not find APIs Request Functon");
            break;
    }
    
    [ProgressHUDHandler showHUD];
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (!self.autosSelectedData||
        autosData.brandID!=self.autosSelectedData.brandID||
        autosData.dealershipID!=self.autosSelectedData.dealershipID||
        autosData.seriesID!=self.autosSelectedData.seriesID||
        autosData.modelID!=self.autosSelectedData.modelID) {
        self.autosSelectedData = autosData;
    }
    
    [[APIsConnection shareConnection] commonAPIsGetAutoSelfDiagnosisStepListWithStep:currentIndex nextStepID:theIDString seriesID:autosData.seriesID modelID:autosData.modelID typeID:self.typeID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@",operation.currentRequest.URL.absoluteString);
        [operation setUserInfo:@{@"iden":@(currentIndex)}];
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSNumber *idenNumber = [operation.userInfo objectForKey:@"iden"];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            if (errorCode==1&&([message rangeOfString:@"商家"].location!=NSNotFound||[message rangeOfString:@"接口"].location!=NSNotFound)) {
                [self showAletViewWhenSelectionDone];
                return;
            }
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {[ProgressHUDHandler dismissHUD];}];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        [self handleDataList:responseObject[CDZKeyOfResultKey] withIdent:idenNumber.integerValue];
        
    }
    
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
