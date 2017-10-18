//
//  ShopAppointmentVC.m
//  cdzer
//
//  Created by KEns0n on 6/13/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define kRepairItemKey @"maintain_item_name"
#define kRepairItemRemarkKey @"remark"
#define kRepairItemWorkingPrice @"price"
#define kRepairItemManHour @"man_hour"
#import "ShopAppointmentVC.h"
#import "InsetsLabel.h"
#import "RepairServiceSelectionVC.h"
#import "MaintenanceServiceSelectionVC.h"
#import "AppointmentConfirmVC.h"
#import "AppointmentInfoTVCell.h"

@interface ShopAppointmentVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *applyButton;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIButton *maintenanceItemButton;

@property (nonatomic, strong) UIButton *repairItemButton;

@property (nonatomic, strong) UISegmentedControl *filterControl;

@property (nonatomic, strong) UITableView *resultTableView;

@property (nonatomic, strong) NSMutableArray *selectedServiceArray;

@property (nonatomic, strong) NSMutableArray *apiProcessedDataList;

@property (nonatomic, strong) NSMutableArray *selectedServiceOringalList;

@property (nonatomic, strong) NSArray *selectedIndexs;

@property (nonatomic, assign) BOOL isFilter;

@property (nonatomic, strong) NSString *totalPrice;

@property (nonatomic, strong) NSString *shopTel;

@property (nonatomic, assign) BOOL repairInfoReady;

@property (nonatomic, assign) BOOL maintenanceInfoReady;

@end

@implementation ShopAppointmentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_resultTableView setEditing:editing animated:animated];
    [_resultTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = NO;
    self.title = getLocalizationString(@"select_service_4_appointment");
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
    NSLog(@"%@",self.diagnosisResultReason);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedRepairServiceData:) name:CDZNotiKeyOfSelectedRepairItemsUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedMaintenanceServiceData:) name:CDZNotiKeyOfSelectedMaintenanceItemsUpdate object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.repairInfoReady = NO;
    self.maintenanceInfoReady = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [ProgressHUDHandler showHUDWithTitle:@"信息更新中" onView:nil];
    if ([_selectedServiceArray[0] count]!=0||(self.diagnosisResultReason&&![self.diagnosisResultReason isEqualToString:@""])) {
        [self getAppointmentRepairInfo];
    }else {
        self.repairInfoReady = YES;
    }
    
    if ([_selectedServiceArray[1] count]!=0) {
        [self getAppointmentMaintenanceInfo];
    }else {
        self.maintenanceInfoReady = YES;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    self.isFilter = NO;
    @weakify(self);
    [RACObserve(self, applyButton.enabled) subscribeNext:^(NSNumber *isEnable) {
        @strongify(self);
        self.applyButton.backgroundColor = (self.applyButton.enabled)?CDZColorOfDefaultColor:CDZColorOfDeepGray;
    }];
    
    [RACObserve(self, selectedIndexs) subscribeNext:^(NSArray *selectedIndexs) {
        @strongify(self);
        BOOL isOn = NO;
        if (selectedIndexs.count>0&&selectedIndexs) {
            isOn = YES;
        }
        self.deleteButton.enabled = isOn;
    }];
    
    [RACObserve(self, deleteButton.enabled) subscribeNext:^(NSNumber *isEnable) {
        @strongify(self);
        self.deleteButton.backgroundColor = (self.deleteButton.enabled)?CDZColorOfRed:CDZColorOfDeepGray;
    }];
    
    [RACObserve(self, filterControl.selectedSegmentIndex) subscribeNext:^(NSNumber *filterIndex) {
        @strongify(self);
        self.isFilter = (filterIndex.integerValue!=0);
        [self.resultTableView reloadData];
    }];
    
    
    [RACObserve(self, apiProcessedDataList) subscribeNext:^(NSMutableArray *apiProcessedDataList) {
        @strongify(self);
        BOOL isEnable = !([apiProcessedDataList[0] count]==0&&[apiProcessedDataList[1] count]==0);
        self.applyButton.enabled = isEnable;
        self.navigationItem.rightBarButtonItem.enabled = isEnable;
    }];
    
    RACSignal *repairInfoReadySignal = RACObserve(self, repairInfoReady);
    RACSignal *maintenanceInfoReadySignal = RACObserve(self, maintenanceInfoReady);
    
    [[RACSignal combineLatest:@[repairInfoReadySignal, maintenanceInfoReadySignal] reduce:^id(NSNumber *startSignal, NSNumber *endSignal){
        return @(startSignal.boolValue&&endSignal.boolValue);
    }] subscribeNext:^(NSNumber *isOn) {
        if (isOn) {
            [ProgressHUDHandler dismissHUD];
            [self.resultTableView reloadData];
        }
    }];

    
}

