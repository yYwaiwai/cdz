//
//  RepairCasesComponent.m
//  cdzer
//
//  Created by KEns0n on 11/27/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#define kListOne @"list_one"
#define kListTwo @"list_two"
#define kObjNameKey @"name"
#define kObjDictionaryKey @"dictionary"
#define kObjIDKey @"id"
#define kObjNoteKey @"note"
#define kObjFirstKey @"first"

#import "RepairCasesComponent.h"

@interface InternalCaseCell : UITableViewCell

@property (nonatomic, strong) InsetsLabel *reminderLabel;

@end

@implementation InternalCaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.reminderLabel = [[InsetsLabel alloc] initWithFrame:self.bounds andEdgeInsetsValue:DefaultEdgeInsets];
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
        _reminderLabel.numberOfLines = 0;
        _reminderLabel.text = @"请先选择车系车型";
        _reminderLabel.hidden = YES;
        _reminderLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_reminderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.textLabel.frame)+2.0f;
    self.detailTextLabel.frame = frame;
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.accessoryType = (selected&&self.reminderLabel.hidden)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.accessoryType = (selected&&self.reminderLabel.hidden)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

@end

@interface InternalCaseVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *currentDataList;

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) UIButton *confrimButton;

@property (nonatomic, strong) NSIndexPath *indexPathForSelectedRow;

@property (nonatomic, assign) NSUInteger typeID;

@end

@implementation InternalCaseNav
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
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.dataLists = [@[] mutableCopy];
        self.selectionIDList = [@[] mutableCopy];
        self.selectionStringList = [@[] mutableCopy];
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, view.frame) subscribeNext:^(id rect) {
        @strongify(self);
        self.visibleViewController.view.frame = self.view.bounds;
        [(InternalCaseVC *)self.visibleViewController contentView].frame = self.visibleViewController.view.bounds;
    }];
}

- (void)initializationUI {
    @autoreleasepool {
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
    }
}
@end

@implementation InternalCaseVC


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
    [[(InternalCaseNav *)self.navigationController ASView] reloadUIData];
    if (!_wasStepTwo) {
        [self getRepairCaseStepOne];
    }
    NSMutableArray *selectionIDList = [self.navigationController mutableArrayValueForKey:@"selectionIDList"];
    NSUInteger ident = _wasStepTwo;
    if (selectionIDList.count>=ident&&selectionIDList.count!=0) {
        [selectionIDList removeObjectsInRange:NSMakeRange(ident, selectionIDList.count-ident)];
        NSLog(@"%@ - selectionIDList::%d", NSStringFromClass(self.class), selectionIDList.count);
    }

    NSMutableArray *selectionStringList = [self.navigationController mutableArrayValueForKey:@"selectionStringList"];
    if (selectionStringList.count>=ident&&selectionStringList.count!=0) {
        [selectionStringList removeObjectsInRange:NSMakeRange(ident, selectionStringList.count-ident)];
        NSLog(@"%@ - selectionStringList::%d", NSStringFromClass(self.class), selectionStringList.count);
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

- (void)updateFrameSize {
    if (CGRectEqualToRect(self.view.bounds, UIScreen.mainScreen.bounds)) {
        self.view.frame = self.navigationController.view.bounds;
        self.contentView.frame = self.view.bounds;
        self.scrollView.frame = self.view.bounds;
        
    }
    CGRect frame = self.contentView.bounds;
    if (!_wasStepTwo) {
        AutosSelectedView *asview = [(InternalCaseNav *)self.navigationController ASView];
        frame.origin.y = CGRectGetMaxY(asview.frame);
        frame.size.height = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(asview.frame);
    }
    if (_wasStepTwo) {
        CGFloat height = 70.0f;
        self.buttonView.frame =CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-height, CGRectGetWidth(self.contentView.frame), height);
        frame.size.height = frame.size.height-CGRectGetHeight(_buttonView.frame);
    }

    self.tableView.frame = frame;
}

- (void)setReactiveRules {
    if (_wasStepTwo) {
        @weakify(self);
        [RACObserve(self, indexPathForSelectedRow) subscribeNext:^(NSIndexPath *indexPathForSelectedRow) {
            @strongify(self);
            BOOL wasExist = (indexPathForSelectedRow!=nil);
            self.confrimButton.enabled = wasExist;
            self.confrimButton.backgroundColor = wasExist?CDZColorOfDefaultColor:CDZColorOfDeepGray;
        }];
    }
    
}

