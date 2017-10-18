//
//  VehicleSelectionPickerVC.m
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//  请选择车型VC

#import "VehicleSelectionPickerVC.h"
#import "SelectionStepFlowView.h"
#import "InsetsLabel.h"
#import "PersonalHistorySelectView.h"
#import "UserSelectedAutosInfoDTO.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define vContainerViewDefaultTag 100
#define vLogoIVDefaultTag 200
#define vInfoLabelDefaultTag 300
#define vWarningLabelDefaultTag 400

@interface VehicleSelectionPickerVC ()

@property (nonatomic, strong) SelectionStepFlowView *stepView;
/// 个人选择的视图
@property (nonatomic, strong) PersonalHistorySelectView *personalSelectView;
/// 历史选择的视图
@property (nonatomic, strong) PersonalHistorySelectView *historySelectView;
/// 图标文件名称
@property (nonatomic, strong) NSArray *logoFileName;
/// 标志名称
@property (nonatomic, strong) NSArray *logoName;
/// 选择汽车数据
@property (nonatomic, strong) UserSelectedAutosInfoDTO *selectedAutoData;

@end
@implementation VehicleSelectionPickerVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:getLocalizationString(@"select_cars")];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    
    // 确认车型的选择
    [self setRightNavButtonWithTitleOrImage:(@"ok")
                                      style:UIBarButtonItemStyleDone
                                     target:self action:@selector(confirmCarSelection) titleColor:nil
                                isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.loginAfterShouldPopToRoot = NO;
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNetworkAccess];
    [self.stepView addKeyboardObserve];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.stepView removeKeyboardObserve];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    //Signal to handle is data ready
    NSArray *array = @[RACObserve(self, personalSelectView.isReady),
                       RACObserve(self, historySelectView.isReady),
                       RACObserve(self, stepView.isReady)];
    @weakify(self);
    [[RACSignal combineLatest:array reduce:^id(NSNumber *isReady1, NSNumber *isReady2, NSNumber *isReady3){
        NSLog(@"%@,%@,%@",isReady1,isReady2,isReady3);
        return @(isReady1.boolValue && isReady2.boolValue && isReady3.boolValue);
    }] subscribeNext:^(NSNumber *isReady) {
        if (isReady.boolValue) {
//            @strongify(self);
            [ProgressHUDHandler dismissHUD];
        }
    }];
    
    //Signal for Autos selected data ready
    [RACObserve(self, selectedAutoData) subscribeNext:^(UserSelectedAutosInfoDTO *autoData) {
        @strongify(self);
        NSLog(@"autoData %@",autoData);
        if (autoData) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }];
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handle personalSelectView is select & data ready
    RACSignal *personalSelectedSignal = RACObserve(self, personalSelectView.isSelected);
    RACSignal *personalDataSignal = RACObserve(self, personalSelectView.autoData);
    [personalSelectedSignal subscribeNext:^(NSNumber *isSelected) {
        if (isSelected.boolValue) {
            @strongify(self);
            [self.historySelectView deselectedSelf];
            [self.stepView deselectedSelf];
        }
    }];
    
    [[RACSignal combineLatest:@[personalSelectedSignal, personalDataSignal] reduce:^id(NSNumber *isSelected, UserSelectedAutosInfoDTO *autoData){
        return @(isSelected.boolValue&&autoData);
    }] subscribeNext:^(NSNumber *isReady) {
        @strongify(self);
        if (isReady.boolValue) {
            self.selectedAutoData = self.personalSelectView.autoData;
        }else {
            self.selectedAutoData = nil;
        }
    }];
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handle historySelectView is select & data ready
    RACSignal *historySelectedSignal = RACObserve(self, historySelectView.isSelected);
    RACSignal *historyDataSignal = RACObserve(self, historySelectView.autoData);
    [historySelectedSignal subscribeNext:^(NSNumber *isSelected) {
        @strongify(self);
        if (isSelected.boolValue) {
            [self.personalSelectView deselectedSelf];
            [self.stepView deselectedSelf];
        }
    }];
    
    [[RACSignal combineLatest:@[historySelectedSignal, historyDataSignal] reduce:^id(NSNumber *isSelected, UserSelectedAutosInfoDTO *autoData){
        return @(isSelected.boolValue&&autoData);
    }] subscribeNext:^(NSNumber *isReady) {
        @strongify(self);
        if (isReady.boolValue) {
            self.selectedAutoData = self.historySelectView.autoData;
        }else {
            self.selectedAutoData = nil;
        }
    }];
    
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handle SelfSelectView is select & data ready
    RACSignal *stepSelectedSignal = RACObserve(self, stepView.isSelected);
    RACSignal *stepDataSignal = RACObserve(self, stepView.autoData);
    
    [stepSelectedSignal subscribeNext:^(NSNumber *isSelected) {
        @strongify(self);
        if (isSelected.boolValue) {
            [self.personalSelectView deselectedSelf];
            [self.historySelectView deselectedSelf];
        }
    }];
    
    [[RACSignal combineLatest:@[stepSelectedSignal, stepDataSignal] reduce:^id(NSNumber *isSelected, UserSelectedAutosInfoDTO *autoData){
        return @(isSelected.boolValue&&autoData);
    }] subscribeNext:^(NSNumber *isReady) {
        @strongify(self);
        if (isReady.boolValue) {
            self.selectedAutoData = self.stepView.autoData;
        }else {
            self.selectedAutoData = nil;
        }
    }];
    
}

