//
//  SelfAnalyzationVC.m
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define stepViewBaseTag 700
#define numLogoBaseTag 600
#define labelBaseTag 500
#define kObjNameKey @"dictionary"
#define kObjIDKey @"id"
#define kObjNoteKey @"note"
#define kSelectedIdxKey @"idx"
#define kSelectedStringKey @"string"

#import "SelfAnalyzationVC.h"
#import "AutosSelectedView.h"
#import "SelfAnalyzationResultVC.h"
#import "VehicleSelectionPickerVC.h"

@interface SelfAnalyzationVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (nonatomic, assign) CGRect keyBoardRect;

@property (nonatomic, strong) AutosSelectedView *ASView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITextField *infoTextField;
@property (nonatomic, strong) UIPickerView *pickerview;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *previousButton, *nextButton, *doneButton;
@property (nonatomic, strong) NSArray *stepViewTitleList;

@property (nonatomic, strong) NSMutableArray *totalDataList, *innerDataList, *selectionLists;
@property (nonatomic, strong) NSNumber *currentStep;
@end

@implementation SelfAnalyzationVC

- (void)viewRuleSetting {
    self.stepViewTitleList = @[@"failure_type",
                               @"failure_appearance",
                               @"failure_type_struct",
                               @"failure_factor_analyze",
                               @"slove_problem",
                               @"component_replacement"];
    self.innerDataList = [NSMutableArray arrayWithObject:@""];
    self.totalDataList = [NSMutableArray arrayWithCapacity:6];
    [self.totalDataList addObjectsFromArray:@[@[],@[],@[],@[],@[],@[]]];
    self.selectionLists = [NSMutableArray arrayWithCapacity:6];
    [self.selectionLists addObjectsFromArray:@[@{kSelectedIdxKey:@(-1),kSelectedStringKey:@""},
                                               @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""},
                                               @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""},
                                               @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""},
                                               @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""},
                                               @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""}]];
    self.currentStep = @(0);
}

