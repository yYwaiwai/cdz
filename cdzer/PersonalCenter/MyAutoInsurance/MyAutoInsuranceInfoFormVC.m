//
//  MyAutoInsuranceInfoFormVC.m
//  cdzer
//
//  Created by KEns0n on 10/12/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  个人车辆保险信息VC

//typedef NS_ENUM(NSInteger, MAIIFType) {
//    MAIIFTypeOfSpace,
////    MAIIFTypeOfMainTitle,
//    MAIIFTypeOfTextField,
//    MAIIFTypeOfSegmentedControl,
//    MAIIFTypeOfSwitch,
//    MAIIFTypeOfFixInfoDisplay,
//    MAIIFTypeOfFixInfoDisplayWithSelection,
//};
//
//#define kContentList @"contentList"
//#define kTitle @"title"
//#define kMAIIFType @"type"

#import "MyAutoInsuranceInfoFormVC.h"
#import "InsetsTextField.h"
#import "UserAutosInfoDTO.h"
#import "InsuranceInfoFormCell.h"
#import "KeyCityDTO.h"
#import "AutosSelectedView.h"
#import "MyCarVC.h"
#import "UserInfosDTO.h"
#import "MAIDSelectionView.h"
#import "UserSelectedAutosInfoDTO.h"

@interface MAIIFAPIsDTOject : NSObject

@property (nonatomic, strong) NSString *brandID;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *brandDealershipID;
@property (nonatomic, strong) NSString *brandDealershipName;
@property (nonatomic, strong) NSString *seriesID;
@property (nonatomic, strong) NSString *seriesIDName;
@property (nonatomic, strong) NSString *modelID;
@property (nonatomic, strong) NSString *modelName;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, strong) NSString *cityID;
@property (nonatomic, strong) NSString *autosNumber;
@property (nonatomic, strong) NSString *autosFrameNum;
@property (nonatomic, strong) NSString *autosEngineNum;
@property (nonatomic, strong) NSString *autosPrice;
@property (nonatomic, strong) NSString *acTypeStr;
@property (nonatomic, strong) NSString *autosRegisterDate;

@property (nonatomic, strong) NSString *autosUsageType;
@property (nonatomic, strong) NSNumber *autosNumOfSeats;
@property (nonatomic, strong) NSNumber *autosWasSHand;
@property (nonatomic, strong) NSString *autosAssignmentDate;

@end

@implementation MAIIFAPIsDTOject
- (instancetype)init {
    self = [super init];
    if (self) {
        self.brandID = @"";
        self.brandName = @"";
        self.brandDealershipID = @"";
        self.brandDealershipName = @"";
        self.seriesID = @"";
        self.seriesIDName = @"";
        self.modelID = @"";
        self.modelName = @"";
        
        self.userName = @"";
        self.phoneNumber = @"";
        
        self.cityID = @"";
        self.autosNumber = @"";
        self.autosFrameNum = @"";
        self.autosEngineNum = @"";
        self.autosPrice = @"";
        self.autosRegisterDate = @"";
        
        self.autosUsageType = @"";
        self.autosNumOfSeats = @0;
        self.autosWasSHand = @0;
        self.autosAssignmentDate = @"";
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}
@end

@interface MyAutoInsuranceInfoFormVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) NSMutableArray *formConfigList;

@property (nonatomic, strong) UserAutosInfoDTO *userAutoInfo;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KeyCityDTO *selectedCity;

@property (nonatomic, strong) UIButton *submitBtn;

@property (nonatomic, strong) NSArray *acTypeList;

@property (nonatomic, strong) NSString *selectedACTypeStr;

@property (nonatomic, strong) MAIDSelectionView *acSelectionView;


- (NSMutableDictionary *)getRowInfoListConfigWithType:(MAIIFType)type title:(NSString *)title placeholder:(NSString *)placeholder textLimit:(NSInteger)limit keyboardType:(UIKeyboardType)keyboardType extraString:(NSString *)extraString value:(id)value popAction:(SEL)action segmentedControlBtnTitles:(nullable NSString *)scButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation MyAutoInsuranceInfoFormVC


