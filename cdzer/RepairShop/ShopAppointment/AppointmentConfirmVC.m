//
//  AppointmentConfirmVC.m
//  cdzer
//
//  Created by KEns0n on 6/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define kRepairItemKey @"maintain_item_name"
#import "AppointmentConfirmVC.h"
#import "AutosSelectedView.h"
#import "InsetsLabel.h"
#import "UserInfosDTO.h"
#import "EngineerListVC.h"
#import "MyMaintenanceManagementVC.h"
#import "RepairShopDetailVC.h"

@interface AppointmentConfirmVC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) InsetsLabel *shopDetailLabel;

@property (nonatomic, strong) UITableView *inputListTV;

@property (nonatomic, strong) UIControl *itemsListContainer;

@property (nonatomic, strong) UITableView *itemsListTV;

//@property (nonatomic, strong) UIButton *applyButton;

@property (nonatomic, strong) NSMutableArray *titleList;

@property (nonatomic, strong) UserInfosDTO *userData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UITextField *tmpTextField;

@property (nonatomic, strong) NSDictionary *selectedEngineerData;

@property (nonatomic, strong) UISwitch *theSwitch;
@end

@implementation AppointmentConfirmVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [self.itemsListContainer removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = getLocalizationString(@"select_service_4_appointment");
    self.contentView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEngineerData:) name:@"ConfirmEngineerData" object:nil];
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, titleList) subscribeNext:^(NSArray *titleList) {
        @strongify(self);
        [self.inputListTV reloadData];
    }];
}

- (void)componentSetting {
    self.dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [self setRightNavButtonWithTitleOrImage:@"提交预约" style:UIBarButtonItemStyleDone target:self action:@selector(submitAppointment) titleColor:nil isNeedToSet:YES];
    
    [self setUpTitleList];
}

- (void)setUpTitleList {
    @autoreleasepool {
        __block NSMutableString *string = [NSMutableString string];
        [_appointmentItemsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(NSArray *)obj enumerateObjectsUsingBlock:^(id subObj, NSUInteger subIdx, BOOL *subStop) {
                if (subIdx<=1) {
                    [string appendFormat:@"   %@\n",subObj];
                    if (subIdx==1&&idx==1) [string deleteCharactersInRange:NSMakeRange(string.length-2, 2)];
                }
                if (subIdx==2) {
                    if (idx==1) [string appendString:@"......"];
                    *subStop = YES;
                }
            }];
        }];
        
        if (!_userData) {
            self.userData = [[DBHandler shareInstance] getUserInfo];
        }
        NSString *userName = _userData.nichen;
        NSString *mobileNo = _userData.telphone;
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.titleList = [@[@{@"title":@"预约人：", @"value":(!userName)?@"请填写预约人":userName, @"tf-Title":@"预约人", @"tf-ph":@"请输入预约人"},
                            @{@"title":@"预约手机：", @"value":(!mobileNo)?@"请填写手机号":mobileNo, @"tf-Title":@"预约手机", @"tf-ph":@"请输入预约手机"},
                            @{@"title":@"预约时间：", @"value":@"请填选择预约时间", @"tf-Title":@"预约时间", @"tf-ph":@"请选择预约时间"},
                            @{@"title":@"技师选择：", @"value":@"请选择技师（如不选择系统会自动分派技师）"},
                            @{@"title":@"同意更换技师和修改预约时间：", @"value":@"switch"},
                            @{@"title":@"已选的服务列表：", @"value":string}] mutableCopy];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGFloat offset = CGRectGetWidth(self.contentView.frame)*0.05;
        self.theSwitch = [UISwitch new];
        _theSwitch.on = NO;