- (void)viewReactiveRules {
    @weakify(self)
    [RACObserve(self, currentStep) subscribeNext:^(NSNumber *currentStep) {
        @strongify(self)
        if (currentStep.integerValue==6) {
            NSLog(@"Beyond Bounds ");
        }
        [self handleSwitchInnerData];
        [self updateStepViewStatus];
        NSInteger currentIndex = [[self.selectionLists[currentStep.integerValue] objectForKey:kSelectedIdxKey] integerValue];
        [self.pickerview selectRow:currentIndex+1 inComponent:0 animated:NO];
        [self.pickerview reloadComponent:0];
    }];
    
    RACSignal *totalDataSignal = [self rac_valuesAndChangesForKeyPath:@keypath(self,totalDataList) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observer:nil];
    [totalDataSignal subscribeNext:^(RACTuple *x){
        NSDictionary *changeDictionary = x.second;
        NSInteger idxOfChange = [changeDictionary[@"indexes"] firstIndex];
        [self updateTotalDataListByIdx:idxOfChange isNeedUpdateSelectID:YES];
    }];
    
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"self_analyzation")];
    [self setRightNavButtonWithTitleOrImage:getLocalizationString(@"finish") style:UIBarButtonItemStyleDone target:self action:@selector(getAutoAnalyztionResult) titleColor:nil isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self viewRuleSetting];
    [self viewReactiveRules];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_totalDataList[0] count]==0) {
        [self getAutoSelfAnalyztionAPIsAccessRequestByID:nil requestIdx:0];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [_ASView reloadUIData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark- Private Functions
- (void)resignKeyboard {
    [_scrollView setContentOffset:CGPointZero animated:YES];
    [_infoTextField resignFirstResponder];
}

- (void)barButtonAction:(UIBarButtonItem *)barButton {
    @autoreleasepool {
        NSInteger currentStep = _currentStep.integerValue;
        if ([barButton isEqual:_nextButton]&&currentStep!=5) {
            currentStep++;
            
        }else if([barButton isEqual:_previousButton]&&currentStep!=0) {
            currentStep--;
        }
        [self showPickerViewByStepView:[self getStepViewByTag:currentStep]];
    }
}

- (UIControl *)getStepViewByTag:(NSInteger)tag {
    return (UIControl *)[_scrollView viewWithTag:tag+stepViewBaseTag];
}

- (void)showPickerViewByStepView:(UIControl *)controlView {
    if(![self.infoTextField isFirstResponder])[self.infoTextField becomeFirstResponder];
    NSInteger tag = controlView.tag-stepViewBaseTag;
    if (_currentStep.integerValue==tag) return;
    self.currentStep = @(tag);
    [self shiftScrollViewWithAnimation];
}

#pragma mark- UI Response & Data Handle Code Section
- (void)updateStepViewStatus {
    @autoreleasepool {
        UIColor *normalColor = CDZColorOfDefaultColor;
        UIColor *selectedColor = UIColor.orangeColor;
        NSInteger currentIdx = _currentStep.integerValue;
        for (int i=0; i<_stepViewTitleList.count; i++) {
            UIControl *conView = [self getStepViewByTag:i];
            UIView *button = [conView viewWithTag:numLogoBaseTag];
            //预设设定
            button.backgroundColor = normalColor;
            button.alpha = 0.4;
            conView.userInteractionEnabled = NO;
            //条件性设定
            if (currentIdx==i) button.backgroundColor = selectedColor;
            if (currentIdx+1>=i&&[_totalDataList[i] count]>0) {
                button.alpha = 1;
                conView.userInteractionEnabled = YES;
            }
        }
        
        _previousButton.enabled = !(currentIdx==0);
        _nextButton.enabled = !(currentIdx==_selectionLists.count-1);
        if (currentIdx!=5){
            if([_totalDataList[currentIdx+1] count]==0) {
                _nextButton.enabled = NO;
            }
        }
        
        self.navigationItem.rightBarButtonItem.enabled = NO;;
        NSDictionary *tmpDic =  @{kSelectedIdxKey:@(-1),kSelectedStringKey:@""};
        if (![_selectionLists.lastObject isEqual:tmpDic]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)updateStepViewTitle {
    @weakify(self)
    [_stepViewTitleList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @strongify(self)
        UIControl *conView = [self getStepViewByTag:idx];
        UILabel *label = (UILabel *)[conView viewWithTag:labelBaseTag];
        NSMutableString *text = [NSMutableString stringWithString:getLocalizationString(obj)];
        if (self.currentStep.integerValue>=idx) {
            [text appendString:[self.selectionLists[idx] objectForKey:kSelectedStringKey]];
        }
        label.text = text;
    }];
}

// 键盘处理
- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyBoardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyBoardRect, _keyBoardRect)) {
        self.keyBoardRect = keyBoardRect;
    }
    [self shiftScrollViewWithAnimation];
    NSLog(@"Step One");
}