- (void)dealloc {
    [self.formConfigList removeAllObjects];
    self.selectedCity = nil;
    self.userAutoInfo = nil;
    self.ASView = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self];
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    if (_isShowCancelBtn) {
        [self setLeftNavButtonWithTitleOrImage:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSubmitForm) titleColor:nil isNeedToSet:YES];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(citySelectionResult:) name:CDZNotiKeyOfUpdateLocation object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(autosSelectionResult:) name:CDZKeyOfSelectedAutosInfo object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateScrollViewOffset:) name:CDZNotiKeyOfUpdateScrollViewOffset object:nil];
    self.title = @"个人车辆保险信息";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
    if (_isFirstTime) {
        [self checkUserAutoInfoExsit];
    }
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkUserAutoInfoExsit {
    BOOL isExsit = NO;
    UserAutosInfoDTO *userAutoInfo = [DBHandler.shareInstance getUserAutosDetail];
    if (_userAutoInfo) {
        if (![userAutoInfo.brandID isEqualToString:self.userAutoInfo.brandID]||
            ![userAutoInfo.dealershipID isEqualToString:self.userAutoInfo.dealershipID]||
            ![userAutoInfo.seriesID isEqualToString:self.userAutoInfo.seriesID]||
            ![userAutoInfo.modelID isEqualToString:self.userAutoInfo.modelID]||
            ![userAutoInfo.frameNumber isEqualToString:self.userAutoInfo.frameNumber]||
            ![userAutoInfo.engineCode isEqualToString:self.userAutoInfo.engineCode]||
            ![userAutoInfo.licensePlate isEqualToString:self.userAutoInfo.licensePlate]||
            ![userAutoInfo.registrTime isEqualToString:self.userAutoInfo.registrTime]) {
            self.userAutoInfo = userAutoInfo;
            [self reloadConfigList];
        }
        if (_userAutoInfo.brandID&&_userAutoInfo.brandID.integerValue>0&&
            _userAutoInfo.dealershipID&&_userAutoInfo.dealershipID.integerValue>0&&
            _userAutoInfo.seriesID&&_userAutoInfo.seriesID.integerValue>0&&
            _userAutoInfo.modelID&&_userAutoInfo.modelID.integerValue>0&&
            _userAutoInfo.frameNumber&&![_userAutoInfo.frameNumber isEqualToString:@""]&&
            _userAutoInfo.engineCode&&![_userAutoInfo.engineCode isEqualToString:@""]&&
            _userAutoInfo.licensePlate&&![_userAutoInfo.licensePlate isEqualToString:@""]&&
            _userAutoInfo.registrTime&&![_userAutoInfo.registrTime isEqualToString:@""]) {
            isExsit = YES;
            [self.tableView reloadData];
        }
    }
    
    if (!isExsit) {
        [ProgressHUDHandler showHUD];
        [self performSelector:@selector(showEditAutoInfoDetailVC) withObject:nil afterDelay:0.8];
    }
}

