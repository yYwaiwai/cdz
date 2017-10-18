//
//  MyAutoInsuranceApplyFormVC.m
//  cdzer
//
//  Created by KEns0n on 10/17/15.
//  Copyright © 2015 CDZER. All rights reserved.
//
#define kSubContainerKey @"subContainerKey"
#define kInsuranceType @"insuranceType"
#define kObjectList @"objectList"
#define kCurrentSelectionID @"currentSelectionID"
#define kObjectDependencyActiveKeyList @"objectDependencyActiveKeyList"
#define kHasDependencyObject @"hasDependencyObject"

#define kPremiumCost @"premiumCost"
#define kCoverageCost @"coverageCost"
#define kTitle @"title"
#define kFlodingKey @"flodingKey"
#define kActiveDateKey @"activeDateKey"
#define kIsActiveKey @"isActiveKey"
#define kInsuranceList @"insuranceList"

#define vThemeColor [UIColor colorWithRed:0.129f green:0.796f blue:0.604f alpha:1.00f]

#import "MyAutoInsuranceApplyFormVC.h"
#import "MyAutoInsuranceInfoFormVC.h"
#import "MAIDAutosDetailView.h"
#import "MAIDSelectionView.h"
#import "MAIDetailCell.h"
#import "InsetsLabel.h"
#import "IQDropDownTextField.h"
#import "MyAutoInsuranceVC.h"

@interface CompanySelectView : UITableViewCell

@property (nonatomic, strong) UIButton *activeButton;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation CompanySelectView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _activeButton.frame = self.bounds;
        _activeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _activeButton.translatesAutoresizingMaskIntoConstraints = YES;
        self.arrowView = [UIImageView.alloc initWithImage:ImageHandler.getRightArrow];
        [self addSubview:_activeButton];
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.accessoryView = userInteractionEnabled?_arrowView:nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    detailTextLabelFrame.origin.x = CGRectGetMaxX(self.textLabel.frame);
    detailTextLabelFrame.size.width = CGRectGetWidth(self.frame)-CGRectGetMaxX(self.textLabel.frame);
    if (self.accessoryView) {
        detailTextLabelFrame.size.width = CGRectGetMinX(self.accessoryView.frame)-CGRectGetMaxX(self.textLabel.frame);
    }
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end

@interface MyAutoInsuranceApplyFormVC ()<UITableViewDataSource, UITableViewDelegate, IQDropDownTextFieldDelegate>

@property (nonatomic, strong) MAIDAutosDetailView *autosDetailView;

@property (nonatomic, strong) MAIDSelectionView *selectionView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *configList;

@property (nonatomic, strong) NSArray *finalConfigList;

@property (nonatomic, strong) CompanySelectView *companyView;

@property (nonatomic, assign) BOOL isFolding;

@property (nonatomic, assign) BOOL isShowFinalResult;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) InsetsLabel *finalPriceLabel;

@property (nonatomic, strong) InsetsLabel *totalPriceLabel;

@property (nonatomic, strong) InsetsLabel *actualPriceLabel;

@property (nonatomic, strong) InsetsLabel *discountPriceLabel;

@property (nonatomic, strong) UIButton *presubmitButton;

@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, assign) IQDropDownTextField *dateTimeTextField;

@property (nonatomic, strong) UIView *tableHeaderView;

@end

@implementation MyAutoInsuranceApplyFormVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = getLocalizationString(@"my_insurance_appointment");
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_autosDetailView updateAutosInsuranceData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    if (!_configList) {
        self.configList = [@[] mutableCopy];
    }
    self.isFolding = NO;
    self.isShowFinalResult = NO;
    
    [self.configList addObjectsFromArray:@[@{kTitle:@"交强险",
                                             kActiveDateKey:@"autosTALCInsuranceActiveDate",
                                             kInsuranceList:@[@{kTitle:@"交强险 + 车船税", kIsActiveKey:@"autosTALCInsuranceActive", kPremiumCost:@"TALCIWithVAVTax",}]},
                                           @{kTitle:@"商业险",
                                             kActiveDateKey:@"commerceInsuranceActiveDate",
                                             kInsuranceList:@[@{kTitle:@"车辆损失险", kIsActiveKey:@"autosDamageInsuranceActive", kPremiumCost:@"autosDamageInsurance",
                                                                kHasDependencyObject:@YES},
                                                              @{kTitle:@"商业第三者责任保险", kSubContainerKey:@"thirdPartyLiabilityInsurance", kIsActiveKey:@"isActive",
                                                                kHasDependencyObject:@YES},
                                                              @{kTitle:@"全车盗抢险", kIsActiveKey:@"robberyAndTheftInsuranceActive", kPremiumCost:@"robberyAndTheftInsurance",
                                                                kHasDependencyObject:@YES},
                                                              @{kTitle:@"驾驶人责任险", kSubContainerKey:@"driverLiabilityInsurance", kIsActiveKey:@"isActive",
                                                                kHasDependencyObject:@YES},
                                                              @{kTitle:@"乘客责任险", kSubContainerKey:@"passengerLiabilityInsurance", kIsActiveKey:@"isActive",
                                                                kHasDependencyObject:@YES},]},
                                           @{kTitle:@"更多附加保险保障", kFlodingKey:@"isFolding",
                                             kInsuranceList:@[// 车辆损失险属下险
                                                              @{kTitle:@"玻璃单独破碎险", kSubContainerKey:@"windshieldDamageInsurance", kIsActiveKey:@"isActive",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              @{kTitle:@"自燃损失险", kSubContainerKey:@"fireInsurance", kIsActiveKey:@"isActive",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              
                                                              @{kTitle:@"车身划痕损失险", kSubContainerKey:@"scratchDamageInsurance", kIsActiveKey:@"isActive",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              @{kTitle:@"指定专修厂特约险", kIsActiveKey:@"specifyServiceFactoryInsuranceActive", kPremiumCost:@"specifyServiceFactoryInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              
                                                              @{kTitle:@"倒车镜与车灯单独损坏险", kSubContainerKey:@"sideMirrorAndHeadlightDamageInsurance", kIsActiveKey:@"isActive",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              @{kTitle:@"涉水行驶损失险", kIsActiveKey:@"wadingDrivingInsuranceActive", kPremiumCost:@"wadingDrivingInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"], kHasDependencyObject:@YES},
                                                              
                                                              // 不计免赔特约险
                                                              @{kTitle:@"不计免赔特约险-车损", kIsActiveKey:@"extraADInsuranceActive", kPremiumCost:@"extraADInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"autosDamageInsuranceActive"]},
                                                              @{kTitle:@"不计免赔特约险-盗抢", kIsActiveKey:@"extraRATInsuranceActive", kPremiumCost:@"extraRATInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"robberyAndTheftInsuranceActive"]},
                                                              @{kTitle:@"不计免赔特约险-三者", kIsActiveKey:@"extraTPLInsuranceActive", kPremiumCost:@"extraTPLInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"thirdPartyLiabilityInsurance.isActive"]},
                                                              
                                                              
                                                              @{kTitle:@"不计免赔特约险-司机乘客", kIsActiveKey:@"extraDLNPLInsuranceActive", kPremiumCost:@"extraDLNPLInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"passengerLiabilityInsurance.isActive",
                                                                                                 @"driverLiabilityInsurance.isActive"]},

                                                              @{kTitle:@"不计免赔特约险-附加险", kIsActiveKey:@"extraPlusInsuranceActive", kPremiumCost:@"extraPlusInsurance",
                                                                kObjectDependencyActiveKeyList:@[@"windshieldDamageInsurance.isActive",
                                                                                                 @"fireInsurance.isActive",
                                                                                                 @"scratchDamageInsurance.isActive",
                                                                                                 @"specifyServiceFactoryInsuranceActive",
                                                                                                 @"sideMirrorAndHeadlightDamageInsurance.isActive",
                                                                                                 @"wadingDrivingInsuranceActive"]},
                                                              ]}]];
    
    
}

- (void)showForm {
    [self pushToInsuranceFormVCWithTitle:nil isFirstTime:NO isShowCancelBtn:NO];
}

- (void)pushToInsuranceFormVCWithTitle:(NSString *)title isFirstTime:(BOOL)isFirstTime isShowCancelBtn:(BOOL)isShowCancelBtn {
    
    @autoreleasepool {
        // MyAutoInsuranceInfoFormVC 个人车辆保险信息VC
        MyAutoInsuranceInfoFormVC *vc = [MyAutoInsuranceInfoFormVC new];
        vc.isShowCancelBtn = isShowCancelBtn;
        vc.isFirstTime = isFirstTime;
        [self setNavBackButtonTitleOrImage:title titleColor:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)initializationUI {
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-70.0f, CGRectGetWidth(self.contentView.frame), 70.0f)];
    _bottomView.backgroundColor = CDZColorOfWhite;
    [_bottomView setViewBorderWithRectBorder:UIRectBorderTop borderSize:1.0f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    [self.contentView addSubview:_bottomView];
    
    self.actualPriceLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, CGRectGetWidth(_bottomView.frame), 20.f)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _actualPriceLabel.hidden = YES;
    _actualPriceLabel.text = @"原价：¥";
    _actualPriceLabel.textColor = CDZColorOfOrangeColor;
    [_bottomView addSubview:_actualPriceLabel];
    
    self.discountPriceLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_actualPriceLabel.frame), CGRectGetWidth(_bottomView.frame), 20.f)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _discountPriceLabel.hidden = YES;
    _discountPriceLabel.text = @"优惠：¥";
    _discountPriceLabel.textColor = CDZColorOfRed;
    [_bottomView addSubview:_discountPriceLabel];
    
    self.finalPriceLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_discountPriceLabel.frame), CGRectGetWidth(_bottomView.frame), 20.f)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _finalPriceLabel.text = @"现价：¥";
    _finalPriceLabel.hidden = YES;
    _finalPriceLabel.textColor = vThemeColor;
    [_bottomView addSubview:_finalPriceLabel];
    
    
    self.totalPriceLabel = [[InsetsLabel alloc] initWithFrame:_bottomView.bounds
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _totalPriceLabel.text = @"总计：¥";
    _totalPriceLabel.textColor = CDZColorOfDefaultColor;
    [_bottomView addSubview:_totalPriceLabel];
    
    
    CGFloat width = CGRectGetWidth(_bottomView.frame)*0.3f;
    self.presubmitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _presubmitButton.frame = CGRectMake(CGRectGetWidth(_bottomView.frame)-width-15.0f, 0.0f, width, 36.0f);
    _presubmitButton.center = CGPointMake(_presubmitButton.center.x, CGRectGetHeight(_bottomView.frame)/2.0f);
    _presubmitButton.backgroundColor = CDZColorOfOrangeColor;
    [_presubmitButton setTitle:@"预约" forState:UIControlStateNormal];
    [_presubmitButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_presubmitButton addTarget:self action:@selector(showFinalSelectionResult) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_presubmitButton];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitButton.hidden = YES;
    _submitButton.frame = _presubmitButton.frame;
    _submitButton.backgroundColor = CDZColorOfDefaultColor;
    [_submitButton setTitle:@"确认预约" forState:UIControlStateNormal];
    [_submitButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(submitAppointment) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_submitButton];
    
    
    self.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 150.0f)];
    
    self.autosDetailView = [[MAIDAutosDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 106.0f)];
    [_autosDetailView autosRegisterbuttonAddTarget:self action:@selector(showForm) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeaderView addSubview:_autosDetailView];
    
    self.companyView = [[CompanySelectView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _companyView.frame = CGRectMake(0.0f, CGRectGetMaxY(_autosDetailView.frame), CGRectGetWidth(self.contentView.frame), 44.0f);
    _companyView.textLabel.textColor = CDZColorOfOrangeColor;
    _companyView.textLabel.text = @"保险公司：";
    _companyView.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO);
    _companyView.detailTextLabel.textColor = CDZColorOfLightGray;
    _companyView.detailTextLabel.text = @"请选择保险公司";
    _companyView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    _companyView.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 18.0f, NO);
    [_companyView.activeButton addTarget:self action:@selector(showCompanySelectionView) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeaderView addSubview:_companyView];
    
    CGRect tvFrame = self.contentView.bounds;
    tvFrame.size.height = CGRectGetMinY(_bottomView.frame);
    self.tableView = [[UITableView alloc] initWithFrame:tvFrame];
    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = _tableHeaderView;
    _tableView.allowsSelection = YES;
    _tableView.allowsMultipleSelection = YES;
    _tableView.allowsSelectionDuringEditing = NO;
    _tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.contentView addSubview:_tableView];
    
    self.selectionView = [MAIDSelectionView new];
    
    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, autosDetailView.isReady) subscribeNext:^(NSNumber *isReady) {
        if (isReady.boolValue) {
            [ProgressHUDHandler dismissHUD];
        }else {
            [ProgressHUDHandler showHUD];
        }
    }];
    
    
    [RACObserve(self, autosDetailView.autosInsuranceDetail.insuranceCompanyList.currentSelectionID) subscribeNext:^(NSNumber *currentSelectionID) {
        @strongify(self);
        NSArray *listArray = self.autosDetailView.autosInsuranceDetail.insuranceCompanyList.objectList;
        if (currentSelectionID&&currentSelectionID.integerValue>=0) {
            MAIDConfigCompanyObject *companyDetail = listArray[currentSelectionID.integerValue];
            self.companyView.detailTextLabel.textColor = CDZColorOfBlack;
            self.companyView.detailTextLabel.text = companyDetail.companyName;
        }else {
            self.companyView.detailTextLabel.textColor = CDZColorOfLightGray;
            self.companyView.detailTextLabel.text = @"请选择保险公司";
        }
    }];
    
    
    [RACObserve(self, autosDetailView.autosInsuranceDetail) subscribeNext:^(NSDictionary *autosInsuranceDetail) {
        @strongify(self);
        NSLog(@"%@", autosInsuranceDetail);
        if (autosInsuranceDetail) {
            [self.tableView reloadData];
        }
    }];
    
    [RACObserve(self, autosDetailView.frame) subscribeNext:^(id theRect) {
        @strongify(self);
        CGRect rect = [theRect CGRectValue];
        
        CGRect cFrame = self.companyView.frame;
        cFrame.origin.y = CGRectGetMaxY(rect);
        self.companyView.frame = cFrame;
        
        CGRect sFrame = self.tableHeaderView.frame;
        sFrame.size.height = CGRectGetMaxY(self.companyView.frame);
        self.tableHeaderView.frame = sFrame;
        
        self.tableView.tableHeaderView = nil;
        self.tableView.tableHeaderView = self.companyView.superview;
    }];
}

