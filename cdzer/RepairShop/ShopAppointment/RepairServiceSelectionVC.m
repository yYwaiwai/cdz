//
//  RepairServiceSelectionVC.m
//  cdzer
//
//  Created by KEns0n on 6/15/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairServiceSelectionVC.h"
#import "InsetsLabel.h"

@interface RepairServiceSelectionVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *mainPartsCategoryTV;

@property (nonatomic, strong) UITableView *subPartsCategoryTV;

@property (nonatomic, strong) NSArray *serviceMainList;

@property (nonatomic, strong) NSMutableArray *serviceSubList;

@property (nonatomic, strong) NSIndexPath *currentMainCatePath;

@end

@implementation RepairServiceSelectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = getLocalizationString(@"select_repair_service");
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_serviceMainList||_serviceMainList.count==0) {
        [self getRepairServiceMainCategory];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, selectedServiceList) subscribeNext:^(NSMutableArray *list) {
        @strongify(self);
        if (list.count!=0) {
            __block BOOL isEnable = NO;
            [self.serviceMainList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableSet *itemListSet = list[idx];
                NSArray *array = [itemListSet allObjects];
                if (array.count != 0) {
                    isEnable = YES;
                    *stop = YES;
                }
            }];
            self.navigationItem.rightBarButtonItem.enabled = isEnable;
        }else {
            
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }];
}

- (void)componentSetting {
    @autoreleasepool {
        self.serviceMainList = @[];
        self.serviceSubList = [@[] mutableCopy];
        if (!_selectedServiceList) {
            self.selectedServiceList = [@[] mutableCopy];
        }
        self.currentMainCatePath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self setRightNavButtonWithTitleOrImage:(@"finish") style:UIBarButtonItemStyleDone target:self action:@selector(submitServiceSelection) titleColor:nil isNeedToSet:YES];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)submitServiceSelection {
    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfSelectedRepairItemsUpdate object:_selectedServiceList];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializationUI {
    @autoreleasepool {
//        InsetsLabel *repairTypeTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 30.0f)
//                                                                andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f)];
//        repairTypeTitle.text = @"请选择维修项目：";
//        repairTypeTitle.backgroundColor = CDZColorOfLightGray;
//        [self.contentView addSubview:repairTypeTitle];
        
        
        CGFloat remainHeight = CGRectGetHeight(self.contentView.frame);//-CGRectGetMaxY(repairTypeTitle.frame);
        CGRect mainPartsTVRect = self.contentView.bounds;
//        mainPartsTVRect.origin.y = CGRectGetMaxY(repairTypeTitle.frame);
        mainPartsTVRect.size.height = remainHeight;
        self.mainPartsCategoryTV = [[UITableView alloc] initWithFrame:mainPartsTVRect style:UITableViewStylePlain];
        _mainPartsCategoryTV.bounces = NO;
        _mainPartsCategoryTV.delegate = self;
        _mainPartsCategoryTV.dataSource = self;
        _mainPartsCategoryTV.allowsSelection = NO;
        _mainPartsCategoryTV.allowsMultipleSelection = NO;
        _mainPartsCategoryTV.allowsSelectionDuringEditing = NO;
        _mainPartsCategoryTV.allowsMultipleSelectionDuringEditing = NO;
        [self.contentView addSubview:_mainPartsCategoryTV];
        
        CGRect subPartsTVRect = mainPartsTVRect;
        subPartsTVRect.origin.x = CGRectGetMaxX(mainPartsTVRect);
        subPartsTVRect.size.width = CGRectGetWidth(self.contentView.frame)-CGRectGetMaxX(mainPartsTVRect);
        self.subPartsCategoryTV = [[UITableView alloc] initWithFrame:subPartsTVRect style:UITableViewStylePlain];
        _subPartsCategoryTV.hidden = YES;
        _subPartsCategoryTV.editing = NO;
        _subPartsCategoryTV.bounces = NO;
        _subPartsCategoryTV.delegate = self;
        _subPartsCategoryTV.dataSource = self;
        _subPartsCategoryTV.allowsSelection = NO;
        _subPartsCategoryTV.allowsMultipleSelection = NO;
        _subPartsCategoryTV.allowsSelectionDuringEditing = NO;
        _subPartsCategoryTV.allowsMultipleSelectionDuringEditing = NO;
        [self.contentView addSubview:_subPartsCategoryTV];
    }
    
}