- (void)showEditAutoInfoDetailVC {
    [ProgressHUDHandler dismissHUD];
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"填写保险信息前，需要完善个人车辆信息，现在去完善吗？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (btnIdx.unsignedIntegerValue==0) {
            [self cancelSubmitForm];
        }
        
        if (btnIdx.unsignedIntegerValue==1) {
            @autoreleasepool {
                MyCarVC *vc = [MyCarVC new];
                vc.wasSubmitAfterLeave = YES;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
}

- (void)cancelSubmitForm {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)componentSetting {
    [self reloadConfigList];
    self.acTypeList = @[@"连续3年未出险", @"连续2年未出险", @"上年未出险", @"新车、上年出险1次", @"新车、上年出险2次", @"新车、上年出险3次", @"新车、上年出险4次", @"新车、上年出险5次"];
    self.selectedACTypeStr = nil;
}

- (void)reloadConfigList {
    @autoreleasepool {
        if (!_formConfigList) {
            self.formConfigList = [NSMutableArray array];
        }
        [self.formConfigList removeAllObjects];
        
        NSString *mobilePhone = (_isFirstTime?DBHandler.shareInstance.getUserInfo.telphone:nil);
        if (!_userAutoInfo&&_isFirstTime) {
            self.userAutoInfo = [DBHandler.shareInstance getUserAutosDetail];
        }else {
            
        }
        
        [_formConfigList addObjectsFromArray:@[@{kTitle:@"", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfSpace
                                                                                                         title:nil placeholder:nil textLimit:1
                                                                                                  keyboardType:UIKeyboardTypeDefault extraString:nil value:nil
                                                                                                     popAction:nil segmentedControlBtnTitles:nil]]},
                                               
                                               @{kTitle:@"车主信息", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfTextField
                                                                                                             title:@"车主姓名：" placeholder:@"请输入车主姓名" textLimit:10
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:nil
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:MAIIFTypeOfTextField
                                                                                                             title:@"联系电话：" placeholder:@"请输入电话号码" textLimit:11
                                                                                                      keyboardType:UIKeyboardTypePhonePad extraString:nil value:mobilePhone
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],]},
                                               
                                               //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                               
                                               @{kTitle:@"", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfSpace
                                                                                                         title:nil placeholder:nil textLimit:11
                                                                                                  keyboardType:UIKeyboardTypeDefault extraString:nil value:nil
                                                                                                     popAction:nil segmentedControlBtnTitles:nil]]},
                                               
                                               @{kTitle:@"车辆信息", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfFixInfoDisplayWithSelection
                                                                                                             title:@"投保城市：" placeholder:@"请选择城市" textLimit:6
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_selectedCity
                                                                                                         popAction:@selector    (pushToCitySelectionView) segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:_isFirstTime?MAIIFTypeOfFixInfoDisplay:MAIIFTypeOfTextField
                                                                                                             title:@"车架号：" placeholder:@"请输入车架号" textLimit:17
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_userAutoInfo.frameNumber
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:_isFirstTime?MAIIFTypeOfFixInfoDisplay:MAIIFTypeOfTextField
                                                                                                             title:@"车牌号：" placeholder:@"请输入车牌号" textLimit:7
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_userAutoInfo.licensePlate
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:_isFirstTime?MAIIFTypeOfFixInfoDisplay:MAIIFTypeOfTextField
                                                                                                             title:@"发动机号：" placeholder:@"发动机号" textLimit:10
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_userAutoInfo.engineCode
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:MAIIFTypeOfTextField
                                                                                                             title:@"车辆价格：" placeholder:@"请输入车辆价格" textLimit:10
                                                                                                      keyboardType:UIKeyboardTypeNumberPad extraString:@"元" value:nil
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:MAIIFTypeOfFixInfoDisplayWithSelection
                                                                                                             title:@"出险次数：" placeholder:@"请出险次数" textLimit:10
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_selectedACTypeStr
                                                                                                         popAction:@selector(showACSelectionView) segmentedControlBtnTitles:nil],
                                                                                
                                                                                [self getRowInfoListConfigWithType:_isFirstTime?MAIIFTypeOfFixInfoDisplay:MAIIFTypeOfDate
                                                                                                             title:@"注册登记日期：" placeholder:@"请选择登记日期" textLimit:10
                                                                                                      keyboardType:UIKeyboardTypeDefault extraString:nil value:_userAutoInfo.registrTime
                                                                                                         popAction:nil segmentedControlBtnTitles:nil],]},
                                               
                                               
                                               //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                               
                                               @{kTitle:@"", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfSpace
                                                                                                         title:nil placeholder:nil textLimit:10
                                                                                                  keyboardType:UIKeyboardTypeDefault extraString:nil value:nil
                                                                                                     popAction:nil segmentedControlBtnTitles:nil]]},
                                               
                                               @{kTitle:@"其他投保信息", kContentList:@[[self getRowInfoListConfigWithType:MAIIFTypeOfSegmentedControl
                                                                                                               title:@"使用性质：" placeholder:nil textLimit:10
                                                                                                        keyboardType:UIKeyboardTypeDefault extraString:nil value:@(0)
                                                                                                           popAction:nil segmentedControlBtnTitles:@"家庭自用汽车", @"企业非营业客车", nil],
                                                                                  
                                                                                  [self getRowInfoListConfigWithType:MAIIFTypeOfTextField
                                                                                                               title:@"座位数量：" placeholder:@"请输入座位数量" textLimit:2
                                                                                                        keyboardType:UIKeyboardTypeNumberPad extraString:@"个" value:nil
                                                                                                           popAction:nil segmentedControlBtnTitles:nil],
                                                                                  
                                                                                  [self getRowInfoListConfigWithType:MAIIFTypeOfSwitch
                                                                                                               title:@"是否过户车：" placeholder:@"" textLimit:2
                                                                                                        keyboardType:UIKeyboardTypeDefault extraString:nil value:@(0)
                                                                                                           popAction:nil segmentedControlBtnTitles:nil],
                                                                                  [self getRowInfoListConfigWithType:MAIIFTypeOfDate
                                                                                                               title:@"过户日期：" placeholder:@"请输入过户日期" textLimit:10
                                                                                                        keyboardType:UIKeyboardTypeDefault extraString:nil value:nil
                                                                                                           popAction:nil segmentedControlBtnTitles:nil],]},]];
    }

}