- (void)showCompanySelectionView {
    if (!_selectionView) {
        self.selectionView = [MAIDSelectionView new];
    }
    MAIDConfigSubObject *configObject = _autosDetailView.autosInsuranceDetail.insuranceCompanyList;
    NSArray *dataList = [configObject.objectList valueForKeyPath:@"companyName"];
    _selectionView.currentSelectionID =  configObject.currentSelectionID;

    @weakify(self);
    [_selectionView setTitle:@"保险公司" withDataList:dataList andWasShowButton:NO responseBlock:^(BOOL isConfirm, NSInteger currentSelectionID) {
        @strongify(self);
        self.autosDetailView.autosInsuranceDetail.insuranceCompanyList.currentSelectionID = currentSelectionID;
    }];
}

- (void)showFinalSelectionResult {
    CDZMAIDConfigMissType type = _autosDetailView.autosInsuranceDetail.wasAllInsuranceDataComplete;
    if (type!=CDZMAIDConfigMissTypeOfNotingMiss) {
        
        NSString *message = nil;
        switch (type) {
            case CDZMAIDConfigMissTypeOfInsuranceDidNotSelected:
                message = @"请至少选择一行保险";
                break;
            case CDZMAIDConfigMissTypeOfInsuranceCompanyDidNotSelected:
                message = @"请选择保险公司";
                break;
            case CDZMAIDConfigMissTypeOfTALCIActiveDateDidNotSelected:
                message = @"请选择交强险的生效日期";
                break;
            case CDZMAIDConfigMissTypeOfCommerceInsuranceActiveDateDidNotSelected:
                message = @"请选择商业险的生效日期";
                break;
                
            default:
                break;
        }
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            if (CDZMAIDConfigMissTypeOfInsuranceDidNotSelected!=type) {
                if (CDZMAIDConfigMissTypeOfInsuranceCompanyDidNotSelected==type) {
                    [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f)];
                    return;
                }
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
        }];
        return;
    }
    self.isShowFinalResult = YES;
    [_autosDetailView hiddenButton];
    _tableView.allowsSelection = !_isShowFinalResult;
    _tableView.allowsMultipleSelection = !_isShowFinalResult;
    @weakify(self);
    NSMutableArray *finalConfigList = [@[] mutableCopy];
    [_configList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull sectionDetail, NSUInteger sectionIdx, BOOL * _Nonnull sectionStop) {
        NSMutableDictionary *newSectionDetail = [sectionDetail mutableCopy];
        NSMutableArray *insuranceList = [@[] mutableCopy];
        [sectionDetail[kInsuranceList] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull rowDetail, NSUInteger rowIdx, BOOL * _Nonnull rowStop) {
            @strongify(self);
            NSString *subContainerKey = rowDetail[kSubContainerKey];
            NSString *isActiveKey = rowDetail[kIsActiveKey];
            if (subContainerKey) {
                isActiveKey = [subContainerKey stringByAppendingPathExtension:isActiveKey];
            }
            BOOL isActive = [[self.autosDetailView.autosInsuranceDetail valueForKeyPath:isActiveKey] boolValue];
            if (isActive) {
                [insuranceList addObject:rowDetail];
            }
        }];
        if (insuranceList.count>0) {
            [newSectionDetail setObject:insuranceList forKey:kInsuranceList];
            [finalConfigList addObject:newSectionDetail];
        }
        
    }];
    [self setLeftNavButtonWithTitleOrImage:@"cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelFinalSelectionResult) titleColor:nil isNeedToSet:YES];
    _actualPriceLabel.hidden = NO;
    _discountPriceLabel.hidden = YES;
    _finalPriceLabel.hidden = NO;
    _submitButton.hidden = NO;
    _totalPriceLabel.hidden = YES;
    _presubmitButton.hidden = YES;
    self.finalConfigList = finalConfigList;
    _companyView.userInteractionEnabled = NO;
    [_tableView reloadData];
}