- (void)calculateAndSetMainCategoryTVFinalWidthByText {
    @autoreleasepool {
        
        CGFloat titleWidth = [SupportingClass getStringSizeWithString:getLocalizationString(@"main_parts_category_title")
                                                                 font:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO)
                                                          widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
        titleWidth += 10.0f*2.0f;
        __block CGFloat rowTitleWidth = 0.0f;
        [_serviceMainList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CGFloat tmpRowTitleWidth = [SupportingClass getStringSizeWithString:obj[@"dictionary"]
                                                                           font:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO)
                                                                    widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
            
            if (tmpRowTitleWidth>=rowTitleWidth) {
                rowTitleWidth = tmpRowTitleWidth+15.0f*2.0f;
            }
        }];
        if (rowTitleWidth>=titleWidth) {
            titleWidth = rowTitleWidth;
        }
        CGRect mainRect = _mainPartsCategoryTV.frame;
        CGRect subRect = _subPartsCategoryTV.frame;
        mainRect.size.width = titleWidth;
        subRect.origin.x = CGRectGetMaxX(mainRect);
        subRect.size.width = CGRectGetWidth(self.contentView.frame)-CGRectGetMaxX(mainRect);
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            self.mainPartsCategoryTV.frame = mainRect;
            self.subPartsCategoryTV.frame = subRect;
        }];
        
    }
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([_mainPartsCategoryTV isEqual:tableView]) {
        if (_serviceMainList.count==0) {
            return 1;
        }
        return _serviceMainList.count;
    }
    
    if (_serviceSubList.count==0) return 1;
    NSInteger mainCateIndex = _mainPartsCategoryTV.indexPathForSelectedRow.row;
    NSMutableSet *set = _serviceSubList[mainCateIndex];
    NSArray *array = [set allObjects];
    if (array.count==0) return 1;
    return  [_serviceSubList[mainCateIndex] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"CellIdent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfWhite];
        cell.textLabel.text = @"";
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    // Configure the cell...
    cell.textLabel.text = @"";
    
    if ([_mainPartsCategoryTV isEqual:tableView]) {
        if (_serviceMainList.count==0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = getLocalizationString(@"no_main_category_data");
        }else {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = [_serviceMainList[indexPath.row] objectForKey:@"dictionary"];
        }
    }else if ([_subPartsCategoryTV isEqual:tableView]) {
        NSMutableSet *set = _serviceSubList[_mainPartsCategoryTV.indexPathForSelectedRow.row];
        NSArray *array = [set allObjects];
        if (array.count==0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = getLocalizationString(@"no_sub_category_data");
        }else {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = [array[indexPath.row] objectForKey:@"dictionary"];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_mainPartsCategoryTV isEqual:tableView]) {
        return 40;
    }
    if (_serviceSubList.count!=0) {
        NSMutableSet *set = _serviceSubList[_mainPartsCategoryTV.indexPathForSelectedRow.row];
        NSArray *array = [set allObjects];
        if (array.count!=0) {
            NSString *text = [array[indexPath.row] objectForKey:@"dictionary"];
            UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
            CGFloat height = [SupportingClass getStringSizeWithString:text font:font widthOfView:CGSizeMake(120.0f, CGFLOAT_MAX)].height;
            height += 20;
            return height;
        }
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @autoreleasepool {
        static NSString *headerIdentifier = @"header";
        
        UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if(!myHeader) {
            myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
            InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                               andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
            titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.tag = 10;
            titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            [myHeader addSubview:titleLabel];
            [myHeader setNeedsUpdateConstraints];
            [myHeader updateConstraintsIfNeeded];
            [myHeader setNeedsLayout];
            [myHeader layoutIfNeeded];
        }
        InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
        NSString *title = getLocalizationString(@"main_parts_category_title");
        if ([tableView isEqual:_subPartsCategoryTV]) {
            title = getLocalizationString(@"sub_parts_category_title");
        }
        titleLabel.text = title;
        return myHeader;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_mainPartsCategoryTV]) {
        if ([indexPath compare:_currentMainCatePath]==NSOrderedSame) {
            return;
        }
        self.currentMainCatePath = indexPath;
        [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
        [self getRepairServiceSubCategory:[_serviceMainList[indexPath.row]objectForKey:@"note"]];
    }else {
        [self updateSubCategorySelectedList:indexPath isRemove:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_subPartsCategoryTV]) {
        [self updateSubCategorySelectedList:indexPath isRemove:YES];
    }
}

- (void)updateSubCategorySelectedList:(NSIndexPath *)indexPath isRemove:(BOOL)isRemove {
    @autoreleasepool {
        NSInteger mainCateIndex = _mainPartsCategoryTV.indexPathForSelectedRow.row;
        NSMutableSet *itemListSet = _serviceSubList[mainCateIndex];
        
        NSArray *array = [itemListSet allObjects];
        NSMutableSet *selectedItemListSet = _selectedServiceList[mainCateIndex];
        if (isRemove) {
            [selectedItemListSet removeObject:array[indexPath.row]];
        }else {
            [selectedItemListSet addObject:array[indexPath.row]];
        }
        
        NSMutableArray *tmpSelectedServiceList = [self mutableArrayValueForKey:@"selectedServiceList"];
        [tmpSelectedServiceList replaceObjectAtIndex:mainCateIndex withObject:selectedItemListSet];
    }
    
}

#pragma mark- Handle API Data Code Section
- (void)updateRepairServiceMainCategory:(id)responseObject {
    @autoreleasepool {
        if (![responseObject isKindOfClass:[NSArray class]]||[responseObject count]==0) {
            return;
        }
        
        self.serviceMainList = responseObject;
        [_mainPartsCategoryTV reloadData];
        if (_serviceMainList.count>0) {
            [self calculateAndSetMainCategoryTVFinalWidthByText];
            _mainPartsCategoryTV.allowsSelection = YES;
            [_mainPartsCategoryTV selectRowAtIndexPath:_currentMainCatePath animated:NO scrollPosition:UITableViewScrollPositionTop];
            [_serviceSubList removeAllObjects];
            @weakify(self);
            [_serviceMainList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self);
                if (self.selectedServiceList.count!=self.serviceMainList.count) {
                    [self.selectedServiceList addObject:[NSMutableSet set]];
                }
                [self.serviceSubList addObject:[NSMutableSet set]];
            }];
            
            [self getRepairServiceSubCategory:[_serviceMainList[0]objectForKey:@"note"]];
        }else {
            [ProgressHUDHandler dismissHUD];
            _mainPartsCategoryTV.allowsSelection = NO;
            _subPartsCategoryTV.hidden = YES;
        }
    }
}