//
//        self.applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        _applyButton.frame = CGRectMake(offset, CGRectGetHeight(self.contentView.frame)-60.0f,
//                                        CGRectGetWidth(self.contentView.frame)-offset*2.0f, 40.0f);
//        _applyButton.backgroundColor = CDZColorOfRed;
//        [_applyButton setTitle:getLocalizationString(@"apply_appointment") forState:UIControlStateNormal];
//        [_applyButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
//        [_applyButton setTitle:getLocalizationString(@"apply_appointment") forState:UIControlStateDisabled];
//        [_applyButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
//        [_applyButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
////        [_applyButton addTarget:self action:@selector(pushToAppointmentConfirmVC) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_applyButton];
        
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
        [self.contentView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToTheAutoSelection) forControlEvents:UIControlEventTouchUpInside];
        
        self.shopDetailLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                        andEdgeInsetsValue:DefaultEdgeInsets];
        _shopDetailLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        _shopDetailLabel.textColor = CDZColorOfBlack;
        _shopDetailLabel.numberOfLines = 0;
        [self.contentView addSubview:_shopDetailLabel];
        NSMutableString *text = [[NSMutableString alloc]initWithFormat:@"维修商：%@",_shopDetail[@"wxs_name"]];
        [text appendFormat:@"\n地址：%@",_shopDetail[@"address"]];
        [text appendFormat:@"\n电话：%@",_shopDetail[@"wxs_telphone"]];
        _shopDetailLabel.text = text;
        
        CGSize size = [SupportingClass getStringSizeWithString:_shopDetailLabel.text
                                                          font:_shopDetailLabel.font
                                                   widthOfView:CGSizeMake(CGRectGetWidth(self.contentView.frame)-_shopDetailLabel.edgeInsets.left-_shopDetailLabel.edgeInsets.right, CGFLOAT_MAX)];
        
        CGRect shopDetailRect = self.contentView.bounds;
        shopDetailRect.origin.y = CGRectGetMaxY(_ASView.frame);
        shopDetailRect.size.height = size.height+20.0f;
        _shopDetailLabel.frame = shopDetailRect;
        
        
        CGRect tvRect = self.contentView.bounds;
        tvRect.origin.y = CGRectGetMaxY(_shopDetailLabel.frame);
        tvRect.size.height =CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_shopDetailLabel.frame)-15.0f;
        self.inputListTV = [[UITableView alloc] initWithFrame:tvRect];
        _inputListTV.backgroundColor = self.contentView.backgroundColor;
        _inputListTV.delegate = self;
        _inputListTV.dataSource = self;
        _inputListTV.bounces = NO;
        _inputListTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_inputListTV];
        
        self.datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minimumDate = [NSDate date];
        _datePicker.date = _datePicker.minimumDate;
        [_datePicker addTarget:self action:@selector(datePickeValeChange:) forControlEvents:UIControlEventValueChanged];
        
        
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        
        self.itemsListContainer = [[UIControl alloc] initWithFrame:window.bounds];
        _itemsListContainer.alpha = 0;
        _itemsListContainer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
        [_itemsListContainer addTarget:self action:@selector(hiddenItemListView) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:_itemsListContainer];
        
        self.itemsListTV = [[UITableView alloc] initWithFrame:CGRectMake(offset, offset*2.5f,
                                                                         CGRectGetWidth(_itemsListContainer.bounds)-offset*2.0f,
                                                                         CGRectGetHeight(_itemsListContainer.bounds)-offset*5.0f)];
        _itemsListTV.backgroundColor = self.contentView.backgroundColor;
        _itemsListTV.delegate = self;
        _itemsListTV.dataSource = self;
        _itemsListTV.bounces = NO;
        _itemsListTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _itemsListTV.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_itemsListTV.frame), 20.0f)];
        
        CGPoint point = _itemsListTV.center;
        point.y = CGRectGetHeight(_itemsListContainer.frame)*1.5f;
        _itemsListTV.center = point;
        [_itemsListTV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_itemsListContainer addSubview:_itemsListTV];
        
//        CGFloat cancelButtonSize = 40.0f;
//        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        cancelButton.frame = CGRectMake(CGRectGetWidth(_itemsListContainer.frame)-cancelButtonSize, 0.0f, cancelButtonSize, cancelButtonSize);
//        cancelButton.titleLabel.font = systemFontBoldWithoutRatio(45.0f);
//        [cancelButton setTitle:@"X" forState:UIControlStateNormal];
//        [cancelButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
//        [cancelButton addTarget:self action:@selector(hiddenItemListView) forControlEvents:UIControlEventTouchUpInside];
//        [_itemsListContainer addSubview:cancelButton];
    }
}