- (void)initializationUI {
    @autoreleasepool {
        self.contentView.backgroundColor = CDZColorOfWhite;
        CGRect frame = self.contentView.bounds;
        if (!_wasStepTwo) {
            AutosSelectedView *asview = [(InternalCaseNav *)self.navigationController ASView];
            [self.contentView addSubview:asview];
            frame.origin.y = CGRectGetMaxY(asview.frame);
            frame.size.height = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(asview.frame);
        }
        if (_wasStepTwo) {
            CGFloat height = 70.0f;
            self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-height, CGRectGetWidth(self.contentView.frame), height)];
            _buttonView.backgroundColor = CDZColorOfWhite;
            _buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            _buttonView.translatesAutoresizingMaskIntoConstraints = YES;
            [_buttonView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
            [self.contentView addSubview:_buttonView];
            
            self.confrimButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _confrimButton.frame = CGRectMake(CGRectGetWidth(_buttonView.frame)*0.1, 5.0f, CGRectGetWidth(_buttonView.frame)*0.8, 40.0f);
            _confrimButton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            _confrimButton.center = CGPointMake(_confrimButton.center.x, CGRectGetHeight(_buttonView.frame)/2.0f);
            _confrimButton.backgroundColor = CDZColorOfDefaultColor;
            _confrimButton.enabled = NO;
            [_confrimButton setTitle:@"确定" forState:UIControlStateNormal];
            [_confrimButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_confrimButton setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
            [_confrimButton addTarget:self action:@selector(getCasesResult) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addSubview:_confrimButton];
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
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 10.0f)];
        [self.contentView addSubview:_tableView];
        
    }
}

- (void)popPreviousStepView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushNextStepViewWithData:(NSArray *)responseObject {
    @autoreleasepool {
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||responseObject.count==0) {
            return;
        }
        InternalCaseVC *vc = InternalCaseVC.new;
        vc.wasStepTwo = YES;
        vc.currentDataList = responseObject;
        vc.ignoreViewResize = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)wasOrTypeCellWithIndexPath:(NSIndexPath *)indexPath {
    if (!_wasStepTwo) {
        NSDictionary *detail = [_currentDataList[indexPath.section] objectAtIndex:indexPath.row];
        return [detail[kObjNameKey] isEqualToString:@"space_line"];
    }
    return NO;
}