- (void)pushToCitySelectionView {
    [self pushToCitySelectionViewWithBackTitle:nil selectedCity:_selectedCity hiddenLocation:YES onlySelection:YES animated:YES];
}

- (void)showACSelectionView {
    @autoreleasepool {
        
        if (!_acSelectionView) {
            self.acSelectionView = [MAIDSelectionView new];
        }
        _acSelectionView.currentSelectionID = 0;
        if (_selectedACTypeStr&&![_selectedACTypeStr isEqualToString:@""]) {
            _acSelectionView.currentSelectionID = [_acTypeList indexOfObject:_selectedACTypeStr];
        }
        
        @weakify(self);
        [_acSelectionView setTitle:@"出险次数" withDataList:_acTypeList andWasShowButton:NO responseBlock:^(BOOL isConfirm, NSInteger currentSelectionID) {
            @strongify(self);
            if (isConfirm) {
                self.selectedACTypeStr = self.acTypeList[currentSelectionID];
                
                NSMutableArray *formConfigList = [self mutableArrayValueForKey:@"formConfigList"];
                NSArray *theConfigList = [self.formConfigList mutableCopy];
                [theConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSMutableDictionary *mainDetail = [detail mutableCopy];
                    NSMutableArray *configList = [detail[kContentList] mutableCopy];
                    
                    [detail[kContentList] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull subDetail, NSUInteger subIdx, BOOL * _Nonnull subStop) {
                        
                        NSMutableDictionary *configDetail = [subDetail mutableCopy];
                        NSString *title = configDetail[kTitle];
                        if (title&&[title rangeOfString:@"出险次数"].location!=NSNotFound) {
                            @strongify(self);
                            [configDetail setObject:self.selectedACTypeStr forKey:kValue];
                            [configList replaceObjectAtIndex:subIdx withObject:configDetail];
                            
                            [mainDetail setObject:configList forKey:kContentList];
                            [formConfigList replaceObjectAtIndex:idx withObject:mainDetail];
                            
                            *subStop = YES;
                            *stop = YES;
                            [self.tableView reloadData];
                        }
                    }];
                }];
            }
        }];
    }
}

- (void)citySelectionResult:(NSNotification *)notiObject {
    @autoreleasepool {
        if ([notiObject.object isKindOfClass:KeyCityDTO.class]) {
            self.selectedCity = notiObject.object;
            @weakify(self);
            NSMutableArray *formConfigList = [self mutableArrayValueForKey:@"formConfigList"];
            NSArray *theConfigList = [_formConfigList mutableCopy];
            [theConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *mainDetail = [detail mutableCopy];
                NSMutableArray *configList = [detail[kContentList] mutableCopy];
                
                [detail[kContentList] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull subDetail, NSUInteger subIdx, BOOL * _Nonnull subStop) {
                    
                    NSMutableDictionary *configDetail = [subDetail mutableCopy];
                    NSString *title = configDetail[kTitle];
                    if (title&&[title rangeOfString:@"投保城市"].location!=NSNotFound) {
                        @strongify(self);
                        [configDetail setObject:self.selectedCity forKey:kValue];
                        [configList replaceObjectAtIndex:subIdx withObject:configDetail];
                        
                        [mainDetail setObject:configList forKey:kContentList];
                        [formConfigList replaceObjectAtIndex:idx withObject:mainDetail];
                        
                        *subStop = YES;
                        *stop = YES;
                        [self.tableView reloadData];
                    }
                }];
            }];
        }
    }
}

