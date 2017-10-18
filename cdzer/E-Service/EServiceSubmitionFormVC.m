//
//  EServiceSubmitionFormVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/6/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceSubmitionFormVC.h"
#import "EServiceSubmitionFormCell.h"
#import "ShopServiceSearchListSelectionVC.h"
#import "UserAutosInfoDTO.h"
#import "EServicePaymentVC.h"
#import "EServiceSelectLocationVC.h"
#import "EServiceAutoCancelApointmentObject.h"
#import "WKWebViewController.h"
#import "MyCarVC.h"
#import "EServiceServiceListVC.h"
#import "EServicePriceDetailVC.h"


@interface EServiceSubmitionFormVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIView *buttomInfoView;

@property (nonatomic, weak) IBOutlet UIButton *submitButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *tncPartLabel;

@property (nonatomic, weak) IBOutlet UIButton *tncButton;



@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *hitsLabelHeightConstraint;

@property (nonatomic, weak) IBOutlet UIView *headerContentView;

@property (nonatomic, weak) IBOutlet UIView *logoImageContainer;

@property (nonatomic, weak) IBOutlet UIImageView *logoImage;

@property (nonatomic, weak) IBOutlet UILabel *selectedAutosLabel;

@property (nonatomic, weak) IBOutlet UIButton *pushToSelectAutosBtn;

@property (nonatomic, weak) IBOutlet UILabel *totalPrice;


@property (nonatomic, strong) UIImage *autoDefaultImage;


@property (nonatomic, assign) CGPoint tvOriginalOffset;

@property (nonatomic, strong) NSMutableArray *formConfigList;

@property (nonatomic, strong) NSString *shopID;

@property (nonatomic, strong) NSString *shopName;

@property (nonatomic, strong) NSString *userPhone;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *timeOfAppiontment;

@property (nonatomic, strong) NSString *repairType;

@property (nonatomic, strong) NSString *serviceItems;

@property (nonatomic, strong) UserAutosInfoDTO *userAutosInfo;

@property (nonatomic, assign) BOOL tncSelectionStatus;

@property (nonatomic, weak) IBOutlet UIButton *checkmarkBtn;

@property (nonatomic, strong) NSString *priceOne;

@property (nonatomic, strong) NSString *priceTwo;

@property (nonatomic, strong) NSString *finalPrice;


@end

@implementation EServiceSubmitionFormVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.userAutosInfo = [DBHandler.shareInstance getUserAutosDetail];
    [self updateHeaderStatus];
    [self updateHeaderViewFrame];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateHeaderStatus];
    [self updateHeaderViewFrame];
    [self.tableView.tableFooterView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:[UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.00] withBroderOffset:nil];
}

