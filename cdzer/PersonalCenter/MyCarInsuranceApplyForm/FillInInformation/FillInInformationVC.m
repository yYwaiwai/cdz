//
//  FillInInformationVC.m
//  cdzer
//
//  Created by 车队长 on 17/1/3.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "FillInInformationVC.h"
#import "LicensePlateSelectionView.h"
#import "AddVehicleVC.h"
#import "MyCarInsuranceApplyFormVC.h"
#import "MyCarVC.h"
#import "UserAutosSelectonVC.h"

@interface FillInInformationVC ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carMessagBGViewLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *changeCarBGViewLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIControl *carMessageControl;

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

@property (weak, nonatomic) IBOutlet UILabel *carMessageLabel;


@property (weak, nonatomic) IBOutlet UIView *changeCarView;

@property (weak, nonatomic) IBOutlet UILabel *vehicleSystemLabel;//车型车系

@property (weak, nonatomic) IBOutlet UIButton *changeCarButton;

@property (weak, nonatomic) IBOutlet UIButton *addCarButton;


@property (weak, nonatomic) IBOutlet UIControl *insuranceCityControl;
////////
@property (weak, nonatomic) IBOutlet UIView *ownerMessageBGView;

@property (weak, nonatomic) IBOutlet UIView *ownerNameView;

@property (weak, nonatomic) IBOutlet UITextField *ownerNameTF;//车主姓名

@property (weak, nonatomic) IBOutlet UIView *contactNumberBGView;

@property (weak, nonatomic) IBOutlet UITextField *contactNumberTF;//联系电话

@property (weak, nonatomic) IBOutlet UIView *carMessageBGView;

@property (weak, nonatomic) IBOutlet UIView *carNumberView;

@property (strong, nonatomic) IBOutlet LicensePlateSelectionView *lpSelectionView;

@property (weak, nonatomic) IBOutlet UITextField *carNumberTF;//车牌号

@property (weak, nonatomic) IBOutlet UIView *frameNumberView;

@property (weak, nonatomic) IBOutlet UITextField *frameNumberTF;//车架号

@property (weak, nonatomic) IBOutlet UIView *engineNumberView;

@property (weak, nonatomic) IBOutlet UITextField *engineNumberTF;//发动机号

@property (weak, nonatomic) IBOutlet UIControl *dateOfRegistrationBGView;

@property (weak, nonatomic) IBOutlet UILabel *dateOfRegistrationLabel;//注册登记日期
@property (weak, nonatomic) IBOutlet UITextField *dateOfRegistrationTF;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

///////
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *carInfoArr;

@property (nonatomic, strong) NSMutableArray *carNumberArr;

@property (nonatomic, strong) UIPickerView *carNumberPickerView;

@property (nonatomic, strong) UIToolbar * pickerViewToolBar;

@property (nonatomic, strong) UIView *pickerBGView;

@property (nonatomic, strong) NSString * carNumberString;

@property (nonatomic, strong) NSString * carIDString;

@property (nonatomic, strong) UserAutosInfoDTO *userAutosInfoDTO;

@property (nonatomic, strong) NSString * errorCodeStr;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;

@property (nonatomic, assign) BOOL isChangeCarMessage;

@property (nonatomic) CGRect keyboardRect;

@property (nonatomic, strong) NSString *carInfoDataOwnerNameStr;
@property (nonatomic, strong) NSString *carInfoDataContactNumberStr;
@property (nonatomic, strong) NSString *carInfoDataSpeciStr;

@end

@implementation FillInInformationVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.ownerNameTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    [self getUserAutosInsuranceMyInurancelist];
    [self getUserAutosInsuranceChangeCarNumber];
    
    if ([self.errorCodeStr isEqualToString:@"1"]) {
        UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
        if (!self.autosSelectedData||
            ![self.autosSelectedData.brandID isEqualToString:@""]||
            ![self.autosSelectedData.dealershipID isEqualToString:@""]||
            ![self.autosSelectedData.seriesID isEqualToString:@""]||
            ![self.autosSelectedData.modelID isEqualToString:@""]) {
            self.autosSelectedData = autosData;
            self.isChangeCarMessage=YES;
        }
        
        
    }
    
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
    self.title=@"填写信息";
    [self.lpSelectionView initializeSettingFromLicensePlate:@"湘A"];
    [self.lpSelectionView setTitleColor:[UIColor colorWithHexString:@"49c7f5"]];
    [self initializationUI];
}