- (void)autosSelectionResult:(NSNotification *)notiObject {
    @autoreleasepool {
        if ([notiObject.object isKindOfClass:UserSelectedAutosInfoDTO.class]) {
            self.ASView.autoData = notiObject.object;
        }
    }
}
//
- (NSMutableDictionary *)getRowInfoListConfigWithType:(MAIIFType)type title:(NSString *)title placeholder:(NSString *)placeholder textLimit:(NSInteger)textLimit
                                         keyboardType:(UIKeyboardType)keyboardType extraString:(NSString *)extraString value:(id)value
                                            popAction:(SEL)action segmentedControlBtnTitles:(nullable NSString *)scButtonTitles, ...{
    @autoreleasepool {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        if(!title) title = @"没标题";
        if(!value) value = NSNull.null;
        if(!placeholder) placeholder = @"";
        [setting addEntriesFromDictionary:@{kTitle:title,
                                            kMAIIFType:@(type),
                                            kTextLimit:@(textLimit),
                                            kValue:value}];
        [setting setObject:value forKey:kValue];
        switch (type) {
            case MAIIFTypeOfFixInfoDisplay:
                break;
                
            case MAIIFTypeOfFixInfoDisplayWithSelection:
                [setting setObject:placeholder forKey:kPlaceholder];
                if (action) {
                    [setting setObject:NSStringFromSelector(action) forKey:kPopAction];
                }
                break;
                
            case MAIIFTypeOfTextField:
                [setting setObject:placeholder forKey:kPlaceholder];
                [setting setObject:@(keyboardType) forKey:kKeyboardType];
                if (extraString&&![extraString isEqualToString:@""]) {
                    [setting setObject:extraString forKey:kExtraString];
                }
                break;
                
            case MAIIFTypeOfSegmentedControl:
                if (scButtonTitles){
                    va_list args;
                    va_start(args, scButtonTitles); // scan for arguments after firstObject.
                    
                    // get rest of the objects until nil is found
                    NSMutableArray *titleList = [NSMutableArray array];
                    for (NSString *str = scButtonTitles; str != nil; str = va_arg(args, NSString*)) {
                        [titleList addObject:str];
                    }
                    va_end(args);
                    [setting setObject:titleList forKey:kTitleList];
                }else {
                    [setting removeAllObjects];
                }
                [setting removeObjectForKey:kValue];
                break;
                
            case MAIIFTypeOfSpace:
                [setting removeObjectForKey:kTitle];
                [setting removeObjectForKey:kValue];
                [setting setObject:@(10.0f) forKey:@"height"];
                break;
                
            case MAIIFTypeOfDate:
                [setting setObject:placeholder forKey:kPlaceholder];
                break;
                
            case MAIIFTypeOfSwitch:
                break;
                
                
            default:
                //            case MAIIFTypeOfMainTitle:
                [setting removeObjectForKey:kValue];
                break;
        }
        
        return setting;
    }
}

- (void)initializationUI {
    
    
    CGRect tableViewFrame = self.contentView.bounds;
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
    _tableView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];
    
    self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:YES onlyForSelection:!_isFirstTime];
    if (!_isFirstTime) {
        [_ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
    }
    [_ASView setBorderWithColor:nil borderWidth:0.0f];
    _tableView.tableHeaderView = _ASView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 70.0f)];
    _tableView.tableFooterView = view;
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitBtn.backgroundColor = CDZColorOfDefaultColor;
    _submitBtn.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame)*0.8f, 30.0f);
    _submitBtn.center = CGPointMake(CGRectGetWidth(view.frame)/2.0f, (CGRectGetHeight(view.frame)-14.0f)/2.0f);
    [_submitBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [_submitBtn setTitle:getLocalizationString(@"submit") forState:UIControlStateNormal];
    [_submitBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAutoInsuranceInfo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_submitBtn];
    
    self.acSelectionView = [MAIDSelectionView new];
}

