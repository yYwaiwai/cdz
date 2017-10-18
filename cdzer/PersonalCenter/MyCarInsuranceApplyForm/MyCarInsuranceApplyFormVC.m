//
//  MyCarInsuranceApplyFormVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/29.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCarInsuranceApplyFormVC.h"
#import "InsuranceDetailsVC.h"
#import "MyCarInsuranceVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MyCarInsuranceApplyFormVC ()<
UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIControl *insuranceCompanyControl;//保险公司

@property (weak, nonatomic) IBOutlet UILabel *insuranceCompanyLabel;//保险公司label

@property (weak, nonatomic) IBOutlet UIView *strongInsuranceControl;//

@property (weak, nonatomic) IBOutlet UIControl *strongInsuranceEffectiveDateControl;//交强险生效日期

@property (weak, nonatomic) IBOutlet UILabel *strongInsuranceEffectiveDateLabel;//交强险生效日期label
@property (weak, nonatomic) IBOutlet UITextField *strongInsuranceEffectiveDateTF;

@property (weak, nonatomic) IBOutlet UIControl *compulsoryInsuranceAndTravelTaxControl;//交强险和车船税

@property (weak, nonatomic) IBOutlet UILabel *compulsoryInsuranceAndTravelTaxLabel;//交强险和车船税label

@property (weak, nonatomic) IBOutlet UIControl *commercialInsuranceControl;//商业险生效日期

@property (weak, nonatomic) IBOutlet UILabel *effectiveDateOfCommercialInsuranceLabel;//商业险生效日期label
@property (weak, nonatomic) IBOutlet UITextField *effectiveDateOfCommercialInsuranceTF;

@property (weak, nonatomic) IBOutlet UIControl *vehicleDamageInsuranceControl;//车辆损失险

@property (weak, nonatomic) IBOutlet UIButton *nonDeductibleWithVehicleDamageInsuranceButton;//车辆损失险 不计免赔

@property (weak, nonatomic) IBOutlet UILabel *vehicleDamageInsuranceLabel;//车辆损失险label

@property (weak, nonatomic) IBOutlet UIControl *thirdPartyLiabilityInsuranceControl;//第三方责任险

@property (weak, nonatomic) IBOutlet UIButton *nonDeductibleWithThirdPartyLiabilityInsuranceButton;//第三方责任险  不计免赔

@property (weak, nonatomic) IBOutlet UILabel *thirdPartyLiabilityInsuranceLabel;//第三方责任险label

@property (weak, nonatomic) IBOutlet UIControl *robberAndTheftInsuranceControl;//全车盗抢险

@property (weak, nonatomic) IBOutlet UIButton *nonDeductibleWithRobberAndTheftInsuranceButton;//全车盗抢险 不计免赔

@property (weak, nonatomic) IBOutlet UILabel *robberAndTheftInsuranceLabel;//全车盗抢险label

@property (weak, nonatomic) IBOutlet UIControl *driverLiabilityInsuranceControl;//驾驶人责任险
@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWithDriverLiabilityInsuranceButton;//驾驶人责任险 不计免赔

@property (weak, nonatomic) IBOutlet UILabel *driverLiabilityInsuranceLabel;//驾驶人责任险label

@property (weak, nonatomic) IBOutlet UIControl *passengerLiabilityInsuranceControl;//乘客责任险
@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWithPassengerLiabilityInsuranceButton;//乘客责任险 不计免赔

@property (weak, nonatomic) IBOutlet UILabel *passengerLiabilityInsuranceLabel;//乘客责任险label

@property (weak, nonatomic) IBOutlet UIImageView *additionalInsuranceCoverageSelectImage;//更多附加保险保障展开图片

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *additionalInsuranceCoverageControlLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIControl *breakageOfGlassControl;//玻璃破碎险

@property (weak, nonatomic) IBOutlet UILabel *breakageOfGlassLabel;//玻璃破碎险label

@property (weak, nonatomic) IBOutlet UIControl *spontaneousLossOfIgnitionControl;//自燃损失险

@property (weak, nonatomic) IBOutlet UILabel *spontaneousLossOfIgnitionLabel;//自燃损失险label

@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWithSpontaneousLossOfIgnitionButton;//自燃损失险 不计免赔

@property (weak, nonatomic) IBOutlet UIControl *scratchRiskControl;//划痕险

@property (weak, nonatomic) IBOutlet UILabel *scratchRiskLabel;//划痕险label

@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWithScratchRiskButton;//划痕险 不计免赔

@property (weak, nonatomic) IBOutlet UIControl *wadingInsuranceControl;//涉水险

@property (weak, nonatomic) IBOutlet UILabel *wadingInsuranceLabel;//涉水险label

@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWithWadingInsuranceButton;//涉水险 不计免赔

@property (weak, nonatomic) IBOutlet UIControl *theSpecifiedServiceFactorySpecialInsuranceControl;//指定专修厂特约险
@property (weak, nonatomic) IBOutlet UILabel *theSpecifiedServiceFactorySpecialInsuranceTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *theSpecifiedServiceFactorySpecialInsuranceLabel;//指定专修厂特约险label

@property (weak, nonatomic) IBOutlet UIButton *onDeductibleWiththeSpecifiedServiceFactorySpecialInsuranceButton;//指定专修厂特约险 不计免赔

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityCardPhotoBgViewLayoutConstraintHeight;
@property (weak, nonatomic) IBOutlet UIControl *identityCardPhotoControl;//身份证照片

@property (weak, nonatomic) IBOutlet UIImageView *identityCardPhotoSelectImage;//身份证照片点击展开

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityCardPhotoClickControlLayoutConstraintHeight;

@property (weak, nonatomic) IBOutlet UIControl *identityCardPhotoClickControl;//上传身份证照片Control

@property (weak, nonatomic) IBOutlet UIImageView *identityCardPhotoImg;////上传身份证照片Img

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityCardPhotoClickControlLayoutConstraint;//展示图片的高  身份证
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivingLicensePhotoBgViewLayoutConstraintHeight;

@property (weak, nonatomic) IBOutlet UIControl *drivingLicensePhotoControl;//行驶证照片

@property (weak, nonatomic) IBOutlet UIImageView *drivingLicensePhotoSelectImage;//行驶证照片点击展开

@property (weak, nonatomic) IBOutlet UIControl *drivingLicensePhotoClickControl;//上传行驶证照片Control

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivingLicensePhotoClickControlLayoutConstraintHeight;

@property (weak, nonatomic) IBOutlet UIImageView *drivingLicensePhotoImg;//上传行驶证照片Img

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivingLicensePhotoClickControlLayoutConstraint;//展示图片的高  行驶证

@property (weak, nonatomic) IBOutlet UIButton *submitAnAppointmentButton;//提交预约

@property (nonatomic, assign) BOOL additionalInsuranceCoverageControlIsshow;

@property (nonatomic, assign) BOOL identityCardPhotoClickControlIsshow;

@property (nonatomic, assign) BOOL drivingLicensePhotoClickControlIsshow;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) UIImage *needUploadImg;

@property (nonatomic, assign) NSInteger identityCardOrDrivingLicense;


///////
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSString *start1DriveDateTime;

