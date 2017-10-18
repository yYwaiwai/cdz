//
//  MyCarVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kNotSetIt getLocalizationString(@"not_define")

#import "MyCarVC.h"
#import "MyAutosInfoInputView.h"
#import "IQDropDownTextField.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MainViewTopViewComponent.h"
#import "MaintenanceRecordVC.h"
#import "IllegalQueryMainVC.h"
#import "MyCarInsuranceVC.h"

@interface MyCarVC () <IQDropDownTextFieldDelegate>

@property (weak, nonatomic) IBOutlet MainViewTopViewComponent *topViewComponent;

@property (weak, nonatomic) IBOutlet UIView *queryView;

@property (weak, nonatomic) IBOutlet UIView *insuranceView;

@property (weak, nonatomic) IBOutlet UIControl *maintainControl;//保养记录

@property (weak, nonatomic) IBOutlet UIControl *peccancyControl;//违章记录

@property (weak, nonatomic) IBOutlet UIControl *insuranceControl;//保险记录

@property (weak, nonatomic) IBOutlet UIControl *carNumberControl;//车牌号码

@property (weak, nonatomic) IBOutlet UIControl *engineNumberControl;//发动机号

@property (weak, nonatomic) IBOutlet UIControl *VINControl;//车架号

@property (weak, nonatomic) IBOutlet UIControl *carColorControl;//车辆颜色

@property (weak, nonatomic) IBOutlet UIControl *nextInsuranceControl;//距下次保险

@property (weak, nonatomic) IBOutlet UIControl *nextAnnualInspectionControl;//距下次年检

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *engineNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *VINLabel;

@property (weak, nonatomic) IBOutlet UILabel *nextInsuranceLabel;

@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

@property (weak, nonatomic) IBOutlet UILabel *nextAnnualInspectionLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentMileageLabel;//当前里程

@property (weak, nonatomic) IBOutlet UILabel *registerDateLabel;//上牌时间

@property (nonatomic, strong) MyAutosInfoInputView *maiiv;

@property (nonatomic, strong) NSString *licensePlate;//车牌

@property (nonatomic, strong) NSString *autosEngineNumber;//发动机号

@property (nonatomic, strong) NSString *autosFrameNumber;//车架号

@property (nonatomic, strong) NSString *autosBodyColor;//车辆颜色

@property (nonatomic, strong) NSString *autosInsuranceDate;//距下次保险

@property (nonatomic, strong) NSString *autosAnniversaryCheckDate;//距下次年检

@property (nonatomic, strong) NSString *initialMileage;//当前里程

@property (nonatomic, strong) NSString *autosRegisterDate;//上牌时间

@property (weak, nonatomic) IBOutlet UILabel *vehicleTypeLabel;//车辆类型

@property (weak, nonatomic) IBOutlet UILabel *carDetailsLabel;//车系

@property (weak, nonatomic) IBOutlet UIImageView *carImage;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
/// 自动数据
@property (nonatomic, strong) NSMutableArray *autosData;

@property (nonatomic, strong) NSMutableDictionary *userAutosInfoData;

/// Store Was Frist Update;
@property (nonatomic, assign) BOOL fristUpdate;

@end

@implementation MyCarVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的车辆";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.navigationController.navigationBar.translucent = YES;
    [self componentSetting];
    [self initializationUI];