- (void)pushToVehicleSelectedVC {
    @weakify(self);
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:YES andSelectionResultBlock:^(UserSelectedAutosInfoDTO *selectedAutosDto) {
        @strongify(self);
        self.ASView.autoData = selectedAutosDto;
        [self.ASView reloadUIData];
    }];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, formConfigList) subscribeNext:^(NSMutableArray *formConfigList) {
        @strongify(self);
        __block BOOL buttonEnable = YES;
        __block UIColor *btnBGColor = CDZColorOfDefaultColor;
        __block BOOL wasSHandAutos = NO;
        [formConfigList enumerateObjectsUsingBlock:^(id  _Nonnull mainObj, NSUInteger mainIdx, BOOL * _Nonnull mainStop) {
            NSArray *configList = mainObj[kContentList];
            [configList enumerateObjectsUsingBlock:^(id  _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = subObj[kValue];
                NSInteger type = [subObj[kMAIIFType] integerValue];
                NSString *title = subObj[kTitle];
                if (type==MAIIFTypeOfSwitch&&[title rangeOfString:@"是否过户车"].location!=NSNotFound){
                    wasSHandAutos = [value boolValue];
                }
                
                if (type==MAIIFTypeOfDate&&[title rangeOfString:@"过户日期"].location!=NSNotFound){
                    if (!wasSHandAutos) {
                        *stop = YES;
                        *mainStop = YES;
                        return;
                    }
                }
                
                if ([value isKindOfClass:NSNull.class]) {
                    buttonEnable = NO;
                    btnBGColor = CDZColorOfDeepGray;
                    *stop = YES;
                    *mainStop = YES;
                }
            }];
        }];
        if ((!self.ASView.autoData.brandID||[self.ASView.autoData.brandID isEqualToString:@""]||
             !self.ASView.autoData.dealershipID||[self.ASView.autoData.dealershipID isEqualToString:@""]||
             !self.ASView.autoData.seriesID||[self.ASView.autoData.seriesID isEqualToString:@""]||
             !self.ASView.autoData.modelID||[self.ASView.autoData.modelID isEqualToString:@""])&&!self.isFirstTime) {
            buttonEnable = NO;
            btnBGColor = CDZColorOfDeepGray;
            
        }
        self.submitBtn.enabled = buttonEnable;
        self.submitBtn.backgroundColor = btnBGColor;
        
    }];
}

- (void)updateScrollViewOffset:(NSNotification *)notiObject {
    
    if (notiObject.userInfo&&notiObject.userInfo.count) {
        CGPoint contentOffset = [notiObject.userInfo[@"offset"] CGPointValue];
        BOOL scrollEnabled = [notiObject.userInfo[@"scrollEnabled"] boolValue];
        @weakify(self);
        self.tableView.scrollEnabled = scrollEnabled;
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            self.tableView.contentOffset = contentOffset;
        }];
    }
    
    
}