- (void)componentSetting {
    @autoreleasepool {
//        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(showItemDelete)];
//        self.navigationItem.rightBarButtonItem = rightItem;
        [self setRightNavButtonWithTitleOrImage:@"edit" style:UIBarButtonItemStylePlain target:self action:@selector(showItemDelete) titleColor:nil isNeedToSet:YES];
        self.selectedServiceArray = [@[@[], @[]] mutableCopy];
        self.selectedServiceOringalList = [@[[NSMutableArray array],[NSMutableArray array]] mutableCopy];
        self.apiProcessedDataList = [@[@[], @[]] mutableCopy];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        CGFloat offset = CGRectGetWidth(self.contentView.frame)*0.05;
        
        self.applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _applyButton.frame = CGRectMake(offset, CGRectGetHeight(self.contentView.frame)-60.0f,
                                        CGRectGetWidth(self.contentView.frame)-offset*2.0f, 40.0f);
        _applyButton.backgroundColor = CDZColorOfDefaultColor;
        [_applyButton setTitle:getLocalizationString(@"apply_appointment") forState:UIControlStateNormal];
        [_applyButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_applyButton setTitle:getLocalizationString(@"apply_appointment") forState:UIControlStateDisabled];
        [_applyButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
        [_applyButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_applyButton addTarget:self action:@selector(pushToAppointmentConfirmVC) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_applyButton];
        
        
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _deleteButton.frame = CGRectMake(offset, CGRectGetHeight(self.contentView.frame)-60.0f,
                                        CGRectGetWidth(self.contentView.frame)-offset*2.0f, 40.0f);
        _deleteButton.hidden = YES;
        _deleteButton.backgroundColor = CDZColorOfRed;
        [_deleteButton setTitle:getLocalizationString(@"delete") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_deleteButton setTitle:getLocalizationString(@"delete") forState:UIControlStateDisabled];
        [_deleteButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
        [_deleteButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_deleteButton addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
        
//        self.maintenanceItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        _maintenanceItemButton.frame = CGRectMake(offset, offset,
//                                        CGRectGetWidth(_applyButton.frame)/2.0f, 40.0f);
//        _maintenanceItemButton.backgroundColor = CDZColorOfDefaultColor;
//        [_maintenanceItemButton setTitle:getLocalizationString(@"repair_Items_select") forState:UIControlStateNormal];
//        [_maintenanceItemButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
//        [_maintenanceItemButton setViewCornerWithRectCorner:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerSize:5.0f];
//        [_maintenanceItemButton addRightBorderWithWidth:0.5f andColor:CDZColorOfGray];
//        [self.contentView addSubview:_maintenanceItemButton];
//        
//        self.repairItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        _repairItemButton.frame = CGRectMake(CGRectGetMaxX(_maintenanceItemButton.frame), offset,
//                                                  CGRectGetWidth(_applyButton.frame)/2.0f, 40.0f);
//        _repairItemButton.backgroundColor = CDZColorOfDefaultColor;
//        [_repairItemButton setTitle:getLocalizationString(@"maintenance_Items_select") forState:UIControlStateNormal];
//        [_repairItemButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
//        [_repairItemButton setViewCornerWithRectCorner:UIRectCornerTopRight|UIRectCornerBottomRight cornerSize:5.0f];
//        [_repairItemButton addLeftBorderWithWidth:0.5f andColor:CDZColorOfGray];
//        [self.contentView addSubview:_repairItemButton];
        
        CGRect filterControlRect = _applyButton.frame;
        filterControlRect.origin = CGPointMake(offset, offset);
        filterControlRect.size.height = 30.f;
        self.filterControl = [[UISegmentedControl alloc] initWithItems:@[getLocalizationString(@"all"),
                                                                         getLocalizationString(@"repair_items_select"),
                                                                         getLocalizationString(@"maintenance_items_select")]];
        _filterControl.selectedSegmentIndex = 0;
        _filterControl.tintColor = CDZColorOfDefaultColor;
        _filterControl.frame = filterControlRect;
        [self.contentView addSubview:_filterControl];

        CGFloat remainHeight = CGRectGetMinY(_applyButton.frame)-CGRectGetMaxY(_filterControl.frame)-offset;
        CGRect resultTVRect = _filterControl.frame;
        resultTVRect.origin.y = CGRectGetMaxY(_filterControl.frame)+offset/2.0f;
        resultTVRect.size = CGSizeMake(CGRectGetWidth(self.filterControl.frame), remainHeight);
        self.resultTableView = [[UITableView alloc] initWithFrame:resultTVRect style:UITableViewStylePlain];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        _resultTableView.bounces = NO;
        _resultTableView.allowsSelection = YES;
        _resultTableView.allowsMultipleSelection = NO;
        _resultTableView.allowsSelectionDuringEditing = YES;
        _resultTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.contentView addSubview:_resultTableView];
        
        
    }
    
}

#pragma mark- Private Functions

- (void)updateSelectedRepairServiceData:(NSNotification *)notiObject {
    if ([notiObject.object isKindOfClass:[NSMutableArray class]]) {
        @autoreleasepool {
            NSMutableArray *array = notiObject.object;
            [self.selectedServiceOringalList replaceObjectAtIndex:0 withObject:array];
            __block NSMutableArray *tmpArray = [NSMutableArray array];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSMutableSet class]]) {
                    if ([(NSMutableSet *)obj count]>0) {
                        [tmpArray addObjectsFromArray:[(NSMutableSet *)obj allObjects]];
                    }
                }
            }];
            
            NSMutableArray *tmpSelectedList = [self mutableArrayValueForKey:@"selectedServiceArray"];
            [tmpSelectedList replaceObjectAtIndex:0 withObject:tmpArray];
        }
        
    }
}