- (void)cancelFinalSelectionResult {
    self.isShowFinalResult = NO;
    [_autosDetailView showButton];
    _tableView.allowsSelection = !_isShowFinalResult;
    _tableView.allowsMultipleSelection = !_isShowFinalResult;
    self.navigationItem.leftBarButtonItem = nil;
    _actualPriceLabel.hidden = YES;
    _discountPriceLabel.hidden = YES;
    _finalPriceLabel.hidden = YES;
    _submitButton.hidden = YES;
    _totalPriceLabel.hidden = NO;
    _presubmitButton.hidden = NO;
    _companyView.userInteractionEnabled = YES   ;
    self.finalConfigList = nil;
    [_tableView reloadData];
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_isShowFinalResult) {
        return _finalConfigList.count;
    }
    return _configList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_isShowFinalResult) {
        return [[_finalConfigList[section] objectForKey:kInsuranceList] count];;
    }
    if (!self.isFolding&&section==2) {
        return 0;
    }
    return [[_configList[section] objectForKey:kInsuranceList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MAIDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[MAIDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    [self updateTableViewCellUIData:cell forRowAtIndexPath:indexPath withTableView:tableView isUpdateSelection:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    @autoreleasepool {
//        NSDictionary *sectionDetail = self.configList[indexPath.section];
//        NSDictionary *rowDetail =  [sectionDetail[kInsuranceList] objectAtIndex:indexPath.row];
//        NSString *objectDependencyActiveKey = rowDetail[kObjectDependencyActiveKey];
//        if (objectDependencyActiveKey) {
//            BOOL isActive = [[_autosDetailView.autosInsuranceDetail valueForKeyPath:objectDependencyActiveKey] boolValue];
//            if (!isActive) {
//                return 0;
//            }
//        }
//    }
    return 54.0f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self updateTableViewCellUIData:nil forRowAtIndexPath:indexPath withTableView:tableView isUpdateSelection:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self updateTableViewCellUIData:nil forRowAtIndexPath:indexPath withTableView:tableView isUpdateSelection:YES];
}


- (void)updateTableViewCellUIData:(nullable UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
                    withTableView:(nullable UITableView *)tableView isUpdateSelection:(BOOL)updateSelection {
    if (!indexPath) return;
    if (!_autosDetailView.autosInsuranceDetail) return;
    if (!tableView) tableView = _tableView;
    if (!cell) cell = [tableView cellForRowAtIndexPath:indexPath];
    [(MAIDetailCell *)cell setIsShowFinalResult:_isShowFinalResult];
    BOOL selected = [tableView.indexPathsForSelectedRows containsObject:indexPath];
    
    NSDictionary *sectionDetail = _isShowFinalResult?self.finalConfigList[indexPath.section]:self.configList[indexPath.section];
    NSDictionary *rowDetail =  [sectionDetail[kInsuranceList] objectAtIndex:indexPath.row];
    
    if (rowDetail) {
        @weakify(self);
        NSString *subContainerKey = @"";
        NSString *coverageCost = nil;
        NSNumber *premiumCost = nil;
        if (rowDetail[kSubContainerKey]) subContainerKey = rowDetail[kSubContainerKey];
        NSString *title = rowDetail[kTitle];
        
        
        NSArray *objectDependencyActiveKeyList = rowDetail[kObjectDependencyActiveKeyList];
        __block BOOL isDependencyActive = NO;
        if (objectDependencyActiveKeyList&&objectDependencyActiveKeyList.count>=1) {
            [objectDependencyActiveKeyList enumerateObjectsUsingBlock:^(NSString * _Nonnull dependencyKey, NSUInteger dependencyIdx, BOOL * _Nonnull keyStop) {
                @strongify(self);
                if ([[self.autosDetailView.autosInsuranceDetail valueForKeyPath:dependencyKey] boolValue]) {
                    isDependencyActive = YES;
                    *keyStop = YES;
                }
            }];
        }else {
            isDependencyActive = YES;
        }

        if ([subContainerKey isEqualToString:@""]) {
            if (rowDetail[kCoverageCost]) {
                NSString *coverageCostKey = rowDetail[kCoverageCost];
                coverageCost = [_autosDetailView.autosInsuranceDetail valueForKeyPath:coverageCostKey];
            }
            
            if (rowDetail[kPremiumCost]) {
                NSString *premiumCostKey = rowDetail[kPremiumCost];
                premiumCost = [_autosDetailView.autosInsuranceDetail valueForKeyPath:premiumCostKey];
            }
            
            
            NSString *activeKey = rowDetail[kIsActiveKey];
            if (updateSelection) {
                if (!isDependencyActive){
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    selected = NO;
                }
                
                [self.autosDetailView.autosInsuranceDetail setValue:@(selected) forKeyPath:activeKey];
                
                if (rowDetail[kHasDependencyObject]&&[rowDetail[kHasDependencyObject] boolValue]) {
                    [self updateDependencyInsuranceWithActiveKey:activeKey];
                }
            }else {
                NSNumber *isActive = [self.autosDetailView.autosInsuranceDetail valueForKeyPath:activeKey];
                if (isActive.boolValue) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    selected = YES;
                }
            }
            [(MAIDetailCell *)cell updateUIDataWithTitle:title isSelected:selected coverageCost:coverageCost coverageCostIsTitle:NO premiumCost:premiumCost];
            [self updateAllTotalPrice];
            
            
        }else {
            
            
            if (!_selectionView) {
                self.selectionView = [MAIDSelectionView new];
            }
            
            MAIDConfigSubObject *configObject = [_autosDetailView.autosInsuranceDetail valueForKeyPath:subContainerKey];
            NSArray *dataList = [configObject.objectList valueForKeyPath:@"coverageCost"];
            switch (configObject.insuranceType) {
                case CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance:
                case CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance:
                    dataList = nil;
                    dataList = [configObject.objectList valueForKeyPath:@"insuranceName"];
                    break;
                default:
                    break;
            }
            
            NSString *activeKey = [subContainerKey stringByAppendingFormat:@".%@", rowDetail[kIsActiveKey]];
            if (updateSelection) {
                _selectionView.currentSelectionID =  configObject.currentSelectionID;
                if (selected&&isDependencyActive) {
                    [_selectionView setTitle:title withDataList:dataList andWasShowButton:NO responseBlock:^(BOOL isConfirm, NSInteger currentSelectionID) {
                        @strongify(self);
                        [self.autosDetailView.autosInsuranceDetail setValue:@(isConfirm) forKeyPath:activeKey];
                        NSLog(@"Current %@ Active Value:%@", activeKey, [self.autosDetailView.autosInsuranceDetail valueForKeyPath:activeKey]);
                        
                        if (isConfirm) {
                            [self.autosDetailView.autosInsuranceDetail setValue:@(currentSelectionID) forKeyPath:[subContainerKey stringByAppendingFormat:@".%@", kCurrentSelectionID]];
                            NSLog(@"aaaa%@", [self.autosDetailView.autosInsuranceDetail valueForKeyPath:[subContainerKey stringByAppendingFormat:@".%@", kCurrentSelectionID]]);
                        }else {
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        }
                        
                        [self updateTableViewCellUIData:cell forRowAtIndexPath:indexPath withTableView:tableView isUpdateSelection:NO];
                        if (rowDetail[kHasDependencyObject]&&[rowDetail[kHasDependencyObject] boolValue]) {
                            [self updateDependencyInsuranceWithActiveKey:activeKey];
                        }
                        [self updateAllTotalPrice];
                        
                    }];
                }else {
                    if (selected) {
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                    selected = NO;
                    [self.autosDetailView.autosInsuranceDetail setValue:@(-1) forKeyPath:[subContainerKey stringByAppendingFormat:@".%@", kCurrentSelectionID]];
                    NSLog(@"%@", [self.autosDetailView.autosInsuranceDetail valueForKeyPath:[subContainerKey stringByAppendingFormat:@".%@", kCurrentSelectionID]]);
                    [self.autosDetailView.autosInsuranceDetail setValue:@(selected) forKeyPath:activeKey];
                    NSLog(@"Current %@ Active Value:%@", activeKey, [self.autosDetailView.autosInsuranceDetail valueForKeyPath:activeKey]);
                    
                    [self updateTableViewCellUIData:cell forRowAtIndexPath:indexPath withTableView:tableView isUpdateSelection:NO];
                    
                    if (rowDetail[kHasDependencyObject]&&[rowDetail[kHasDependencyObject] boolValue]) {
                        [self updateDependencyInsuranceWithActiveKey:activeKey];
                    }
                    [self updateAllTotalPrice];
                    
                }
                
                
                
            }else {
                BOOL isTitle = NO;
                if (configObject.insuranceType==CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance||
                    configObject.insuranceType==CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance) {
                    isTitle = YES;
                }
                if (configObject.currentSelectionID>=0&&configObject.currentSelectionID<=(configObject.objectList.count-1)) {
                    MAIDConfigObjectDetail *configDetail = configObject.configDetail;
                    
                    premiumCost = configDetail.premiumCost;
                    
                    switch (configObject.insuranceType) {
                            
                        case CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance:
                        case CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance:
                            coverageCost = configDetail.insuranceName;
                            break;
                            
                        case CDZMAIDConfigTypeOfDriverLiabilityInsurance:
                        case CDZMAIDConfigTypeOfVehicleFireInsurance:
                        case CDZMAIDConfigTypeOfPassengerLiabilityInsurance:
                        case CDZMAIDConfigTypeOfVehicleScratchDamageInsurance:
                        case CDZMAIDConfigTypeOfThirdPartyLiabilityInsurance:
                            coverageCost = configDetail.coverageCost;
                            break;
                            
                        case CDZMAIDConfigTypeForComanyList:
                        default:
                            break;
                    }
                }
                
                NSNumber *isActive = [self.autosDetailView.autosInsuranceDetail valueForKeyPath:activeKey];
                if (isActive.boolValue) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    selected = YES;
                }
                
                [(MAIDetailCell *)cell updateUIDataWithTitle:title isSelected:selected coverageCost:coverageCost coverageCostIsTitle:isTitle premiumCost:premiumCost];
            }
            
        }
    }
    
    
}

- (void)updateDependencyInsuranceWithActiveKey:(NSString *)activeKey{
    @autoreleasepool {
        if (!activeKey||[activeKey isEqualToString:@""]) return;
        @weakify(self);
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if ([evaluatedObject isKindOfClass:NSString.class]) {
                return ([(NSString *)evaluatedObject rangeOfString:activeKey].location!=NSNotFound);
            }
            return NO;
        }];
        
        [_configList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull sectionDetail, NSUInteger section, BOOL * _Nonnull sectionStop) {
            if (section>1) {
                [sectionDetail[kInsuranceList] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull rowDetail, NSUInteger row, BOOL * _Nonnull rowStop) {
                    
                    NSArray *objectDependencyActiveKeyList = rowDetail[kObjectDependencyActiveKeyList];
                    if (objectDependencyActiveKeyList&&objectDependencyActiveKeyList.count>=1) {
                        NSArray *keyWasContains = [objectDependencyActiveKeyList filteredArrayUsingPredicate:predicate];
                        if (!keyWasContains||keyWasContains.count==0) return;
                        
                        
                        @strongify(self);
                        __block BOOL isDependencyActive = NO;
                        [objectDependencyActiveKeyList enumerateObjectsUsingBlock:^(NSString * _Nonnull dependencyKey, NSUInteger dependencyIdx, BOOL * _Nonnull keyStop) {
                            @strongify(self);
                            if ([[self.autosDetailView.autosInsuranceDetail valueForKeyPath:dependencyKey] boolValue]) {
                                isDependencyActive = YES;
                                *keyStop = YES;
                            }
                        }];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        NSLog(@"%@",self.tableView.indexPathsForSelectedRows);
                        BOOL rowWasDeselected = [self.tableView.indexPathsForSelectedRows containsObject:indexPath];
                        if (!isDependencyActive&&rowWasDeselected) [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [self updateTableViewCellUIData:nil forRowAtIndexPath:indexPath withTableView:nil isUpdateSelection:!isDependencyActive];
                        
                    }
                    
                }];
            }
        }];
    }
    
}