- (void)pushToResultViewWithResultDetail:(NSDictionary *)resultDetail theIDsList:(NSArray *)theIDsList theTextList:(NSArray *)theTextList {
    @autoreleasepool {
        if (!resultDetail||resultDetail.count==0||!theIDsList||theIDsList.count==0||!theTextList||theTextList.count==0) {
            return;
        }
        [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfSDCResult object:nil userInfo:@{CDZKeyOfResultKey:resultDetail, @"theIDsList":theIDsList, @"theTextList":theTextList}];
    }
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!_wasStepTwo) {
        if (self.currentDataList.count>0) {
            return 2;
        }
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!_wasStepTwo) {
        if (_currentDataList.count==0) {
            return 1;
        }
        return [_currentDataList[section] count];
    }
    return _currentDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InternalCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[InternalCaseCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17.0f, NO);
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 12.0f, NO);
        cell.detailTextLabel.textColor = CDZColorOfDeepGray;
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.reminderLabel.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (_currentDataList.count==0&&!_wasStepTwo) {
        cell.reminderLabel.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (!_wasStepTwo) {
        NSArray *list = _currentDataList[indexPath.section];
        NSDictionary *detail = list[indexPath.row];
        if (![self wasOrTypeCellWithIndexPath:indexPath]) {
            cell.textLabel.text = detail[(indexPath.section==0)?kObjDictionaryKey:kObjFirstKey];
        }else {
            cell.textLabel.text = @"---------------------------------------------";
        }
        if (indexPath.section==1) {
            cell.detailTextLabel.text = detail[kObjNameKey];
        }
    }else {
        cell.textLabel.text = [_currentDataList[indexPath.row] objectForKey:kObjDictionaryKey];
    }
    
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    if (cell.detailTextLabel.text.length>2&&[[cell.detailTextLabel.text substringToIndex:1] isEqualToString:@" "]) {
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_currentDataList.count==0&&!_wasStepTwo) {
        return CGRectGetHeight(tableView.frame);
    }

    if ([self wasOrTypeCellWithIndexPath:indexPath]) {
        return 30.0f;
    }
    if (indexPath.section==1&&indexPath.row==[_currentDataList[indexPath.section] count]-1) {
        return 70;
    }
    if (indexPath.section==1) {
        return 58;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_currentDataList.count==0) {
        return 0;
    }
    if (!_wasStepTwo) return 50.0f;
    if (section==1) return 50.0f;
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
            
            if (_wasStepTwo) {
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
        NSArray *titleList = @[@"问题："];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.0f, NO);
        titleLabel.textAlignment = NSTextAlignmentCenter;

        if (!_wasStepTwo) {
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
    if (_currentDataList.count==0&&!_wasStepTwo) {
        return;
    }
    @autoreleasepool {
        if (![self wasOrTypeCellWithIndexPath:indexPath]) {
            self.indexPathForSelectedRow = indexPath;
            NSString *theID = @"";
            NSString *theString = @"";
            NSMutableArray *selectionIDList = [self.navigationController mutableArrayValueForKey:@"selectionIDList"];
            NSMutableArray *selectionStringList = [self.navigationController mutableArrayValueForKey:@"selectionStringList"];
            if (!_wasStepTwo) {
                NSArray *list = _currentDataList[indexPath.section];
                NSDictionary *detail = list[indexPath.row];
                theID = detail[kObjIDKey];
                theString = detail[(indexPath.section==0)?kObjDictionaryKey:kObjFirstKey];
                self.typeID = indexPath.section;
                [selectionIDList removeAllObjects];
                [selectionStringList removeAllObjects];
                [selectionStringList addObject:theString];
                [selectionIDList addObject:theID];
                [self getRepairCaseStepTwoWithStepID:theID andStepString:theString];
            }else {
                theID = [_currentDataList[indexPath.row] objectForKey:kObjIDKey];
                theString = [_currentDataList[indexPath.row] objectForKey:kObjDictionaryKey];
                if (selectionStringList.count==2) [selectionStringList removeLastObject];
                if (selectionStringList.count==2) [selectionIDList removeLastObject];
                [selectionStringList addObject:theString];
                [selectionIDList addObject:theID];
            }
        }else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
}

#pragma mark- APIs Access Request

- (void)getRepairCaseStepOne {
    AutosSelectedView *asview = [(InternalCaseNav *)self.navigationController ASView];
    NSString *modelID = asview.autoData.modelID;
    if (!modelID||[modelID isEqualToString:@""]) {
        NSLog(@"did not selet the autos");
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetHistoryCasesOfStepOneListWithAutosModelID:modelID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        NSDictionary *obj = responseObject[CDZKeyOfResultKey];
//        NSMutableArray *firstObject = obj[kListOne];
//        [firstObject addObject:@{@"id":@"",
//                                 @"value":@"",
//                                 @"dictionary":@"space_line",
//                                 @"type":@"1",
//                                 @"note":@"",}]
        self.currentDataList = @[obj[kListOne], obj[kListTwo]];
        NSMutableArray *totalData = [self.navigationController mutableArrayValueForKey:@"dataLists"];
        [totalData removeAllObjects];
        [totalData addObject:responseObject];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)getRepairCaseStepTwoWithStepID:(NSString *)stepID andStepString:(NSString *)stepString {
    
    if (!stepID||[stepID isEqualToString:@""]||!stepString||[stepString isEqualToString:@""]) {
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetHistoryCasesOfStepTwoListWithStepOneID:stepID selectedTextTitle:stepString isDescSymptoms:_typeID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (!responseObject[CDZKeyOfResultKey]||[responseObject[CDZKeyOfResultKey] count]==0) {
            errorCode = 1;
        }
        if (errorCode!=0) {
            if (!responseObject[CDZKeyOfResultKey]||[responseObject[CDZKeyOfResultKey] count]==0) {
                message = @"没有更多选择";
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        [self pushNextStepViewWithData:responseObject[CDZKeyOfResultKey]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)getCasesResult {
    NSMutableArray *selectionIDList = [self.navigationController valueForKey:@"selectionIDList"];
    NSMutableArray *selectionStringList = [self.navigationController valueForKey:@"selectionStringList"];
    
    AutosSelectedView *asview = [(InternalCaseNav *)self.navigationController ASView];
    NSString *brandID = asview.autoData.brandID;
    NSString *brandDealershipID = asview.autoData.dealershipID;
    NSString *seriesID = asview.autoData.seriesID;
    NSString *modelID = asview.autoData.modelID;
    //    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetHistoryCasesResultListWithTwoStepIDsList:selectionIDList twoStepTextList:selectionStringList address:@"" priceSort:@"" brandID:brandID brandDealershipID:brandDealershipID seriesID:seriesID modelID:modelID pageNums:@(1) pageSizes:@(10) success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0||[responseObject[CDZKeyOfResultKey] count]==0) {
            if ([responseObject[CDZKeyOfResultKey] count]==0) {
                message = @"没有你所要求的结果";
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [self pushToResultViewWithResultDetail:responseObject[CDZKeyOfResultKey] theIDsList:selectionIDList theTextList:selectionStringList];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

@end