- (void)datePickeValeChange:(UIDatePicker *)datePicker {
    self.tmpTextField.text = [_dateFormatter stringFromDate:[datePicker date]];
    [self.tmpTextField sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)pushToTheAutoSelection {
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO andSelectionResultBlock:nil];
}

- (void)confirmAppointment {
    
}

- (void)getEngineerData:(NSNotification *)noitObject {
    self.selectedEngineerData = noitObject.object;
    [self updateInputDataBy:3];
}

- (void)updateInputDataBy:(NSInteger)index {
    if (index>(_titleList.count-1)) {
        return;
    }
    @autoreleasepool {
        if(index<=2&&_tmpTextField.text&&![_tmpTextField.text isEqualToString:@""]){
            NSMutableArray *array = [self mutableArrayValueForKey:@"titleList"];
            NSMutableDictionary *settingDetail = [array[index] mutableCopy];
            [settingDetail setObject:_tmpTextField.text forKey:@"value"];
            [array replaceObjectAtIndex:index withObject:settingDetail];
        }
        if(index==3){
            NSMutableArray *array = [self mutableArrayValueForKey:@"titleList"];
            NSMutableDictionary *settingDetail = [array[index] mutableCopy];
            NSString *name = _selectedEngineerData[@"compellation"];
            [settingDetail setObject:name forKey:@"value"];
            [array replaceObjectAtIndex:index withObject:settingDetail];
        }
    }
    
    _tmpTextField = nil;
}

- (void)showItemListView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGPoint point = self.itemsListTV.center;
        point.y -= CGRectGetHeight(self.itemsListContainer.frame);
        self.itemsListTV.center = point;
        self.itemsListContainer.alpha = 1;
    }];
}

- (void)hiddenItemListView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGPoint point = self.itemsListTV.center;
        point.y += CGRectGetHeight(self.itemsListContainer.frame);
        self.itemsListTV.center = point;
        self.itemsListContainer.alpha = 0;
    }completion:^(BOOL finished) {
        @strongify(self);
        self.itemsListTV.contentOffset = CGPointMake(0.0f, 0.0f);
    }];
}

- (void)appointmentSuccessApply {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(BaseTabBarController *)result.lastObject setSelectedIndex:3];
    }

    MyMaintenanceManagementVC *vc = MyMaintenanceManagementVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([tableView isEqual:_itemsListTV]) {
        return _appointmentItemsList.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([tableView isEqual:_itemsListTV]) {
        return [_appointmentItemsList[section] count];
    }
    return _titleList.count;
}