- (void)updateRepairServiceSubCategory:(id)responseObject {
    @autoreleasepool {
        if (![responseObject isKindOfClass:[NSArray class]]) {
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        NSInteger mainCateIndex = -1;
        if (_mainPartsCategoryTV.indexPathForSelectedRow) mainCateIndex = _mainPartsCategoryTV.indexPathForSelectedRow.row;
        if (mainCateIndex > -1) {
            _subPartsCategoryTV.hidden = NO;
            NSMutableSet *set = _serviceSubList[mainCateIndex];
            [set addObjectsFromArray:responseObject];
            [_serviceSubList replaceObjectAtIndex:mainCateIndex withObject:set];
            [_subPartsCategoryTV reloadData];
            if (set.count>0) {
                _subPartsCategoryTV.editing = YES;
                _subPartsCategoryTV.allowsSelectionDuringEditing = YES;
                _subPartsCategoryTV.allowsMultipleSelectionDuringEditing = YES;
                @weakify(self);
                NSArray *selectedArray = [_selectedServiceList[mainCateIndex] allObjects];
                NSArray *listArray = [_serviceSubList[mainCateIndex] allObjects];
                [selectedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self);
                    NSInteger index = [listArray indexOfObject:obj];
                    [self.subPartsCategoryTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }];
                [_subPartsCategoryTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }else {
                _subPartsCategoryTV.editing = NO;
                _subPartsCategoryTV.allowsSelectionDuringEditing = NO;
                _subPartsCategoryTV.allowsMultipleSelectionDuringEditing = NO;
            }
        }else {
            _subPartsCategoryTV.hidden = YES;
            _subPartsCategoryTV.editing = NO;
            _subPartsCategoryTV.allowsSelectionDuringEditing = NO;
            _subPartsCategoryTV.allowsMultipleSelectionDuringEditing = NO;

        }
        
    }
}


#pragma mark- API Access Code Section
- (void)getRepairServiceMainCategory {
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] commonAPIsGetAutoFailureTypeListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        @strongify(self);
        [self updateRepairServiceMainCategory:responseObject[CDZKeyOfResultKey]];
        
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

- (void)getRepairServiceSubCategory:(NSString *)mainID {
    @weakify(self);
    if (!mainID) mainID = @"";
    [[APIsConnection shareConnection] commonAPIsGetAutoFaultSymptomListWithAutoFailureTypeID:mainID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [self updateRepairServiceSubCategory:@[]];
            return;
        }
        @strongify(self);
        [self updateRepairServiceSubCategory:responseObject[CDZKeyOfResultKey]];
        
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