- (void)updateHeaderStatus {
    BOOL userAutosInfoExist = (self.userAutosInfo.brandID.integerValue>0&&self.userAutosInfo.dealershipID.integerValue>0
                               &&self.userAutosInfo.seriesID.integerValue>0&&self.userAutosInfo.modelID.integerValue>0);
    self.headerContentView.hidden = !userAutosInfoExist;
    self.pushToSelectAutosBtn.hidden = userAutosInfoExist;
    self.selectedAutosLabel.text = @"";
    self.logoImage.image = self.autoDefaultImage;
    if (userAutosInfoExist) {
        self.selectedAutosLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",self.userAutosInfo.brandName, self.userAutosInfo.dealershipName, self.userAutosInfo.seriesName, self.userAutosInfo.modelName];
        
        if ([self.userAutosInfo.brandImgURL isContainsString:@"http"]) {
            [self.logoImage setImageWithURL:[NSURL URLWithString:self.userAutosInfo.brandImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (IBAction)tncSelectionType {
    self.tncSelectionStatus = !self.tncSelectionStatus;
    self.checkmarkBtn.selected = self.tncSelectionStatus;
}

- (void)componentSetting {
    @autoreleasepool {
        self.priceOne = [SupportingClass verifyAndConvertDataToString:self.priceDetail[@"price"]];
        self.priceTwo = [SupportingClass verifyAndConvertDataToString:self.priceDetail[@"price_two"]];
        
        
        
        self.tncSelectionStatus = YES;
        self.userAutosInfo = [DBHandler.shareInstance getUserAutosDetail];
        if (self.serviceType==EServiceTypeOfEInspect) {
            [self setRightNavButtonWithTitleOrImage:@"价格表" style:UIBarButtonItemStylePlain target:self action:@selector(pushToPriceTable) titleColor:nil isNeedToSet:YES];
        }else {
            self.totalPrice.text = [NSString stringWithFormat:@"%0.2f", self.priceOne.floatValue];
            self.finalPrice = self.totalPrice.text;
        }
    
        UINib *nib4Self = [UINib nibWithNibName:@"EServiceFormVCComponent" bundle:nil];
        [nib4Self instantiateWithOwner:self options:nil];

        
        self.shopID = @"";
        self.shopName = @"";
        self.userPhone = @"";
        self.userName = @"";
        self.timeOfAppiontment = @"";
        self.repairType = @"";
        self.serviceItems = @"";
        
        
        self.formConfigList = [NSMutableArray arrayWithObjects:@[@{kTitle:@"姓名：", kType:@(EServiceFormActionOfTextField),
                                                                   kValue:@"userName", kPlaceHolder:@"请输入姓名",
                                                                   vKeyboardType:@(UIKeyboardTypeDefault), kMaxStringLength:@12},
                                                                 @{kTitle:@"电话：", kType:@(EServiceFormActionOfTextField),
                                                                   kValue:@"userPhone", kPlaceHolder:@"请输入联系电话", vKeyboardType:@(UIKeyboardTypeNumberPad), kMaxStringLength:@11},], @[@{}], nil];
        switch (self.serviceType) {
            case EServiceTypeOfERepair:{
                self.title = [NSString stringWithFormat:@"E代修－%@",self.wasAppointment?@"预约":@"快速下单"];
                [self.submitButton setTitle:self.wasAppointment?@"预约":@"快速下单" forState:UIControlStateNormal];
                
                
                if (self.wasSelectedConsultant) {
                    [self.formConfigList addObject:@[@{kTitle:@"专员姓名：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantName", kPlaceHolder:@"--"},
                                                     @{kTitle:@"专员电话：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantPhone", kPlaceHolder:@"--"},]];
                    [self.formConfigList addObject:@[@{}]];
                }
                
                NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:@{kTitle:@"接车地点：", kType:@(EServiceFormActionOfSelector),
                                                                             kValue:@"userLocatedAddress", kPlaceHolder:@"请选择地址",
                                                                             kSeletor:NSStringFromSelector(@selector(pushToSelectLocation))}];
                
                if (self.wasAppointment) {
                    [tmpArray addObject:@{kTitle:@"预约时间：", kType:@(EServiceFormActionOfDateTime),
                                          kValue:@"timeOfAppiontment", kPlaceHolder:@"请选择日期"}];
                }
                
                NSMutableArray *repairItemsList = [NSMutableArray array];
                NSArray <NSString *> *tmpList = [DBHandler.shareInstance.getRepairShopServiceTypeList valueForKey:@"name"];
                if (tmpList.count==0) {
                    [repairItemsList addObjectsFromArray:@[@"发动机", @"底盘", @"车身及附件", @"电子、电器", @"保养配件"]];
                }else {
                    [repairItemsList addObjectsFromArray:tmpList];
//                    [tmpList enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
//                        if (![string isContainsString:@"玻璃"]&&
//                            ![string isContainsString:@"电瓶"]&&
//                            ![string isContainsString:@"轮胎"]) {
//                            [repairItemsList addObject:string];
//                        }
//                    }];
                }
                
//                [self.formConfigList addObject:@[@{kTitle:@"代修项目：", kType:@(EServiceFormActionOfPickerSelection),
//                                                   kValue:@"serviceItems", kPlaceHolder:@"请选择代修项目",
//                                                   kSelectionList:repairItemsList,},]];
                [tmpArray addObject:@{kTitle:@"代修项目：", kType:@(EServiceFormActionOfPickerSelection),
                                      kValue:@"serviceItems", kPlaceHolder:@"请选择代修项目",
                                      kSelectionList:repairItemsList,}];
                [tmpArray addObject:@{kTitle:@"维修商：", kType:@(EServiceFormActionOfSelector),
                                      kValue:@"shopName", kPlaceHolder:@"请选择维修商",
                                      kSeletor:NSStringFromSelector(@selector(pushToRepairShopSelection))}];
//                [self.formConfigList addObject:tmpArray];
//                [self.formConfigList addObject:@[@{}]];
                [self.formConfigList addObject:tmpArray];
                
                break;
            }
            case EServiceTypeOfEInspect:{
                self.title = [NSString stringWithFormat:@"E代检－%@",self.wasAppointment?@"预约":@"快速下单"];
                [self.submitButton setTitle:self.wasAppointment?@"预约":@"快速下单" forState:UIControlStateNormal];
                
                
                
                if (self.wasSelectedConsultant) {
                    [self.formConfigList addObject:@[@{kTitle:@"专员姓名：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantName", kPlaceHolder:@"--"},
                                                     @{kTitle:@"专员电话：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantPhone", kPlaceHolder:@"--"},]];
                    [self.formConfigList addObject:@[@{}]];
                }
                
                
                NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:@{kTitle:@"接车地点：", kType:@(EServiceFormActionOfSelector),
                                                                             kValue:@"userLocatedAddress", kPlaceHolder:@"请选择地址",
                                                                             kSeletor:NSStringFromSelector(@selector(pushToSelectLocation))}];
                if (self.wasAppointment) {
                    [tmpArray addObject:@{kTitle:@"预约时间：", kType:@(EServiceFormActionOfDateTime),
                                          kValue:@"timeOfAppiontment", kPlaceHolder:@"请选择日期"}];
                }
                [self.formConfigList addObject:tmpArray];
                [self.formConfigList addObject:@[@{}]];
                [self.formConfigList addObject:@[@{kTitle:@"代检项目：", kType:@(EServiceFormActionOfPickerSelection),
                                                   kValue:@"serviceItems", kPlaceHolder:@"请选择代检项目",
                                                   kSelectionList:@[@"领取环保标识", @"车辆上线检测", ],}]];
            }
                break;
            case EServiceTypeOfEInsurance:{
                self.title = @"E代赔－快速下单";
                [self.submitButton setTitle:@"快速下单" forState:UIControlStateNormal];
                
                if (self.wasSelectedConsultant) {
                    [self.formConfigList addObject:@[@{kTitle:@"专员姓名：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantName", kPlaceHolder:@"--"},
                                                     @{kTitle:@"专员电话：", kType:@(EServiceFormActionOfDisplayOnly),
                                                       kValue:@"consultantPhone", kPlaceHolder:@"--"},]];
                    [self.formConfigList addObject:@[@{}]];
                }
                
                [self.formConfigList addObject:@[@{kTitle:@"接车地点：", kType:@(EServiceFormActionOfSelector),
                                                   kValue:@"userLocatedAddress", kPlaceHolder:@"请选择地址",
                                                   kSeletor:NSStringFromSelector(@selector(pushToSelectLocation))},
                                                 @{kTitle:@"事故种类：", kType:@(EServiceFormActionOfPickerSelection),
                                                   kValue:@"serviceItems", kPlaceHolder:@"请选择事故种类",
                                                   kSelectionList:@[@"单人事故", @"多方事故", @"带伤事故"],},]];
            }
                break;
                
            default:
                break;
        }
        
        
        NSString *btnTitle = @"《车队长E服务协议》";
        NSString *partTitle = self.wasAppointment?@"预约":@"快速下单";
        switch (self.serviceType) {
            case EServiceTypeOfERepair:
                btnTitle = @"《车队长E代修服务协议》";
                break;
            case EServiceTypeOfEInspect:
                btnTitle = @"《车队长E代检服务协议》";
                break;
            case EServiceTypeOfEInsurance:
                btnTitle = @"《车队长E代赔服务协议》";
                break;
            default:
                break;
        }
        self.tncPartLabel.text = partTitle;
        [self.tncButton setTitle:btnTitle forState:UIControlStateNormal];
        
        [self.buttomInfoView setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:1.0f];
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0f;
        UINib *nib = [UINib nibWithNibName:@"EServiceSubmitionFormCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        [self updateHeaderViewFrame];
    }
    
}

- (void)setReactiveRules {
    //    @weakify(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateHeaderViewFrame {
    BOOL userAutosInfoExist = (self.userAutosInfo.brandID.integerValue>0&&self.userAutosInfo.dealershipID.integerValue>0
                               &&self.userAutosInfo.seriesID.integerValue>0&&self.userAutosInfo.modelID.integerValue>0);
    self.hitsLabelHeightConstraint.constant = userAutosInfoExist?0:27.0f;
    CGRect frame = self.tableHeaderView.frame;
    frame.size.width = SCREEN_WIDTH;
    self.tableHeaderView.frame = frame;
    frame.size.height = roundf(CGRectGetHeight(self.headerContentView.frame)+self.hitsLabelHeightConstraint.constant);
    self.tableHeaderView.frame = frame;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = self.tableHeaderView;
    [self.logoImageContainer setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImageContainer.frame)/2.0f];
    [self.logoImage setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImage.frame)/2.0f];
    self.autoDefaultImage = self.logoImage.image;
}

- (IBAction)pushToMyAutosInfoVC {
    @autoreleasepool {
        MyCarVC *vc = [MyCarVC new];
        vc.wasBackRootView = NO;
        vc.wasSubmitAfterLeave = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToSelectLocation {
    @autoreleasepool {
        EServiceSelectLocationVC *vc = [EServiceSelectLocationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self);
        vc.responsBlock = ^(BMKPoiInfo *addressPoiInfo) {
            @strongify(self);
            self.userLocatedAddressCoordinate = addressPoiInfo.pt;
            self.userLocatedAddress = addressPoiInfo.address;
            [self.tableView reloadData];
        };
    }
}

- (void)pushToRepairShopSelection {
    @autoreleasepool {
        NSLog(@"pushToRepairShopSelection");
        ShopServiceSearchListSelectionVC *vc = ShopServiceSearchListSelectionVC.new;
        vc.repairItem = self.serviceItems;
        @weakify(self);
        vc.resultBlock = ^void(NSString *shopID, NSString *shopName){
            @strongify(self);
            if (shopID) {
                self.shopID = shopID;
            }
            if (shopName) {
                self.shopName = shopName;
            }
            [self.tableView reloadData];
        };
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.formConfigList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.formConfigList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellWithIdentifier = @"cell";
    EServiceSubmitionFormCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    if (!cell.responseBlock) {
        @weakify(self);
        cell.responseBlock = ^(NSIndexPath *indexPath, NSString *value) {
            @strongify(self);
            NSDictionary *theDetailConfig = [self.formConfigList[indexPath.section] objectAtIndex:indexPath.row];
            EServiceFormAction actionType = [theDetailConfig[kType] unsignedIntegerValue];
            if (actionType==EServiceFormActionOfSelector) {
                NSString *seletorKey = theDetailConfig[kSeletor];
                if (self.serviceType==EServiceTypeOfERepair&&
                    [seletorKey isEqualToString:@"pushToRepairShopSelection"]&&
                    (!self.serviceItems||[self.serviceItems isEqualToString:@""])) {
                    [SupportingClass showToast:@"请先选择代修项目"];
                    return;
                }
                SEL selector = NSSelectorFromString(seletorKey);
                if ([self respondsToSelector:selector]) {
                    SuppressPerformSelectorLeakWarning([self performSelector:selector];)
                }
                return;
            }
            NSString *valueKey = theDetailConfig[kValue];
            [self setValue:value forKeyPath:valueKey];
            if (self.serviceType==EServiceTypeOfEInspect&&[valueKey isEqualToString:@"serviceItems"]) {
                if ([value isContainsString:@"环保标识"]) {
                    self.totalPrice.text = [NSString stringWithFormat:@"%0.2f", self.priceOne.floatValue];
                    self.finalPrice = self.totalPrice.text;
                }
                if ([value isContainsString:@"上线检测"]) {
                    self.totalPrice.text = [NSString stringWithFormat:@"%0.2f", self.priceTwo.floatValue];
                    self.finalPrice = self.totalPrice.text;
                }
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
    }
    
    UIEdgeInsets separatorInset = cell.separatorInset;
    separatorInset.left = 15.0f;
    
    
    UIEdgeInsets layoutMargins = cell.layoutMargins;
    layoutMargins.left = 8;
    
    NSDictionary *detailConfig = [self.formConfigList[indexPath.section] objectAtIndex:indexPath.row];
    if (detailConfig.count==0) {
        cell.showDisplayView = NO;
    }else {
        cell.showDisplayView = YES;
        NSString *valueString = [self valueForKey:detailConfig[kValue]];
        [cell configViewDisplay:detailConfig withValue:valueString];
    }
    
    NSUInteger sectionCount = [self.formConfigList[indexPath.section] count];
    if (indexPath.row==(sectionCount-1)||
        (indexPath.row==0&&sectionCount==1)) {
        separatorInset.left = 0;
        layoutMargins.left = 0;
    }
    cell.layoutMargins = layoutMargins;
    cell.separatorInset = separatorInset;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)pushToPriceTable {
    @autoreleasepool {
        
        EServicePriceDetailVC*vc = EServicePriceDetailVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
//        NSString *priceTableURL = @"http://www.cdzer.com/e1.html";
//        NSString *perfixString = @"E代修";
//        switch (self.serviceType) {
//            case EServiceTypeOfEInspect:
//                priceTableURL = @"http://www.cdzer.com/e2.html";
//                perfixString = @"E代检";
//                break;
//            case EServiceTypeOfEInsurance:
//                priceTableURL = @"http://www.cdzer.com/e3.html";
//                perfixString = @"E代赔";
//                break;
//            default:
//                priceTableURL = @"http://www.cdzer.com/e1.html";
//                break;
//        }
//        WebViewVC *vc = WebViewVC.new;
//        vc.title = [perfixString stringByAppendingString:@"价格表"];
//        vc.URL = [NSURL URLWithString:priceTableURL];
//        [self setDefaultNavBackButtonWithoutTitle];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToTNC {
    @autoreleasepool {
        NSString *title = @"《车队长E服务协议》";
        NSString *urlPrefixString = @"";
        switch (self.serviceType) {
            case EServiceTypeOfERepair:
                title = @"《车队长E代修服务协议》";
                urlPrefixString = [kTNCURLPrefix stringByAppendingString:@"eRepair.html"];
                break;
            case EServiceTypeOfEInspect:
                title = @"《车队长E代检服务协议》";
                urlPrefixString = [kTNCURLPrefix stringByAppendingString:@"eCheck.html"];
                break;
            case EServiceTypeOfEInsurance:
                title = @"《车队长E代赔服务协议》";
                urlPrefixString = [kTNCURLPrefix stringByAppendingString:@"eCompensate.html"];
                break;
            default:
                break;
        }
        if ([urlPrefixString isEqualToString:@""]) {
            return;
        }
        
        
        WKWebViewController *webVC = [[WKWebViewController alloc] initWithURL:[NSURL URLWithString:urlPrefixString]];
        webVC.title = title;
        webVC.showPageTitleAndURL = NO;
        webVC.hideBarsWithGestures = NO;
        webVC.supportedWebNavigationTools = WKWebNavigationToolNone;
        webVC.supportedWebActions = WKWebActionNone;
        webVC.webViewContentScale = 500;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:webVC animated:YES];
        
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

- (IBAction)submitNow {
    if (self.checkValueWasMissing) return;
    
    if (!self.tncSelectionStatus) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"你必须同意车队长E服务协议才能使用服务" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
        return;
    }
        
    [self submitAppointmentOrderWasAutoType:!self.wasSelectedConsultant];
}

- (void)pushToEServiceList {
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceListVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        EServiceServiceListVC *vc = EServiceServiceListVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)checkValueWasMissing {
    BOOL isMissing = NO;
    NSString *message = @"";
    
    if ([self.userName isEqualToString:@""]){
        isMissing = YES;
        message = [message stringByAppendingString:@"请输入姓名\n"];
    }
    
    if ([self.userPhone isEqualToString:@""]){
        isMissing = YES;
        message = [message stringByAppendingString:@"请输入电话\n"];
    }
    if (self.userPhone.length!=11){
        isMissing = YES;
        message = [message stringByAppendingString:@"请输入正确电话\n"];
    }
    
    if ([self.userLocatedAddress isEqualToString:@""]){
        isMissing = YES;
        message = [message stringByAppendingString:@"请输入或定位始发点\n"];
    }
    
    
    switch (self.serviceType) {
        case EServiceTypeOfERepair:
            
            if ([self.timeOfAppiontment isEqualToString:@""]&&self.wasAppointment){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择预约时间\n"];
            }else {
                self.timeOfAppiontment = @"暂无";
            }
            
            if ([self.shopID isEqualToString:@""]||[self.shopName isEqualToString:@""]){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择维修商\n"];
            }
            
            self.repairType = @"暂无";
//            if ([self.repairType isEqualToString:@""]){
//                isMissing = YES;
//                message = [message stringByAppendingString:@"请选择维修类型\n"];
//            }
            
            if ([self.serviceItems isEqualToString:@""]){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择代修项目\n"];
            }
            
            break;
        case EServiceTypeOfEInspect:
            self.shopID = @"暂无";
            self.shopName = @"暂无";
            self.repairType = @"暂无";
            
            if ([self.timeOfAppiontment isEqualToString:@""]&&self.wasAppointment){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择预约时间\n"];
            }else {
                self.timeOfAppiontment = @"暂无";
            }
            
            if ([self.serviceItems isEqualToString:@""]){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择代检项目\n"];
            }
            
            break;
        case EServiceTypeOfEInsurance:
            self.shopID = @"暂无";
            self.shopName = @"暂无";
            self.repairType = @"暂无";
            self.timeOfAppiontment = @"暂无";
            
            if ([self.serviceItems isEqualToString:@""]){
                isMissing = YES;
                message = [message stringByAppendingString:@"请选择事故种类\n"];
            }
            
            break;
        default:
            break;
    }
    
    if (isMissing) {
        message = [message stringByReplacingCharactersInRange:NSMakeRange(message.length-1, 1) withString:@""];
        [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
    
    
    return isMissing;
}

- (void)submitAppointmentOrderWasAutoType:(BOOL)orderWasAutoType {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *model = @"暂无";
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceMakeAppointmentWithAccessToken:self.accessToken repairShopID:self.shopID repairShopName:self.shopName registrant:self.userName registrantPhone:self.userPhone address:self.userLocatedAddress autosModelName:model servieceItems:self.serviceItems projectType:self.repairType appointmentTime:self.timeOfAppiontment longitude:@(self.userLocatedAddressCoordinate.longitude).stringValue latitude:@(self.userLocatedAddressCoordinate.latitude).stringValue requestedConsultantID:self.consultantID eServiceType:_serviceType eRepairFree:self.finalPrice orderWasAutoType:orderWasAutoType success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0){
            if ([message isContainsString:@"没有专员"]) {
                message = @"很抱歉，您所在的位置，20KM以内，找不到相关专员为您服务，敬请谅解！";
            }
            
            if ([message isContainsString:@"重复状态"]) {
                [ProgressHUDHandler dismissHUD];
                message = @"你已预约过E代修服务，请完成服务后再次下单或预约！";
                switch (self.serviceType) {
                    case EServiceTypeOfERepair:
                        message = @"你已预约过E代修服务，请完成服务后再次下单或预约！";
                        break;
                    case EServiceTypeOfEInspect:
                        message = @"你已预约过E代检服务，请完成服务后再次下单或预约！";
                        break;
                    case EServiceTypeOfEInsurance:
                        message = @"你已预约过E代赔服务，请完成服务后再次下单或预约！";
                        break;
                    default:
                        break;
                }
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [self pushToEServiceList];
                }];
                return;
            }
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        if (UserBehaviorHandler.shareInstance.getUserMemberType>=UserMemberTypeOfPlatinum) {
            [ProgressHUDHandler dismissHUD];
            [self pushToEServiceList];
            return;
        }
        
        NSString *eServiceID = responseObject[@"e_server_id"];
        if(eServiceID) {
            EServiceCancelRecordDTO *dto = [EServiceCancelRecordDTO createDataToObjectWithEServiceType:self.serviceType dbUID:nil eServiceID:eServiceID userID:vGetUserID createdDateTime:[[NSDate date] timeIntervalSince1970]];
            if (dto) {
                [EServiceAutoCancelApointmentObject addServiceCancelRecordWithDto:dto];
            }
        }
        
        NSString *consultantID = responseObject[@"comm_user_id"];
        NSString *servicePrice = [SupportingClass verifyAndConvertDataToString:responseObject[@"sign"]];
        NSString *credits = [SupportingClass verifyAndConvertDataToString:responseObject[@"credits"]];
        NSString *creditsRatio = [SupportingClass verifyAndConvertDataToString:responseObject[@"proportion"]];
        if (!creditsRatio||[creditsRatio isEqualToString:@""]) creditsRatio = @"0.01";
        EServicePaymentVC *vc = [EServicePaymentVC new];
        vc.serviceType = self.serviceType;
        vc.eServiceID = eServiceID;
        vc.creditsRatio = creditsRatio;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
        
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

@end