- (UITableViewCell *)getItemListCellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setBackgroundColor:CDZColorOfWhite];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = CDZColorOfDefaultColor;
    }
    
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = [_appointmentItemsList[indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_itemsListTV]) {
        return [self getItemListCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *identItemsCell = @"ItemsCell";
    BOOL isLastItem = ((_titleList.count-1)==indexPath.row);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(isLastItem)?identItemsCell:CDZKeyOfCellIdentKey];
    if (isLastItem) {
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identItemsCell];
            [cell setBackgroundColor:CDZColorOfWhite];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
            cell.textLabel.numberOfLines = 0;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = CDZColorOfDefaultColor;
        }
    }else {
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
            [cell setBackgroundColor:CDZColorOfWhite];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
            cell.textLabel.numberOfLines = 0;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = CDZColorOfDefaultColor;
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (cell.accessoryView) {
        cell.accessoryView = nil;
    }
    cell.textLabel.text = @"";
    cell.textLabel.text = [_titleList[indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = @"";
    if (![[_titleList[indexPath.row] objectForKey:@"value"]isEqualToString:@"switch"]) {
        cell.detailTextLabel.text = [_titleList[indexPath.row] objectForKey:@"value"];
    }else {
        cell.accessoryView = _theSwitch;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_itemsListTV]) {
        NSString *string = [_appointmentItemsList[indexPath.section] objectAtIndex:indexPath.row];
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        CGFloat height = [SupportingClass getStringSizeWithString:string
                                                             font:font
                                                      widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-30.0f, CGFLOAT_MAX)].height+20.0f;
        
        return height;
    }
    
    if (indexPath.row==(_titleList.count-1)) {
        @autoreleasepool {
            NSString *string = [_titleList[indexPath.row] objectForKey:@"title"];
            NSString *detailString = [_titleList[indexPath.row] objectForKey:@"value"];
            UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            UIFont *detailFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
            CGFloat height = [SupportingClass getStringSizeWithString:string
                                                                 font:font
                                                          widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-30.0f, CGFLOAT_MAX)].height+20.0f;
            
            CGFloat detailHeight = [SupportingClass getStringSizeWithString:detailString
                                                                       font:detailFont
                                                                widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-30.0f, CGFLOAT_MAX)].height;
            
            return height+detailHeight;
        }
    }
    return 36.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_itemsListTV]) {
        return 35.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([tableView isEqual:_itemsListTV]) {
        @autoreleasepool {
            static NSString *headerIdentifier = @"header";
            UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
            if(!myHeader) {
                myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
                InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                                   andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
                titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
                titleLabel.textAlignment = NSTextAlignmentLeft;
                titleLabel.tag = 10;
                titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
                titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                [myHeader addSubview:titleLabel];
            
                [myHeader setNeedsUpdateConstraints];
                [myHeader updateConstraintsIfNeeded];
                [myHeader setNeedsLayout];
                [myHeader layoutIfNeeded];
            }
            NSArray *titleList = @[getLocalizationString(@"repair_items_selected"),
                                   getLocalizationString(@"maintenance_items_selected")];
            InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
            NSString *title = titleList[section];
            titleLabel.text = title;
            
            return myHeader;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_inputListTV==tableView) {
        [self showInputView:indexPath];
    }
}

- (void)showInputView:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (indexPath.row<=2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[_titleList[indexPath.row] objectForKey:@"tf-Title"]
                                                                message:nil delegate:self cancelButtonTitle:getLocalizationString(@"cancel")
                                                      otherButtonTitles:getLocalizationString(@"ok"), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textFiled = [alertView textFieldAtIndex:0];
            textFiled.text = [_titleList[indexPath.row] objectForKey:@"value"];
            textFiled.placeholder = [_titleList[indexPath.row] objectForKey:@"tf-ph"];
            textFiled.tag = indexPath.row;
            self.tmpTextField = textFiled;
            if (indexPath.row==2){
                _datePicker.minimumDate = NSDate.date;
                if ([textFiled.text isEqualToString:@"请填选择预约时间"]){
                    _datePicker.date = NSDate.date;
                    textFiled.text = [_dateFormatter stringFromDate:_datePicker.date];
                }else {
                    _datePicker.date = [_dateFormatter dateFromString:textFiled.text];
                }
                textFiled.inputView = _datePicker;
            }
            
            [alertView show];
        }
        if (indexPath.row==3) {
            
            EngineerListVC * engineerListVC = [[EngineerListVC alloc] init];
            engineerListVC.shopID = _shopDetail[@"id"];
            engineerListVC.isForSelection = YES;
            engineerListVC.selectedEngineerData = _selectedEngineerData;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:engineerListVC animated:YES];
        }
        if (indexPath.row==5) {
            [self showItemListView];
        }
    }
}

#pragma mark- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *textFiled = [alertView textFieldAtIndex:0];
    if (buttonIndex==1) {
        [self updateInputDataBy:textFiled.tag];
    
    }

}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] == 0){
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)itemsInfoDataPrepare {
    @autoreleasepool {
        __block NSMutableString *listString = [NSMutableString stringWithString:@""];
        [_appointmentItemsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *array = (NSArray *)obj;
                if (array.count!=0) {
                    NSString *tmpString = [array componentsJoinedByString:@","];
                    [listString appendString:tmpString];
                    [listString appendString:@","];
                    
                }
            }
        }];
        NSRange range = NSMakeRange(listString.length-1, 1);
        if ([[listString substringWithRange:range] isEqualToString:@","]) {
            [listString deleteCharactersInRange:range];
        }
        return listString;
    }
}