- (void)updateSelectedMaintenanceServiceData:(NSNotification *)notiObject {
    if ([notiObject.object isKindOfClass:[NSMutableArray class]]) {
        @autoreleasepool {
            NSMutableArray *array = notiObject.object;
            [self.selectedServiceOringalList replaceObjectAtIndex:1 withObject:array];
            __block NSMutableArray *tmpArray = [NSMutableArray array];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSMutableSet class]]) {
                    if ([(NSMutableSet *)obj count]>0) {
                        [tmpArray addObjectsFromArray:[(NSMutableSet *)obj allObjects]];
                    }
                }
            }];
            
            NSMutableArray *tmpSelectedList = [self mutableArrayValueForKey:@"selectedServiceArray"];
            [tmpSelectedList replaceObjectAtIndex:1 withObject:tmpArray];
        }
        
    }
}

- (void)showItemDelete {
    @autoreleasepool {
        self.selectedIndexs = nil;
        [self setEditing:!self.editing animated:YES];
        self.deleteButton.hidden = !self.editing;
        self.navigationItem.rightBarButtonItem.title = getLocalizationString((!self.editing)?@"edit":@"cancel");
    }
}

- (void)pushToAppointmentConfirmVC {
    @autoreleasepool {
        AppointmentConfirmVC *vc = [AppointmentConfirmVC new];
        vc.shopDetail = _dataDetail;
        NSArray *repairList = [_apiProcessedDataList[0] valueForKey:kRepairItemKey];
        NSArray *maintenanceList = [_apiProcessedDataList[1] valueForKey:kRepairItemKey];
        vc.appointmentItemsList = @[repairList,maintenanceList];
        [self setNavBackButtonTitleOrImage:getLocalizationString(@"cancel") titleColor:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)deleteSelectedItems {
    @autoreleasepool {
        NSMutableIndexSet *repairOfItemsToDelete = nil;
        NSMutableIndexSet *maintenanceOfItemsToDelete = nil;
        for (NSIndexPath *selectionIndex in self.selectedIndexs)
        {
            if (selectionIndex.section == 0) {
                if (!repairOfItemsToDelete) {
                    repairOfItemsToDelete = [NSMutableIndexSet new];
                }
                [repairOfItemsToDelete addIndex:selectionIndex.row];
            }
            if (selectionIndex.section == 1) {
                if (!maintenanceOfItemsToDelete) {
                    maintenanceOfItemsToDelete = [NSMutableIndexSet new];
                }
                [maintenanceOfItemsToDelete addIndex:selectionIndex.row];
            }
        }
        // Delete the objects from our data model.
        
        NSMutableArray *apiProcessedDataList = [self mutableArrayValueForKey:@"apiProcessedDataList"];
        NSMutableArray *selectedServiceArray = [self mutableArrayValueForKey:@"selectedServiceArray"];
        NSMutableArray *selectedServiceOringalArray = [self mutableArrayValueForKey:@"selectedServiceOringalList"];
        if (repairOfItemsToDelete) {
            
            NSMutableArray *repairOfAPIProcessedItemsList = _apiProcessedDataList[0];
            NSMutableArray *repairOfItemsOringalList = _selectedServiceOringalList[0];
            [repairOfItemsOringalList removeObjectsAtIndexes:repairOfItemsToDelete];
            [selectedServiceOringalArray replaceObjectAtIndex:0 withObject:repairOfItemsOringalList];
            
            [_selectedServiceOringalList[0] enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                if ([obj isKindOfClass:NSArray.class]&&[(NSMutableArray *)obj count]>0) {
                    NSMutableArray *subList = [obj mutableCopy];
                    [subList enumerateObjectsUsingBlock:^(id   subObj, NSUInteger subIdx, BOOL *  subStop) {
                        
                    }];
                    NSString *key = @"dictionary";
                }
            }];
            [repairOfAPIProcessedItemsList removeObjectsAtIndexes:repairOfItemsToDelete];
            [apiProcessedDataList replaceObjectAtIndex:0 withObject:repairOfAPIProcessedItemsList];
            
            NSMutableArray *repairOfItemsList = _selectedServiceArray[0];
            [repairOfItemsList removeObjectsAtIndexes:repairOfItemsToDelete];
            [selectedServiceArray replaceObjectAtIndex:0 withObject:repairOfItemsList];
            
        }
        
        if (maintenanceOfItemsToDelete) {
            NSMutableArray *maintenanceOfAPIProcessedItemsList = _apiProcessedDataList[1];
            [maintenanceOfAPIProcessedItemsList removeObjectsAtIndexes:maintenanceOfItemsToDelete];
            [apiProcessedDataList replaceObjectAtIndex:1 withObject:maintenanceOfAPIProcessedItemsList];
            
            NSMutableArray *maintenanceOfIemsList = _selectedServiceArray[1];
            [maintenanceOfIemsList removeObjectsAtIndexes:maintenanceOfItemsToDelete];
            [selectedServiceArray replaceObjectAtIndex:1 withObject:maintenanceOfIemsList];
            
            
            NSMutableArray *maintenanceOfIemsOringalList = _selectedServiceOringalList[1];
            [maintenanceOfIemsOringalList removeObjectsAtIndexes:maintenanceOfItemsToDelete];
            [selectedServiceOringalArray replaceObjectAtIndex:1 withObject:maintenanceOfIemsOringalList];
            
        }

        
        
        // Tell the tableView that we deleted the objects
        [self.resultTableView deleteRowsAtIndexPaths:self.selectedIndexs withRowAnimation:UITableViewRowAnimationTop];
        [self showItemDelete];
    }
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_isFilter) {
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger sectionIndex = _isFilter?(_filterControl.selectedSegmentIndex-1):section;
    if ([_apiProcessedDataList[sectionIndex] count]==0) {
        return tableView.editing?0:1;
    }
    return [_apiProcessedDataList[sectionIndex] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"ShopAppointmentTVC";
    AppointmentInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[AppointmentInfoTVCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setBackgroundColor:CDZColorOfWhite];
    }
    cell.selectionStyle = tableView.editing?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
    // Configure the cell...
    cell.textLabel.text = @"";
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = @"";
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = CDZColorOfDeepGray;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    [cell clearAllResultLabelText];
    NSInteger sectionIndex = _isFilter?(_filterControl.selectedSegmentIndex-1):indexPath.section;
    
    if ([_apiProcessedDataList[sectionIndex] count]==0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = getLocalizationString(@"repair_select_remind");
        if (sectionIndex==1) {
            cell.textLabel.text = getLocalizationString(@"maintenance_select_remind");
        }
        cell.detailTextLabel.text = getLocalizationString(@"click_and_go");
        
    }else {
        NSDictionary *detail = [_apiProcessedDataList[sectionIndex] objectAtIndex:indexPath.row];
        NSString *itemName = [SupportingClass verifyAndConvertDataToString:detail[kRepairItemKey]];
        NSString *manHour = [SupportingClass verifyAndConvertDataToString:detail[kRepairItemManHour]];
        NSString *workingPrice = [SupportingClass verifyAndConvertDataToString:detail[kRepairItemWorkingPrice]];
        NSString *totalWorkingPrice = @(manHour.integerValue*workingPrice.doubleValue).stringValue;
        NSString *serviceAdvice = [SupportingClass verifyAndConvertDataToString:detail[kRepairItemRemarkKey]];
        
        cell.itemName = itemName;
        cell.manHour = manHour;
        cell.workingPrice = workingPrice;
        cell.totalWorkingPrice = totalWorkingPrice;
        cell.serviceAdvice = serviceAdvice;
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSInteger sectionIndex = _isFilter?(_filterControl.selectedSegmentIndex-1):indexPath.section;
        if ([_apiProcessedDataList[sectionIndex] count]!=0) {
            CGFloat offset = tableView.editing?70.0f:30.0f;
            NSString *string = [_apiProcessedDataList[sectionIndex][indexPath.row] objectForKey:kRepairItemKey];
            NSString *detailString = [_apiProcessedDataList[sectionIndex][indexPath.row] objectForKey:kRepairItemRemarkKey];
            UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17.0f, NO);
            UIFont *detailFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 12.0f, NO);
            CGFloat height = [SupportingClass getStringSizeWithString:string
                                                                font:font
                                                         widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-offset, CGFLOAT_MAX)].height+20.0f;
 
            CGFloat detailHeight = [SupportingClass getStringSizeWithString:detailString
                                                                 font:detailFont
                                                          widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-offset, CGFLOAT_MAX)].height;
            
            return 130;
        }
    }
    return 56.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 35.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @autoreleasepool {
        static NSString *headerIdentifier = @"header";
        NSInteger sectionIndex = _isFilter?(_filterControl.selectedSegmentIndex-1):section;
        UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if(!myHeader) {
            myHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
            InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                               andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
            titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.tag = 10;
            titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            [myHeader addSubview:titleLabel];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tag = 11;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f);
            [button addTarget:self action:@selector(headerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:getLocalizationString(@"change") forState:UIControlStateNormal];
            [button setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
            [myHeader addSubview:button];
            
            [myHeader setNeedsUpdateConstraints];
            [myHeader updateConstraintsIfNeeded];
            [myHeader setNeedsLayout];
            [myHeader layoutIfNeeded];
        }
        NSArray *titleList = @[getLocalizationString(@"repair_items_selected"),
                               getLocalizationString(@"maintenance_items_selected")];
        InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
        NSString *title = titleList[sectionIndex];
        titleLabel.text = title;
        
        UIButton *button = (UIButton *)[myHeader viewWithTag:11];
        button.accessibilityIdentifier = @(sectionIndex).stringValue;
        button.hidden = (([_apiProcessedDataList[sectionIndex] count]==0)||tableView.editing);
        
        return myHeader;
    }
}