@property (nonatomic, strong) UIView *pickerBGView;//pickerView

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIToolbar * pickerViewToolBar;

@property (nonatomic, strong) NSArray *resultArr;

@property (nonatomic, strong) NSMutableArray *pickerViewArr;

@property (nonatomic, strong) NSString *pickerViewString;

@property (nonatomic, strong) NSString *tagStr;

@property (nonatomic, strong) NSString *licenseImgUrlStr;

@property (nonatomic, strong) NSString *identityImgUrlStr;


//是否投保 标志值
@property (nonatomic, strong) NSString *compulsoryInsuranceAndTravelTaxStr;////交强险和车船税
@property (nonatomic, strong) NSString *vehicleDamageInsuranceStr;////车辆损失险
@property (nonatomic, strong) NSString *thirdPartyLiabilityInsuranceStr;////第三方责任险
@property (nonatomic, strong) NSString *robberAndTheftInsuranceStr;////全车盗抢险
@property (nonatomic, strong) NSString *driverLiabilityInsuranceStr;////驾驶人责任险
@property (nonatomic, strong) NSString *passengerLiabilityInsuranceStr;////乘客责任险
@property (nonatomic, strong) NSString *breakageOfGlassStr;////玻璃破碎险
@property (nonatomic, strong) NSString *spontaneousLossOfIgnitionStr;////自燃损失险
@property (nonatomic, strong) NSString *scratchRiskStr;////划痕险
@property (nonatomic, strong) NSString *wadingInsuranceStr;////涉水险
@property (nonatomic, strong) NSString *theSpecifiedServiceFactorySpecialInsuranceStr;////指定专修厂特约险

@property (nonatomic, strong) NSString *lossSpecialStr;//不计免赔——车损
@property (nonatomic, strong) NSString *thirdSpecialStr;//不计免赔——三责
@property (nonatomic, strong) NSString *theftSpecialStr;//不计免赔——盗抢
@property (nonatomic, strong) NSString *dSeatSpecialStr;//不计免赔——司机
@property (nonatomic, strong) NSString *pSeatSpecialStr;//不计免赔——乘客
@property (nonatomic, strong) NSString *fireSpecialStr;//不计免赔——自燃损失险
@property (nonatomic, strong) NSString *scratchSpecialStr;//不计免赔——划痕险
@property (nonatomic, strong) NSString *waterSpecialStr;//不计免赔——涉水险

@property (nonatomic, strong) NSString *pidStr;

@property (nonatomic, assign) BOOL isReAppointment;

@property (nonatomic) CGRect keyboardRect;

@property (nonatomic, assign) BOOL isCommercialOrStrong;

@end

@implementation MyCarInsuranceApplyFormVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUserAutosInsuranceGetCompany];
    if ([self.fromStr isEqualToString:@"保险详情"]) {
        [self upDataReAppoimtResult];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"预约保险";
    
    [self initializationUI];
}