- (void)activeLoginVC {
    if (!UserBehaviorHandler.shareInstance.getUserToken) {
        [self presentLoginViewWithBackTitle:@"cancel" animated:YES completion:^{
           
        }];
    }
}

#pragma mark- Pirvate Functions
- (void)getNetworkAccess{
    UIView *view = nil;
    if (_onlyForSelection) view = _stepView.toolBar.superview;
    [ProgressHUDHandler showHUDWithTitle:@"" onView:view];
    if (!_onlyForSelection) {
        [_historySelectView setupUIInfoData];
        [_personalSelectView setupUIInfoData];
    }
    [_stepView setupUIInfoData];
    
}

#pragma mark -  确定车型的点击事件
- (void)confirmCarSelection {
    @autoreleasepool {
        if (_onlyForSelection) {
            NSLog(@"%@", _selectedAutoData);
            [NSNotificationCenter.defaultCenter postNotificationName:CDZKeyOfSelectedAutosInfo object:_selectedAutoData];
        }else {
            
            BOOL isDone = [[DBHandler shareInstance] updateSelectedAutoData:_selectedAutoData];
            if (_stepView.isSelected.boolValue && isDone) {
                [[DBHandler shareInstance] updateAutoSelectedHistory:_selectedAutoData];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)responseSelection:(id)sender {
    if ([sender isKindOfClass:[UIControl class]]) {
        
    }
}

#pragma mark- Data Handle
- (void)dataSetupAndRequest {
    [ProgressHUDHandler showHUD];
}

#pragma mark- UI Initial And Setting
- (void)initializationUI {
    @autoreleasepool {
        
        self.scrollView.hidden = NO;
        self.scrollView.scrollEnabled = NO;
        
        
        //History Autos Selection
        self.historySelectView = [[PersonalHistorySelectView alloc] initWithFrame:CGRectMake(0.0f, vAdjustByScreenRatio(6.0f), CGRectGetWidth(self.scrollView.frame), vAdjustByScreenRatio(120.0f))];
        [_historySelectView initializationUIWasHistoryView:YES];
        [self.scrollView addSubview:_historySelectView];
        
        //User Autos Selection
        self.personalSelectView = [[PersonalHistorySelectView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                              CGRectGetMaxY(_historySelectView.frame)+vAdjustByScreenRatio(6.0f),
                                                                                              CGRectGetWidth(self.scrollView.frame),
                                                                                              vAdjustByScreenRatio(120.0f))];
        [_personalSelectView initializationUIWasHistoryView:NO];
        [_personalSelectView addTarget:self action:@selector(activeLoginVC) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_personalSelectView];
        [_personalSelectView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
        
        //User Autos Step Flow Selection
        self.stepView = [[SelectionStepFlowView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   CGRectGetMaxY(_personalSelectView.frame)+vAdjustByScreenRatio(6.0f),
                                                                                   CGRectGetWidth(self.scrollView.frame),
                                                                                   vAdjustByScreenRatio((IS_IPHONE_4_OR_LESS?170.0f:180.0f)))];
        _stepView.onlyForSelection = _onlyForSelection;
        [_stepView initializationUI];
        [self.scrollView addSubview:_stepView];
        [_stepView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    
}

#pragma Dummy Data Code Section
- (void)cutTheCarLogo {
    if(!_logoFileName){
        [self setLogoFileName:@[@"bugatti",@"pagani",@"maybach",
                                @"bentley",@"spyker",@"rolls_royce",
                                @"ferrari",@"Lamborghini",@"maserati",
                                @"aston_martin",@"porsche",@"lincoln",
                                @"hammer",@"lexus",@"jaguar",
                                @"bmw",@"benz",@"lotus"]];
    }
    if(!_logoName){
        [self setLogoName:@[@"布加迪",@"帕加尼",@"迈巴赫",
                            @"宾利",@"世爵",@"劳斯莱斯",
                            @"法拉利",@"兰博基尼",@"马萨拉蒂",
                            @"阿斯顿马丁",@"保时捷",@"林肯",
                            @"悍马",@"雷克萨斯",@"捷豹",
                            @"宝马",@"奔驰",@"路特斯"]];
    }
    CGFloat startCutX = 53.0f;
    CGFloat startCutY = 70.0f;
    CGFloat rowGap = 99.0f;
    CGFloat columnGap = 96.0f;
    CGFloat imageWidth = 292.0f;
    CGFloat imageHeight = 292.0f;
    NSInteger columnCount = 3;
    NSInteger totalCount = 18;
    UIImage *totalCarLogo = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"car_logo" ofType:@"jpg"]];
    for (int i = 0; i < totalCount; i++) {
        
        NSInteger currentRow = i/columnCount;
        NSInteger currentColumn = i%columnCount;
        
        CGRect frame = CGRectMake(startCutX+(columnGap+imageWidth)*currentColumn,
                                  startCutY+(rowGap+imageHeight)*currentRow,
                                  imageWidth,
                                  imageHeight);
        [ImageHandler getImageFromCacheByRatioFromImage:[ImageHandler croppingImageWithImage:totalCarLogo toRect:frame] fileRootPath:kSysImageCaches fileName:[_logoFileName objectAtIndex:i] type:FMImageTypeOfPNG exifData:nil needToUpdate:YES];
        
    }
    
}

/*
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