- (void)initializationUI {
    @autoreleasepool {
        self.carInfoArr=[NSMutableArray new];
        self.carNumberArr=[NSMutableArray new];
        
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
        
        self.dateOfRegistrationTF.inputView = self.datePicker;
        self.dateOfRegistrationTF.inputAccessoryView = self.toolbar;
       

    }
}


-(void)viewDidLayoutSubviews
{
    [self.changeCarButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    [self.addCarButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    [self.changeCarButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:CDZColorOfWhite withBroderOffset:nil];
    [self.addCarButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:CDZColorOfWhite withBroderOffset:nil];
    [self.lpSelectionView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    [self.lpSelectionView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    [self.insuranceCityControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.ownerMessageBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.ownerNameView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.contactNumberBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.carMessageBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.carNumberView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.frameNumberView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.engineNumberView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.dateOfRegistrationBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.nextButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
}
//更换车辆
- (IBAction)changeCarButtonClick:(id)sender {
    if (self.carNumberArr.count>0) {
        [self upPickerViewUI];
    }
}


//添加车辆
- (IBAction)addCarButtonClick:(id)sender {
    AddVehicleVC*vc=[AddVehicleVC new];
    if ([self.errorCodeStr isEqualToString:@"1"]) {
        vc.fromStr=@"添加保险车辆";
    }
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    
}
//注册登记时间
- (void)hiddenKeyboard {
    self.start2DriveDateTime = self.dateOfRegistrationTF.text;
    [self.dateOfRegistrationTF resignFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    self.keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *textField = nil;
    if (self.ownerNameTF.isFirstResponder) {
        textField = self.ownerNameTF;
    }
    if (self.carNumberTF.isFirstResponder) {
        textField = self.carNumberTF;
    }
    if (self.frameNumberTF.isFirstResponder) {
        textField = self.frameNumberTF;
    }
    if (self.engineNumberTF.isFirstResponder) {
        textField = self.engineNumberTF;
    }
    if (self.contactNumberTF.isFirstResponder) {
        textField = self.contactNumberTF;
    }
    if (self.dateOfRegistrationTF.isFirstResponder) {
        textField = self.dateOfRegistrationTF;
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
    self.dateOfRegistrationTF.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.dateOfRegistrationTF==textField){
        NSDate *date = NSDate.date;//[NSDate dateWithTimeInterval:(2*60*60) sinceDate:NSDate.date];
        if (!self.dateOfRegistrationTF.text||[self.dateOfRegistrationTF.text isEqualToString:@""]) {
            self.start2DriveDateTime = [self.dateFormatter stringFromDate:date];
            self.dateOfRegistrationTF.text = self.start2DriveDateTime;
        }
        self.datePicker.maximumDate = date;
        self.datePicker.date = [self.dateFormatter dateFromString:self.start2DriveDateTime];
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.dateOfRegistrationTF==textField) {
        self.dateOfRegistrationTF.text = self.start2DriveDateTime;
    }
}

-(void)cancelAction{
    [self.pickerBGView removeFromSuperview];
    [self.pickerViewToolBar removeFromSuperview];
    [self.carNumberPickerView removeFromSuperview];
    
}

-(void)finishAction{
    [self.pickerBGView removeFromSuperview];
    [self.pickerViewToolBar removeFromSuperview];
    [self.carNumberPickerView removeFromSuperview];
    if (self.carNumberString.length==0) {
        self.carNumberString=self.carNumberArr.firstObject;
    }
    [self changeCarUpData];
}

#pragma mark- UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (!self.carNumberArr) return 0;
    return self.carNumberArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *string = self.carNumberArr[row];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.carNumberString = _carNumberArr[row];
}



-(void)upPickerViewUI
{
    self.pickerBGView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.pickerBGView.backgroundColor=[UIColor colorWithHexString:@"323232" alpha:0.5];
    [self.view addSubview:self.pickerBGView];
    self.carNumberPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-150.0, CGRectGetWidth(self.view.frame), 150)];
    self.carNumberPickerView.dataSource = self;
    self.carNumberPickerView.delegate = self;
//    self.carNumberPickerView.showsSelectionIndicator = YES;
    self.carNumberPickerView.backgroundColor=CDZColorOfWhite;
    self.pickerViewToolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.carNumberPickerView.frame)-40, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [self.pickerViewToolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *finishBtn=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishAction)];
    UIBarButtonItem *cancelBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction)];
    finishBtn.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
    cancelBtn.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
    UIBarButtonItem *flexible=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSArray *btnArr=[[NSArray alloc]initWithObjects:cancelBtn,flexible,finishBtn, nil];
    [self.pickerViewToolBar setItems:btnArr];
    
    [self.pickerBGView addSubview:self.pickerViewToolBar];
    [self.pickerBGView addSubview:self.carNumberPickerView];
}

