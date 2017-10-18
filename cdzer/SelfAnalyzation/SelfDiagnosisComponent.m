//
//  SelfDiagnosisComponent.m
//  cdzer
//
//  Created by KEns0n on 11/27/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#define kLiveDescribe @"live_describe"
#define kMajorDescribe @"major_describe"
#define kObjNameKey @"name"
#define kObjRepairGuideID @"relateId"
#define kObjIDKey @"id"
#define kObjParentIDKey @"parent_id"
#define kObjDetailContentKey @"detail_content"

#import "SelfDiagnosisComponent.h"

@interface InternalDiagnosisCell : UITableViewCell
@end

@implementation InternalDiagnosisCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.textLabel.frame)+4.0f;
    self.detailTextLabel.frame = frame;
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.accessoryType = selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.accessoryType = selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

@end

@interface InternalDiagnosisVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL wasLastResult;

@property (nonatomic, strong) NSNumber *typeID;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *currentDataList;

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) NSIndexPath *indexPathForSelectedRow;

@property (nonatomic, strong) InsetsLabel *reminderLabel;

@property (nonatomic, strong) UIButton *repairGuideButton;

@property (nonatomic, strong) UIButton *inspectButton;

@property (nonatomic, strong) UIButton *wxsSearchButton;

@end

@implementation InternalDiagnosisNav
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CDZColorOfWhite;
    
    [self componentSetting];
    [self setReactiveRules];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.ASView reloadUIData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)componentSetting {
    @autoreleasepool {
        self.dataLists = [@[] mutableCopy];
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, view.frame) subscribeNext:^(id rect) {
        @strongify(self);
        self.visibleViewController.view.frame = self.view.bounds;
        [(InternalDiagnosisVC *)self.visibleViewController contentView].frame = self.visibleViewController.view.bounds;
    }];
}

- (void)initializationUI {
    @autoreleasepool {
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
    }
}
@end

@implementation InternalDiagnosisVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.backgroundColor = CDZColorOfWhite;
    
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserSelectedAutosInfoDTO *autoData = [(InternalDiagnosisNav *)self.navigationController ASView].autoData;
    if (_stepIndex==SelfDiagnosisStepOne) {
        if (autoData.modelID&&autoData.seriesID) {
            _reminderLabel.hidden = YES;
            [self getAutoSelfAnalyztionAPIsAccessRequestByID:nil requestIdx:_stepIndex];
        }else {
            _reminderLabel.hidden = NO;
        }
    }
    NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    [self updateFrameSize];
    
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)componentSetting {
    if (!self.currentDataList) {
        self.currentDataList = @[];
    }
}

- (void)setReactiveRules {
    if (_wasLastResult) {
        @weakify(self);
        [RACObserve(self, indexPathForSelectedRow) subscribeNext:^(NSIndexPath *indexPathForSelectedRow) {
            @strongify(self);
            BOOL wasExist = (indexPathForSelectedRow!=nil);
            self.wxsSearchButton.enabled = wasExist;
            self.wxsSearchButton.backgroundColor = wasExist?CDZColorOfDefaultColor:CDZColorOfDeepGray;
            self.inspectButton.enabled = wasExist;
            self.inspectButton.backgroundColor = wasExist?CDZColorOfDefaultColor:CDZColorOfDeepGray;
            self.repairGuideButton.enabled = wasExist;
            self.repairGuideButton.backgroundColor = wasExist?CDZColorOfDefaultColor:CDZColorOfDeepGray;
        }];
    }
    
}

- (void)updateFrameSize {
    if (CGRectEqualToRect(self.view.bounds, UIScreen.mainScreen.bounds)) {
        self.view.frame = self.navigationController.view.bounds;
        self.contentView.frame = self.view.bounds;
        self.scrollView.frame = self.view.bounds;
        
    }
    
    self.contentView.backgroundColor = CDZColorOfWhite;
    CGRect frame = self.contentView.bounds;
    if (_stepIndex==SelfDiagnosisStepOne) {
        AutosSelectedView *asview = [(InternalDiagnosisNav *)self.navigationController ASView];
        frame.origin.y = CGRectGetMaxY(asview.frame);
        frame.size.height = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(asview.frame);
    }
    if (_wasLastResult) {
        CGFloat height = 85.0f;
        self.buttonView.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-height, CGRectGetWidth(self.contentView.frame), height);
        frame.size.height = frame.size.height-CGRectGetHeight(_buttonView.frame);
    }
    
    self.tableView.frame = frame;
    
    self.reminderLabel.frame = self.contentView.bounds;
}