- (void)headerButtonAction:(UIButton *)button {
    NSInteger idx = button.accessibilityIdentifier.integerValue;
    [self pushToSerivceViewByIndex:idx];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionIndex = _isFilter?(_filterControl.selectedSegmentIndex-1):indexPath.section;
    if ([_apiProcessedDataList[sectionIndex] count]==0) {
        [self pushToSerivceViewByIndex:sectionIndex];
        return;
    }
    self.selectedIndexs = tableView.indexPathsForSelectedRows;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedIndexs = tableView.indexPathsForSelectedRows;
    
}

- (void)pushToSerivceViewByIndex:(NSInteger)index {
    @autoreleasepool {
        BaseViewController *vc ;
        if (index==0) {
            vc = [RepairServiceSelectionVC new];
            if ([_selectedServiceOringalList[0] count]!=0) {
                [(RepairServiceSelectionVC *)vc setSelectedServiceList:_selectedServiceOringalList[0]];
            }
        }else if (index==1) {
            NSString *repairShopID = _dataDetail[@"id"];
            vc = [MaintenanceServiceSelectionVC new];
            if ([_selectedServiceOringalList[1] count]!=1) {
                [(MaintenanceServiceSelectionVC *)vc setShopID:repairShopID];
                [(MaintenanceServiceSelectionVC *)vc setSelectedServiceList:_selectedServiceOringalList[1]];
            }
        }
        
        if (vc) {
            [self setNavBackButtonTitleOrImage:getLocalizationString(@"cancel") titleColor:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark- Data Receive Handle
- (void)handleAPIData:(id)responseObject identID:(NSUInteger)identID{
    if (![responseObject isKindOfClass:[NSDictionary class]]||identID>1) {
        if (identID==0) self.repairInfoReady = YES;
        if (identID==1) self.maintenanceInfoReady = YES;
        if (identID>2) {
            self.repairInfoReady = YES;
            self.maintenanceInfoReady = YES;
        }
        return;
    }
    @autoreleasepool {
        self.shopTel = responseObject[@"wxs_telphone"];
        self.totalPrice = responseObject[@"total_price"];
        NSArray *dataList = responseObject[@"list_total"];
        NSMutableArray *tmpProcessedDataList = [self mutableArrayValueForKey:@"apiProcessedDataList"];
        
        NSMutableArray *subArray = [NSMutableArray array];
        NSString *key = (identID==0)?@"dictionary":@"main_name";
        NSArray *infoList = _selectedServiceArray[identID];
        [infoList enumerateObjectsUsingBlock:^(id subObj, NSUInteger subIdx, BOOL *subStop) {
            NSString *title = subObj[key];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.maintain_item_name = %@",title];
            NSArray *resultList = [dataList filteredArrayUsingPredicate:predicate];
            if (resultList.count>0) {
                [subArray addObject:resultList.lastObject];
            }
        }];
        NSLog(@"the counting was equality %d",([infoList count]==subArray.count));
        NSLog(@"subArray counting was %d",subArray.count);
        NSLog(@"obj counting was %d",[infoList count]);
        
        if (self.diagnosisResultReason&&![self.diagnosisResultReason isEqualToString:@""]&&identID==0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.maintain_item_name = %@",self.diagnosisResultReason];
            NSArray *resultList = [dataList filteredArrayUsingPredicate:predicate];
            if (resultList.count>0) {
                [subArray addObject:resultList.lastObject];
            }
        }
        [tmpProcessedDataList replaceObjectAtIndex:identID withObject:subArray];
        
        
        
        if (identID==0) self.repairInfoReady = YES;
        if (identID==1) self.maintenanceInfoReady = YES;
    }
}

#pragma mark- API Access Code Section
- (NSString *)appointmentRepairInfoDataPrepare {
    @autoreleasepool {
        NSMutableString *listString = [NSMutableString stringWithString:@""];
        NSArray *repairInfoList = _selectedServiceArray[0];
        if (repairInfoList.count!=0) {
            if ([repairInfoList isKindOfClass:[NSArray class]]) {
                NSString *key = @"dictionary";
                NSArray *array = [repairInfoList valueForKey:key];
                if (array.count!=0) {
                    NSString *tmpString = [array componentsJoinedByString:@","];
                    [listString appendString:tmpString];
                    [listString appendString:@","];
                    
                }
            }
            
            NSRange range = NSMakeRange(listString.length-1, 1);
            if ([[listString substringWithRange:range] isEqualToString:@","]) {
                [listString deleteCharactersInRange:range];
            }
        }
        NSString *finalListString = listString;
        if (self.diagnosisResultReason&&![self.diagnosisResultReason isEqualToString:@""]) {
            if ([listString isEqualToString:@""]) {
                finalListString = self.diagnosisResultReason;
            }else {
                finalListString = [NSString stringWithFormat:@"%@,%@",self.diagnosisResultReason,listString];
            }
        }
        return finalListString;
    }
}

- (void)getAppointmentRepairInfo {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        
        NSString *listString = [self appointmentRepairInfoDataPrepare];
        if ([listString isEqualToString:@""]) {
            self.repairInfoReady = YES;
            return;
        }
        NSString *repairShopID = _dataDetail[@"id"];
        @weakify(self);
        [[APIsConnection shareConnection] maintenanceShopsAPIsGetAppointmentPrepareRepairInfoWithAccessToken:self.accessToken shopID:repairShopID repairServiceItemListString:listString success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode!=0) {
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    self.repairInfoReady = YES;
                }];
                return;
            }
            self.repairInfoReady = YES;
            NSDictionary *result = responseObject[CDZKeyOfResultKey];
            [self handleAPIData:result identID:0];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
            @strongify(self);
            self.repairInfoReady = YES;
        }];

    }
}

