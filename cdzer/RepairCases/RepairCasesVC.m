//
//  RepairCasesVC.m
//  cdzer
//
//  Created by KEns0n on 6/19/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define stepViewBaseTag 700
#define numLogoBaseTag 600
#define labelBaseTag 500
#define cellHeight 40.0f
#define kObjNameKey @"name"
#define kObjIDKey @"id"
#define kObjDictionaryKey @"dictionary"
#define kObjNoteKey @"note"
#define kObjFirstKey @"first"

#import "RepairCasesVC.h"
#import "AutosSelectedView.h"
#import "InsetsLabel.h"
#import <UIView+Borders/UIView+Borders.h>
#import "RepairCasesResultVC.h"

@interface RepairCasesVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CGRect keyboardRect;
@property (nonatomic, strong) NSNumber *currentSelectType;
@property (nonatomic, strong) NSMutableArray *totalDataList;

@property (nonatomic, strong) UITableView *firstStepTV;
@property (nonatomic, strong) UITableView *secondStepTV;
@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) UIView *typeSelectionView;
@property (nonatomic, strong) UIControl *secondStepTVMainView;;

@property (nonatomic, strong) UIButton *descSymptoms, *descAutosMalfunction;

@property (nonatomic, strong) NSIndexPath *firstIndexPath, *secondIndexPath;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView *confirmButtonMainView;

@end

@implementation RepairCasesVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"get_cases")];
    [self setRightNavButtonWithTitleOrImage:@"类型" style:UIBarButtonItemStyleDone target:self action:@selector(showHidenTypeView) titleColor:CDZColorOfWhite isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self componentSetting];
    [self setReactiveRules];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_totalDataList[0][0] count]==0||[_totalDataList[0][1] count]==0) {
        [self getRepairCaseStepOne];
    }
    [_ASView reloadUIData];
}

- (void)componentSetting {
    self.totalDataList = [@[@[@[],@[]],@[]] mutableCopy];
    self.currentSelectType = @(-1);
}

