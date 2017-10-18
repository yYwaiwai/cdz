//
//  ModifyPasswordVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/20.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ModifyPasswordVC.h"


@interface ModifyPasswordVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *oldPassWordView;

@property (weak, nonatomic) IBOutlet UITextField *oldPassWordTF;

@property (weak, nonatomic) IBOutlet UIView *nPassWordView;

@property (weak, nonatomic) IBOutlet UITextField *nPassWordTF;

@property (weak, nonatomic) IBOutlet UIView *passWordView;

@property (weak, nonatomic) IBOutlet UITextField *passWordTF;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ModifyPasswordVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_oldPassWordTF resignFirstResponder];
    [_nPassWordTF resignFirstResponder];
    [_passWordTF resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    self.title=@"修改密码";
    [self.submitButton.layer setCornerRadius:3.0];
    [self.submitButton.layer setMasksToBounds:YES];
    self.submitButton.titleLabel.alpha=0.5;
    [self.oldPassWordView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.nPassWordView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.passWordView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.oldPassWordTF||self.nPassWordTF||self.passWordTF) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.oldPassWordTF.text.length!=0&&self.nPassWordTF.text.length!=0&&self.passWordTF.text.length!=0) {
        self.submitButton.titleLabel.alpha=1;
        [self.submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.submitButton.titleLabel.alpha=0.5;
    }
}

- (IBAction)submitButtonClick {
    
    if(!_oldPassWordTF.text||[_oldPassWordTF.text isEqualToString:@""]){
        [ProgressHUDHandler showErrorWithStatus:@"请输入旧密码"  onView:nil completion:^{}];
        return;
    }else if(!_nPassWordTF.text||[_nPassWordTF.text isEqualToString:@""]){
        [ProgressHUDHandler showErrorWithStatus:@"请输入新密码"  onView:nil completion:^{}];
        return;
    }else if(!_passWordTF.text||[_passWordTF.text isEqualToString:@""]){
        [ProgressHUDHandler showErrorWithStatus:@"请输入二次新密码"  onView:nil completion:^{}];
        return;
    }else if(![_nPassWordTF.text isEqualToString:_passWordTF.text]){
        [ProgressHUDHandler showErrorWithStatus:@"两次密码不相同"  onView:nil completion:^{}];
        return;
    }
    
    [self updateUserPassword];
    
}

- (void)showLoadingInPickerSuperview:(NSString *)title {
    @autoreleasepool {
//        UIView *view = _toolbar.superview.superview;
//        if (view) {
//            [ProgressHUDHandler showHUDWithTitle:title onView:view];
//        }else {
        [ProgressHUDHandler showHUDWithTitle:title onView:nil];
//        }
    }
}

- (void)updateUserPassword {
    if (!vGetUserToken) return;
    [self showLoadingInPickerSuperview:@"更新密码中...."];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPostUserChangePasswordWithAccessToken:vGetUserToken oldPassword:_oldPassWordTF.text newPassword:_nPassWordTF.text newPasswordAgain:_passWordTF.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功"  onView:nil completion:^{
            [self.navigationController popViewControllerAnimated:YES];
            //            [self responseDataUpdate];
        }];
        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"更新密码失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
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