- (void)shiftScrollViewWithAnimation{
    UIControl *conView = [self getStepViewByTag:_currentStep.integerValue];
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY(conView.frame)+CGRectGetMinY(conView.superview.frame);
    CGFloat visibleContentsHeight = (CGRectGetHeight(_scrollView.frame)-CGRectGetHeight(_keyBoardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    
    [_scrollView setContentOffset:point animated:NO];
    
}

- (void)restoreScrollViewToTop {
    [_scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
}

#pragma Data Handle
- (void)updateTotalDataListByIdx:(NSInteger)changeIdx isNeedUpdateSelectID:(BOOL)isNeedUpdate{
    [_totalDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx>changeIdx) {
            NSLog(@"current::%lu changeIdx::%ld",(unsigned long)idx,(long)changeIdx);
            [self.totalDataList replaceObjectAtIndex:idx withObject:@[]];
        }
        if (isNeedUpdate) {
            if (idx>=changeIdx) {
                [self.selectionLists replaceObjectAtIndex:idx withObject:@{kSelectedIdxKey:@(-1),kSelectedStringKey:@""}];
            }
        }
    }];
    [self updateStepViewTitle];
    [self updateStepViewStatus];
}

#pragma mark- UI Config And Setup
- (void)initStepFlowView:(CGRect *)lastRect tagID:(NSInteger)tagID contianerView:(UIView *)contianerView withStrKey:(NSString *)strKey {
    if (!contianerView) return;
    CGRect rect = *lastRect;
    UIControl *view = [[UIControl alloc] initWithFrame:rect];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setTag:stepViewBaseTag+tagID];
    [view addTarget:self action:@selector(showPickerViewByStepView:) forControlEvents:UIControlEventTouchUpInside];
    [contianerView addSubview:view];
    rect.origin.y = CGRectGetMaxY(rect);
    *lastRect = rect;
    
    CGRect numLogoRect = CGRectZero;
    numLogoRect.size = CGSizeMake(CGRectGetHeight(rect)*0.6, CGRectGetHeight(rect)*0.6);
    UIButton *numLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    [numLogo setFrame:numLogoRect];
    [numLogo setCenter:CGPointMake(vAdjustByScreenRatio(26.0f), CGRectGetHeight(rect)/2.0f)];
    [numLogo setUserInteractionEnabled:NO];
    [numLogo setTitle:[[NSNumber numberWithInteger:tagID+1] stringValue] forState:UIControlStateNormal];
    [numLogo setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [numLogo.titleLabel setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(12.0f)]];
    [numLogo.layer setCornerRadius:CGRectGetHeight(numLogoRect)/2.0f];
    [numLogo.layer setMasksToBounds:YES];
    [numLogo setTag:numLogoBaseTag];
    [numLogo setBackgroundColor:CDZColorOfDefaultColor];
    [numLogo setAlpha:0.5];
    [view addSubview:numLogo];
    
    
    CGFloat stepLblPositionX = CGRectGetMaxX(numLogo.frame)+vAdjustByScreenRatio(4.0f);
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(stepLblPositionX,
                                                                   0.0f,
                                                                   CGRectGetWidth(rect)-stepLblPositionX,
                                                                   CGRectGetHeight(rect))];
    [stepLabel setText:getLocalizationString(strKey)];
    [stepLabel setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)]];
    [stepLabel setTag:labelBaseTag];
    [view addSubview:stepLabel];
}

