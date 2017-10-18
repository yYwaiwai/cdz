//
//  SignInVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SignInVC.h"
#import "RegisterVC.h"
#import "ModifyPasswordsVC.h"

#import "InsetsTextField.h"
#import "AFViewShaker.h"
#import "UserAutosInfoDTO.h"
#import "UserInfosDTO.h"

@interface SignInVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;//用户头像

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UITextField *passWordTF;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;//登录button

@property (weak, nonatomic) IBOutlet UIButton *registerButton;//注册

@property (weak, nonatomic) IBOutlet UIButton *forgetPassword;//忘记密码

@property (weak, nonatomic) IBOutlet UIButton *customerServiceTelephone;//客服电话

@property (weak, nonatomic) IBOutlet UIView *messageBgView;

@property (weak, nonatomic) IBOutlet UIView *telBgView;
/// 文本警告标签
@property (weak, nonatomic) IBOutlet UILabel *textAlertLabel;

/// 用户输入账户密码出错的震动视图
@property (nonatomic, strong) AFViewShaker *viewShaker;

/// 键盘的frame
@property (nonatomic, assign) CGRect keyboardRect; ///<键盘坐标组
/// 工具条
@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, copy) ULVCLoginCancelResposeBlock cancelBlock;

/// 时间
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UserInfosDTO *userInfoDTO;

@end

@implementation SignInVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.messageBgView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:CDZColorOfWhite withBroderOffset:nil];
    [self.telBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfWhite withBroderOffset:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
        if ([_phoneTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_phoneTF];
        }else if ([_passWordTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_passWordTF];
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
    [_passWordTF resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializationUI];
    
}

- (void)initializationUI {
    self.signInButton.layer.cornerRadius=4.0;
    self.signInButton.layer.masksToBounds=YES;
    self.messageBgView.layer.cornerRadius=2.0;
    self.messageBgView.layer.masksToBounds=YES;

    self.signInButton.enabled=NO;
    
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
    [_passWordTF setInputAccessoryView:_toolBar];
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:_phoneTF.placeholder];
    [placeholder addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:NSMakeRange(0, _phoneTF.placeholder.length)];
    [placeholder addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:12]
                       range:NSMakeRange(0, _phoneTF.placeholder.length)];
    _phoneTF.attributedPlaceholder = placeholder;
    
    NSMutableAttributedString *passWordTFPlaceholder = [[NSMutableAttributedString alloc]initWithString:_passWordTF.placeholder];
    [passWordTFPlaceholder addAttribute:NSForegroundColorAttributeName
                        value:[UIColor whiteColor]
                        range:NSMakeRange(0, _passWordTF.placeholder.length)];
    [passWordTFPlaceholder addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12]
                        range:NSMakeRange(0, _passWordTF.placeholder.length)];
    _passWordTF.attributedPlaceholder = passWordTFPlaceholder;
    self.userInfoDTO =  [DBHandler.shareInstance getUserInfo];

    if (self.userInfoDTO.telphone.length>0) {
        _phoneTF.text=self.userInfoDTO.telphone;
    }
}

#pragma mark Private Action
- (IBAction)dismissSelf {
    @weakify(self)
    if (self.accessToken||[UserBehaviorHandler.shareInstance.getUserID isEqualToString:@"0"]) {
        [UserBehaviorHandler.shareInstance userLogoutWasPopupDialog:NO andCompletionBlock:^{
            @strongify(self)
            if (self.cancelBlock) self.cancelBlock();
            [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfTokenUpdate object:nil userInfo:@{@"result":@NO}];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfTokenUpdate object:nil userInfo:@{@"result":@NO}];
        [self dismissViewControllerAnimated:YES completion:^{}];
        
    }
}

- (void)setCancelLoginResponseBlock:(ULVCLoginCancelResposeBlock)cancelBlock {
    self.cancelBlock = nil;
    self.cancelBlock = cancelBlock;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.phoneTF.text.length>=11&&self.passWordTF.text.length>=5) {
        [self.signInButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:1] forState:UIControlStateNormal];
        self.signInButton.enabled=YES;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.phoneTF.text.length>=11&&self.passWordTF.text.length>=5) {
        [self.signInButton setTitleColor:[UIColor colorWithHexString:@"ffffff" alpha:1] forState:UIControlStateNormal];
        self.signInButton.enabled=YES;
    }
}
#pragma mark- Loging Action Section  登录
- (IBAction)submitLogin:(id)sender {
    [self hiddenKeyboard];
    if (self.phoneTF.text.length==0) {
        [ProgressHUDHandler showErrorWithStatus:@"请填写手机号码" onView:self.view completion:nil];
        return;
    }
    if (self.passWordTF.text.length==0) {
        [ProgressHUDHandler showErrorWithStatus:@"请填写登录密码" onView:self.view completion:nil];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self)
    [UserBehaviorHandler.shareInstance userLoginWithUserPhone:_phoneTF.text password:_passWordTF.text success:^{
        [ProgressHUDHandler showSuccessWithStatus:getLocalizationString(@"login_success") onView:nil completion:^{
            @strongify(self)
            [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfTokenUpdate object:nil userInfo:@{@"result":@YES}];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }];
    } failure:^(NSString *errorMessage, NSError *error) {
        @strongify(self)
        [ProgressHUDHandler dismissHUD];
        [self showAlertLabel:errorMessage];
    }];
    
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(hiddenAlertLabel) userInfo:nil repeats:NO];
}

- (void)hiddenAlertLabel{
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
//注册
- (IBAction)registerButtonClick:(id)sender {
    RegisterVC *vc = [RegisterVC new];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

//忘记密码
- (IBAction)forgetPasswordClick:(id)sender {
    ModifyPasswordsVC *vc = [ModifyPasswordsVC new];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

//客服电话
- (IBAction)customerServiceTelephoneClick:(id)sender {
    
//     [SupportingClass makeACall:UserBehaviorHandler.shareInstance.getCSHotline andContents:@"%@\n是否拨打客服号码？" withTitle:nil];
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