- (void)setReactiveRules {
    @weakify(self);
    RACSignal *indexOneSignal = [RACObserve(self, firstIndexPath) map:^id(NSIndexPath *indexPath) {
        return @(indexPath!=nil);
    }];
    
    RACSignal *indexTwoSignal = [RACObserve(self, secondIndexPath) map:^id(NSIndexPath *indexPath) {
        return @(indexPath!=nil);
    }];
    
    RACSignal *typeViewSignal = [RACObserve(self, typeSelectionView.alpha) map:^id(NSNumber *alpha) {
        return @(alpha.integerValue==0);
    }];
    
    RACSignal *secondTVMVSignal = [RACObserve(self, secondStepTVMainView.alpha) map:^id(NSNumber *alpha) {
        return @(alpha.integerValue==1);
    }];
    
    
    [[RACSignal combineLatest:@[indexOneSignal, indexTwoSignal, typeViewSignal, secondTVMVSignal] reduce:^id(NSNumber *indexOneSignal, NSNumber *indexTwoSignal, NSNumber *alphaValue, NSNumber *tvAlphaValue){
        return @(indexOneSignal.boolValue&&indexTwoSignal.boolValue&&alphaValue.boolValue&&tvAlphaValue.boolValue);
    }] subscribeNext:^(NSNumber *isDone) {
        @strongify(self);
        CGFloat offsetY = CGRectGetHeight(self.contentView.frame);
        if (isDone.boolValue) {
            offsetY = CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(self.confirmButtonMainView.frame);
        }
       [UIView animateWithDuration:0.25 animations:^{
           CGRect frame = self.confirmButtonMainView.frame;
           frame.origin.y = offsetY;
           self.confirmButtonMainView.frame = frame;
           self.confirmButtonMainView.alpha = isDone.boolValue;
       }];
    }];
//    [RACObserve(self, totalDataList) subscribeNext:^(id sender) {
//        @strongify(self);
//        NSArray *tmpArray = self.selectionLists;
//        [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if (self.currentStepIndex.row<idx) {
//                NSMutableDictionary *detailData = [obj mutableCopy];
//                [detailData setObject:@(-1) forKey:kSelectedIdxKey];
//                [detailData setObject:@"" forKey:kSelectedStringKey];
//                [self.selectionLists replaceObjectAtIndex:idx withObject:detailData];
//            }
//        }];
//        [self.tableView reloadData];
//    }];
//    
//    [RACObserve(self, tableView.contentSize) subscribeNext:^(id sender) {
//        NSLog(@"%@",sender);
//    }];
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
        [self.contentView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
        self.firstStepTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_ASView.frame),
                                                                         CGRectGetWidth(self.contentView.frame),
                                                                         CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_ASView.frame))];
        _firstStepTV.bounces = NO;
        _firstStepTV.showsHorizontalScrollIndicator = YES;
        _firstStepTV.showsVerticalScrollIndicator = YES;
        _firstStepTV.delegate = self;
        _firstStepTV.dataSource = self;
        [self.contentView addSubview:_firstStepTV];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        self.secondStepTVMainView = [[UIControl alloc] initWithFrame:_firstStepTV.frame];
        _secondStepTVMainView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.6f];
        _secondStepTVMainView.alpha = 0;
        [_secondStepTVMainView addTarget:self action:@selector(hiddenSecondStepTVWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_secondStepTVMainView];
        
        self.secondStepTV = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame), 0.0f,
                                                                          CGRectGetWidth(self.contentView.frame)*0.75f,
                                                                          CGRectGetHeight(_secondStepTVMainView.frame))];
        _secondStepTV.bounces = NO;
        _secondStepTV.showsHorizontalScrollIndicator = YES;
        _secondStepTV.showsVerticalScrollIndicator = YES;
        _secondStepTV.delegate = self;
        _secondStepTV.dataSource = self;
        _secondStepTV.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_secondStepTV.frame), 70.0f)];
        [_secondStepTVMainView addSubview:_secondStepTV];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        [self initTypeView];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.confirmButtonMainView = [[UIControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(self.confirmButtonMainView.frame),
                                                                                 CGRectGetWidth(self.contentView.frame),
                                                                                 66.f)];
        _confirmButtonMainView.backgroundColor = [UIColor colorWithRed:0.227f green:0.227f blue:0.227f alpha:1.00f];
        _confirmButtonMainView.alpha = 0;
        [self.contentView addSubview:_confirmButtonMainView];
        
        CGFloat width = CGRectGetWidth(self.contentView.frame)*0.8f;
        CGFloat offsetX = CGRectGetWidth(self.contentView.frame)*0.1f;
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmButton.titleLabel.numberOfLines = 0;
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _confirmButton.frame = CGRectMake(offsetX,
                                         (CGRectGetHeight(_confirmButtonMainView.frame)-36.0f)/2,
                                         width, 36.0f);
        [_confirmButton setTitleEdgeInsets:DefaultEdgeInsets];
        [_confirmButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_confirmButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_confirmButton setTitleColor:CDZColorOfWhite forState:UIControlStateHighlighted];
        [_confirmButton setTitle:getLocalizationString(@"ok") forState:UIControlStateNormal];
        [_confirmButton setTitle:getLocalizationString(@"ok") forState:UIControlStateHighlighted];
        [_confirmButton setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfDefaultColor withRect:_descSymptoms.bounds] forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfOrangeColor withRect:_descSymptoms.bounds] forState:UIControlStateHighlighted];
        [_confirmButton addTarget:self action:@selector(getCasesResult) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButtonMainView insertSubview:_confirmButton belowSubview:_typeSelectionView];
    }
}