- (void)initializationUI {
    @autoreleasepool {
        self.contentView.backgroundColor = CDZColorOfWhite;
        CGRect frame = self.contentView.bounds;
        if (_stepIndex==SelfDiagnosisStepOne) {
            AutosSelectedView *asview = [(InternalDiagnosisNav *)self.navigationController ASView];
            [self.contentView addSubview:asview];
            frame.origin.y = CGRectGetMaxY(asview.frame);
            frame.size.height = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(asview.frame);
        }
        if (_wasLastResult) {
            CGFloat height = 85.0f;
            self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-height, CGRectGetWidth(self.contentView.frame), height)];
            _buttonView.backgroundColor = CDZColorOfWhite;
            _buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            _buttonView.translatesAutoresizingMaskIntoConstraints = YES;
            [_buttonView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
            [self.contentView addSubview:_buttonView];
            
            self.inspectButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _inspectButton.frame = CGRectMake(CGRectGetWidth(_buttonView.frame)*0.1f, 8.0f, CGRectGetWidth(_buttonView.frame)*0.38f, 32.0f);
            _inspectButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            _inspectButton.backgroundColor = CDZColorOfDefaultColor;
            _inspectButton.enabled = NO;
            [_inspectButton setTitle:@"维修指南" forState:UIControlStateNormal];
            [_inspectButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_inspectButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
            [_inspectButton addTarget:self action:@selector(getRepairGuideVC) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addSubview:_inspectButton];
            
            
            
            self.repairGuideButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _repairGuideButton.frame = CGRectMake(CGRectGetWidth(_buttonView.frame)*0.52f, CGRectGetMinY(_inspectButton.frame), CGRectGetWidth(_buttonView.frame)*0.38f, 32.0f);
            _repairGuideButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            _repairGuideButton.backgroundColor = CDZColorOfDefaultColor;
            _repairGuideButton.enabled = NO;
            [_repairGuideButton setTitle:@"继续检查" forState:UIControlStateNormal];
            [_repairGuideButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_repairGuideButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
            [_repairGuideButton addTarget:self action:@selector(getNexitDiagnosisResult) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addSubview:_repairGuideButton];
            
            
            
            self.wxsSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _wxsSearchButton.frame = CGRectMake(CGRectGetWidth(_buttonView.frame)*0.1, CGRectGetMaxY(_inspectButton.frame)+5.0f, CGRectGetWidth(_buttonView.frame)*0.8, 32.0f);
            _wxsSearchButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            _wxsSearchButton.backgroundColor = CDZColorOfDefaultColor;
            _wxsSearchButton.enabled = NO;
            [_wxsSearchButton setTitle:@"查找商家" forState:UIControlStateNormal];
            [_wxsSearchButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_wxsSearchButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
            [_wxsSearchButton addTarget:self action:@selector(getDiagnosisResult) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addSubview:_wxsSearchButton];
            
            
            
            frame.size.height = frame.size.height-CGRectGetHeight(_buttonView.frame);
        }
        
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.backgroundColor = CDZColorOfClearColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = YES;
        _tableView.bounces = NO ;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_tableView];
        
        
        self.reminderLabel = [[InsetsLabel alloc] initWithFrame:self.contentView.bounds];
        _reminderLabel.text = @"请先选择车系车型";
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
        _reminderLabel.hidden = YES;
        _reminderLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_reminderLabel];
        
    }
}