//    [self setReactiveRules];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = 20;
    self.navigationController.navigationBarHidden = YES;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    if (self.userAutosInfoData.count==0||!self.userAutosInfoData) {
        [self getMyAutoData];
    }
    
    if (self.showTrafficViolationReminder) {
        [SupportingClass showAlertViewWithTitle:nil message:@"查违章至少需要完善车牌号及发动机号" isShowImmediate:YES cancelButtonTitle:@"我知道了" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = 10;
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.queryView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.insuranceView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    
    BorderOffsetObject *offsets = [BorderOffsetObject new];
    offsets.leftUpperOffset = round(offsets.leftBottomOffset = CGRectGetHeight(self.engineNumberControl.frame)*0.2);
    offsets.rightUpperOffset=offsets.leftUpperOffset;
    [self.engineNumberControl setViewBorderWithRectBorder:UIRectBorderLeft  borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:offsets];
    [self.nextInsuranceControl setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:offsets];
    [self.VINControl setViewBorderWithRectBorder:UIRectBorderLeft  borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:offsets];
    [self.nextAnnualInspectionControl setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:offsets];
    self.maintainControl.layer.masksToBounds=YES;
    self.maintainControl.layer.cornerRadius=3.0;
    self.peccancyControl.layer.masksToBounds=YES;
    self.peccancyControl.layer.cornerRadius=3.0;
    self.insuranceControl.layer.masksToBounds=YES;
    self.insuranceControl.layer.cornerRadius=3.0;
    [self.maintainControl setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.peccancyControl setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.insuranceControl setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        self.autosData = [@[@{@"title":@"myautos_brand", @"value":kNotSetIt, @"valueKey":CDZAutosKeyOfBrandName,
                              @"valueID":NSNull.null, @"valueIDKey":@"brandId", @"valueIcon":@"", @"valueIconKey":@"brand_img",
                              @"inputType":@(MAIInputTypeOfAutosSelection), @"resultUpdateKey":MAIInputKeyFirstValue},
                            @{@"title":@"myautos_dealership", @"value":kNotSetIt, @"valueKey":@"factory_name",
                              @"valueID":NSNull.null, @"valueIDKey":@"factoryId",
                              @"inputType":@(MAIInputTypeOfAutosSelection), @"resultUpdateKey":MAIInputKeySecondValue},
                            @{@"title":@"myautos_series", @"value":kNotSetIt, @"valueKey":@"fct_name",
                              @"valueID":NSNull.null, @"valueIDKey":@"fctId",
                              @"inputType":@(MAIInputTypeOfAutosSelection), @"resultUpdateKey":MAIInputKeyThirdValue},
                            @{@"title":@"myautos_model", @"value":kNotSetIt, @"valueKey":@"spec_name",
                              @"valueID":NSNull.null, @"valueIDKey":@"specId",
                              @"inputType":@(MAIInputTypeOfAutosSelection), @"resultUpdateKey":MAIInputKeyFourthValue},
                            ] mutableCopy];

    }
    
    
    if (UserBehaviorHandler.shareInstance.getUserType>=6) {
        self.submitButton.hidden = YES;
    }
    
    UIImage *image = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"BackIndicatorDefault@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)backLastVC {
    [SupportingClass showAlertViewWithTitle:@"" message:@"您已修改车辆信息还没有保存，是否退出?" isShowImmediate:YES cancelButtonTitle:@"退出" otherButtonTitles:@"立即保存" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>=1) {
            [self updateAutosInfomation];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];

    
}

- (void)initializationUI {
    @autoreleasepool {
        self.VINLabel.numberOfLines = 0;
        self.engineNumberLabel.numberOfLines=0;
        self.carImage.layer.masksToBounds=YES;
        self.carImage.layer.cornerRadius=25;
        
        
        
        self.maiiv = [[MyAutosInfoInputView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_maiiv];
        self.maiiv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.maiiv.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        @weakify(self);
        [self.maiiv setMAICompletionBlock:^(MAIInputType type, NSDictionary *result) {
            if (type==MAIInputTypeOfNone) return;
            @strongify(self);
            switch (type) {
                case MAIInputTypeOfLicensePlate:
                    self.licensePlate = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"car_number"] = self.licensePlate;
                    break;
                    
                case MAIInputTypeOfAutosEngineNumber:
                    self.autosEngineNumber = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"engine_code"] = self.autosEngineNumber;
                    break;
                    
                case MAIInputTypeOfAutosFrameNumber:
                    self.autosFrameNumber = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"frame_no"] = self.autosFrameNumber;
                    break;
                    
                case MAIInputTypeOfAutosBodyColor:
                    self.autosBodyColor = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"color"] = self.autosBodyColor;
                    break;
                    
                    
                case MAIInputTypeOfAutosInsuranceDate:
                    self.autosInsuranceDate = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"insure_time"] = self.autosInsuranceDate;
                    break;
                    
                case MAIInputTypeOfAutosAnniversaryCheckDate:
                    self.autosAnniversaryCheckDate = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"annual_time"] = self.autosAnniversaryCheckDate;
                    break;
                    
                case MAIInputTypeOfInitialMileage:
                    self.initialMileage = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"mileage"] = self.initialMileage;
                    break;
                    
                    
                case MAIInputTypeOfAutosRegisterDate:
                    self.autosRegisterDate = result[MAIInputKeyFirstValue];
                    self.userAutosInfoData[@"registr_time"]  = self.autosRegisterDate;
                    break;
                    
                case MAIInputTypeOfAutosSelection:{
                    NSMutableArray *headerArray = [self mutableArrayValueForKey:@"autosData"];
                    [self.autosData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *data = [obj mutableCopy];
                        NSString *resultUpdateKey = obj[@"resultUpdateKey"];
                        
                        NSDictionary *resultData = result[resultUpdateKey];
                        NSString *title = resultData[@"title"];
                        NSString *theIDkey = resultData[@"keyID"];
                        [data setObject:title forKey:@"value"];
                        [data setObject:@(theIDkey.integerValue) forKey:@"valueID"];
                        if (resultData[@"icon"]&&obj[@"valueIcon"]) {
                            [data setObject:resultData[@"icon"] forKey:@"valueIcon"];
                            [self.userAutosInfoData setObject:resultData[@"icon"] forKey:data[@"valueIconKey"]];
                        }
                        [headerArray replaceObjectAtIndex:idx withObject:data];
                        [self.userAutosInfoData setObject:data[@"value"] forKey:data[@"valueKey"]];
                        [self.userAutosInfoData setObject:data[@"valueID"] forKey:data[@"valueIDKey"]];
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            [self updateUIData];

        }];
 
    }
}