-(void)viewDidLayoutSubviews
{
    [self.insuranceCompanyControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.strongInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.strongInsuranceEffectiveDateControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.strongInsuranceEffectiveDateControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.compulsoryInsuranceAndTravelTaxControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.commercialInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.vehicleDamageInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.thirdPartyLiabilityInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.robberAndTheftInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.driverLiabilityInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.passengerLiabilityInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.insuranceCompanyControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.insuranceCompanyControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.insuranceCompanyControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.breakageOfGlassControl setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.spontaneousLossOfIgnitionControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.scratchRiskControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.wadingInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.theSpecifiedServiceFactorySpecialInsuranceControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.identityCardPhotoControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.drivingLicensePhotoControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.submitAnAppointmentButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.pickerViewArr=[NSMutableArray new];
        
        _additionalInsuranceCoverageControlIsshow=YES;
        self.identityCardPhotoClickControlIsshow=YES;
        _drivingLicensePhotoClickControlIsshow=YES;
        self.additionalInsuranceCoverageControlLayoutConstraint.constant=0;
        self.identityCardPhotoClickControlLayoutConstraint.constant=0;
        self.identityCardPhotoBgViewLayoutConstraintHeight.constant=33;
        self.identityCardPhotoClickControlLayoutConstraintHeight.constant=0;
        self.drivingLicensePhotoClickControlLayoutConstraint.constant=0;
        self.drivingLicensePhotoBgViewLayoutConstraintHeight.constant=33;
        self.drivingLicensePhotoClickControlLayoutConstraintHeight.constant=0;
        
        self.theSpecifiedServiceFactorySpecialInsuranceTitleLabel.adjustsFontSizeToFitWidth=YES;
        
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        
        self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [self.toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        doneButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [self.toolbar setItems:buttonsArray];
        
        self.strongInsuranceEffectiveDateTF.inputView = self.datePicker;
        self.strongInsuranceEffectiveDateTF.inputAccessoryView = self.toolbar;
        
        self.effectiveDateOfCommercialInsuranceTF.inputView = self.datePicker;
        self.effectiveDateOfCommercialInsuranceTF.inputAccessoryView = self.toolbar;
        
        self.lossSpecialStr=@"1";
        self.thirdSpecialStr=@"1";
        self.theftSpecialStr=@"0";
        self.dSeatSpecialStr=@"1";
        self.pSeatSpecialStr=@"1";
        self.fireSpecialStr=@"0";
        self.scratchSpecialStr=@"0";
        self.waterSpecialStr=@"0";
        
    }
}

#pragma mark- 重新预约的 保险数据
-(void)upDataReAppoimtResult
{
    self.pidStr=self.reAppoimtResultDic[@"pid"];
    self.carIDStr=self.reAppoimtResultDic[@"car_id"];
    self.insuranceCompanyLabel.text=self.reAppoimtResultDic[@"company"];//保险公司label
    self.strongInsuranceEffectiveDateTF.text=self.reAppoimtResultDic[@"s_time"];;//交强险生效日期label
    
    self.effectiveDateOfCommercialInsuranceTF.text=self.reAppoimtResultDic[@"b_time"];;//商业险生效日期label
    if ([self.effectiveDateOfCommercialInsuranceTF.text isEqualToString:@""]) {
        self.effectiveDateOfCommercialInsuranceTF.text=@"";
    }
    self.licenseImgUrlStr=self.reAppoimtResultDic[@"license_img"];//上传行驶证照片
    self.identityImgUrlStr=self.reAppoimtResultDic[@"identity_img"];//上传身份证照片Img
    if ([self.identityImgUrlStr containsString:@"http"]) {
        [self.identityCardPhotoImg sd_setImageWithURL:[NSURL URLWithString:self.identityImgUrlStr] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    if ([self.licenseImgUrlStr containsString:@"http"]) {
        [self.drivingLicensePhotoImg sd_setImageWithURL:[NSURL URLWithString:self.licenseImgUrlStr] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    
    NSArray *insureInfoArr=self.reAppoimtResultDic[@"insure_info"];
    for (NSDictionary *coverageTypeDic in insureInfoArr) {
        NSString *coverageTypeStr=coverageTypeDic[@"coverage_type"];
        if ([coverageTypeStr isEqualToString:@"全车盗抢险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.robberAndTheftInsuranceLabel.text=@"不投保";
                self.robberAndTheftInsuranceStr=@"0";
            }else{
                self.robberAndTheftInsuranceLabel.text=@"投保";
                self.robberAndTheftInsuranceStr=@"1";
            }
        }
        if ([coverageTypeStr isEqualToString:@"玻璃单独破碎险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.breakageOfGlassLabel.text=@"不投保";
            }
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"1"]) {
                self.breakageOfGlassLabel.text=@"国产玻璃";
            }if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"2"]){
                self.breakageOfGlassLabel.text=@"进口玻璃";
            }
            self.breakageOfGlassStr=coverageTypeDic[@"coverage_no"];
        }
        if ([coverageTypeStr isEqualToString:@"商业第三者责任保险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.thirdPartyLiabilityInsuranceLabel.text=@"不投保";
            }else{
                self.thirdPartyLiabilityInsuranceLabel.text=coverageTypeDic[@"coverage_no"];
               self.pickerViewString=self.thirdPartyLiabilityInsuranceStr=coverageTypeDic[@"coverage_no"];
            }
        }
        if ([coverageTypeStr isEqualToString:@"驾驶人责任险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.driverLiabilityInsuranceLabel.text=@"不投保";
            }else{
                self.driverLiabilityInsuranceLabel.text=coverageTypeDic[@"coverage_no"];
                self.pickerViewString=self.driverLiabilityInsuranceStr=coverageTypeDic[@"coverage_no"];
            }
        }
        if ([coverageTypeStr isEqualToString:@"车辆损失险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.vehicleDamageInsuranceLabel.text=@"不投保";
            }else{
                self.vehicleDamageInsuranceStr=@"1";
                self.vehicleDamageInsuranceLabel.text=@"投保";
            }
        }
        if ([coverageTypeStr isEqualToString:@"自燃损失险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.spontaneousLossOfIgnitionLabel.text=@"不投保";
            }else{
                self.spontaneousLossOfIgnitionStr=@"1";
                self.spontaneousLossOfIgnitionLabel.text=@"投保";
            }
            
        }

        if ([coverageTypeStr isEqualToString:@"乘客责任险"]) {
            self.passengerLiabilityInsuranceLabel.text=coverageTypeDic[@"coverage_no"];
            self.pickerViewString=self.passengerLiabilityInsuranceStr=coverageTypeDic[@"coverage_no"];
        }

        if (![self.reAppoimtResultDic[@"s_time"] isEqualToString:@""]) {
            if ([coverageTypeStr isEqualToString:@"车船税"]||[coverageTypeStr isEqualToString:@"交强险"]) {
                self.compulsoryInsuranceAndTravelTaxLabel.text=@"投保";
                self.compulsoryInsuranceAndTravelTaxStr=@"1";
            }
        }else{
            self.strongInsuranceEffectiveDateTF.text=@"请选择生效日期";
            self.compulsoryInsuranceAndTravelTaxLabel.text=@"不投保";
        }
        
        if ([coverageTypeStr isEqualToString:@"车身划痕损失险"]) {
            self.scratchRiskLabel.text=coverageTypeDic[@"coverage_no"];
            self.pickerViewString=self.scratchRiskStr=coverageTypeDic[@"coverage_no"];
        }
        if ([coverageTypeStr isEqualToString:@"指定专修厂特约险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.theSpecifiedServiceFactorySpecialInsuranceLabel.text=@"不投保";
            }else{
                self.theSpecifiedServiceFactorySpecialInsuranceLabel.text=@"投保";
                self.theSpecifiedServiceFactorySpecialInsuranceStr=@"1";
            }
        }
        if ([coverageTypeStr isEqualToString:@"涉水行驶损失险"]) {
            
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.wadingInsuranceLabel.text=@"不投保";
            }else{
                self.wadingInsuranceLabel.text=@"投保";
                self.wadingInsuranceStr=@"1";
            }
        }
        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-盗抢"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.nonDeductibleWithRobberAndTheftInsuranceButton.hidden=YES;
            }else{
                self.nonDeductibleWithRobberAndTheftInsuranceButton.hidden=NO;
                self.nonDeductibleWithRobberAndTheftInsuranceButton.selected=YES;
                self.theftSpecialStr=@"1";
            }
            
            
        }

        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-三者"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.hidden=YES;
            }else{
                self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.hidden=NO;
                self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.selected=YES;
            }
            self.thirdSpecialStr=coverageTypeDic[@"coverage_no"];
        }

        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-车损"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                 self.nonDeductibleWithVehicleDamageInsuranceButton.hidden=YES;
            }else{
                self.nonDeductibleWithVehicleDamageInsuranceButton.hidden=NO;
                self.nonDeductibleWithVehicleDamageInsuranceButton.selected=YES;
                self.lossSpecialStr=@"1";
            }
            
        }

        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-司机座位险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.onDeductibleWithDriverLiabilityInsuranceButton.hidden=YES;
            }else{
                self.onDeductibleWithDriverLiabilityInsuranceButton.hidden=NO;
                self.onDeductibleWithDriverLiabilityInsuranceButton.selected=YES;
            }
            self.dSeatSpecialStr=coverageTypeDic[@"coverage_no"];
        }
        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-乘客座位险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.onDeductibleWithPassengerLiabilityInsuranceButton.hidden=YES;
            }else{
                self.onDeductibleWithPassengerLiabilityInsuranceButton.hidden=NO;
                self.onDeductibleWithPassengerLiabilityInsuranceButton.selected=YES;
            }
            self.pSeatSpecialStr=coverageTypeDic[@"coverage_no"];
        }
        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-自燃险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=YES;
            }else{
                self.fireSpecialStr=@"1";
                if (self.additionalInsuranceCoverageControlLayoutConstraint.constant==215) {
                    self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected=YES;
                    self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=NO;
                }
            }
            
        }
        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-划痕险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.onDeductibleWithScratchRiskButton.hidden=YES;
            }else{
                
                if (self.additionalInsuranceCoverageControlLayoutConstraint.constant==215) {
                    self.onDeductibleWithScratchRiskButton.selected=YES;
                    self.onDeductibleWithScratchRiskButton.hidden=NO;
                }
            }
            self.scratchSpecialStr=coverageTypeDic[@"coverage_no"];
        }
        if ([coverageTypeStr isEqualToString:@"不计免赔特约险-涉水险"]) {
            if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                self.onDeductibleWithWadingInsuranceButton.hidden=YES;
            }else{
                self.waterSpecialStr=@"1";
                if (self.additionalInsuranceCoverageControlLayoutConstraint.constant==215) {
                    self.onDeductibleWithWadingInsuranceButton.selected=YES;
                    self.onDeductibleWithWadingInsuranceButton.hidden=NO;
                }
            }
            
        }

        
    }

}