- (void)initTypeView {
    CGRect typeRect = self.contentView.bounds;
    typeRect.origin.y = CGRectGetMaxY(_ASView.frame);
    typeRect.size.height = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_ASView.frame);
    self.typeSelectionView = [[UIView alloc] initWithFrame:typeRect];
    _typeSelectionView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.88f];
    [self.contentView addSubview:_typeSelectionView];
    
    CGFloat hight = CGRectGetHeight(_typeSelectionView.frame)*0.36f;
    CGFloat offsetY = CGRectGetHeight(_typeSelectionView.frame)*0.07;
    CGFloat width = CGRectGetWidth(_typeSelectionView.frame)*0.8f;
    CGFloat offsetX = CGRectGetWidth(_typeSelectionView.frame)*0.1f;
    
    self.descAutosMalfunction = [UIButton buttonWithType:UIButtonTypeSystem];
    _descAutosMalfunction.titleLabel.numberOfLines = 0;
    _descAutosMalfunction.titleLabel.textAlignment = NSTextAlignmentCenter;
    _descAutosMalfunction.frame = CGRectMake(offsetX, offsetY, width, hight);
    [_descAutosMalfunction setTitleEdgeInsets:DefaultEdgeInsets];
    [_descAutosMalfunction setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [_descAutosMalfunction setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_descAutosMalfunction setTitleColor:CDZColorOfWhite forState:UIControlStateSelected];
    [_descAutosMalfunction setTitleColor:CDZColorOfBlack forState:UIControlStateHighlighted];
    [_descAutosMalfunction setTitle:@"如果您知道您的车辆故障所处的车辆部位，您可以点击此处以车辆部位查找问题：" forState:UIControlStateNormal];
    [_descAutosMalfunction setTitle:@"如果您知道您的车辆故障所处的车辆部位，您可以点击此处以车辆部位查找问题：" forState:UIControlStateSelected];
    [_descAutosMalfunction setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfDefaultColor withRect:_descAutosMalfunction.bounds] forState:UIControlStateNormal];
    [_descAutosMalfunction setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfOrangeColor withRect:_descAutosMalfunction.bounds] forState:UIControlStateSelected];
    [_descAutosMalfunction addTarget:self action:@selector(typeSelection:) forControlEvents:UIControlEventTouchUpInside];
    [_typeSelectionView addSubview:_descAutosMalfunction];
    
    self.descSymptoms = [UIButton buttonWithType:UIButtonTypeSystem];
    _descSymptoms.titleLabel.numberOfLines = 0;
    _descSymptoms.titleLabel.textAlignment = NSTextAlignmentCenter;
    _descSymptoms.frame = CGRectMake(offsetX, CGRectGetMaxY(_descAutosMalfunction.frame)+offsetY*2.0f, width, hight);
    [_descSymptoms setTitleEdgeInsets:DefaultEdgeInsets];
    [_descSymptoms setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [_descSymptoms setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_descSymptoms setTitleColor:CDZColorOfWhite forState:UIControlStateSelected];
    [_descSymptoms setTitleColor:CDZColorOfBlack forState:UIControlStateHighlighted];
    [_descSymptoms setTitle:@"如果您不知道是什么问题，\n请选择点击此处以症状描述查找问题：" forState:UIControlStateNormal];
    [_descSymptoms setTitle:@"如果您不知道是什么问题，\n请选择点击此处以症状描述查找问题：" forState:UIControlStateSelected];
    [_descSymptoms setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfDefaultColor withRect:_descSymptoms.bounds] forState:UIControlStateNormal];
    [_descSymptoms setBackgroundImage:[ImageHandler createImageWithColor:CDZColorOfOrangeColor withRect:_descSymptoms.bounds] forState:UIControlStateSelected];
    [_descSymptoms addTarget:self action:@selector(typeSelection:) forControlEvents:UIControlEventTouchUpInside];
    [_typeSelectionView addSubview:_descSymptoms];
    
}

- (void)pushToVehicleSelectedVC {
    [self pushToAutoSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO];
}

#pragma mark- Private Functions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHidenTypeView {
 
    if (_typeSelectionView.alpha) {
        [self hiddenTypeViewWithAnimation];
    }else {
        [self showTypeViewWithAnimation];
    }
}

- (void)hiddenTypeViewWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.typeSelectionView.alpha = 0;
        CGRect frame = self.typeSelectionView.frame;
        frame.origin.y = CGRectGetHeight(self.contentView.frame);
        self.typeSelectionView.frame = frame;
        
        self.navigationItem.rightBarButtonItem.tintColor = CDZColorOfWhite;
        self.navigationItem.rightBarButtonItem.enabled = YES;;
    }];
}

