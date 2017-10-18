//
//  BasicInformationVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/20.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "BasicInformationVC.h"
#import "ModifyPasswordVC.h"
#import "NetProgressImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface BasicInformationVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;

@property (weak, nonatomic) IBOutlet UIControl *headImageControl;
/// 头像视图
@property (weak, nonatomic) IBOutlet NetProgressImageView *headPortraitImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;


@property (weak, nonatomic) IBOutlet UIButton *cancellationButton;

@property (weak, nonatomic) IBOutlet UIView *nView;

@property (weak, nonatomic) IBOutlet UIView *ncView;

@property (weak, nonatomic) IBOutlet UIControl *xbView;

@property (weak, nonatomic) IBOutlet UIView *sjView;

@property (weak, nonatomic) IBOutlet UIControl *xgView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topMainViewHeightConstraint;

/// old用户信息
@property (nonatomic, strong) UserInfosDTO *oldUserInfo;
/// 用户信息
@property (nonatomic, strong) UserInfosDTO *userInfo;

@property (nonatomic, assign) BOOL needPopBackAfterUpdate;

@end

@implementation BasicInformationVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserDetail];
    
}

- (void)componentSetting {

    self.oldUserInfo = DBHandler.shareInstance.getUserInfo;
    self.userInfo = DBHandler.shareInstance.getUserInfo;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.nameTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.nickNameTF];
    
    
    
    [self.cancellationButton.layer setCornerRadius:3.0];
    [self.cancellationButton.layer setMasksToBounds:YES];
    NSString *image = self.userInfo.portrait;
    
    [self.nView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.ncView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.xbView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.sjView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.xgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    
    self.topMainViewHeightConstraint.constant = IS_IPHONE_4_OR_LESS?124:148;
    self.headPortraitImageView.layer.masksToBounds = YES;
    self.headPortraitImageView.layer.allowsEdgeAntialiasing = YES;
    self.headPortraitImageView.layer.cornerRadius = CGRectGetWidth(self.headPortraitImageView.frame)/2.0f;
    self.headPortraitImageView.userInteractionEnabled = NO;
    [self.headPortraitImageView setImageURL:image];

    self.nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self setRightNavButtonWithTitleOrImage:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(updateUserInfomation) titleColor:nil isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 40.0f)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(updateTextValue)];
    doneButton.tintColor = [UIColor colorWithHexString:@"49C7F5"];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [toolbar setItems:buttonsArray];
    self.nameTF.inputAccessoryView = toolbar;
    self.nickNameTF.inputAccessoryView = toolbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"基本资料";
    self.navShouldPopOtherVC = YES;
    [self componentSetting];
    [self initializationUI];
//    [self setReactiveRules];
}

- (void)initializationUI {
    [self updateData];
}

- (void)updateData {
    
    self.nameTF.text = self.userInfo.realname;
    self.nickNameTF.text=self.userInfo.nichen;
    if (self.userInfo.gender==0) {
        self.genderLabel.text=@"女";
    }else
    {
        self.genderLabel.text=@"男";
    }
    
    self.telephoneLabel.text = self.userInfo.telphone;
    
    if ([self.userInfo.portrait isContainsString:@"http"]) {
        self.headPortraitImageView.imageURL = self.userInfo.portrait;
    }
}