- (void)updateAllTotalPrice {
    self.finalPriceLabel.text = [NSString stringWithFormat:@"参考价格：¥%0.2f",  _autosDetailView.autosInsuranceDetail.totalPrice.doubleValue];
    self.discountPriceLabel.text = [NSString stringWithFormat:@"商业险折扣：¥%0.2f",  _autosDetailView.autosInsuranceDetail.discountPrice.doubleValue];
    self.actualPriceLabel.text = [NSString stringWithFormat:@"原价：¥%0.2f",  _autosDetailView.autosInsuranceDetail.actualPrice.doubleValue];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"参考总价：¥%0.2f",  _autosDetailView.autosInsuranceDetail.actualPrice.doubleValue];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
        titleLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
        titleLabel.textColor = CDZColorOfWhite;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.tag = 10;
        titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [myHeader addSubview:titleLabel];
        
        CGRect buttonRect = myHeader.bounds;
        buttonRect.size.width = 60.0f;
        buttonRect.origin.x = CGRectGetWidth(tableView.bounds)-CGRectGetWidth(buttonRect);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonRect;
        button.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        button.selected = NO;
        button.tag = 11;
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        button.translatesAutoresizingMaskIntoConstraints = YES;
        [button setTitle:@"展开＋" forState:UIControlStateNormal];
        [button setTitle:@"收起－" forState:UIControlStateSelected];
        [button setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [button setTitleColor:CDZColorOfOrangeColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(extraInsuranceSelection:) forControlEvents:UIControlEventTouchUpInside];
        [myHeader addSubview:button];

        UIToolbar *toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolBar setItems:buttonsArray];
        
        IQDropDownTextField *dateTimeTextField = IQDropDownTextField.new;
        dateTimeTextField.tag = 13;
        dateTimeTextField.textColor = CDZColorOfClearColor;
        dateTimeTextField.frame = CGRectMake(CGRectGetWidth(myHeader.frame)*0.4f, 0.0f, CGRectGetWidth(myHeader.frame)*0.6f, 0.0f);
        dateTimeTextField.delegate = self;
        dateTimeTextField.inputAccessoryView = toolBar;
        dateTimeTextField.dropDownMode = IQDropDownModeDatePicker;
        dateTimeTextField.datePickerMode = UIDatePickerModeDate;
        [dateTimeTextField.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [myHeader addSubview:dateTimeTextField];
        
        NSMutableAttributedString *dateAttributedString = [NSMutableAttributedString new];
        [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"生效日期：" attributes:@{NSForegroundColorAttributeName:vThemeColor}]];
        [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"请选择日期" attributes:@{NSForegroundColorAttributeName:CDZColorOfLightGray}]];
        
        UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dateButton.frame = myHeader.bounds;
        dateButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        dateButton.selected = NO;
        dateButton.tag = 12;
        dateButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        dateButton.translatesAutoresizingMaskIntoConstraints = YES;
        dateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        dateButton.titleEdgeInsets = DefaultEdgeInsets;
        [dateButton setAttributedTitle:dateAttributedString forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(showDateSelector:) forControlEvents:UIControlEventTouchUpInside];
        [myHeader addSubview:dateButton];
        
        [myHeader setNeedsUpdateConstraints];
        [myHeader updateConstraintsIfNeeded];
        [myHeader setNeedsLayout];
        [myHeader layoutIfNeeded];
    }
    
    InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
    titleLabel.text = [_configList[section] objectForKey:kTitle];
    
    UIButton *button = (UIButton *)[myHeader viewWithTag:11];
    UIButton *dateButton = (UIButton *)[myHeader viewWithTag:12];
    IQDropDownTextField *dateTimeTextField = (IQDropDownTextField *)[myHeader viewWithTag:13];
    
    dateTimeTextField.hidden = YES;
    button.hidden = YES;
    dateButton.userInteractionEnabled = !_isShowFinalResult;
    dateButton.hidden = YES;
    
    
    
    NSString *isFoldingKey = [_configList[section] objectForKey:kFlodingKey];
    if (isFoldingKey&&!_isShowFinalResult) {
        button.hidden = NO;
        button.selected = [[self valueForKeyPath:isFoldingKey] boolValue];
    }
    
    NSString *activeDateKey = [_configList[section] objectForKey:kActiveDateKey];
    if (activeDateKey) {
        NSDate *date = [_autosDetailView.autosInsuranceDetail valueForKeyPath:activeDateKey];
        NSString *dateString = @"请选择日期";
        if (date) dateString = [_autosDetailView.autosInsuranceDetail.dateFormatter stringFromDate:date];
        
        NSMutableAttributedString *dateAttributedString = [NSMutableAttributedString new];
        [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"生效日期：" attributes:@{NSForegroundColorAttributeName:vThemeColor}]];
        [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:dateString attributes:@{NSForegroundColorAttributeName:CDZColorOfLightGray}]];
        [dateButton setAttributedTitle:dateAttributedString forState:UIControlStateNormal];
        
        dateTimeTextField.hidden = NO;
        dateTimeTextField.accessibilityIdentifier = @(section).stringValue;
        dateButton.hidden = NO;
        dateButton.accessibilityIdentifier = @(section).stringValue;
    }
    return myHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (void)extraInsuranceSelection:(UIButton *)button {
    button.selected = !button.selected;
    self.isFolding = button.selected;
    [self.tableView reloadData];
    if (button.selected) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)showDateSelector:(UIButton *)button {
    NSUInteger section = button.accessibilityIdentifier.integerValue;
    UITableViewHeaderFooterView *myHeader = [_tableView headerViewForSection:section];
    IQDropDownTextField *dateTimeTextField = (IQDropDownTextField *)[myHeader viewWithTag:13];
    
    NSString *activeDateKey = [_configList[section] objectForKey:kActiveDateKey];
    NSDate *date = [_autosDetailView.autosInsuranceDetail valueForKeyPath:activeDateKey];
    dateTimeTextField.minimumDate = NSDate.date;
    dateTimeTextField.date = NSDate.date;
    if (date) {
        dateTimeTextField.date = date;
    }
    if (![dateTimeTextField isFirstResponder]) {
        [dateTimeTextField becomeFirstResponder];
        self.dateTimeTextField = dateTimeTextField;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    _tableView.scrollEnabled = NO;
}

#pragma mark - IQDropDownTextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString *)item {
    NSUInteger section = textField.accessibilityIdentifier.integerValue;
    UITableViewHeaderFooterView *myHeader = [_tableView headerViewForSection:section];
    if (myHeader) {
        UIButton *dateButton = (UIButton *)[myHeader viewWithTag:12];
        NSString *activeDateKey = [_configList[section] objectForKey:kActiveDateKey];
        if (activeDateKey) {
            NSMutableAttributedString *dateAttributedString = [NSMutableAttributedString new];
            [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"生效日期：" attributes:@{NSForegroundColorAttributeName:vThemeColor}]];
            [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:item attributes:@{NSForegroundColorAttributeName:CDZColorOfLightGray}]];
            [dateButton setAttributedTitle:dateAttributedString forState:UIControlStateNormal];
            
            NSDate *date = [textField.dateFormatter dateFromString:item];
            if (date) {
                [self.autosDetailView.autosInsuranceDetail setValue:date forKeyPath:activeDateKey];
            }
        }
    }
}