- (NSString *)appointmentMaintenanceInfoDataPrepare {
    @autoreleasepool {
        NSMutableString *listString = [NSMutableString stringWithString:@""];
        NSArray *maintenanceInfoList = _selectedServiceArray[1];
        
        if ([maintenanceInfoList isKindOfClass:[NSArray class]]) {
            NSString *key = @"id";
            NSArray *array = [maintenanceInfoList valueForKey:key];
            if (array.count!=0) {
                NSString *tmpString = [array componentsJoinedByString:@","];
                [listString appendString:tmpString];
                [listString appendString:@","];
                
            }
        }
        
        NSRange range = NSMakeRange(listString.length-1, 1);
        if ([[listString substringWithRange:range] isEqualToString:@","]) {
            [listString deleteCharactersInRange:range];
        }
        return listString;
    }
}

- (void)getAppointmentMaintenanceInfo {
    @autoreleasepool {
        
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        
        NSString *midListString = [self appointmentMaintenanceInfoDataPrepare];
        if ([midListString isEqualToString:@""]) {
            self.maintenanceInfoReady = YES;
            return;
        }
        NSString *repairShopID = _dataDetail[@"id"];
//        [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
        @weakify(self);
        [[APIsConnection shareConnection] maintenanceShopsAPIsGetAppointmentPrepareMaintenanceInfoWithAccessToken:self.accessToken shopID:repairShopID maintenanceServiceIDListString:midListString success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode!=0) {
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    self.maintenanceInfoReady = YES;
                }];
                return;
            }
            self.maintenanceInfoReady = YES;
            NSDictionary *result = responseObject[CDZKeyOfResultKey];
            [self handleAPIData:result identID:1];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
            @strongify(self);
            self.maintenanceInfoReady = YES;
        }];
        
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        
    }else {
        [self.navigationController popViewControllerAnimated:YES];
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