//车牌号码
- (IBAction)carNumberClick {
    
    if (UserBehaviorHandler.shareInstance.getUserType>=6||
        UserBehaviorHandler.shareInstance.getUserMemberType>=UserMemberTypeOfSilverMedal) {
        [SupportingClass showAlertViewWithTitle:@"车牌号已锁定" message:@"因为您的会员类型已经是银牌以上或您的汽车已绑定GPS，所以您不能修改车牌号！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [_maiiv setInputType:MAIInputTypeOfLicensePlate withOriginalValue:self.licensePlate];
    [_maiiv showView];
}
//发动机号
- (IBAction)engineNumberClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6) {
        [SupportingClass showAlertViewWithTitle:@"发动机号已锁定" message:@"因为您的汽车已绑定GPS，所以您不能修改发动机号！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [_maiiv setInputType:MAIInputTypeOfAutosEngineNumber withOriginalValue:self.autosEngineNumber];
    [_maiiv showView];
}
//车架号
- (IBAction)VINClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6||
        UserBehaviorHandler.shareInstance.getUserMemberType>=UserMemberTypeOfSilverMedal) {
        [SupportingClass showAlertViewWithTitle:@"车架号已锁定" message:@"因为您的会员类型已经是银牌以上或您的汽车已绑定GPS，所以您不能修改车架号！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];

        return;
    }
    [_maiiv setInputType:MAIInputTypeOfAutosFrameNumber withOriginalValue:self.autosFrameNumber];
    [_maiiv showView];
}
//车辆颜色
- (IBAction)carColorClick {
    [_maiiv setInputType:MAIInputTypeOfAutosBodyColor withOriginalValue:self.autosBodyColor];
    [_maiiv showView];
}
//距下次保险
- (IBAction)nextInsuranceClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6||
        UserBehaviorHandler.shareInstance.getUserMemberType>=UserMemberTypeOfSilverMedal) {
        [SupportingClass showAlertViewWithTitle:@"保险日期已锁定" message:@"因为您的会员类型已经是银牌以上或您的汽车已绑定GPS，所以您不能修改保险日期！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [_maiiv setInputType:MAIInputTypeOfAutosInsuranceDate withOriginalValue:self.autosInsuranceDate];
    [_maiiv showView];
}
//距下次年检
- (IBAction)nextAnnualInspectionClick {
    [_maiiv setInputType:MAIInputTypeOfAutosAnniversaryCheckDate withOriginalValue:self.autosAnniversaryCheckDate];
    [_maiiv showView];
}
//保养记录
- (IBAction)maintainClick {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        MaintenanceRecordVC *vc = [MaintenanceRecordVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//违章记录
- (IBAction)peccancyClick {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        IllegalQueryMainVC *vc = [IllegalQueryMainVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

//保险记录
- (IBAction)insuranceClick {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        MyCarInsuranceVC *vc = [MyCarInsuranceVC new];
        vc.fromStr=@"我的车辆";
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }    
}

//当前里程
- (IBAction)currentMileageClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6) {
        [SupportingClass showAlertViewWithTitle:@"里程记录已锁定" message:@"因为您的汽车已绑定GPS，所以您不能修改里程记录！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [_maiiv setInputType:MAIInputTypeOfInitialMileage withOriginalValue:self.initialMileage];
    [_maiiv showView];
}

//上牌时间
- (IBAction)registerDateClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6) {
        [SupportingClass showAlertViewWithTitle:@"上牌时间已锁定" message:@"因为您的汽车已绑定GPS，所以您不能修改上牌时间！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    [_maiiv setInputType:MAIInputTypeOfAutosRegisterDate withOriginalValue:self.autosRegisterDate];
    [_maiiv showView];
}

//换车按钮
- (IBAction)changeTrainsClick {
    if (UserBehaviorHandler.shareInstance.getUserType>=6) {
        [SupportingClass showAlertViewWithTitle:@"汽车车型已锁定" message:@"因为您的汽车已绑定GPS，所以您不能修改汽车车型！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    NSArray *valueList = [self.autosData valueForKey:@"valueID"];
    NSString *originalValue = [valueList componentsJoinedByString:@","];
    [_maiiv setInputType:MAIInputTypeOfAutosSelection withOriginalValue:originalValue];
    [_maiiv showView];
}


/* "annual_time" = "2016-02-28";
 brandId = 33;
 "brand_img" = "http://x.autoimg.cn/app/image/brand/33_3.png";
 "brand_name" = "\U5965\U8fea";
 "car_number" = "\U6e58A25J09";
 color = "\U7c73\U8272";
 "engine_code" = 12345678901234567;
 factoryId = 36;
 "factory_name" = "\U4e00\U6c7d-\U5927\U4f17\U5965\U8fea";
 fctId = 692;
 "fct_name" = "\U5965\U8feaA4L";
 "frame_no" = 12345678901234567;
 id = 16012814224944920421;
 imei = "";
 "insure_time" = "2016-02-28";
 "maintain_time" = "";
 mileage = 598;
 "registr_time" = "2012-01-28";
 specId = 4642;
 "spec_name" = "2009\U6b3e 2.0 TFSI \U6280\U672f\U578b";*/

- (void)updateUIData {
    if (!self.licensePlate||[self.licensePlate isEqualToString:@""]) {
        self.licensePlate = @"--";
    }
    
    if (!self.autosEngineNumber||[self.autosEngineNumber isEqualToString:@""]) {
        self.autosEngineNumber = @"--";
    }
    
    if (!self.autosFrameNumber||[self.autosFrameNumber isEqualToString:@""]) {
        self.autosFrameNumber = @"--";
    }
    
    if (!self.autosInsuranceDate||[self.autosInsuranceDate isEqualToString:@""]) {
        self.autosInsuranceDate = @"--";
    }
    
    if (!self.autosBodyColor||[self.autosBodyColor isEqualToString:@""]) {
        self.autosBodyColor = @"--";
    }
    
    if (!self.autosAnniversaryCheckDate||[self.autosAnniversaryCheckDate isEqualToString:@""]) {
        self.autosAnniversaryCheckDate = @"--";
    }
    
    if (!self.initialMileage||[self.initialMileage isEqualToString:@""]) {
        self.initialMileage = @"--";
    }
    
    if (!self.autosRegisterDate||[self.autosRegisterDate isEqualToString:@""]) {
        self.autosRegisterDate = @"--";
    }
    self.carNumberLabel.text = self.licensePlate;
    self.engineNumberLabel.text = self.autosEngineNumber;
    self.VINLabel.text = self.autosFrameNumber;
    self.nextInsuranceLabel.text = self.autosInsuranceDate;
    self.carColorLabel.text = self.autosBodyColor;
    self.nextAnnualInspectionLabel.text = self.autosAnniversaryCheckDate;
    self.currentMileageLabel.text = self.initialMileage;
    self.registerDateLabel.text = self.autosRegisterDate;
    self.vehicleTypeLabel.text = self.userAutosInfoData[@"fct_name"];
    if ([self.vehicleTypeLabel.text isEqualToString:@""]) {
        self.vehicleTypeLabel.text = @"请选择车型";
    }
    self.carDetailsLabel.text = self.userAutosInfoData[@"spec_name"];
    _carImage.image = [ImageHandler getDefaultWhiteLogo];
    NSString *imgURL = [self.userAutosInfoData objectForKey:@"brand_img"];
    if ([imgURL containsString:@"http"]) {
        [_carImage sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
}

- (void)updateAutosInfoData {
    self.licensePlate = self.userAutosInfoData[@"car_number"];
    self.autosEngineNumber = self.userAutosInfoData[@"engine_code"];
    self.autosFrameNumber = self.userAutosInfoData[@"frame_no"];
    self.autosInsuranceDate = self.userAutosInfoData[@"insure_time"];
    self.autosBodyColor = self.userAutosInfoData[@"color"];
    self.autosAnniversaryCheckDate = self.userAutosInfoData[@"annual_time"];
    self.initialMileage = self.userAutosInfoData[@"mileage"];
    self.autosRegisterDate = self.userAutosInfoData[@"registr_time"];
    
    NSMutableArray *headerArray = [self mutableArrayValueForKey:@"autosData"];
    [headerArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *data = [obj mutableCopy];
        NSString *key = obj[@"valueKey"];
        id object = self.userAutosInfoData[key];
        if (object) {
            NSString *string = @"";
            if ([object isKindOfClass:[NSNumber class]]) {
                string  = [(NSNumber *)object stringValue];
            }
            if ([object isKindOfClass:[NSString class]]) {
                string  = object;
            }
            if ([string isEqualToString:@""]) {
                [data setObject:kNotSetIt forKey:@"value"];
            }else {
                [data setObject:string forKey:@"value"];
            }
        }else{
            [data setObject:kNotSetIt forKey:@"value"];
        }
        
        
        NSString *theIDKey = obj[@"valueIDKey"];
        NSString *numString = self.userAutosInfoData[theIDKey];
        if (numString) {
            if ([numString isEqualToString:@""]) {
                [data setObject:NSNull.null forKey:@"valueID"];
            }else {
                [data setObject:@(numString.integerValue) forKey:@"valueID"];
            }
        }else{
            [data setObject:NSNull.null forKey:@"valueID"];
        }
        
        if ([obj objectForKey:@"valueIconKey"]) {
            NSString *iconKey = obj[@"valueIconKey"];
            NSString *iconURL = self.userAutosInfoData[iconKey];
            [data setObject:iconURL forKey:@"valueIcon"];
        }
        
        
        
        [headerArray replaceObjectAtIndex:idx withObject:data];
        
    }];
    NSString *theIDs = [(NSArray *)[self.autosData valueForKey:@"valueID"] componentsJoinedByString:@","];
    [_maiiv initAutoDataAndSelect:theIDs];
    [self updateUIData];
}

#pragma mark- API Access Code Section
- (void)getMyAutoData {
    if (!self.accessToken) {
        return;
    }
    @weakify(self);
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    [[APIsConnection shareConnection] personalCenterAPIsGetMyAutoListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
       
        @strongify(self);
        self.userAutosInfoData = [responseObject[CDZKeyOfResultKey] mutableCopy];
        NSString *brandID = [SupportingClass verifyAndConvertDataToString:self.userAutosInfoData[@"brandId"]];
        NSString *factoryID = [SupportingClass verifyAndConvertDataToString:self.userAutosInfoData[@"factoryId"]];
        NSString *fctID = [SupportingClass verifyAndConvertDataToString:self.userAutosInfoData[@"fctId"]];
        NSString *specID = [SupportingClass verifyAndConvertDataToString:self.userAutosInfoData[@"specId"]];
        if ([brandID isEqualToString:@""]||[factoryID isEqualToString:@""]||
            [fctID isEqualToString:@""]||[specID isEqualToString:@""]) {
            self.fristUpdate = YES;
        }
        
        [self updateAutosInfoData];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error); [ProgressHUDHandler dismissHUD];
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

/*车牌号验证*/
- (BOOL)validateCarNo:(NSString*)carNo {
    NSString *carRegex=@"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}

- (IBAction)updateAutosInfomation {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (![self validateCarNo:self.licensePlate]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的车牌号码"] onView:self.view completion:nil];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新资料中...." onView:nil];
    NSString *userAutosID = self.userAutosInfoData[@"id"];
    NSString *maintenanceDate = self.userAutosInfoData[@"maintain_time"];
    
    NSString *brandID = @"";
    NSString *dealershipID = @"";
    NSString *seriesID = @"";
    NSString *modelID = @"";
    NSString *checkSelectedIdx = [[self.autosData valueForKey:@"valueID"] componentsJoinedByString:@","];
    if ([checkSelectedIdx rangeOfString:kNullString].location==NSNotFound) {
        brandID = [SupportingClass verifyAndConvertDataToString:[self.autosData[0] objectForKey:@"valueID"]];
        dealershipID = [SupportingClass verifyAndConvertDataToString:[self.autosData[1] objectForKey:@"valueID"]];
        seriesID = [SupportingClass verifyAndConvertDataToString:[self.autosData[2] objectForKey:@"valueID"]];
        modelID = [SupportingClass verifyAndConvertDataToString:[self.autosData[3] objectForKey:@"valueID"]];
    }
    
    //    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPatchMyAutoWithAccessToken:self.accessToken myAutoID:userAutosID myAutoNumber:self.licensePlate myAutoBodyColor:self.autosBodyColor myAutoMileage:self.initialMileage myAutoFrameNum:self.autosFrameNumber myAutoEngineNum:self.autosEngineNumber insuranceDate:self.autosInsuranceDate annualCheckDate:self.autosAnniversaryCheckDate maintenanceDate:nil registrDate:self.autosRegisterDate brandID:brandID brandDealershipID:dealershipID seriesID:seriesID modelID:modelID insuranceNum:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        if (self.fristUpdate) {
            message = @"添加成功";
        }
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            UserAutosInfoDTO *dto = [UserAutosInfoDTO new];
            [dto processDataToObject:self.userAutosInfoData optionWithUID:UserBehaviorHandler.shareInstance.getUserID];
            UserSelectedAutosInfoDTO *selectedDto = [DBHandler.shareInstance getSelectedAutoData];
            if (!selectedDto.dbUID||selectedDto.isSelectFromOnline) {
                [selectedDto processDataToObjectWithDto:dto];
                BOOL isDone = [[DBHandler shareInstance] updateSelectedAutoData:selectedDto];
                NSLog(@"isDone:%d",isDone);
            }
            NSLog(@"%@", dto);
            NSLog(@"success update user autos detail data::::::%d", [DBHandler.shareInstance updateUserAutosDetailData:dto.processObjectToDBData]);
            
            if (self.wasSubmitAfterLeave) {
                if (!self.wasBackRootView) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }else{
                if ([message isEqualToString:@"修改成功"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
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