- (void)showTypeViewWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.typeSelectionView.alpha = 1;
        CGRect frame = self.typeSelectionView.frame;
        frame.origin.y = CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(frame);
        self.typeSelectionView.frame = frame;
        
        
        self.navigationItem.rightBarButtonItem.tintColor = CDZColorOfOrangeColor;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)showSecondStepTVWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.secondStepTVMainView.alpha = 1;
        CGRect frame = self.secondStepTV.frame;
        frame.origin.x = CGRectGetWidth(self.secondStepTVMainView.frame)-CGRectGetWidth(frame);
        self.secondStepTV.frame = frame;
    }];
}

- (void)hiddenSecondStepTVWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.secondStepTVMainView.alpha = 0;
        CGRect frame = self.secondStepTV.frame;
        frame.origin.x = CGRectGetWidth(self.secondStepTVMainView.frame);
        self.secondStepTV.frame = frame;
        
    }];
}

- (void)cleanSelectionRecord {
    [_totalDataList replaceObjectAtIndex:1 withObject:@[]];
    self.firstIndexPath = nil;
    self.secondIndexPath = nil;
    [_firstStepTV reloadData];
    [_secondStepTV reloadData];
    [self hiddenSecondStepTVWithAnimation];
}

- (void)typeSelection:(UIButton *)button {
    if ([button isEqual:_descAutosMalfunction]) {
        _descSymptoms.selected = NO;
        button.selected = YES;
        [self hiddenTypeViewWithAnimation];
        if (_currentSelectType.integerValue==0) {
            return;
        }
        self.currentSelectType = @(0);
        [self cleanSelectionRecord];
    }
    if ([button isEqual:_descSymptoms]) {
        _descAutosMalfunction.selected = NO;
        button.selected = YES;
        [self hiddenTypeViewWithAnimation];
        if (_currentSelectType.integerValue==1) {
            return;
        }
        self.currentSelectType = @(1);
        [self cleanSelectionRecord];
    }
}