- (void)hiddenKeyboard {
    _tableView.scrollEnabled = YES;
    [self.dateTimeTextField resignFirstResponder];
}

- (void)submitAppointment {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    MAIDConfigObject *autosInsuranceDetail = _autosDetailView.autosInsuranceDetail;
    NSString *carId = autosInsuranceDetail.carMAIID;
    
    MAIDConfigCompanyObject *companyDetail = autosInsuranceDetail.insuranceCompanyList.configDetail;
    NSString *insuranceCompany = companyDetail.companyName;
    NSString *autosTALCInsuranceActiveDateStr = @"";
    NSNumber *vehicleAndVesselTax = @(0);
    NSNumber *autosTALCInsurance = @(0);
    if (autosInsuranceDetail.autosTALCInsuranceActive) {
        autosTALCInsuranceActiveDateStr = [autosInsuranceDetail.dateFormatter stringFromDate:autosInsuranceDetail.autosTALCInsuranceActiveDate];
        vehicleAndVesselTax = autosInsuranceDetail.vehicleAndVesselTax;
        autosTALCInsurance = autosInsuranceDetail.autosTALCInsurance;
    }
    
    NSString *commerceInsuranceActiveDate = @"";
    if (autosInsuranceDetail.autosDamageInsuranceActive||
        autosInsuranceDetail.robberyAndTheftInsuranceActive||
        autosInsuranceDetail.passengerLiabilityInsurance.isActive||
        autosInsuranceDetail.driverLiabilityInsurance.isActive||
        autosInsuranceDetail.thirdPartyLiabilityInsurance.isActive) {
        commerceInsuranceActiveDate = [autosInsuranceDetail.dateFormatter stringFromDate:autosInsuranceDetail.commerceInsuranceActiveDate];
    }
    
    NSNumber *autosDamageInsurance = @(0);
    if (autosInsuranceDetail.autosDamageInsuranceActive) {
        autosDamageInsurance = autosInsuranceDetail.autosDamageInsurance;
    }
    
    NSString *thirdPartyLiabilityInsuranceCoverage = @"";
    NSNumber *thirdPartyLiabilityInsurance = @(0);
    if (autosInsuranceDetail.thirdPartyLiabilityInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.thirdPartyLiabilityInsurance.configDetail;
        thirdPartyLiabilityInsuranceCoverage = configDetail.coverageCost;
        thirdPartyLiabilityInsurance = configDetail.premiumCost;
    }
    
    NSNumber *robberyAndTheftInsurance = @(0);
    if (autosInsuranceDetail.robberyAndTheftInsuranceActive) {
        robberyAndTheftInsurance = autosInsuranceDetail.robberyAndTheftInsurance;
    }
    
    NSString *driverLiabilityInsuranceCoverage = @"";
    NSNumber *driverLiabilityInsurance = @(0);
    if (autosInsuranceDetail.driverLiabilityInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.driverLiabilityInsurance.configDetail;
        driverLiabilityInsuranceCoverage = configDetail.coverageCost;
        driverLiabilityInsurance = configDetail.premiumCost;
    }
    
    NSString *passengerLiabilityInsuranceCoverage = @"";
    NSNumber *passengerLiabilityInsurance = @(0);
    if (autosInsuranceDetail.passengerLiabilityInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.passengerLiabilityInsurance.configDetail;
        passengerLiabilityInsuranceCoverage = configDetail.coverageCost;
        passengerLiabilityInsurance = configDetail.premiumCost;
    }
    
    
    
    NSString *windshieldDamageInsuranceType = @"";
    NSNumber *windshieldDamageInsurance = @(0);
    if (autosInsuranceDetail.windshieldDamageInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.windshieldDamageInsurance.configDetail;
        windshieldDamageInsuranceType = configDetail.insuranceName;
        windshieldDamageInsurance = configDetail.premiumCost;
    }
    
    
    NSNumber *fireInsurance = @(0);
    if (autosInsuranceDetail.fireInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.fireInsurance.configDetail;
        fireInsurance = configDetail.premiumCost;
    }
    
    NSString *scratchDamageInsuranceCoverage = @"";
    NSNumber *scratchDamageInsurance = @(0);
    if (autosInsuranceDetail.scratchDamageInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.scratchDamageInsurance.configDetail;
        scratchDamageInsuranceCoverage = configDetail.coverageCost;
        scratchDamageInsurance = configDetail.premiumCost;
    }
    
    NSNumber *specifyServiceFactoryInsurance = @(0);
    if (autosInsuranceDetail.specifyServiceFactoryInsuranceActive) {
        specifyServiceFactoryInsurance = autosInsuranceDetail.specifyServiceFactoryInsurance;
    }
    
    NSString *sideMirrorAndHeadlightDamageInsuranceType = @"";
    NSNumber *sideMirrorAndHeadlightDamageInsurance = @(0);
    if (autosInsuranceDetail.sideMirrorAndHeadlightDamageInsurance.isActive) {
        MAIDConfigObjectDetail *configDetail = autosInsuranceDetail.sideMirrorAndHeadlightDamageInsurance.configDetail;
        sideMirrorAndHeadlightDamageInsuranceType = configDetail.insuranceName;
        sideMirrorAndHeadlightDamageInsurance = configDetail.premiumCost;
    }
    
    NSNumber *wadingDrivingInsurance = @(0);
    if (autosInsuranceDetail.wadingDrivingInsuranceActive) {
        wadingDrivingInsurance = autosInsuranceDetail.wadingDrivingInsurance;
    }
    
    NSNumber *extraADInsurance = @(0);
    if (autosInsuranceDetail.extraADInsuranceActive) {
        extraADInsurance = autosInsuranceDetail.extraADInsurance;
    }
    NSNumber *extraRATInsurance = @(0);
    if (autosInsuranceDetail.extraRATInsuranceActive) {
        extraRATInsurance = autosInsuranceDetail.extraRATInsurance;
    }
    NSNumber *extraTPLInsurance = @(0);
    if (autosInsuranceDetail.extraTPLInsuranceActive) {
        extraTPLInsurance = autosInsuranceDetail.extraTPLInsurance;
    }
    NSNumber *extraDLNPLInsurance = @(0);
    if (autosInsuranceDetail.extraDLNPLInsuranceActive) {
        extraDLNPLInsurance = autosInsuranceDetail.extraDLNPLInsurance;
    }
    NSNumber *extraPlusInsurance = @(0);
    if (autosInsuranceDetail.extraPlusInsuranceActive) {
        extraPlusInsurance = autosInsuranceDetail.extraPlusInsurance;
    }
    double minusTALCIWithVAVTax = (autosInsuranceDetail.autosTALCInsuranceActive)?autosInsuranceDetail.TALCIWithVAVTax.doubleValue:0.0f;
    NSNumber *businessTotalPriceWithDiscount = @([SupportingClass roundToLastTwoFloatValue:autosInsuranceDetail.totalPrice.doubleValue-minusTALCIWithVAVTax]);
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsuranceAppointmentWithAccessToken:self.accessToken
                                                                                                  carId:carId
                                                                                       insuranceCompany:insuranceCompany
                                                                               VTALCInsuranceActiveDate:autosTALCInsuranceActiveDateStr
                                                                                    vehicleAndVesselTax:vehicleAndVesselTax
                                                                                     autosTALCInsurance:autosTALCInsurance
     
                                                                            commerceInsuranceActiveDate:commerceInsuranceActiveDate
                                                                                   autosDamageInsurance:autosDamageInsurance
                                                                   thirdPartyLiabilityInsuranceCoverage:thirdPartyLiabilityInsuranceCoverage
                                                                           thirdPartyLiabilityInsurance:thirdPartyLiabilityInsurance
                                                                               robberyAndTheftInsurance:robberyAndTheftInsurance
     
     
                                                                       driverLiabilityInsuranceCoverage:driverLiabilityInsuranceCoverage
                                                                               driverLiabilityInsurance:driverLiabilityInsurance
                                                                    passengerLiabilityInsuranceCoverage:passengerLiabilityInsuranceCoverage
                                                                            passengerLiabilityInsurance:passengerLiabilityInsurance
     
                                                                          windshieldDamageInsuranceType:windshieldDamageInsuranceType
                                                                              windshieldDamageInsurance:windshieldDamageInsurance
                                                                                          fireInsurance:fireInsurance
                                                                         scratchDamageInsuranceCoverage:scratchDamageInsuranceCoverage
                                                                                 scratchDamageInsurance:scratchDamageInsurance
                                                                         specifyServiceFactoryInsurance:specifyServiceFactoryInsurance
                                                              sideMirrorAndHeadlightDamageInsuranceType:sideMirrorAndHeadlightDamageInsuranceType
                                                                  sideMirrorAndHeadlightDamageInsurance:sideMirrorAndHeadlightDamageInsurance
                                                                                 wadingDrivingInsurance:wadingDrivingInsurance
     
                                                                                       extraADInsurance:extraADInsurance
                                                                                      extraRATInsurance:extraRATInsurance
                                                                                      extraTPLInsurance:extraTPLInsurance
                                                                                    extraDLNPLInsurance:extraDLNPLInsurance
                                                                                     extraPlusInsurance:extraPlusInsurance
                                                                         businessTotalPriceWithDiscount:businessTotalPriceWithDiscount
    success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"预约成功！24小时以内客服会联络您核实资料，请耐心等候！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (errorCode==0) {
                
                NSPredicate *btbcPredicateBTB = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
                NSArray *btbcResult = [self.navigationController.viewControllers filteredArrayUsingPredicate:btbcPredicateBTB];
                if (btbcResult&&btbcResult.count>0) {
                    [(BaseTabBarController *)btbcResult.lastObject setSelectedIndex:3];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyAutoInsuranceVC.class];
                NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
                if (result&&result.count>0) {
                    
                    [self.navigationController popToViewController:result.lastObject animated:YES];
                }
                
                MyAutoInsuranceVC *vc = MyAutoInsuranceVC.new;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        
    }failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
        
    }];
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