- (void)initializationUI {
    @autoreleasepool {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        [_scrollView setBackgroundColor:self.contentView.backgroundColor];
        [_scrollView setBounces:NO];
        [_scrollView setScrollEnabled:NO];
        [self.contentView addSubview:_scrollView];
        
        CGRect bannerRect = CGRectZero;
        UIImage *bannerImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"self_test" type:FMImageTypeOfPNG scaleWithPhone4:NO needToUpdate:NO];
        bannerRect.origin.y = (IS_IPHONE_4_OR_LESS)?(-10.0f):0.0f;
        bannerRect.size = bannerImage.size;
        UIImageView *bannerView = [[UIImageView alloc] initWithFrame:bannerRect];
        [bannerView setImage:bannerImage];
        [_scrollView addSubview:bannerView];
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, CGRectGetMaxY(bannerView.frame))];
        [_scrollView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        [self setupPickerView];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        NSString *stepFlowTxt = getLocalizationString(@"setp_flow_title");
        UIFont *stepFlowFont = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
        CGRect stepFlowRect = CGRectZero;
        stepFlowRect.origin.x = vAdjustByScreenRatio(12.0f);
        stepFlowRect.origin.y = CGRectGetMaxY(_ASView.frame)+vAdjustByScreenRatio(vO2OSpaceSpace);
        stepFlowRect.size = [SupportingClass getStringSizeWithString:stepFlowTxt font:stepFlowFont widthOfView:CGSizeMake(CGFLOAT_MAX, vAdjustByScreenRatio(30.0f))];
        UILabel *stepFlowLabel = [[UILabel alloc] initWithFrame:stepFlowRect];
        [stepFlowLabel setBackgroundColor:[UIColor clearColor]];
        [stepFlowLabel setFont:stepFlowFont];
        [stepFlowLabel setText:stepFlowTxt];
        [_scrollView addSubview:stepFlowLabel];
        
        CGFloat perHeight = IS_IPHONE_4_OR_LESS?vAdjustByScreenRatio(35.0f):vAdjustByScreenRatio(40.0f);
        UIView *contianerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         CGRectGetMaxY(stepFlowRect)+vAdjustByScreenRatio(vO2OSpaceSpace),
                                                                         CGRectGetWidth(self.contentView.frame),
                                                                         perHeight*[_stepViewTitleList count])];
        [contianerView setShapeLayer:[ImageHandler
                                      drawDashedBorderByType:BorderTypeSolid
                                      target:contianerView
                                      shapeLayer:contianerView.shapeLayer
                                      borderColor:[UIColor lightGrayColor]
                                      cornerRadius:0.0f
                                      borderWidth:1.0f
                                      dashPattern:0
                                      spacePattern:0
                                      numberOfColumns:0
                                      numberOfRows:6]];
        [contianerView setBackgroundColor:CDZColorOfWhite];
        [_scrollView addSubview:contianerView];
        
        
        __block CGRect sfViewsLastRect = CGRectZero;
        sfViewsLastRect.size.width = CGRectGetWidth(contianerView.frame);
        sfViewsLastRect.size.height = perHeight;
        [_stepViewTitleList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self initStepFlowView:&sfViewsLastRect tagID:idx contianerView:contianerView withStrKey:(NSString *)obj];
        }];
        
    }
}

- (void)setupPickerView {
    self.pickerview = [[UIPickerView alloc] init];
    _pickerview.delegate = self;
    _pickerview.dataSource = self;
    
    self.toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [_toolBar setBarStyle:UIBarStyleDefault];
    self.doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"cancel")
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(resignKeyboard)];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    self.previousButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:101
                                                                       target:self
                                                                       action:@selector(barButtonAction:)];
    _previousButton.enabled = NO;
    UIBarButtonItem *fixSpaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:self
                                                                                   action:nil];
    fixSpaceButton.width = 10.0f;
    self.nextButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:102
                                                                   target:self
                                                                   action:@selector(barButtonAction:)];
    self.nextButton.enabled = NO;
    NSArray * buttonsArray = [NSArray arrayWithObjects:_doneButton,spaceButton,_previousButton,fixSpaceButton,_nextButton,fixSpaceButton,nil];
    [_toolBar setItems:buttonsArray];
    
    self.infoTextField = [[UITextField alloc] initWithFrame:_ASView.frame];
    _infoTextField.inputView = _pickerview;
    _infoTextField.inputAccessoryView = _toolBar;
    _infoTextField.delegate = self;
    _infoTextField.alpha = 0.0f;
    [_scrollView insertSubview:_infoTextField belowSubview:_ASView];

}