- (void)popPreviousStepView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushNextStepViewWithData:(NSArray *)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||responseObject.count==0) {
            return;
        }
        InternalDiagnosisVC *vc = InternalDiagnosisVC.new;
        vc.stepIndex = ident;
        vc.typeID = _typeID;
        vc.currentDataList = responseObject;
        vc.ignoreViewResize = YES;
        vc.wasLastResult = (responseObject.firstObject[kObjDetailContentKey]&&![responseObject.firstObject[kObjDetailContentKey] isEqualToString:@""]);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)wasOrTypeCellWithIndexPath:(NSIndexPath *)indexPath {
    if (_stepIndex==SelfDiagnosisStepOne) {
        NSDictionary *detail = [_currentDataList[indexPath.section] objectAtIndex:indexPath.row];
        return [detail[kObjNameKey] isEqualToString:@"space_line"];
    }
    return NO;
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_stepIndex==SelfDiagnosisStepOne) {
        if (self.currentDataList.count>0) {
            return 2;
        }
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_stepIndex==SelfDiagnosisStepOne) {
        return [_currentDataList[section] count];
    }
    return _currentDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InternalDiagnosisCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[InternalDiagnosisCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO);
        cell.detailTextLabel.textColor = CDZColorOfDeepGray;
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    if (_stepIndex==SelfDiagnosisStepOne) {
        if (![self wasOrTypeCellWithIndexPath:indexPath]) {
            NSArray *list = _currentDataList[indexPath.section];
            cell.textLabel.text = [list[indexPath.row] objectForKey:kObjNameKey];
        }else {
            cell.textLabel.text = @"---------------------------------------------";
        }
        
    }else {
        cell.textLabel.text = [_currentDataList[indexPath.row] objectForKey:kObjNameKey];
        if(_wasLastResult) {
            cell.detailTextLabel.text = [_currentDataList[indexPath.row] objectForKey:kObjDetailContentKey];
        }
    }
    
    if ([[cell.textLabel.text substringToIndex:1] isEqualToString:@" "]) {
        cell.textLabel.text = [cell.textLabel.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self wasOrTypeCellWithIndexPath:indexPath]) {
        return 30.0f;
    }
    if (_wasLastResult) {
        CGFloat totalHeight = 30.0f;
        UIFont *textLabelFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        UIFont *detailTextLabelFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO);
        NSString * textLabelText = [_currentDataList[indexPath.row] objectForKey:kObjNameKey];
        NSString * detailTextLabelText = [_currentDataList[indexPath.row] objectForKey:kObjDetailContentKey];
        
        textLabelText= [textLabelText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        textLabelText = [textLabelText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        detailTextLabelText = [detailTextLabelText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        detailTextLabelText = [detailTextLabelText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        totalHeight += [SupportingClass getStringSizeWithString:textLabelText font:textLabelFont widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame), CGFLOAT_MAX) withEdgeInset:DefaultEdgeInsets].height;
        totalHeight += [SupportingClass getStringSizeWithString:detailTextLabelText font:detailTextLabelFont widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame), CGFLOAT_MAX) withEdgeInset:DefaultEdgeInsets].height;
        
        return totalHeight;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_stepIndex==SelfDiagnosisStepOne) {
        return 50.0f;
    }
    
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @autoreleasepool {
        static NSString *headerIdentifier = @"header";
        UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if(!myHeader) {
            myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
            InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                      andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.tag = 10;
            titleLabel.numberOfLines = 0;
            titleLabel.textColor = [UIColor colorWithRed:0.157f green:0.663f blue:0.725f alpha:1.00f];
            titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            [myHeader.contentView addSubview:titleLabel];
            
            if (_stepIndex!=SelfDiagnosisStepOne) {
                UIButton *backPreviousStepBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                backPreviousStepBtn.tag = 11;
                backPreviousStepBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
                backPreviousStepBtn.translatesAutoresizingMaskIntoConstraints = YES;
                backPreviousStepBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [backPreviousStepBtn setTitle:@"上一步" forState:UIControlStateNormal];
                [backPreviousStepBtn setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
                [backPreviousStepBtn addTarget:self action:@selector(popPreviousStepView) forControlEvents:UIControlEventTouchUpInside];
                [myHeader addSubview:backPreviousStepBtn];
                CGFloat width = [SupportingClass getStringSizeWithString:@"上一步" font:backPreviousStepBtn.titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
                backPreviousStepBtn.frame = CGRectMake(0.0f, 0.0f, width+30.0f, CGRectGetHeight(myHeader.frame));
            }
            
            [myHeader setNeedsUpdateConstraints];
            [myHeader updateConstraintsIfNeeded];
            [myHeader setNeedsLayout];
            [myHeader layoutIfNeeded];
        }
        InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
        NSArray *titleList = @[(_wasLastResult?@"诊断结果：":@"问题：")];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.0f, NO);
        titleLabel.textAlignment = NSTextAlignmentCenter;

        if (_stepIndex==SelfDiagnosisStepOne) {
            titleList = @[@"如果您知道您的车辆故障所处的车辆部位，你可以直接选择它：",
                          @"如果您不知道是什么问题，匹配一条符合以下描述的症状："];
            titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
            titleLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        NSString *title = titleList[section];
        titleLabel.text = title;
        [myHeader setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
        return myHeader;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (![self wasOrTypeCellWithIndexPath:indexPath]) {
            self.indexPathForSelectedRow = indexPath;
            if (_wasLastResult) return;
            NSString *theID = @"";
            if (_stepIndex==SelfDiagnosisStepOne) {
                NSArray *list = _currentDataList[indexPath.section];
                theID = [list[indexPath.row] objectForKey:kObjIDKey];
                self.typeID = [SupportingClass verifyAndConvertDataToNumber:[list[indexPath.row] objectForKey:@"type"]];
            }else {
                theID = [_currentDataList[indexPath.row] objectForKey:kObjIDKey];
                self.typeID = [SupportingClass verifyAndConvertDataToNumber:[_currentDataList[indexPath.row] objectForKey:@"type"]];
            }
            [self getAutoSelfAnalyztionAPIsAccessRequestByID:theID requestIdx:_stepIndex+1];
        }else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
}

// 处理结果
- (void)handleDataList:(id)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject) {
            NSLog(@"DataList Error at %@",NSStringFromClass(self.class));
            return;
        }
        if ([responseObject count]==0) {
            NSString *message = @"暂无更多选择";
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        if (ident==0) {
//            NSMutableArray *fristObject = [responseObject[kMajorDescribe] mutableCopy];
//            [fristObject addObject:@{@"id":@"",
//                                     @"name":@"space_line",
//                                     @"type":@"1",
//                                     @"parent_id":@""}];
            responseObject = @[responseObject[kMajorDescribe], responseObject[kLiveDescribe]];
        }
        
        NSMutableArray *totalData = [self.navigationController mutableArrayValueForKey:@"dataLists"];
        if (totalData.count>=ident&&totalData.count!=0) {
            [totalData removeObjectsInRange:NSMakeRange(ident, totalData.count-ident)];
            NSLog(@"%@ - totalData::%d", NSStringFromClass(self.class), totalData.count);
        }
        [totalData addObject:responseObject];
        
        if (ident==0) {
            self.currentDataList = responseObject;
            [self.tableView reloadData];
        }else {
            [self pushNextStepViewWithData:responseObject withIdent:ident];
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
    AutosSelectedView *asview = [(InternalDiagnosisNav *)self.navigationController ASView];
    [[APIsConnection shareConnection] commonAPIsGetAutoSelfDiagnosisStepListWithStep:currentIndex nextStepID:theIDString seriesID:asview.autoData.seriesID modelID:asview.autoData.modelID typeID:_typeID success:^(NSURLSessionDataTask *operation, id responseObject) {
        [operation setUserInfo:@{@"iden":@(currentIndex)}];
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
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

- (void)getDiagnosisResult {
    NSString *reasonName = [_currentDataList[_indexPathForSelectedRow.row] objectForKey:kObjNameKey];
    if (!reasonName) {
        NSLog(@"Missing Part Name");
        return;
    }
    
    AutosSelectedView *asview = [(InternalDiagnosisNav *)self.navigationController ASView];
    NSString *brandId = asview.autoData.brandID;
    NSNumber *pageNums = @(1);
    NSNumber *pageSizes = @(10);
    NSNumber *longitude = @(112.979353);
    NSNumber *latitude = @(28.213478);
    NSNumber *cityID = @(197);
//    [ProgressHUDHandler showHUD];
//    [[APIsConnection shareConnection] selfDiagnoseAPIsGetDiagnoseResultListWithReasonName:reasonName brandId:brandId pageNums:pageNums pageSizes:pageSizes longitude:longitude latitude:latitude cityID:cityID success:^(NSURLSessionDataTask *operation, id responseObject) {
//        
//        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
//        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
//        NSLog(@"%@",message);
//        [ProgressHUDHandler dismissHUD];
//        if (errorCode!=0) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return ;
//        }
//        if (responseObject) {
//            [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfSDCResult object:nil userInfo:@{CDZKeyOfResultKey:responseObject[CDZKeyOfResultKey]}];
//        }
//        
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [ProgressHUDHandler dismissHUD];
//        if (error.code==-1009) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return;
//        }
//        
//        
//        if (error.code==-1001) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return;
//        }
//        
//        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//        }];
//    }];
}

- (void)getNexitDiagnosisResult {
    NSString *reasonName = [_currentDataList[_indexPathForSelectedRow.row] objectForKey:kObjNameKey];
    NSString *repairGuideID = [_currentDataList[_indexPathForSelectedRow.row] objectForKey:kObjRepairGuideID];
    if (!reasonName||!repairGuideID) {
        NSLog(@"Missing Parameters");
        return;
    }
    [self getNexitDiagnosisResultDetail:repairGuideID withTitle:reasonName];
}

- (void)getNexitDiagnosisResultDetail:(NSString *)procedureDetailID  withTitle:(NSString *)title {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairStepGuideDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (responseObject) {
            
            [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfNextDiagnosisResult object:nil userInfo:@{CDZKeyOfResultKey:responseObject[CDZKeyOfResultKey], @"procedureID":procedureDetailID, @"title":title}];
        }
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
    }];
}

- (void)getRepairGuideVC {
    NSString *reasonName = [_currentDataList[_indexPathForSelectedRow.row] objectForKey:kObjNameKey];
    NSString *repairGuideID = [_currentDataList[_indexPathForSelectedRow.row] objectForKey:kObjRepairGuideID];
    if (!reasonName||!repairGuideID) {
        NSLog(@"Missing Parameters");
        return;
    }
    
    [self getRepairGuideProcedureDetail:repairGuideID withTitle:reasonName];
}

- (void)getRepairGuideProcedureDetail:(NSString *)procedureDetailID withTitle:(NSString *)title {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (responseObject) {
            
            [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfRepairGuideResult object:nil userInfo:@{CDZKeyOfResultKey:responseObject[CDZKeyOfResultKey], @"title":title}];
        }
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
    }];
}


@end
