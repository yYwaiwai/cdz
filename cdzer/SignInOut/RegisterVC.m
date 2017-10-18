//
//  RegisterVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RegisterVC.h"
#import "InsetsTextField.h"
#import "AFViewShaker.h"
#import "UserAgreementWithCdzVC.h"

@interface RegisterVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *messageBgView;

@property (weak, nonatomic) IBOutlet UIView *phoneTFBgView;

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UIView *passwordTFBgView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIView *againPasswordTFBgView;

@property (weak, nonatomic) IBOutlet UITextField *againPasswordTF;

@property (weak, nonatomic) IBOutlet InsetsTextField *verificationCodeTF;

@property (weak, nonatomic) IBOutlet ValidCodeButton *verificationCodeButton;//验证码按钮

@property (weak, nonatomic) IBOutlet UIControl *customerServiceControl;//客服电话

@property (weak, nonatomic) IBOutlet UIControl *readingProtocolControl;//阅读协议

@property (weak, nonatomic) IBOutlet UIButton *readingProtocolImageButton;//是否阅读协议的图片

@property (weak, nonatomic) IBOutlet UIButton *nextOneButton;//登录注册按钮

@property (weak, nonatomic) IBOutlet UIButton *userAgreementButton;//车队长用户协议
/// 文本警告
@property (nonatomic, weak) IBOutlet UILabel *textAlertLabel;

@property (weak, nonatomic) IBOutlet UITextField *invitationCodeTF;

@property (weak, nonatomic) IBOutlet UIView *invitationCodeContainerView;

/// 工具条
@property (nonatomic, strong) UIToolbar *toolBar;
/// 键盘的frame
@property (nonatomic, assign) CGRect keyboardRect; ///<键盘坐标组
/// 倒计时 时间
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AFViewShaker *viewShaker;

@end

@implementation RegisterVC

- (void)dealloc {
    self.viewShaker = nil;
    self.phoneTF = nil;
    self.passwordTF = nil;
    self.toolBar = nil;
    self.nextOneButton = nil;
    if (_timer && [_timer isValid]){
        [_timer invalidate];
        self.timer = nil;
    }
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.navBar.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.messageBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.phoneTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.passwordTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.invitationCodeContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.againPasswordTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"注册账号";
    [self initializationUI];
    self.nextOneButton.layer.masksToBounds=YES;
    self.nextOneButton.layer.cornerRadius=3.0;
}

- (void)initializationUI {
    @autoreleasepool {
        self.toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
        [_toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem * spaceButton = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:self
                                                                                      action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [_toolBar setItems:buttonsArray];
        
        
        [_phoneTF setInputAccessoryView:_toolBar];
        [_passwordTF setInputAccessoryView:_toolBar];
        [_againPasswordTF setInputAccessoryView:_toolBar];
        [_invitationCodeTF setInputAccessoryView:_toolBar];
        [_verificationCodeTF setInputAccessoryView:_toolBar];
        
        [_verificationCodeTF setKeyboardType:UIKeyboardTypeNumberPad];
        [_verificationCodeTF setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_verificationCodeTF setReturnKeyType:UIReturnKeyNext];
        [_verificationCodeTF setEnablesReturnKeyAutomatically:YES];
        
        self.viewShaker = [[AFViewShaker alloc] initWithView:self.view];
        [self.verificationCodeButton buttonSettingWithType:VCBTypeOfRegisterValid];
        
        [self.nextOneButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:0.5] forState:UIControlStateNormal];
        self.nextOneButton.enabled=NO;
        
        [_nextOneButton addTarget:self
                            action:@selector(submitRegister)
                  forControlEvents:UIControlEventTouchUpInside];
        
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.phoneTF];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
        if ([_phoneTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_phoneTF];
        }
        if ([_passwordTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_passwordTF];
        }
        if ([_againPasswordTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_againPasswordTF];
        }
        if ([_invitationCodeTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_invitationCodeTF];
        }
        if ([_verificationCodeTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_verificationCodeTF];
        }
    }
    
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
    self.scrollView.scrollEnabled = NO;
}

- (void)hiddenKeyboard {
    [self resignKeyboard];
    self.keyboardRect = CGRectZero;
    CGPoint point = CGPointZero;
    [self.scrollView setContentOffset:point animated:NO];
    self.scrollView.scrollEnabled = YES;
}

- (void)resignKeyboard {
    [_phoneTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    [_againPasswordTF resignFirstResponder];
    [_invitationCodeTF resignFirstResponder];
    [_verificationCodeTF resignFirstResponder];
}

- (void)showAlertLabel:(NSString *)message {
    if (_timer && [_timer isValid]){
        [_timer invalidate];
        self.timer = nil;
    }
    _textAlertLabel.text = message;
    @weakify(self)
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self)
        self.textAlertLabel.alpha = 1.0f;
    }completion:^(BOOL finished) {
        [self.viewShaker shake];
    }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(hideAlertLabel) userInfo:nil repeats:NO];
}