- (void)pushToVehicleSelectedVC {
    @autoreleasepool {
        VehicleSelectionPickerVC *vc = [VehicleSelectionPickerVC new];
        [self setNavBarBackButtonTitle:nil titleColor:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showLoadingInPickerSuperview {
    @autoreleasepool {
        UIView *view = _toolBar.superview.superview;
        if (view) {
            [ProgressHUDHandler showHUDWithTitle:nil onView:view];
        }else {
            [ProgressHUDHandler showHUD];
        }
    }
}

#pragma mark- UIPickerView & UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(CGRectZero, _keyBoardRect)) {
        [self shiftScrollViewWithAnimation];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.innerDataList.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    @autoreleasepool {
        UILabel *labelText = [UILabel new];
        [labelText setTextAlignment:NSTextAlignmentCenter];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.font = [UIFont boldSystemFontOfSize:20.0];
        labelText.textColor = [UIColor blackColor];
        [labelText setText:self.innerDataList[row]];
        
        if (row == 0)
        {
            labelText.font = [UIFont boldSystemFontOfSize:30.0];
            labelText.textColor = [UIColor lightGrayColor];
        }
        return labelText;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self selectionHandleWithRow:row];
}

- (void)selectionHandleWithRow:(NSInteger)row {
    @autoreleasepool {
        
        [self updateSelectionListDataWithRow:row];
        if (row<1||_currentStep.integerValue>=5) {
            [self updateTotalDataListByIdx:_currentStep.integerValue isNeedUpdateSelectID:!(_currentStep.integerValue>=5)];
            return;
        }
        NSInteger realIdx = row-1;
        NSArray *dataArray = _totalDataList[_currentStep.integerValue];
        NSString *theIDString = [dataArray[realIdx] objectForKey:kObjNoteKey];
        [self getAutoSelfAnalyztionAPIsAccessRequestByID:theIDString requestIdx:_currentStep.integerValue+1];
    }
    
}

- (void)updateSelectionListDataWithRow:(NSInteger)row {
    @autoreleasepool {
        NSString *nameString = self.innerDataList[row];
        if (row==0) nameString = @"";
        NSDictionary *tmpDic = @{kSelectedIdxKey:@(row-1),kSelectedStringKey:nameString};
        [_selectionLists replaceObjectAtIndex:_currentStep.integerValue withObject:tmpDic];
        [self updateStepViewTitle];
    }
}

#pragma network data Handle Section
// 处理结果
- (void)handleDataList:(NSArray *)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject||responseObject.count==0) {
            NSLog(@"DataList Error at %@",NSStringFromClass(self.class));
            return;
        }
        NSMutableArray *totalData = [self mutableArrayValueForKey:@"totalDataList"];
        [totalData replaceObjectAtIndex:ident withObject:responseObject];
    
        if (ident==0) {
            [self handleSwitchInnerData];
            [self updateStepViewStatus];
        }
    }
}
// 处理内部列表结果
- (void)handleSwitchInnerData {
    @autoreleasepool {
        NSMutableArray *innerData = [self mutableArrayValueForKey:@"innerDataList"];
        NSArray *dataNameArray = [_totalDataList objectAtIndex:_currentStep.integerValue];
        NSString *firstObjTitleKey = [NSString stringWithFormat:@"please_select_failure_titile_id_%ld",(long)_currentStep.integerValue];
        
        [innerData replaceObjectAtIndex:0 withObject:getLocalizationString(firstObjTitleKey)];
        [innerData removeObjectsInRange:NSMakeRange(1, innerData.count-1)];
        [innerData addObjectsFromArray:[dataNameArray valueForKey:kObjNameKey]];
    }
}
// 提示提交完成
- (void)confirmBtnActionGetResult:(UIButton *)button {
    @autoreleasepool {
        SelfAnalyzationResultVC *sarVC = [[SelfAnalyzationResultVC alloc] init];
        [self.navigationController pushViewController:sarVC animated:YES];
    }
}