#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _formConfigList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDictionary *detail = _formConfigList[section];
    if (section==(_formConfigList.count-1)) {
        NSLog(@"passing sction 2");
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSInteger type = [evaluatedObject[kMAIIFType] integerValue];
            NSString *title = evaluatedObject[kTitle];
            BOOL isOn = NO;
            if (type==MAIIFTypeOfSwitch&&[title rangeOfString:@"是否过户车"].location!=NSNotFound) {
                if (evaluatedObject[kValue]&&[evaluatedObject[kValue] isKindOfClass:NSNumber.class]) {
                    isOn = [evaluatedObject[kValue] boolValue];
                }
            }
            return isOn;
        }];
        NSArray *contentList = (NSArray *)detail[kContentList];
        NSArray *result = [contentList filteredArrayUsingPredicate:predicate];
        if (!result||result.count==0) {
            return [detail[kContentList] count]-1;
        }
    }
    return [detail[kContentList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InsuranceInfoFormCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[InsuranceInfoFormCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        cell.textLabel.text = @"";
        //        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        //        cell.detailTextLabel.text = @"";
        //        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        //        cell.textLabel.numberOfLines = 0;
        //        cell.detailTextLabel.numberOfLines = 0;
        //        cell.detailTextLabel.textColor = CDZColorOfDefaultColor;
    }
    NSDictionary *data = _formConfigList[indexPath.section];
    NSDictionary *configDetail = [data[kContentList] objectAtIndex:indexPath.row];
    if (!cell.scrollView) {
        cell.scrollView = tableView;
    }
    if (!cell.actionTarget) {
        cell.actionTarget = self;
    }
    cell.indexPath = indexPath;
    if (!cell.resultBlock) {
        @weakify(self);
        cell.resultBlock = ^(MAIIFType theType, id result, NSIndexPath *indexPath) {
            @strongify(self);
            [self resultResponeHandlerWithType:theType result:result indexPath:indexPath];
        };
    }
    [cell updateUIDataWithDate:configDetail];
    //    NSDictionary *data = nil;
    //    NSString *title = data[kTitle];
    //    if ([title isEqualToString:@"space"]) {
    //        cell.accessoryType = UITableViewCellAccessoryNone;
    //        cell.contentView.backgroundColor = tableView.backgroundColor;
    //    }else {
    //        cell.textLabel.text = getLocalizationString(title);
    //        cell.detailTextLabel.text = data[kValue];
    //        cell.accessoryType = (vGetUserType==CDZUserTypeOfGPSWithODBUser||vGetUserType==CDZUserTypeOfGPSUser)?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
    //        cell.contentView.backgroundColor = CDZColorOfWhite;
    //    }
    
    // Configure the cell...
    
    return cell;
}

- (void)resultResponeHandlerWithType:(MAIIFType)type result:(id)result indexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", result);
    
    @autoreleasepool {
        
        switch (type) {
            case MAIIFTypeOfTextField:
            case MAIIFTypeOfDate:
                if (![result isKindOfClass:NSString.class]||!result||[result isEqualToString:@""]) {
                    result = nil;
                    result = NSNull.null;
                }
                break;
                
            case MAIIFTypeOfSegmentedControl:
            case MAIIFTypeOfSwitch:
                if (![result isKindOfClass:NSNumber.class]) {
                    result = @(0);
                }
                break;
                
            default:
                break;
        }
        NSMutableArray *formConfigList = [self mutableArrayValueForKey:@"formConfigList"];
        NSMutableDictionary *mainDetail = [formConfigList[indexPath.section] mutableCopy];
        NSMutableArray *configList = [mainDetail[kContentList] mutableCopy];
        NSMutableDictionary *configDetail= [configList[indexPath.row] mutableCopy];
        [configDetail setObject:result forKey:kValue];
        [configList replaceObjectAtIndex:indexPath.row withObject:configDetail];
        [mainDetail setObject:configList forKey:kContentList];
        [formConfigList replaceObjectAtIndex:indexPath.section withObject:mainDetail];
        if (type==MAIIFTypeOfSwitch) {
            [self.tableView reloadData];
            if ([result boolValue]) {
                CGPoint point = CGPointZero;
                point.y = self.tableView.contentSize.height-CGRectGetHeight(self.tableView.frame);
                [self.tableView setContentOffset:point animated:YES];
            }
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = _formConfigList[indexPath.section];
    NSDictionary *configDetail = [data[kContentList] objectAtIndex:indexPath.row];
    MAIIFType type = [configDetail[kMAIIFType] integerValue];
    if (type==MAIIFTypeOfSpace) {
        return [configDetail[@"height"] floatValue];
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *detail = _formConfigList[section];
    NSString *title = detail[kTitle];
    if (!title||[detail[kTitle] isEqualToString:@""]) {
        return 0;
    }
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewCell *myHeader = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerIdentifier];
        myHeader.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 19.0f, NO);
        myHeader.textLabel.textColor = CDZColorOfOrangeColor;
    }
    myHeader.backgroundColor = tableView.backgroundColor;
    NSDictionary *detail = _formConfigList[section];
    NSString *title = detail[kTitle];
    myHeader.textLabel.text = @"";
    if (title&&![detail[kTitle] isEqualToString:@""]) {
        myHeader.textLabel.text = title;
    }
    return myHeader;
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"indexPath:::%@",indexPath);
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (MAIIFAPIsDTOject *)getDTOData {
    
    __block MAIIFAPIsDTOject *dto = [MAIIFAPIsDTOject new];
    
    
    dto.brandID = _userAutoInfo.brandID;
    dto.brandName = _userAutoInfo.brandName;
    dto.brandDealershipID = _userAutoInfo.dealershipID;
    dto.brandDealershipName = _userAutoInfo.dealershipName;
    dto.seriesID = _userAutoInfo.seriesID;
    dto.seriesIDName = _userAutoInfo.seriesName;
    dto.modelID = _userAutoInfo.modelID;
    dto.modelName = _userAutoInfo.modelName;
    if (!_isFirstTime) {
        dto.brandID = _ASView.autoData.brandID;
        dto.brandName = _ASView.autoData.brandName;
        dto.brandDealershipID = _ASView.autoData.dealershipID;
        dto.brandDealershipName = _ASView.autoData.dealershipName;
        dto.seriesID = _ASView.autoData.seriesID;
        dto.seriesIDName = _ASView.autoData.seriesName;
        dto.modelID = _ASView.autoData.modelID;
        dto.modelName = _ASView.autoData.modelName;
    }
    
    [_formConfigList enumerateObjectsUsingBlock:^(id  _Nonnull mainObj, NSUInteger mainIdx, BOOL * _Nonnull mainStop) {
        NSArray* subConfigList = mainObj[kContentList];
        [subConfigList enumerateObjectsUsingBlock:^(id  _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *title = detail[kTitle];
            id value = detail[kValue];
            
            if ([title isEqualToString:@"车主姓名："]) {
                dto.userName = [SupportingClass verifyAndConvertDataToString:value];
            }
            if ([title isEqualToString:@"联系电话："]) {
                dto.phoneNumber = [SupportingClass verifyAndConvertDataToString:value];
            }
            
            
            
            if ([title isEqualToString:@"投保城市："]) {
                dto.cityID = [SupportingClass verifyAndConvertDataToString:[(KeyCityDTO *)value cityName]];
            }
            if ([title isEqualToString:@"车架号："]) {
                dto.autosFrameNum = [SupportingClass verifyAndConvertDataToString:value];
            }
            if ([title isEqualToString:@"车牌号："]) {
                dto.autosNumber = [SupportingClass verifyAndConvertDataToString:value];
            }
            if ([title isEqualToString:@"发动机号："]) {
                dto.autosEngineNum = [SupportingClass verifyAndConvertDataToString:value];
            }
            if ([title isEqualToString:@"车辆价格："]) {
                dto.autosPrice = [SupportingClass verifyAndConvertDataToString:value];
            }
            if ([title isEqualToString:@"注册登记日期："]) {
                dto.autosRegisterDate = [SupportingClass verifyAndConvertDataToString:value];
            }
            
            if ([title isEqualToString:@"出险次数："]) {
                dto.acTypeStr = [SupportingClass verifyAndConvertDataToString:value];
            }
            
            if ([title isEqualToString:@"使用性质："]) {
                NSString *string = [detail[kTitleList] objectAtIndex:[detail[kValue] integerValue]];
                dto.autosUsageType = string;
            }
            if ([title isEqualToString:@"座位数量："]) {
                dto.autosNumOfSeats = [SupportingClass verifyAndConvertDataToNumber:value];
            }
            if ([title isEqualToString:@"是否过户车："]) {
                dto.autosWasSHand = [SupportingClass verifyAndConvertDataToNumber:value];
            }
            if ([title isEqualToString:@"过户日期："]) {
                dto.autosAssignmentDate = [SupportingClass verifyAndConvertDataToString:value];
            }
            
        }];
    }];
    
    return dto;
    
}