- (IBAction)userLogout:(id)sender {
    @weakify(self);
    [[UserBehaviorHandler shareInstance] userLogoutWasPopupDialog:YES andCompletionBlock:^{
        @strongify(self);
        self.oldUserInfo = nil;
        self.userInfo = nil;
        self.headPortraitImageView.imageURL=nil;
        self.nameTF.text=@"";
        self.nickNameTF.text=@"";
        self.genderLabel.text=@"";
        self.telephoneLabel.text=@"";
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)gender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:nil
                                  cancelButtonTitle:getLocalizationString(@"cancel")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"女", @"男",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        if (buttonIndex.integerValue==0) {
            self.genderLabel.text=@"女";
            self.userInfo.gender = @0;
        }
        
        if (buttonIndex.integerValue==1) {
            self.genderLabel.text=@"男";
            self.userInfo.gender = @1;
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if (![self.userInfo.realname isEqualToString:self.oldUserInfo.realname]||
            ![self.userInfo.nichen isEqualToString:self.oldUserInfo.nichen]||
            ![self.userInfo.gender isEqual:self.oldUserInfo.gender]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
    }];
}

- (void)updateTextValue {
    [self.nameTF resignFirstResponder];
    self.userInfo.realname = self.nameTF.text;
    
    [self.nickNameTF resignFirstResponder];
    self.userInfo.nichen = self.nickNameTF.text;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![self.userInfo.realname isEqualToString:self.oldUserInfo.realname]||
        ![self.userInfo.nichen isEqualToString:self.oldUserInfo.nichen]||
        ![self.userInfo.gender isEqual:self.oldUserInfo.gender]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.nameTF==textField) {
        [textField resignFirstResponder];
        self.userInfo.realname = self.nameTF.text;
    }
    
    if (self.nickNameTF==textField) {
        [textField resignFirstResponder];
        self.userInfo.nichen = self.nickNameTF.text;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![self.userInfo.realname isEqualToString:self.oldUserInfo.realname]||
        ![self.userInfo.nichen isEqualToString:self.oldUserInfo.nichen]||
        ![self.userInfo.gender isEqual:self.oldUserInfo.gender]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    if (textField.text.length>=7&&![string isEqualToString:@""]) return NO;
        
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 7;
    UITextField *textField = (UITextField *)notiObj.object;
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
}

- (IBAction)modifyPassword {
    
    ModifyPasswordVC*vc=[[ModifyPasswordVC alloc]init];
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showImageTypeActionSheet {
    @autoreleasepool {
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

#pragma -mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil) image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [ImageHandler imageWithImage:image convertToSize:CGSizeMake(300, 300)];
        [ProgressHUDHandler showHUDWithTitle:@"更新资料中...." onView:nil];
        
        [[APIsConnection shareConnection] personalCenterAPIsPostUseryPortraitImage:image imageName:@"userImage" imageType:ConnectionImageTypeOfJPEG success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            if (errorCode!=0||!responseObject) {
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"error" message:@"更新头像失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
                return;
            }
            NSString *url = responseObject[@"url"];
            @strongify(self);
            [self updateUserPortraitURL:url];
            
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
            
            [SupportingClass showAlertViewWithTitle:@"error" message:@"更新头像失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
        }];
    }];
}

- (void)updateUserPortraitURL:(NSString *)url {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPatchUserPersonalInformationWithAccessToken:self.accessToken byPortraitPath:url mobileNumber:nil realName:nil nickName:nil sexual:nil bod:nil qqNumber:nil email:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
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
            [self.headPortraitImageView setImageURL:url];
            [self getUserDetail];
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"更新资料失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
}

- (void)getUserDetail {
    if (!self.accessToken) {
        return;
    }
    [ProgressHUDHandler showHUD];
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalCenterAPIsGetPersonalInformationWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (!self.userInfo) {
            self.userInfo = [UserInfosDTO new];
        }
        if (!self.oldUserInfo) {
            self.oldUserInfo = [UserInfosDTO new];
        }
        
        [self.userInfo processDataToObjectWithData:[responseObject objectForKey:CDZKeyOfResultKey] isFromDB:NO];
        [self.oldUserInfo processDataToObjectWithData:[responseObject objectForKey:CDZKeyOfResultKey] isFromDB:NO];
        [DBHandler.shareInstance updateUserInfo:self.userInfo];
        if (self.needPopBackAfterUpdate) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self updateData];
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}

- (void)showLoadingInPickerSuperview:(NSString *)title {
    @autoreleasepool {
            [ProgressHUDHandler showHUDWithTitle:title onView:nil];
        }
    }

#pragma mark- APIs Access Request
- (void)updateUserInfomation {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    if ([self.nameTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入姓名" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    if ([self.nickNameTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入昵称" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    [self showLoadingInPickerSuperview:@"更新资料中...."];
    NSString *userName = self.userInfo.realname;
    NSString *nickName = self.userInfo.nichen;
    NSNumber *gender = self.userInfo.gender;
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPatchUserPersonalInformationWithAccessToken:self.accessToken byPortraitPath:nil mobileNumber:nil realName:userName nickName:nickName sexual:gender bod:nil  qqNumber:nil email:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
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
            [self getUserDetail];
        }];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"更新资料失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNavBackBtnPopOtherAction {
    [self updateTextValue];
    if ([self.userInfo.realname isEqualToString:self.oldUserInfo.realname]&&
        ![self.userInfo.realname isEqualToString:@""]&&
        [self.userInfo.nichen isEqualToString:self.oldUserInfo.nichen]&&
        ![self.userInfo.nichen isEqualToString:@""]&&
        [self.userInfo.gender isEqual:self.oldUserInfo.gender]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [SupportingClass showAlertViewWithTitle:@"" message:@"你已修改个人信息还没有保存，是否退出？" isShowImmediate:YES cancelButtonTitle:@"退出" otherButtonTitles:@"立即保存" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                self.needPopBackAfterUpdate = YES;
                [self updateUserInfomation];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
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

@end