#pragma mark- APIs Access Request
- (void)getAutoSelfAnalyztionAPIsAccessRequestByID:(NSString *)theIDString requestIdx:(NSInteger)idx {
    [self showLoadingInPickerSuperview];
    switch (idx) {
        case 0:{
            // 请求故障种类
            NSLog(@"%@ accessing Auto failure type list request",NSStringFromClass(self.class));
            [[APIsConnection shareConnection] commonAPIsGetAutoFailureTypeListWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@0}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        case 1:{
            // 请求故障现象
            NSLog(@"%@ accessing Auto fault symptom list request",NSStringFromClass(self.class));
            if (!theIDString) {
                return;
            }
            [[APIsConnection shareConnection] commonAPIsGetAutoFaultSymptomListWithAutoFailureTypeID:theIDString  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@1}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        case 2:{
            // 请求故障架构
            NSLog(@"%@ accessing Auto fault structure list request",NSStringFromClass(self.class));
            if (!theIDString) {
                return;
            }
            [[APIsConnection shareConnection] commonAPIsGetAutoFaultStructureListWithAutoFaultSymptomID:theIDString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@2}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        case 3:{
            // 请求原因分析
            NSLog(@"%@ accessing Diagnosis result list request",NSStringFromClass(self.class));
            if (!theIDString) {
                return;
            }
            [[APIsConnection shareConnection] commonAPIsGetDiagnosisResultListWithAutoFaultStructureID:theIDString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@3}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        case 4:{
            // 请求故障解决方案
            NSLog(@"%@ accessing solution plan list request",NSStringFromClass(self.class));
            if (!theIDString) {
                return;
            }
            [[APIsConnection shareConnection] theSelfDiagnosisAPIsGetSolutionPlanWithDiagnosisResultID:theIDString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@4}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        case 5:{
            // 请求配件更换建议
            NSLog(@"%@ accessing proposed replacement parts list request",NSStringFromClass(self.class));
            if (!theIDString) {
                return;
            }
            [[APIsConnection shareConnection] theSelfDiagnosisAPIsGetProposedReplacementPartsWithSolutionPlanID:theIDString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [operation setUserInfo:@{@"iden":@5}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
            break;
        default:
            NSLog(@"Not find APIs Request Functon");
            break;
    }
}

- (void)getAutoAnalyztionResult {
    [self showLoadingInPickerSuperview];
    NSString *partName = [_selectionLists.lastObject objectForKey:kSelectedStringKey];
    if (!partName) {
        [ProgressHUDHandler showErrorWithStatus:@"Missing Part Name" onView:nil completion:^{
        }];
        return;
    }
    NSString *seriesID = _ASView.autoData[CDZAutosKeyOfSeriesID];
    NSString *autoModelID = _ASView.autoData[CDZAutosKeyOfModelID];
    NSString *address = nil;
    NSNumber *isDescenting = @(0);
    NSString *longitude = @"112.979353";
    NSString *latitude = @"28.213478";
    
    [[APIsConnection shareConnection] theSelfDiagnosisAPIsGetMaintenanceShopsSuggestListWithReplacementPartsName:partName
                                                                                                        seriesID:seriesID
                                                                                                     autoModelID:autoModelID
                                                                                                         address:address
                                                                                                    isDescenting:isDescenting
                                                                                                       longitude:longitude
                                                                                                        latitude:latitude
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        switch (errorCode) {
            case 0:
                NSLog(@"%@",responseObject[CDZKeyOfResultKey]);
                break;
            case 1:
            case 2:
                [SupportingClass showAlertViewWithTitle:getLocalizationString(@"error") message:message isShowImmediate:YES cancelButtonTitle:getLocalizationString(@"ok") otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {                 [ProgressHUDHandler dismissHUD];
                }];
                break;
                
            default:
                break;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
    }];
}

- (void)requestResultHandle:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSNumber *idenNumber = [operation.userInfo objectForKey:@"iden"];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
  
        switch (errorCode) {
            case 0:
                [self handleDataList:[responseObject objectForKey:CDZKeyOfResultKey] withIdent:idenNumber.integerValue];
                break;
            case 1:
            case 2:
                [self updateTotalDataListByIdx:_currentStep.integerValue isNeedUpdateSelectID:NO];
                [SupportingClass showAlertViewWithTitle:getLocalizationString(@"error") message:message isShowImmediate:YES cancelButtonTitle:getLocalizationString(@"ok") otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {                 [ProgressHUDHandler dismissHUD];
                }];
                break;
                
            default:
                break;
        }
        
    }
    
}

@end
