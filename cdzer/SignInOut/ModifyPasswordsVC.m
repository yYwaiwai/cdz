//
//  ModifyPasswordsVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ModifyPasswordsVC.h"
#import "InsetsTextField.h"
#import "AFViewShaker.h"

@interface ModifyPasswordsVC ()<UITextFieldDelegate>

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

@property (weak, nonatomic) IBOutlet UIButton *modifyPasswordButton;//立即修改
/// 文本警告
@property (nonatomic, weak) IBOutlet UILabel *textAlertLabel;

/// 工具条
@property (nonatomic, strong) UIToolbar *toolBar;
/// 键盘的frame
@property (nonatomic, assign) CGRect keyboardRect; ///<键盘坐标组
/// 倒计时 时间
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AFViewShaker *viewShaker;


@end

@implementation ModifyPasswordsVC

- (void)dealloc {
    self.viewShaker = nil;
    self.phoneTF = nil;
    self.passwordTF = nil;
    self.textAlertLabel = nil;
    self.toolBar = nil;
    self.modifyPasswordButton = nil;
    if (_timer && [_timer isValid]){
        [_timer invalidate];
        self.timer = nil;
    }
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.navBar.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.messageBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.phoneTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.passwordTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.againPasswordTFBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    self.title=@"修改密码";
    [self initializationUI];
    self.modifyPasswordButton.layer.masksToBounds=YES;
    self.modifyPasswordButton.layer.cornerRadius=3.0;
    self.modifyPasswordButton.titleLabel.alpha=0.5;
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
        [_verificationCodeTF setInputAccessoryView:_toolBar];
        
        [_verificationCodeTF setKeyboardType:UIKeyboardTypeNumberPad];
        [_verificationCodeTF setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_verificationCodeTF setReturnKeyType:UIReturnKeyNext];
        [_verificationCodeTF setEnablesReturnKeyAutomatically:YES];
        
        self.viewShaker = [[AFViewShaker alloc] initWithView:self.view];
        [self.verificationCodeButton buttonSettingWithType:VCBTypeOfPWForgetValid];
        
        [self.modifyPasswordButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:0.5] forState:UIControlStateNormal];
        self.modifyPasswordButton.enabled=NO;
        
        [_modifyPasswordButton addTarget:self
                           action:@selector(submitForgetPW)
                 forControlEvents:UIControlEventTouchUpInside];
        
        
    }
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
    if (self.phoneTF.text.length>=11&&self.passwordTF.text.length>=6&&self.againPasswordTF.text.length>=6&&self.verificationCodeTF.text.length) {
        [self.modifyPasswordButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:1.0] forState:UIControlStateNormal];
        self.modifyPasswordButton.enabled=YES;
    }
    
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    if (notiObj.object==self.phoneTF) {
        BOOL enabled = (self.phoneTF.text.length>=11);
        self.verificationCodeButton.isReady = enabled;
        self.verificationCodeButton.enabled = enabled;
        self.verificationCodeButton.userPhone = self.verificationCodeButton.enabled?@(self.phoneTF.text.longLongValue):nil;
        
    }
    
}

- (void)submitForgetPW {
    [self hiddenKeyboard];
    
    if (self.passwordTF.text.length>=6&&self.againPasswordTF.text.length>=6) {
        if (![self.passwordTF.text isEqualToString:self.againPasswordTF.text]) {
            [self showAlertLabel:@"密码不相称"];
            return;
        }
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self)
    [UserBehaviorHandler.shareInstance userForgotPasswordWithUserPhone:_phoneTF.text validCode:_verificationCodeTF.text password:_passwordTF.text repassword:_againPasswordTF.text success:^{
        [ProgressHUDHandler showSuccessWithStatus:getLocalizationString(@"pw_update_success") onView:nil completion:^{
            @strongify(self)
            [self dismissSelf];
        }];
    } failure:^(NSString *errorMessage, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        @strongify(self)
        [self showAlertLabel:errorMessage];
    }];
    
    
}

#pragma mark Private Action
- (IBAction)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
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