#pragma mark-请选择生效日期
- (void)hiddenKeyboard {
    if (self.strongInsuranceEffectiveDateTF) {
        self.start1DriveDateTime = self.strongInsuranceEffectiveDateTF.text;
        [self.strongInsuranceEffectiveDateTF resignFirstResponder];
    }
    if (self.effectiveDateOfCommercialInsuranceTF) {
        self.start2DriveDateTime = self.effectiveDateOfCommercialInsuranceTF.text;
        [self.effectiveDateOfCommercialInsuranceTF resignFirstResponder];
    }
    
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    self.keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *textField = nil;
    if (self.strongInsuranceEffectiveDateTF.isFirstResponder) {
        textField = self.strongInsuranceEffectiveDateTF;
    }
    if (self.effectiveDateOfCommercialInsuranceTF.isFirstResponder) {
        textField = self.effectiveDateOfCommercialInsuranceTF;
    }
    if (textField) {
        [self shiftScrollViewWithAnimation:textField];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)notiObj {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    UIView *theView = self.scrollView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([textField.superview convertRect:textField.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.scrollView setContentOffset:point animated:NO];
}

- (void)dateChangeFromDatePicker:(UIDatePicker *)datePicker {
    if (self.isCommercialOrStrong==NO) {
        self.strongInsuranceEffectiveDateTF.text = [self.dateFormatter stringFromDate:datePicker.date];
    }
    if (self.isCommercialOrStrong==YES) {
        self.effectiveDateOfCommercialInsuranceTF.text = [self.dateFormatter stringFromDate:datePicker.date];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.strongInsuranceEffectiveDateTF==textField){
        self.isCommercialOrStrong=NO;
        NSDate *date = NSDate.date;//[NSDate dateWithTimeInterval:(2*60*60) sinceDate:NSDate.date];
        if (!self.strongInsuranceEffectiveDateTF.text||[self.strongInsuranceEffectiveDateTF.text isEqualToString:@""]) {
            self.start1DriveDateTime = [self.dateFormatter stringFromDate:date];
            self.strongInsuranceEffectiveDateTF.text = self.start1DriveDateTime;
        }
        if ([self.fromStr isEqualToString:@"保险详情"]) {
            textField.text = self.reAppoimtResultDic[@"s_time"];
            if (![self.reAppoimtResultDic[@"s_time"] isEqualToString:self.strongInsuranceEffectiveDateTF.text]) {
                textField.text =self.strongInsuranceEffectiveDateTF.text;
            }
            date= [self.dateFormatter dateFromString:textField.text];
            self.datePicker.date = [self.dateFormatter dateFromString:textField.text];
        }else{
            self.datePicker.date = [self.dateFormatter dateFromString:self.start1DriveDateTime];
        }
        self.datePicker.minimumDate = date;
        
        
    }
    if (self.effectiveDateOfCommercialInsuranceTF==textField){
        self.isCommercialOrStrong=YES;
        NSDate *date = NSDate.date;//[NSDate dateWithTimeInterval:(2*60*60) sinceDate:NSDate.date];
        if (!self.effectiveDateOfCommercialInsuranceTF.text||[self.effectiveDateOfCommercialInsuranceTF.text isEqualToString:@""]) {
            self.start2DriveDateTime = [self.dateFormatter stringFromDate:date];
            self.effectiveDateOfCommercialInsuranceTF.text = self.start2DriveDateTime;
        }
        if ([self.fromStr isEqualToString:@"保险详情"]) {
            textField.text = self.reAppoimtResultDic[@"b_time"];
            if (![self.reAppoimtResultDic[@"b_time"] isEqualToString:self.effectiveDateOfCommercialInsuranceTF.text]) {
                textField.text =self.effectiveDateOfCommercialInsuranceTF.text;
            }
            date= [self.dateFormatter dateFromString:textField.text];
            self.datePicker.date = [self.dateFormatter dateFromString:textField.text];
        }else{
            self.datePicker.date = [self.dateFormatter dateFromString:self.start2DriveDateTime];
        }
        self.datePicker.minimumDate = date;
        
        
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag==55) {
        self.strongInsuranceEffectiveDateTF.text = self.start1DriveDateTime;
    }
    if (textField.tag==56) {
        self.effectiveDateOfCommercialInsuranceTF.text = self.start2DriveDateTime;
    }
}

#pragma mark-controlClick
- (IBAction)controlClick:(UIControl *)sender {
    
    if (self.pickerViewArr.count>0) {
        [self.pickerViewArr removeAllObjects];
    }
    if (sender.tag==20) {//保险公司
        for (NSDictionary *dic in self.resultArr) {
            [self.pickerViewArr addObject:dic[@"name"]];
        }
    }
//    if (sender.tag==21) {//交强险+车船税
//        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"投保", nil];
//    }
    if (sender.tag==22) {//车辆损失险
        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"投保",@"不投保", nil];
    }
    if (sender.tag==23) {//商业第三者责任险
        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"5万",@"10万",@"20万",@"30万",@"50万",@"100万", nil];
    }
    if (sender.tag==24) {//全车盗抢险
        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"投保",@"不投保", nil];
    }
    if (sender.tag==25) {//司机座位责任险
        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"1万",@"2万",@"3万",@"4万",@"5万",@"10万",@"15万",@"20万", nil];
    }
    if (sender.tag==26) {//乘客座位责任险
        self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"1万",@"2万",@"3万",@"4万",@"5万",@"10万",@"15万",@"20万", nil];
    }
    
    
        self.tagStr=[NSString stringWithFormat:@"%d",sender.tag];
    if ([self.vehicleDamageInsuranceLabel.text isEqualToString:@"投保"]) {
        if (sender.tag==27) {//玻璃单独破碎险
            self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"国产玻璃",@"进口玻璃", nil];
        }
        if (sender.tag==28) {//自燃损失险
            self.pickerViewArr=[NSMutableArray arrayWithObjects:@"投保",@"不投保", nil];
        }
        if (sender.tag==29) {//车身划痕损失险
            self.pickerViewArr=[NSMutableArray arrayWithObjects:@"不投保",@"2000",@"5000",@"10000",@"20000", nil];
        }
        if (sender.tag==30) {//涉水行驶损失险
            self.pickerViewArr=[NSMutableArray arrayWithObjects:@"投保",@"不投保", nil];
        }
        if (sender.tag==31) {//指定专修厂特约险
            self.pickerViewArr=[NSMutableArray arrayWithObjects:@"投保",@"不投保", nil];
        }

    }
    
    if (self.pickerViewArr.count>0) {
        [self upPickerViewUI];
    }
    
}

-(void)upPickerViewUI
{
   
    self.pickerBGView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.pickerBGView.backgroundColor=[UIColor colorWithHexString:@"323232" alpha:0.5];
    [self.view addSubview:self.pickerBGView];
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-150.0, CGRectGetWidth(self.view.frame), 150)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    //    self.carNumberPickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor=CDZColorOfWhite;
    self.pickerViewToolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.pickerView.frame)-40, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [self.pickerViewToolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *finishBtn=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishAction)];
    UIBarButtonItem *cancelBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction)];
    UIBarButtonItem *flexible=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    finishBtn.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
    cancelBtn.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
    NSArray *btnArr=[[NSArray alloc]initWithObjects:cancelBtn,flexible,finishBtn, nil];
    [self.pickerViewToolBar setItems:btnArr];
    
    [self.pickerBGView addSubview:self.pickerViewToolBar];
    [self.pickerBGView addSubview:self.pickerView];
    self.pickerViewString=nil;
}

-(void)cancelAction{
    [self.pickerBGView removeFromSuperview];
    [self.pickerViewToolBar removeFromSuperview];
    [self.pickerView removeFromSuperview];
    
}

