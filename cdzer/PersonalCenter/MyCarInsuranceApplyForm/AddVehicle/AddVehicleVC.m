//
//  AddVehicleVC.m
//  cdzer
//
//  Created by 车队长 on 17/1/3.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "AddVehicleVC.h"
#import "LicensePlateSelectionView.h"
#import "UserAutosSelectonVC.h"
#import "MyCarVC.h"

@interface AddVehicleVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIControl *headViewControl;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *headLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UILabel *chooseTitleLabel;

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

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

//////
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@property (nonatomic, strong) UserAutosInfoDTO *userAutoInfo;

@property (nonatomic, assign) BOOL isAddCarMessage;

@property (nonatomic, strong) NSString *speciStr;

@property (nonatomic) CGRect keyboardRect;

@end

@implementation AddVehicleVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.fromStr isEqualToString:@"添加保险车辆"]) {
        [self checkUserAutoInfoExsit];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.ownerNameTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.frameNumberTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.engineNumberTF];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
//    if ([self.fromStr isEqualToString:@"完善车辆信息"]) {
//        [self pushToVehicleSelectedVC];
//        return;
//    }
//    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
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

-(void)viewDidLayoutSubviews
{
    CGFloat headImageViewHeight=self.headImageView.frame.size.height;
    [self.headImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:headImageViewHeight/2];
    [self.headImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    
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
    [self.commitButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
}


- (void)checkUserAutoInfoExsit {
    BOOL isExsit = NO;
    UserAutosInfoDTO *userAutoInfo = [DBHandler.shareInstance getUserAutosDetail];
    if (!_userAutoInfo) {
        if (![userAutoInfo.brandID isEqualToString:self.userAutoInfo.brandID]||
            ![userAutoInfo.dealershipID isEqualToString:self.userAutoInfo.dealershipID]||
            ![userAutoInfo.seriesID isEqualToString:self.userAutoInfo.seriesID]||
            ![userAutoInfo.modelID isEqualToString:self.userAutoInfo.modelID]||
            ![userAutoInfo.frameNumber isEqualToString:self.userAutoInfo.frameNumber]||
            ![userAutoInfo.engineCode isEqualToString:self.userAutoInfo.engineCode]||
            ![userAutoInfo.licensePlate isEqualToString:self.userAutoInfo.licensePlate]||
            ![userAutoInfo.registrTime isEqualToString:self.userAutoInfo.registrTime]) {
            self.userAutoInfo = userAutoInfo;
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
        }
        
    }
    
    if (isExsit) {
        NSMutableString *string = [NSMutableString string];
        [string appendFormat:@"%@ %@",self.userAutoInfo.seriesName, self.userAutoInfo.modelName];
        
        //                NSString *carNumber=self.userAutosInfoDTO.licensePlate;
        self.headLabel.text=[NSString stringWithFormat:@"%@",string];
        self.carNumberTF.text=self.userAutoInfo.licensePlate;
        if (self.carNumberTF.text.length>0) {
            [self.lpSelectionView initializeSettingFromLicensePlate:[self.carNumberTF.text substringFromIndex:2]];
            self.carNumberTF.text=[self.carNumberTF.text substringFromIndex:self.carNumberTF.text.length-5];
        }
        self.speciStr=self.userAutoInfo.modelID;
        self.frameNumberTF.text=self.userAutoInfo.frameNumber;
        self.engineNumberTF.text=self.userAutoInfo.engineCode;
        self.carNumberTF.enabled=NO;
        self.frameNumberTF.enabled=NO;
        self.engineNumberTF.enabled=NO;
        self.lpSelectionView.userInteractionEnabled=NO;
        self.headViewControl.userInteractionEnabled=NO;
        NSString *imgURLString = self.userAutoInfo.brandImgURL;
        self.headImageView.image = [ImageHandler getDefaultWhiteLogo];
        if ([imgURLString rangeOfString:@"http"].location!=NSNotFound) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURLString] placeholderImage:[ImageHandler getDefaultWhiteLogo]];

        }
//        [ProgressHUDHandler showHUD];
//        [self performSelector:@selector(showEditAutoInfoDetailVC) withObject:nil afterDelay:0.8];
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

//选择车型
- (void)pushToVehicleSelectedVC {
    @weakify(self);
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:YES andSelectionResultBlock:^(UserSelectedAutosInfoDTO *selectedAutosDto) {
        @strongify(self);
        NSString*seriesName = selectedAutosDto.seriesName;
        NSString*modelName = selectedAutosDto.modelName;
        NSString *imgURL = selectedAutosDto.brandImgURL;
        self.speciStr=selectedAutosDto.modelID;
        if ([imgURL containsString:@"http"]) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        self.headLabel.text = [NSString stringWithFormat:@"%@ %@",seriesName,modelName];
        
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"添加车辆";
    
    if (!_isAddCarMessage) {
        [self.headViewControl addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
    }

    
    if (self.isShowCancelBtn) {
        [self setLeftNavButtonWithTitleOrImage:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelFormEdit) titleColor:nil isNeedToSet:YES];
    }
    
    [self.lpSelectionView initializeSettingFromLicensePlate:@"湘A"];
    [self.lpSelectionView setTitleColor:[UIColor colorWithHexString:@"49c7f5"]];
    [self initializationUI];
}

- (void)cancelFormEdit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializationUI {
    @autoreleasepool {
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        
        
        
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



//- (IBAction)dateOfRegistrationControlClick:(UIControl *)sender {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择注册登记日期"
//                                                                             message:nil
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:getLocalizationString(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//    }];
//    [alertController addAction:cancelAction];
//    
//    @weakify(alertController);
//    @weakify(self);
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:getLocalizationString(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//        @strongify(alertController);
//        @strongify(self);
//        UITextField *textField = alertController.textFields.firstObject;
//        self.start2DriveDateTime = textField.text;
//        self.dateOfRegistrationLabel.text = self.start2DriveDateTime;
//    }];
//    [alertController addAction:okAction];
//    
//    
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        @strongify(self);
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
//        textField.placeholder = @"请选择注册登记日期";
//        textField.keyboardType =UIKeyboardTypeNumberPad;
//        textField.delegate = self;
//        textField.inputView = self.datePicker;
//        textField.inputAccessoryView = self.toolbar;
//        textField.accessibilityIdentifier = @"dateTime";
//        self.datePicker.date = NSDate.date;
//        NSDate *selectedDate = [self.dateFormatter dateFromString:self.start2DriveDateTime];
//        if (selectedDate) {
//            self.datePicker.date = selectedDate;
//        }
//        textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
//        self.datePicker.maximumDate = NSDate.date;
//    }];
//    [self.navigationController presentViewController:alertController animated:YES completion:nil];
//    
//}
//
//- (void)alertTextFieldDidChange:(NSNotification *)notiObj {
//    UIAlertController *alertController = (UIAlertController *)self.navigationController.presentedViewController;
//    if (alertController) {
//        UITextField *textField = alertController.textFields.firstObject;
//        UIAlertAction *okAction = alertController.actions.lastObject;
//        okAction.enabled = (textField.text.length>0);
//        if (textField.text.length>7) {
//            textField.text = [textField.text substringToIndex:7];
//        }
//    }
//}
//
//- (void)datePickerValueChange:(UIDatePicker *)datePicker {
//    UIAlertController *alertController = (UIAlertController *)self.navigationController.presentedViewController;
//    if (alertController) {
//        UITextField *textField = alertController.textFields.firstObject;
//        textField.text = [self.dateFormatter stringFromDate:datePicker.date];
//        [textField sendActionsForControlEvents:UIControlEventValueChanged];
//    }
//}
//
//- (void)resignAlertTextFieldFirstResponder {
//    UIAlertController *alertController = (UIAlertController *)self.navigationController.presentedViewController;
//    if (alertController) {
//        UITextField *textField = alertController.textFields.firstObject;
//        [textField resignFirstResponder];
//    }
//}


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
    if (textField==self.contactNumberTF) {
        NSUInteger length = textField.text.length;
        if (length==11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.carNumberTF) {
        NSUInteger length = textField.text.length;
        if (length==5&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.frameNumberTF) {
        NSUInteger length = textField.text.length;
        if (length==17&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.engineNumberTF) {
        NSUInteger length = textField.text.length;
        if (length==17&&![string isEqualToString:@""]) {
            return NO;
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



/*车牌号验证*/
- (BOOL)validateCarNo:(NSString*)carNo {
    NSString *carRegex=@"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}
/*手机号和固网电话验证*/
- (BOOL)isValidateMobile:(NSString *)mobile {
    NSString *phoneNFixLineRegex = @"^(((0\\d{2,3}|\\d{2,3})(-\\d{7,8}|\\d{7,8}))|(1[34578]\\d{9}))$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNFixLineRegex];
    return [phoneTest evaluateWithObject:mobile];
}
//提交
- (IBAction)commitButtonClick:(id)sender {
    NSString *carNumber=[NSString stringWithFormat:@"%@%@",self.lpSelectionView.combineString,self.carNumberTF.text];
    if (self.speciStr.length==0||self.ownerNameTF.text.length==0||![self isValidateMobile:self.contactNumberTF.text]||self.carNumberTF.text.length==0||![self validateCarNo:carNumber]||self.frameNumberTF.text.length==0||self.engineNumberTF.text.length==0||self.dateOfRegistrationTF.text.length==0) {
        
        if (self.speciStr.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请选择车辆信息"] onView:self.view completion:nil];
            return;
        }
        if (self.ownerNameTF.text.length==0) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入车主姓名"] onView:self.view completion:nil];
            return;
        }
        if (![self isValidateMobile:self.contactNumberTF.text]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的联系电话"] onView:self.view completion:nil];
            return;
        }
        if (![self validateCarNo:carNumber]) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的车牌号码"] onView:self.view completion:nil];
            return;
        }
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


- (void)submitAutoInsuranceInfoAppPremiumAddCar {
    if (!self.accessToken) {
        return;
    }
    @autoreleasepool {
        
        NSString *carNumberStr=[NSString stringWithFormat:@"%@%@",self.lpSelectionView.combineString,self.carNumberTF.text];
        
        [ProgressHUDHandler showHUD];
        @weakify(self);
        [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppPremiumAddCarWithAccessToken:self.accessToken phoneNo:self.contactNumberTF.text city:@"长沙市" realname:self.ownerNameTF.text speci:self.speciStr frameNo:self.frameNumberTF.text enginecode:self.engineNumberTF.text registertime:self.dateOfRegistrationTF.text carCumber:carNumberStr success:^(NSURLSessionDataTask *operation, id responseObject) {
            [ProgressHUDHandler dismissHUD];
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@=-=%@",message,operation);
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
                    [self.navigationController popViewControllerAnimated:YES];

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