- (void)submitAutoInsuranceInfo {
    if (!self.accessToken) {
        return;
    }
    @autoreleasepool {
        
        MAIIFAPIsDTOject *dtobject = [self getDTOData];
        [ProgressHUDHandler showHUD];
        @weakify(self);
        [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsuranceInfoWithAccessToken:self.accessToken brandID:dtobject.brandID brandName:dtobject.brandName brandDealershipID:dtobject.brandDealershipID brandDealershipName:dtobject.brandDealershipName seriesID:dtobject.seriesID seriesName:dtobject.seriesIDName modelID:dtobject.modelID modelName:[dtobject.brandName stringByAppendingFormat:@" %@", dtobject.modelName] userName:dtobject.userName phoneNumber:dtobject.phoneNumber cityID:dtobject.cityID autosNumber:dtobject.autosNumber autosFrameNum:dtobject.autosFrameNum autosEngineNum:dtobject.autosEngineNum autosPrice:dtobject.autosPrice acTypeStr:dtobject.acTypeStr autosRegisterDate:dtobject.autosRegisterDate autosUsageType:dtobject.autosUsageType autosNumOfSeats:dtobject.autosNumOfSeats autosWasSHand:dtobject.autosWasSHand autosAssignmentDate:dtobject.autosAssignmentDate success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                return;
            }
            if(errorCode!=0){
                if ([message isContainsString:@"不能重复添加"]) {
                    message = @"车辆不能重复添加";
                }
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
                }];
                return;
            }
            @strongify(self);
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
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
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
@end