-(void)finishAction{
    [self.pickerBGView removeFromSuperview];
    [self.pickerViewToolBar removeFromSuperview];
    [self.pickerView removeFromSuperview];
    if (self.pickerViewString.length==0) {
        self.pickerViewString=self.pickerViewArr.firstObject;
    }
    [self pickerViewStringUpData];
}
#pragma mark-pickerview 选值
-(void)pickerViewStringUpData{
    if ([self.tagStr isEqualToString:@"20"]) {//保险公司
        self.insuranceCompanyLabel.text=self.pickerViewString;
    }
    if ([self.tagStr isEqualToString:@"21"]) {//交强险+车船税
        self.compulsoryInsuranceAndTravelTaxLabel.text=self.compulsoryInsuranceAndTravelTaxLabel.text;
        
    }
    if ([self.tagStr isEqualToString:@"22"]) {//车辆损失险
        self.vehicleDamageInsuranceLabel.text=self.pickerViewString;
        if ([self.vehicleDamageInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.nonDeductibleWithVehicleDamageInsuranceButton.hidden=YES;
            self.spontaneousLossOfIgnitionLabel.text=@"不投保";
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=YES;
            self.scratchRiskLabel.text=@"不投保";
            self.onDeductibleWithScratchRiskButton.hidden=YES;
            self.wadingInsuranceLabel.text=@"不投保";
            self.onDeductibleWithWadingInsuranceButton.hidden=YES;
            self.breakageOfGlassLabel.text=@"不投保";
            self.theSpecifiedServiceFactorySpecialInsuranceLabel.text=@"不投保";
            
            self.nonDeductibleWithVehicleDamageInsuranceButton.enabled=NO;
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.enabled=NO;
            self.onDeductibleWithScratchRiskButton.enabled=NO;
            self.onDeductibleWithWadingInsuranceButton.enabled=NO;
        }else{
            self.nonDeductibleWithVehicleDamageInsuranceButton.hidden=NO;
            
            self.nonDeductibleWithVehicleDamageInsuranceButton.enabled=YES;
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.enabled=YES;
            self.onDeductibleWithScratchRiskButton.enabled=YES;
            self.onDeductibleWithWadingInsuranceButton.enabled=YES;
        }

           }
    if ([self.tagStr isEqualToString:@"23"]) {//商业第三者责任险
        self.thirdPartyLiabilityInsuranceLabel.text=self.pickerViewString;
        if ([self.thirdPartyLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.hidden=YES;
        }else{
            self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.hidden=NO;
            self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.selected=NO;
        }
    }
    if ([self.tagStr isEqualToString:@"24"]) {//全车盗抢险
        self.robberAndTheftInsuranceLabel.text=self.pickerViewString;
        if ([self.robberAndTheftInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.nonDeductibleWithRobberAndTheftInsuranceButton.hidden=YES;
        }else{
            self.nonDeductibleWithRobberAndTheftInsuranceButton.hidden=NO;
            self.nonDeductibleWithRobberAndTheftInsuranceButton.selected=YES;
        }

    }
    if ([self.tagStr isEqualToString:@"25"]) {//司机座位责任险
        self.driverLiabilityInsuranceLabel.text=self.pickerViewString;
        if ([self.driverLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.onDeductibleWithDriverLiabilityInsuranceButton.hidden=YES;
        }else{
            self.onDeductibleWithDriverLiabilityInsuranceButton.hidden=NO;
            self.onDeductibleWithDriverLiabilityInsuranceButton.selected=YES;
        }

    }
    if ([self.tagStr isEqualToString:@"26"]) {//乘客座位责任险
        self.passengerLiabilityInsuranceLabel.text=self.pickerViewString;
        if ([self.passengerLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.onDeductibleWithPassengerLiabilityInsuranceButton.hidden=YES;
        }else{
            self.onDeductibleWithPassengerLiabilityInsuranceButton.hidden=NO;
            self.onDeductibleWithPassengerLiabilityInsuranceButton.selected=YES;
        }
    }
    if ([self.tagStr isEqualToString:@"27"]) {//玻璃单独破碎险
        self.breakageOfGlassLabel.text=self.pickerViewString;
    }
    
    
    if ([self.tagStr isEqualToString:@"28"]) {//自燃损失险
        self.spontaneousLossOfIgnitionLabel.text=self.pickerViewString;
        if ([self.spontaneousLossOfIgnitionLabel.text isEqualToString:@"不投保"]) {
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=YES;
        }else{
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=NO;
            self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected=YES;
        }


    }
    if ([self.tagStr isEqualToString:@"29"]) {//车身划痕损失险
        self.scratchRiskLabel.text=self.pickerViewString;
        if ([self.scratchRiskLabel.text isEqualToString:@"不投保"]) {
            self.onDeductibleWithScratchRiskButton.hidden=YES;
        }else{
            self.onDeductibleWithScratchRiskButton.hidden=NO;
            self.onDeductibleWithScratchRiskButton.selected=YES;
        }

    }
    if ([self.tagStr isEqualToString:@"30"]) {//涉水行驶损失险
        self.wadingInsuranceLabel.text=self.pickerViewString;
        if ([self.wadingInsuranceLabel.text isEqualToString:@"不投保"]) {
            self.onDeductibleWithWadingInsuranceButton.hidden=YES;
        }else{
            self.onDeductibleWithWadingInsuranceButton.hidden=NO;
            self.onDeductibleWithWadingInsuranceButton.selected=YES;
        }

    }
    if ([self.tagStr isEqualToString:@"31"]) {//指定专修厂特约险
        self.theSpecifiedServiceFactorySpecialInsuranceLabel.text=self.pickerViewString;
    }

}

-(void)allPickerViewLabelDate
{
    if ([self.compulsoryInsuranceAndTravelTaxLabel.text isEqualToString:@"不投保"]) {
        self.compulsoryInsuranceAndTravelTaxStr=@"0";
    }else{
        self.compulsoryInsuranceAndTravelTaxStr=@"1";
    }
    if ([self.vehicleDamageInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.vehicleDamageInsuranceStr=@"0";
        
    }else{
        self.vehicleDamageInsuranceStr=@"1";
    }
    if ([self.thirdPartyLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.thirdPartyLiabilityInsuranceStr=@"0";
    }else{
        self.thirdPartyLiabilityInsuranceStr=self.thirdPartyLiabilityInsuranceLabel.text;
    }
    if ([self.robberAndTheftInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.robberAndTheftInsuranceStr=@"0";
    }else{
        self.robberAndTheftInsuranceStr=@"1";
    }
    
    if ([self.driverLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.driverLiabilityInsuranceStr=@"0";
    }else{
        self.driverLiabilityInsuranceStr=self.driverLiabilityInsuranceLabel.text;
    }
    if ([self.passengerLiabilityInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.passengerLiabilityInsuranceStr=@"0";
    }else{
        self.passengerLiabilityInsuranceStr=self.passengerLiabilityInsuranceLabel.text;
    }
    if ([self.breakageOfGlassLabel.text isEqualToString:@"不投保"]) {
        self.breakageOfGlassStr=@"0";
    }else{
        if ([self.breakageOfGlassLabel.text isEqualToString:@"国产玻璃"]) {
            self.breakageOfGlassStr=@"1";
        }
        if ([self.breakageOfGlassLabel.text isEqualToString:@"进口玻璃"]) {
            self.breakageOfGlassStr=@"2";
        }
    }
    if ([self.spontaneousLossOfIgnitionLabel.text isEqualToString:@"不投保"]) {
        self.spontaneousLossOfIgnitionStr=@"0";
    }else{
        self.spontaneousLossOfIgnitionStr=@"1";
    }
    if ([self.scratchRiskLabel.text isEqualToString:@"不投保"]) {
        self.scratchRiskStr=@"0";
    }else{
        self.scratchRiskStr=self.scratchRiskLabel.text;
    }
    if ([self.wadingInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.wadingInsuranceStr=@"0";
    }else{
        self.wadingInsuranceStr=@"1";
    }
    
    if ([self.theSpecifiedServiceFactorySpecialInsuranceLabel.text isEqualToString:@"不投保"]) {
        self.theSpecifiedServiceFactorySpecialInsuranceStr=@"0";
    }else{
        self.theSpecifiedServiceFactorySpecialInsuranceStr=@"1";
    }
    self.lossSpecialStr=[NSString stringWithFormat:@"%hhd",self.nonDeductibleWithVehicleDamageInsuranceButton.selected];
    self.thirdSpecialStr=[NSString stringWithFormat:@"%hhd",self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.selected];
    self.theftSpecialStr=[NSString stringWithFormat:@"%hhd",self.nonDeductibleWithRobberAndTheftInsuranceButton.selected];
    self.dSeatSpecialStr=[NSString stringWithFormat:@"%hhd",self.onDeductibleWithDriverLiabilityInsuranceButton.selected];
    self.pSeatSpecialStr=[NSString stringWithFormat:@"%hhd",self.onDeductibleWithPassengerLiabilityInsuranceButton.selected];
    self.fireSpecialStr=[NSString stringWithFormat:@"%hhd",self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected];
    self.scratchSpecialStr=[NSString stringWithFormat:@"%hhd",self.onDeductibleWithScratchRiskButton.selected];
    self.waterSpecialStr=[NSString stringWithFormat:@"%hhd",self.onDeductibleWithWadingInsuranceButton.selected];


}


#pragma mark- UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (!self.pickerViewArr) return 0;
    return self.pickerViewArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *string = self.pickerViewArr[row];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerViewString = self.pickerViewArr[row];
}


#pragma mark-是否不计免赔
- (IBAction)nonDeductibleButtonClick:(UIButton *)sender {
    if ([self.vehicleDamageInsuranceLabel.text isEqualToString:@"投保"]&& sender.tag==100)
    {
        self.nonDeductibleWithVehicleDamageInsuranceButton.selected = !self.nonDeductibleWithVehicleDamageInsuranceButton.selected;
        NSLog(@"%hhd",self.nonDeductibleWithVehicleDamageInsuranceButton.selected);
    }
    if (![self.thirdPartyLiabilityInsuranceLabel.text isEqualToString:@"不投保"]&& sender.tag==101)
    {
        self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.selected = !self.nonDeductibleWithThirdPartyLiabilityInsuranceButton.selected;
       
    }
    if ([self.robberAndTheftInsuranceLabel.text isEqualToString:@"投保"]&& sender.tag==102)
    {
        self.nonDeductibleWithRobberAndTheftInsuranceButton.selected = !self.nonDeductibleWithRobberAndTheftInsuranceButton.selected;
            }
    if (![self.driverLiabilityInsuranceLabel.text isEqualToString:@"不投保"]&& sender.tag==103)
    {
        self.onDeductibleWithDriverLiabilityInsuranceButton.selected = !self.onDeductibleWithDriverLiabilityInsuranceButton.selected;
            }
    if (![self.passengerLiabilityInsuranceLabel.text isEqualToString:@"不投保"]&& sender.tag==104)
    {
        self.onDeductibleWithPassengerLiabilityInsuranceButton.selected = !self.onDeductibleWithPassengerLiabilityInsuranceButton.selected;
            }
    if ([self.spontaneousLossOfIgnitionLabel.text isEqualToString:@"投保"]&& sender.tag==105)
    {
        self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected = !self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected;
        
    }
    if (![self.scratchRiskLabel.text isEqualToString:@"不投保"]&& sender.tag==106)
    {
        self.onDeductibleWithScratchRiskButton.selected = !self.onDeductibleWithScratchRiskButton.selected;
            }
    if ([self.wadingInsuranceLabel.text isEqualToString:@"投保"]&& sender.tag==107)
    {
        self.onDeductibleWithWadingInsuranceButton.selected = !self.onDeductibleWithWadingInsuranceButton.selected;
            }

    
    
}


#pragma mark-是否展开 更多附加保险保障
- (IBAction)additionalInsuranceCoverageControlClickIsshow:(UIControl *)sender {
    self.additionalInsuranceCoverageSelectImage.highlighted=_additionalInsuranceCoverageControlIsshow;
    [self fromInsuranceDetail];
    if (_additionalInsuranceCoverageControlIsshow==YES) {
        self.additionalInsuranceCoverageControlLayoutConstraint.constant=215;
        self.additionalInsuranceCoverageControlIsshow=NO;
        self.breakageOfGlassControl.hidden=NO;
        self.spontaneousLossOfIgnitionControl.hidden=NO;
        self.scratchRiskControl.hidden=NO;
        self.wadingInsuranceControl.hidden=NO;
        self.theSpecifiedServiceFactorySpecialInsuranceControl.hidden=NO;
    }else{
        self.additionalInsuranceCoverageControlLayoutConstraint.constant=0;
        _additionalInsuranceCoverageControlIsshow=YES;
        self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=YES;
        self.onDeductibleWithScratchRiskButton.hidden=YES;
        self.onDeductibleWithWadingInsuranceButton.hidden=YES;
        self.onDeductibleWiththeSpecifiedServiceFactorySpecialInsuranceButton.hidden=YES;
        self.breakageOfGlassControl.hidden=YES;
        self.spontaneousLossOfIgnitionControl.hidden=YES;
        self.scratchRiskControl.hidden=YES;
        self.wadingInsuranceControl.hidden=YES;
        self.theSpecifiedServiceFactorySpecialInsuranceControl.hidden=YES;
    }
    
}
-(void)fromInsuranceDetail
{
    if ([self.fromStr isEqualToString:@"保险详情"]) {
        NSArray *insureInfoArr=self.reAppoimtResultDic[@"insure_info"];
        for (NSDictionary *coverageTypeDic in insureInfoArr) {
            NSString *coverageTypeStr=coverageTypeDic[@"coverage_type"];
            if ([coverageTypeStr isEqualToString:@"不计免赔特约险-自燃险"]) {
                if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                    self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=YES;
                }else{
                    self.onDeductibleWithSpontaneousLossOfIgnitionButton.hidden=NO;
                    if (self.additionalInsuranceCoverageSelectImage.highlighted==YES) {
                        self.onDeductibleWithSpontaneousLossOfIgnitionButton.selected=YES;
                    }
                }
            }
            if ([coverageTypeStr isEqualToString:@"不计免赔特约险-划痕险"]) {
                if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                    self.onDeductibleWithScratchRiskButton.hidden=YES;
                }else{
                    self.onDeductibleWithScratchRiskButton.hidden=NO;
                    if (self.additionalInsuranceCoverageSelectImage.highlighted==YES) {
                        self.onDeductibleWithScratchRiskButton.selected=YES;
                    }
                }
            }
            if ([coverageTypeStr isEqualToString:@"不计免赔特约险-涉水险"]) {
                if ([coverageTypeDic[@"coverage_no"] isEqualToString:@"0"]) {
                    self.onDeductibleWithWadingInsuranceButton.hidden=YES;
                }else{
                    self.onDeductibleWithWadingInsuranceButton.hidden=NO;
                    if (self.additionalInsuranceCoverageSelectImage.highlighted==YES) {
                        self.onDeductibleWithWadingInsuranceButton.selected=YES;
                    }
                }
            }
        }
    }

}
//是否展开身份证照片
- (IBAction)identityCardPhotoControlClickIsshow:(UIControl *)sender {
    
    self.identityCardPhotoSelectImage.highlighted=_identityCardPhotoClickControlIsshow;
    if (_identityCardPhotoClickControlIsshow==YES) {
        self.identityCardPhotoClickControlLayoutConstraint.constant=117;
        self.identityCardPhotoBgViewLayoutConstraintHeight.constant=150;
        self.identityCardPhotoClickControlLayoutConstraintHeight.constant=90;
        self.identityCardPhotoClickControlIsshow=NO;
    }else{
        self.identityCardPhotoClickControlLayoutConstraint.constant=0;
        self.identityCardPhotoBgViewLayoutConstraintHeight.constant=33;
        self.identityCardPhotoClickControlLayoutConstraintHeight.constant=0;
        _identityCardPhotoClickControlIsshow=YES;
    }

}
//是否展开行驶证照片
- (IBAction)drivingLicensePhotoControlClickIsshow:(UIControl *)sender {
    self.drivingLicensePhotoSelectImage.highlighted=_drivingLicensePhotoClickControlIsshow;
    if (_drivingLicensePhotoClickControlIsshow==YES) {
        self.drivingLicensePhotoClickControlLayoutConstraint.constant=117;
        self.drivingLicensePhotoBgViewLayoutConstraintHeight.constant=150;
        self.drivingLicensePhotoClickControlLayoutConstraintHeight.constant=90;
        _drivingLicensePhotoClickControlIsshow=NO;
    }else{
        self.drivingLicensePhotoClickControlLayoutConstraint.constant=0;
        self.drivingLicensePhotoBgViewLayoutConstraintHeight.constant=33;
        self.drivingLicensePhotoClickControlLayoutConstraintHeight.constant=0;
        _drivingLicensePhotoClickControlIsshow=YES;
    }
}

#pragma mark-上传身份证    上传行驶证
- (IBAction)identityCardPhotoControlClick:(UIControl*)sender {
    
    self.identityCardOrDrivingLicense=sender.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择图片来源"
                                  delegate:nil
                                  cancelButtonTitle:getLocalizationString(@"cancel")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照", @"相册",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        if (buttonIndex.integerValue<=1) {
            [self showImagePicker:(buttonIndex.boolValue)?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
        }
    }];

    
    
}


- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    
    if (sourceType==UIImagePickerControllerSourceTypeCamera&&IS_SIMULATOR) {
        [SupportingClass showAlertViewWithTitle:@""
                                        message:@"本机不支援相机功能!"
                                isShowImmediate:YES cancelButtonTitle:@"ok"
                              otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    @autoreleasepool {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
            
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if (*stop) {
                    NSLog(@"Allow");
                    return;
                }
                *stop = TRUE;
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Not Allow");
                [self dismissViewControllerAnimated:YES completion:nil];
                [SupportingClass showAlertViewWithTitle:@"" message:@"车队长没有被授权访问的照片数据。\n请检查私隐控制权限／家长控制权限！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
                
            }];
        }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted ||[ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied ){
            [SupportingClass showAlertViewWithTitle:@"" message:@"车队长没有被授权访问的照片数据。\n请检查私隐控制权限／家长控制权限！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.allowsEditing = YES;
        if (sourceType==UIImagePickerControllerSourceTypePhotoLibrary) {
            imagePicker.allowsEditing = YES;
        }
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark-上传图片接口
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (portraitImg == nil) portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        portraitImg = [ImageHandler imageWithImage:portraitImg convertToSize:CGSizeMake(960, 654)];
        [ProgressHUDHandler showHUD];
        
        [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetTestPicWithImage:portraitImg imageName:@"use" imageType:ConnectionImageTypeOfJPEG success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            [ProgressHUDHandler dismissHUD];
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            
            if (errorCode!=0) {
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
                return;
            }else{
                if (self.identityCardOrDrivingLicense==1) {
                    self.identityImgUrlStr=responseObject[@"url"];
                    if ([ self.identityImgUrlStr containsString:@"http"]) {
                        [self.identityCardPhotoImg sd_setImageWithURL:[NSURL URLWithString: self.identityImgUrlStr] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
                    }
                }
                if (self.identityCardOrDrivingLicense==2) {
                    self.licenseImgUrlStr=responseObject[@"url"];
                    if ([ self.licenseImgUrlStr containsString:@"http"]) {
                        [self.drivingLicensePhotoImg sd_setImageWithURL:[NSURL URLWithString: self.licenseImgUrlStr] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
                    }
                }
            }
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
            
            [ProgressHUDHandler dismissHUD];
            if (self.identityCardOrDrivingLicense==1) {
                self.identityCardPhotoImg.image=[UIImage imageNamed:@"shangchuanshenfenzhengzhengmian.png"];
            }
            if (self.identityCardOrDrivingLicense==2) {
                self.drivingLicensePhotoImg.image=[UIImage imageNamed:@"shangchuanxingshizhengzhaopian.png"];
            }
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
            
            [SupportingClass showAlertViewWithTitle:@"error" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
        }];
        
        
        
        
    }];
}



#pragma mark-提交预约
- (IBAction)submitAnAppointmentButtonClick:(id)sender {
    [self allPickerViewLabelDate];
    if ([self.insuranceCompanyLabel.text isEqualToString:@"请选择保险公司"]||[self.strongInsuranceEffectiveDateTF.text isEqualToString:@"请选择生效日期"]||self.identityImgUrlStr==nil||self.licenseImgUrlStr==nil) {
        if ([self.insuranceCompanyLabel.text isEqualToString:@"请选择保险公司"]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择保险公司"] onView:self.view completion:nil];
            return;
        }
        if ([self.compulsoryInsuranceAndTravelTaxLabel.text isEqualToString:@"投保"]&&[self.strongInsuranceEffectiveDateTF.text isEqualToString:@"请选择生效日期"]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择交强险生效日期"] onView:self.view completion:nil];
            return;
        }
        
    }
    if (![self.vehicleDamageInsuranceStr isEqualToString:@"0"]||![self.thirdPartyLiabilityInsuranceStr isEqualToString:@"0"]||![self.robberAndTheftInsuranceStr isEqualToString:@"0"]||![self.driverLiabilityInsuranceStr isEqualToString:@"0"]||![self.passengerLiabilityInsuranceStr isEqualToString:@"0"]) {
        if ([self.effectiveDateOfCommercialInsuranceTF.text isEqualToString:@"请选择生效日期"]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择商业险生效日期"] onView:self.view completion:nil];
            return;
        }
    }
    if ([self.vehicleDamageInsuranceStr isEqualToString:@"0"]&&[self.thirdPartyLiabilityInsuranceStr isEqualToString:@"0"]&&[self.robberAndTheftInsuranceStr isEqualToString:@"0"]&&[self.driverLiabilityInsuranceStr isEqualToString:@"0"]&&[self.passengerLiabilityInsuranceStr isEqualToString:@"0"]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请至少选择一项保险"] onView:self.view completion:nil];
        return;
    }
    if (![self.strongInsuranceEffectiveDateTF.text isEqualToString:@"请选择生效日期"]&&[self.compulsoryInsuranceAndTravelTaxStr isEqualToString:@"0"]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择交强险"] onView:self.view completion:nil];
        return;
    }
    if (self.identityImgUrlStr==nil||self.licenseImgUrlStr==nil) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请上传身份证和行驶证照片"] onView:self.view completion:nil];
        return;
        
    }
    
    else{
        NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",self.insuranceCompanyLabel.text,
              self.carIDStr,
              self.licenseImgUrlStr,
              self.identityImgUrlStr,
              self.strongInsuranceEffectiveDateTF.text,
              self.effectiveDateOfCommercialInsuranceTF.text,
              self.compulsoryInsuranceAndTravelTaxStr,
              self.vehicleDamageInsuranceStr,
              self.robberAndTheftInsuranceStr,
              self.thirdPartyLiabilityInsuranceStr,
              self.breakageOfGlassStr,
              self.driverLiabilityInsuranceStr,
              self.passengerLiabilityInsuranceStr,
              self.spontaneousLossOfIgnitionStr,
              self.scratchRiskStr,
              self.theSpecifiedServiceFactorySpecialInsuranceStr,
              self.wadingInsuranceStr,
              self.lossSpecialStr,
              self.thirdSpecialStr,
              self.theftSpecialStr,
              self.dSeatSpecialStr,
              self.pSeatSpecialStr,
              self.fireSpecialStr,
              self.scratchSpecialStr,
              self.waterSpecialStr,
              self.pidStr);
        if ([self.strongInsuranceEffectiveDateTF.text  isEqualToString:@"请选择生效日期"]) {
            self.strongInsuranceEffectiveDateTF.text=@"";
        }
        if ([self.effectiveDateOfCommercialInsuranceTF.text  isEqualToString:@"请选择生效日期"]) {
            self.effectiveDateOfCommercialInsuranceTF.text=@"";
        }
        if ([self.fromStr isEqualToString:@"保险详情"]) {
            [self getConfirmReAppoint];
        }else{
            [self getAppAddPremiumList];
        }

    }
}

#pragma mark- 保险公司接口
- (void)getUserAutosInsuranceGetCompany {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetCompanyWithsuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@===%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode==0) {
            self.resultArr=[responseObject objectForKey:CDZKeyOfResultKey];
            
            
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }
        
        
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


#pragma mark-预约保险接口
-(void)getAppAddPremiumList{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    
    [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppAddPremiumListWithAccessToken:self.accessToken company:self.insuranceCompanyLabel.text carId:self.carIDStr city:@"长沙市" licenseimg:self.licenseImgUrlStr identityImg:self.identityImgUrlStr sTime:self.strongInsuranceEffectiveDateTF.text bTime:self.effectiveDateOfCommercialInsuranceTF.text premiumSali:self.compulsoryInsuranceAndTravelTaxStr bDamage:self.vehicleDamageInsuranceStr bThief:self.robberAndTheftInsuranceStr bLiability:self.thirdPartyLiabilityInsuranceStr premiumGlass:self.breakageOfGlassStr driverSeat:self.driverLiabilityInsuranceStr passengerSeat:self.passengerLiabilityInsuranceStr premiumNature:self.spontaneousLossOfIgnitionStr premiumBody:self.scratchRiskStr premiumRepair:self.theSpecifiedServiceFactorySpecialInsuranceStr premiumWater:self.wadingInsuranceStr lossSpecial:self.lossSpecialStr thirdSpecial:self.thirdSpecialStr theftSpecial:self.theftSpecialStr dSeatSpecial:self.dSeatSpecialStr pSeatSpecial:self.pSeatSpecialStr fireSpecial:self.fireSpecialStr scratchSpecial:self.scratchSpecialStr waterSpecial:self.waterSpecialStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@===%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            NSString *sign=[responseObject objectForKey:@"sign"];
            [SupportingClass showAlertViewWithTitle:@"" message:@"您已提交成功" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self getAppInsuranceAppBuyListWith:sign];
                
            }];
            
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }
        
        
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];

    }];
}
#pragma mark-确定重新预约接口
-(void)getConfirmReAppoint
{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
//    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    
    [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceConfirmReAppointWithAccessToken:self.accessToken pid:self.pidStr company:self.insuranceCompanyLabel.text carId:self.carIDStr city:@"长沙市" licenseimg:self.licenseImgUrlStr identityImg:self.identityImgUrlStr sTime:self.strongInsuranceEffectiveDateTF.text bTime:self.effectiveDateOfCommercialInsuranceTF.text premiumSali:self.compulsoryInsuranceAndTravelTaxStr bDamage:self.vehicleDamageInsuranceStr bThief:self.robberAndTheftInsuranceStr bLiability:self.thirdPartyLiabilityInsuranceStr premiumGlass:self.breakageOfGlassStr driverSeat:self.driverLiabilityInsuranceStr passengerSeat:self.passengerLiabilityInsuranceStr premiumNature:self.spontaneousLossOfIgnitionStr premiumBody:self.scratchRiskStr premiumRepair:self.theSpecifiedServiceFactorySpecialInsuranceStr premiumWater:self.wadingInsuranceStr lossSpecial:self.lossSpecialStr thirdSpecial:self.thirdSpecialStr theftSpecial:self.theftSpecialStr dSeatSpecial:self.dSeatSpecialStr pSeatSpecial:self.pSeatSpecialStr fireSpecial:self.fireSpecialStr scratchSpecial:self.scratchSpecialStr waterSpecial:self.waterSpecialStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@===%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            NSString *sign=[responseObject objectForKey:@"sign"];
            [SupportingClass showAlertViewWithTitle:@"" message:@"您已提交成功" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                self.isReAppointment=YES;
                [self getAppInsuranceAppBuyListWith:sign];
            }];
            
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }
        
        
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        
    }];

}

-(void)getAppInsuranceAppBuyListWith:(NSString *)pid
{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceAppBuyListWithAccessToken:self.accessToken pid:pid success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            NSDictionary* insuranceDetail=[responseObject objectForKey:CDZKeyOfResultKey];
            InsuranceDetailsVC *vc=[InsuranceDetailsVC new];
            vc.detailDic=insuranceDetail;
            vc.pidStr=pid;
            if (self.isReAppointment==YES) {
                vc.isReAppointmentStr=@"重新预约";
            }
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
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