- (NSNumber *)serviceType {
    BOOL haveRepairType = NO;
    BOOL haveMaintenanceType = NO;
    if ([_appointmentItemsList[0] count]!=0) {
        haveRepairType = YES;
    }
    if ([_appointmentItemsList[1] count]!=0) {
        haveMaintenanceType = YES;
    }
    if (haveRepairType&&haveMaintenanceType) {
        return @(2);
    }
    if (haveMaintenanceType) {
        return @(1);
    }
    return @(0);

}

- (void)submitAppointment {
    [self.inputListTV reloadData];
    __block BOOL isReady = YES;
    NSArray *array = @[@"请填写预约人",
                       @"请填写手机号",
                       @"请填选择预约时间"];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *string = [self.titleList[idx] objectForKey:@"value"];
        if ([obj isEqualToString:string]||[string isEqualToString:@""]) {
            isReady = NO;
            *stop = YES;
            [SupportingClass showAlertViewWithTitle:nil message:obj isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        }
    }];
    if (!isReady) return;
    
    
    if (!self.ASView.autoData.brandID||[self.ASView.autoData.brandID isEqualToString:@""]||
        !self.ASView.autoData.dealershipID||[self.ASView.autoData.dealershipID isEqualToString:@""]||
        !self.ASView.autoData.seriesID||[self.ASView.autoData.seriesID isEqualToString:@""]||
        !self.ASView.autoData.modelID||[self.ASView.autoData.modelID isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择预约车辆型号！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @autoreleasepool {
//        NSString *shopID =  _shopDetail[@"id"];
//        NSString *serviceItem = [self itemsInfoDataPrepare];
//        NSNumber *serviceType = [self serviceType];
//        BOOL isPurchaseByShop = YES;
//        NSString *contactName = [_titleList[0] objectForKey:@"value"];
//        NSString *contactNumber = [_titleList[1] objectForKey:@"value"];
//        NSString *dateTime = [_titleList[2] objectForKey:@"value"];
//        NSString *technicianID = _selectedEngineerData[@"id"];
//        if(!technicianID) technicianID = @"";
//        NSString *brandID = _ASView.autoData.brandID;
//        NSString *brandDealershipID = _ASView.autoData.dealershipID;
//        NSString *seriesID = _ASView.autoData.seriesID;
//        NSString *modelID = _ASView.autoData.modelID;
//        
//        [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"send_appointment") onView:nil];
//        @weakify(self);
//        [[APIsConnection shareConnection] maintenanceShopsAPIsPostConfirmAppointmentMaintenanceServieWithAccessToken:self.accessToken
//                                                                                                              shopID:shopID
//                                                                                                         serviceItem:serviceItem
//                                                                                                         serviceType:serviceType
//                                                                                                         contactName:contactName
//                                                                                                       contactNumber:contactNumber
//                                                                                                      purchaseByShop:isPurchaseByShop
//                                                                                                            dateTime:dateTime
//                                                                                                        technicianID:technicianID
//                                                                                                            isChange:@(_theSwitch.on)
//                                                                                                             brandID:brandID
//                                                                                                   brandDealershipID:brandDealershipID
//                                                                                                            seriesID:seriesID
//                                                                                                             modelID:modelID
//        success:^(NSURLSessionDataTask *operation, id responseObject) {
//            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
//            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
//            NSLog(@"%@",message);
//            if (errorCode!=0) {
//                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
//                [ProgressHUDHandler dismissHUD];
//                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
//                return;
//            }
//            [ProgressHUDHandler dismissHUDWithCompletion:^{
//                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                    @strongify(self);
//                    [self appointmentSuccessApply];
//                }];
//                
//            }];
//            
//        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//            NSLog(@"%@",error);
//            [ProgressHUDHandler dismissHUD];
//            if (error.code==-1009) {
//                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                }];
//                return;
//            }
//            
//            
//            if (error.code==-1001) {
//                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                }];
//                return;
//            }
//            
//            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//        }];
        
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        self.navShouldPopOtherVC = NO;
    }else {
        self.navShouldPopOtherVC = YES;
    }
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", RepairShopDetailVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            BaseViewController *vc = result.lastObject;
            [self.navigationController popToViewController:vc animated:YES];
        }else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
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