- (void)pushToResultViewWithResultDetail:(NSDictionary *)resultDetail theIDsList:(NSArray *)theIDsList theTextList:(NSArray *)theTextList {
    @autoreleasepool {
        RepairCasesResultVC *vc = [RepairCasesResultVC new];
        vc.resultDetail = resultDetail;
        vc.theTextList = theTextList;
        vc.theIDsList = theIDsList;
        [self setNavBarBackButtonTitleOrImage:nil titleColor:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([tableView isEqual:_firstStepTV]) {
        if (_currentSelectType.integerValue<0) {
            return 0;
        }
        return [_totalDataList[0][_currentSelectType.integerValue] count];
    }
    
    return [_totalDataList[1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.detailTextLabel.textColor = CDZColorOfDeepGray;
        
    }
    // Configure the cell...
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.textLabel.numberOfLines = 1;
    if ([tableView isEqual:_firstStepTV]) {
        NSArray *array = [_totalDataList[0] objectAtIndex:_currentSelectType.integerValue];
        NSDictionary *detail = array[indexPath.row];
        if (_currentSelectType.integerValue==0) {
            cell.textLabel.text = detail[kObjDictionaryKey];
        }else {
            cell.textLabel.text = detail[kObjFirstKey];
            if ([[detail[kObjFirstKey] substringToIndex:1]isEqualToString:@" "]) {
                cell.textLabel.text = [detail[kObjFirstKey] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            cell.detailTextLabel.text = detail[kObjNameKey];
            if ([[detail[kObjNameKey] substringToIndex:1]isEqualToString:@" "]) {
                cell.detailTextLabel.text = [detail[kObjNameKey] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
        }
    }
    if ([tableView isEqual:_secondStepTV]) {
        cell.textLabel.numberOfLines = 0;
        NSArray *array = _totalDataList[1];
        NSDictionary *detail = array[indexPath.row];
        cell.textLabel.text = detail[kObjDictionaryKey];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_secondStepTV]) {
        
        NSDictionary *data = [_totalDataList[1] objectAtIndex:indexPath.row];
        NSString *string = data[kObjDictionaryKey];
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17.0f, NO);
        CGSize size = [SupportingClass getStringSizeWithString:string font:font widthOfView:CGSizeMake(CGRectGetWidth(tableView.frame)-2.0f*15.0f, CGFLOAT_MAX)];
        return size.height+22.0f;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Update the delete button's title based on how many items are selected.
    NSLog(@"%@",[tableView indexPathsForSelectedRows]);
    if ([tableView isEqual:_firstStepTV]) {
        if (_firstIndexPath) {
            if ([indexPath compare:_firstIndexPath]==NSOrderedSame&&[_totalDataList[1] count]!=0) {
                [self showSecondStepTVWithAnimation];
                return;
            }
        }
        self.secondIndexPath = nil;
        self.firstIndexPath = indexPath;
        [self getRepairCaseStepTwo:indexPath];
    }
    if ([tableView isEqual:_secondStepTV]) {
        self.secondIndexPath = indexPath;
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


#pragma mark- APIs Access Request
- (void)getRepairCaseStepOne {
    NSString *modelID = _ASView.autoData.modelID;
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
        [self.totalDataList replaceObjectAtIndex:0 withObject:@[obj[@"list_one"], obj[@"list_two"]]];
        
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

- (void)getRepairCaseStepTwo:(NSIndexPath *)indexPath {
    NSArray *array = [_totalDataList[0] objectAtIndex:_currentSelectType.integerValue];
    NSDictionary *detail = array[indexPath.row];
    NSString *theID = @"";
    NSString *theTitle = @"";
    if ([detail[kObjIDKey] isKindOfClass:NSNumber.class]) {
        theID = [detail[kObjIDKey] stringValue];
    }else {
        theID = detail[kObjIDKey];
    }
    if (!_currentSelectType.boolValue) {
        theTitle = detail[kObjDictionaryKey];
    }else {
        theTitle = detail[kObjNameKey];
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetHistoryCasesOfStepTwoListWithStepOneID:theID selectedTextTitle:theTitle isDescSymptoms:_currentSelectType.boolValue success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (responseObject[CDZKeyOfResultKey]) {
            [self.totalDataList replaceObjectAtIndex:1 withObject:responseObject[CDZKeyOfResultKey]];
        }
        if (errorCode!=0||[self.totalDataList[1] count]==0) {
            if ([self.totalDataList[1] count]==0) {
                message = @"没有更多选择";
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        [self.secondStepTV reloadData];
        [self showSecondStepTVWithAnimation];

        
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
    NSArray *dataArrayOne = [_totalDataList[0] objectAtIndex:_currentSelectType.integerValue];
    NSArray *dataArrayTwo = _totalDataList[1];
    NSDictionary *detailOne = dataArrayOne[_firstIndexPath.row];
    NSDictionary *detailTwo = dataArrayTwo[_secondIndexPath.row];
    NSString *stringKeyForOne = (_currentSelectType.boolValue)?kObjFirstKey:kObjDictionaryKey;
    
    NSArray *theIDsList = @[detailTwo[kObjIDKey], detailOne[kObjIDKey]];
    NSArray *theTextList = @[detailTwo[kObjDictionaryKey], detailOne[stringKeyForOne]];
    NSString *brandID = _ASView.autoData.brandID;
    NSString *brandDealershipID = _ASView.autoData.dealershipID;
    NSString *seriesID = _ASView.autoData.seriesID;
    NSString *modelID = _ASView.autoData.modelID;
//    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetHistoryCasesResultListWithTwoStepIDsList:theIDsList twoStepTextList:theTextList address:@"" priceSort:@"" brandID:brandID brandDealershipID:brandDealershipID seriesID:seriesID modelID:modelID pageNums:@(1) pageSizes:@(10) success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        [self pushToResultViewWithResultDetail:responseObject[CDZKeyOfResultKey] theIDsList:theIDsList theTextList:theTextList];
        
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