-(void)changeCarUpData{
    for (NSDictionary *obj in self.carInfoArr) {
        NSString *carNumber=obj[@"car_number"];
        if ([self.carNumberString isEqualToString:carNumber]) {
            self.vehicleSystemLabel.text=[NSString stringWithFormat:@"车型车系：%@",obj[@"speci_name"]];
            self.ownerNameTF.text=obj[@"real_name"];
            self.contactNumberTF.text=obj[@"phone_no"];
            self.carNumberTF.text=obj[@"car_number"];
            if (self.carNumberTF.text.length>0) {
                [self.lpSelectionView initializeSettingFromLicensePlate:[self.carNumberTF.text substringFromIndex:2]];
                self.carNumberTF.text=[self.carNumberTF.text substringFromIndex:self.carNumberTF.text.length-5];
            }
            
            self.frameNumberTF.text=obj[@"frame_no"];
            self.engineNumberTF.text=obj[@"engine_code"];
            self.dateOfRegistrationTF.text=obj[@"register_time"];
            self.carIDString=obj[@"id"];
        }
    }
}

//下一步
- (IBAction)nextButtonClick:(id)sender {
    if ([self.errorCodeStr isEqualToString:@"1"]||![self.ownerNameTF.text isEqualToString:self.carInfoDataOwnerNameStr]||![self.contactNumberTF.text isEqualToString:self.carInfoDataContactNumberStr]) {
        [self addCarVCDate];
        
    }else{
        if (self.carIDString.length>0) {
            MyCarInsuranceApplyFormVC *vc=[MyCarInsuranceApplyFormVC new];
            vc.carIDStr=self.carIDString;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [SupportingClass showAlertViewWithTitle:@"" message:@"请选择要预约保险的车辆！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
        }

    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    if (textField==self.contactNumberTF) {
        if (textField.text.length==0&&![string isEqualToString:@"1"]) {
            return NO;
        }
        
        NSUInteger length = textField.text.length;
        if (length==11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    
    if (![string isEqualToString:@""]) {
        if (textField==self.contactNumberTF) {
            NSUInteger length = textField.text.length;
            if (length==17&&![string isEqualToString:@""]) {
                return NO;
            }
        }
      
    }
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    UITextField *textField = (UITextField *)notiObj.object;
    NSUInteger maxLenght = 17;
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage];
    if ([lang isContainsString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length>maxLenght) {
                textField.text = [toBeString substringToIndex:maxLenght];
            }
        }else {
            
        }
    }else {
        if (toBeString.length>maxLenght) {
            textField.text = [toBeString substringToIndex:maxLenght];
        }
    }
    if ([textField.text isContainsString:@" "]){
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }

}

///*车牌号验证*/
//- (BOOL)validateCarNo:(NSString*)carNo {
//    NSString *carRegex=@"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
//    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
//    return [carTest evaluateWithObject:carNo];
//}
/*手机号和固网电话验证*/
- (BOOL)isValidateMobile:(NSString *)mobile {
    NSString *phoneNFixLineRegex = @"^(((0\\d{2,3}|\\d{2,3})(-\\d{7,8}|\\d{7,8}))|(1[34578]\\d{9}))$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNFixLineRegex];
    return [phoneTest evaluateWithObject:mobile];
}

-(void)addCarVCDate{
    NSString *carNumber=[NSString stringWithFormat:@"%@%@",self.lpSelectionView.combineString,self.carNumberTF.text];
    if (self.ownerNameTF.text.length==0||![self isValidateMobile:self.contactNumberTF.text]||self.carNumberTF.text.length==0||self.frameNumberTF.text.length==0||self.engineNumberTF.text.length==0||self.dateOfRegistrationTF.text.length==0) {
        if (self.ownerNameTF.text.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入车主姓名"] onView:self.view completion:nil];
            return;
        }
        if (![self isValidateMobile:self.contactNumberTF.text]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的联系电话"] onView:self.view completion:nil];
            return;
        }
        
//        if (![self isValidateMobile:carNumber]) {
//            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的车牌号码"] onView:self.view completion:nil];
//            return;
//        }
        if (self.frameNumberTF.text.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入车架号"] onView:self.view completion:nil];
            return;
        }
        
        if (self.engineNumberTF.text.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入发动机号"] onView:self.view completion:nil];
            return;
        }
        
        if (self.dateOfRegistrationTF.text.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择注册登记日期"] onView:self.view completion:nil];
            return;
        }
        
        
    }
    [self submitAutoInsuranceInfoAppPremiumAddCar];
    
}

-(void)carMessageControlData{
    [self.carImageView.layer setCornerRadius:22.5];
    [self.carImageView.layer setMasksToBounds:YES];
    [self.carImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@ %@",self.userAutosInfoDTO.seriesName, self.userAutosInfoDTO.modelName];
    [self.carImageView sd_setImageWithURL:[NSURL URLWithString:self.userAutosInfoDTO.brandImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    self.carMessageLabel.text = self.userAutosInfoDTO.modelName;
    if (self.isChangeCarMessage==YES) {
        NSMutableString *string = [NSMutableString string];
        [string appendFormat:@"%@ %@",self.autosSelectedData.seriesName, self.autosSelectedData.modelName];
        [self.carImageView sd_setImageWithURL:[NSURL URLWithString:self.autosSelectedData.brandImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        self.carMessageLabel.text = self.autosSelectedData.modelName;
    }
    [self.carMessageControl addTarget:self action:@selector(headViewControlClick) forControlEvents:UIControlEventTouchUpInside];
    self.carMessageControl.hidden=NO;
    self.changeCarView.hidden=YES;
}

- (void)headViewControlClick {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


// 点击首页的预约保险
- (void)getUserAutosInsuranceMyInurancelist {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceMyInurancelistWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        self.errorCodeStr=[NSString stringWithFormat:@"%ld",(long)errorCode];
        NSLog(@"%@===%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        self.dateOfRegistrationBGView.userInteractionEnabled=NO;
        UserAutosInfoDTO *autosData = [DBHandler.shareInstance getUserAutosDetail];;
        if (!self.userAutosInfoDTO||
            [self.userAutosInfoDTO.brandID isEqualToString:@""]||
            [self.userAutosInfoDTO.dealershipID isEqualToString:@""]||
            [self.userAutosInfoDTO.seriesID isEqualToString:@""]||
            [self.userAutosInfoDTO.modelID isEqualToString:@""]) {
            self.userAutosInfoDTO = autosData;
        }
        if (errorCode==0) {
            self.carMessageControl.hidden=YES;
            self.changeCarView.hidden=NO;
            self.carMessagBGViewLayoutConstraint.constant=80;
            self.changeCarBGViewLayoutConstraint.constant=80;
            NSDictionary *carInfoData = responseObject[@"car_info"];
            self.vehicleSystemLabel.text=[NSString stringWithFormat:@"车型车系：%@ %@",carInfoData[@"fct_name"],carInfoData[@"speci_name"]];
            self.ownerNameTF.text=carInfoData[@"real_name"];
            self.contactNumberTF.text=carInfoData[@"phone_no"];
            self.carNumberTF.text=carInfoData[@"car_number"];
            self.carInfoDataOwnerNameStr=carInfoData[@"real_name"];
            self.carInfoDataContactNumberStr=carInfoData[@"phone_no"];
            self.carInfoDataSpeciStr=carInfoData[@"speci"];
            if (self.carNumberTF.text.length>0) {
                [self.lpSelectionView initializeSettingFromLicensePlate:[self.carNumberTF.text substringFromIndex:2]];
                self.carNumberTF.text=[self.carNumberTF.text substringFromIndex:self.carNumberTF.text.length-5];
            }
            self.frameNumberTF.text=carInfoData[@"frame_no"];
            self.engineNumberTF.text=carInfoData[@"engine_code"];
            self.dateOfRegistrationTF.text=carInfoData[@"register_time"];
            self.carIDString=carInfoData[@"id"];
        }else{
            if (errorCode==3) {
                self.carMessageControl.hidden=YES;
                self.changeCarView.hidden=NO;
                [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue>0) {
                        MyCarVC*vc=[MyCarVC new];
                        [self setDefaultNavBackButtonWithoutTitle];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                                    }];
                
            }
            if (errorCode==1) {
                
                self.carMessagBGViewLayoutConstraint.constant=63;
                self.changeCarBGViewLayoutConstraint.constant=63;
                [self carMessageControlData];
                NSMutableString *string = [NSMutableString string];
                [string appendFormat:@"%@ %@",self.userAutosInfoDTO.seriesName, self.userAutosInfoDTO.modelName];
                self.vehicleSystemLabel.text=[NSString stringWithFormat:@"车型车系：%@",string];
                self.carNumberTF.text=self.userAutosInfoDTO.licensePlate;
                if (self.carNumberTF.text.length>0) {
                    [self.lpSelectionView initializeSettingFromLicensePlate:[self.carNumberTF.text substringFromIndex:2]];
                    self.carNumberTF.text=[self.carNumberTF.text substringFromIndex:self.carNumberTF.text.length-5];
                }
                self.frameNumberTF.text=self.userAutosInfoDTO.frameNumber;
                self.engineNumberTF.text=self.userAutosInfoDTO.engineCode;
                self.dateOfRegistrationBGView.userInteractionEnabled=YES;

                return;
            }
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

// 更换车辆
- (void)getUserAutosInsuranceChangeCarNumber {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceChangeCarNumberWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@===%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            if (self.carNumberArr.count>0) {
                [self.carNumberArr removeAllObjects];
            }
            self.carInfoArr = [responseObject objectForKey:@"car_info"];
            [self.carNumberArr addObject:@""];
            for (NSDictionary *obj in self.carInfoArr) {
                [self.carNumberArr addObject:[obj objectForKey:@"car_number"]];
            }
            
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

// 添加保险车辆
- (void)submitAutoInsuranceInfoAppPremiumAddCar {
    if (!self.accessToken) {
        return;
    }
    @autoreleasepool {
        
        NSString *carNumberStr=[NSString stringWithFormat:@"%@%@",self.lpSelectionView.combineString,self.carNumberTF.text];
        
        [ProgressHUDHandler showHUD];
//        NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",self.ownerNameTF.text,self.contactNumberTF.text,carNumberStr,self.frameNumberTF.text,self.engineNumberTF.text,self.dateOfRegistrationTF.text,self.accessToken,self.userAutosInfoDTO.modelID);
        @weakify(self);
        [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppPremiumAddCarWithAccessToken:self.accessToken phoneNo:self.contactNumberTF.text city:@"长沙市" realname:self.ownerNameTF.text speci:self.userAutosInfoDTO.modelID frameNo:self.frameNumberTF.text enginecode:self.engineNumberTF.text registertime:self.dateOfRegistrationTF.text carCumber:carNumberStr success:^(NSURLSessionDataTask *operation, id responseObject) {
            [ProgressHUDHandler dismissHUD];
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@=-=%@",message,operation.currentRequest.URL.absoluteString);
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                return;
            }
            @strongify(self);
            [ProgressHUDHandler dismissHUD];
            if(errorCode!=0){
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
                }];
                return;
            }else{
                if(errorCode==0){
                    self.carIDString=[responseObject objectForKey:@"sign"];
                    if (self.carIDString.length>0) {
                        MyCarInsuranceApplyFormVC *vc=[MyCarInsuranceApplyFormVC new];
                        vc.carIDStr=self.carIDString;
                        [self setDefaultNavBackButtonWithoutTitle];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
            }
            
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