- (void)hideAlertLabel{
    if (_textAlertLabel.alpha != 0.0f) {
        [UIView animateWithDuration:0.25 animations:^{
            self.textAlertLabel.alpha = 0.0f;
        }];
    }
    if (_timer && [_timer isValid]){
        [_timer invalidate];
        self.timer = nil;
    }
}

#pragma mark- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self hideAlertLabel];
    if (!CGRectEqualToRect(CGRectZero, _keyboardRect)) {
        [self shiftScrollViewWithAnimation:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hiddenKeyboard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isEqualToString:@""]) {
        
        if (textField == self.phoneTF) {
            if (self.phoneTF.text.length>=11){
                [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"电话号码不可超过1１位"] onView:self.view completion:nil];
                return NO;
            }
        }
            }
        [self.nextOneButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:1.0] forState:UIControlStateNormal];
        self.nextOneButton.enabled=YES;

    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.passwordTF) {
        if (self.passwordTF.text.length < 6) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"密码不可小于６位"] onView:self.view completion:nil];
            return NO;
        }
        
    }
    if (textField == self.againPasswordTF) {
        if (self.againPasswordTF.text.length <6) {
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"确认密码号不可小于６位"] onView:self.view completion:nil];
            return NO;
        }
        
    }
    return YES;
}

/*手机号和固网电话验证*/
- (BOOL)isValidateMobile:(NSString *)mobile {
    NSString *phoneNFixLineRegex = @"^(((0\\d{2,3}|\\d{2,3})(-\\d{7,8}|\\d{7,8}))|(1[34578]\\d{9}))$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNFixLineRegex];
    return [phoneTest evaluateWithObject:mobile];
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    if (notiObj.object==self.phoneTF) {
        BOOL enabled = (self.phoneTF.text.length>=11);
        self.verificationCodeButton.isReady = enabled;
        self.verificationCodeButton.enabled = enabled;
        self.verificationCodeButton.userPhone = self.verificationCodeButton.enabled?@(self.phoneTF.text.longLongValue):nil;

    }
    
}
//验证码按钮
- (IBAction)verificationCodeClick:(id)sender {
}

//客服电话
- (IBAction)customerServiceClick:(id)sender {
     [SupportingClass makeACall:@"0731-88865777" andContents:@"%@\n是否拨打客服号码？" withTitle:nil];
}


//阅读协议
- (IBAction)readingProtocolClick:(id)sender {
    self.readingProtocolImageButton.selected=!self.readingProtocolImageButton.selected;
}


//车队长用户协议
- (IBAction)userAgreementClick:(id)sender {
    UserAgreementWithCdzVC *vc = [UserAgreementWithCdzVC new];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Loging Action Section
- (void)submitRegister {
    [self hiddenKeyboard];
    
    if (![self isValidateMobile:self.phoneTF.text]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的联系电话"] onView:self.view completion:nil];
        return;
    }
    if (self.passwordTF.text.length<6&&self.againPasswordTF.text.length<6) {
        if (![self.passwordTF.text isEqualToString:self.againPasswordTF.text]) {
            [self showAlertLabel:@"密码不相称"];
            return;
        }
    }
    
    [ProgressHUDHandler showHUD];
    if (!self.readingProtocolImageButton.selected) {
        [self showAlertLabel:@"阅读并勾选协议"];
        [ProgressHUDHandler dismissHUD];
        return;
    }
    @weakify(self)
    [UserBehaviorHandler.shareInstance userRegisterWithUserPhone:self.phoneTF.text validCode:self.verificationCodeTF.text password:self.passwordTF.text repassword:self.againPasswordTF.text invitationCode:self.invitationCodeTF.text success:^{
        @strongify(self)
        [UserBehaviorHandler.shareInstance userLoginWithUserPhone:self.phoneTF.text password:self.passwordTF.text success:^{
            [ProgressHUDHandler showSuccessWithStatus:getLocalizationString(@"register_success") onView:nil completion:^{
                @strongify(self)
                [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfTokenUpdate object:nil userInfo:@{@"result":@YES}];
                [self dismissViewControllerAnimated:YES completion:^{}];
                
            }];
        } failure:^(NSString *errorMessage, NSError *error) {
            [ProgressHUDHandler dismissHUD];
            @strongify(self)
            [self showAlertLabel:errorMessage];
        }];
    } failure:^(NSString *errorMessage, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        @strongify(self)
        [self showAlertLabel:errorMessage];
    }];
    
    
}

- (IBAction)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
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
