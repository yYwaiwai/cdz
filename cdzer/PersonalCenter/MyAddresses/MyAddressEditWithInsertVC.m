//
//  MyAddressEditWithInsertVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyAddressEditWithInsertVC.h"
#import "PCRDataModel.h"
#import "AddressDTO.h"

@interface MyAddressEditWithInsertVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *consigneeTF;

@property (weak, nonatomic) IBOutlet UITextField *telephoneTF;

@property (weak, nonatomic) IBOutlet UITextField *cityTF;

@property (weak, nonatomic) IBOutlet UITextField *detailedAddressTF;

@property (weak, nonatomic) IBOutlet UISwitch *defaultAddressSwitch;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) UIPickerView *selectCityPickerView;

/// 数据模型
@property (nonatomic, strong) PCRDataModel *dataModel;

@property (nonatomic, strong) AddressDTO *addressDetail;

@end

@implementation MyAddressEditWithInsertVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    self.title = self.isReviewEditMode?@"编辑收货地址":@"添加收货地址";
    [self initializationUI];
    if (self.firstAdd) {
//        self.defaultAddressSwitch.superview.hidden = YES;
        self.defaultAddressSwitch.on = YES;
        self.defaultAddressSwitch.enabled = NO;
    }
    if (self.isReviewEditMode) {
        [self setRightNavButtonWithTitleOrImage:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteUserAddress) titleColor:nil isNeedToSet:YES];
        [self getAddressDetail];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        
        self.dataModel = [PCRDataModel new];
        if (!self.dataModel.completeBlock) {
            @weakify(self);
            self.dataModel.completeBlock = ^{
                @strongify(self);
                [self.selectCityPickerView reloadAllComponents];
                [self.selectCityPickerView selectRow:self.dataModel.provinceObjIdx inComponent:0 animated:YES];
                [self.selectCityPickerView selectRow:self.dataModel.cityObjIdx inComponent:1 animated:YES];
                [self.selectCityPickerView selectRow:self.dataModel.regionObjIdx inComponent:2 animated:YES];
            };
        }
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 44.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolbar setItems:buttonsArray];
        
        self.selectCityPickerView = [UIPickerView new];
        self.selectCityPickerView.backgroundColor = UIColor.whiteColor;
        self.selectCityPickerView.delegate = self;
        self.selectCityPickerView.dataSource = self;
        
        self.consigneeTF.inputAccessoryView = toolbar;
        self.telephoneTF.inputAccessoryView = toolbar;
        self.detailedAddressTF.inputAccessoryView = toolbar;
        self.cityTF.inputAccessoryView = toolbar;
        self.cityTF.inputView = self.selectCityPickerView;
        UIColor *color = [UIColor colorWithHexString:@"909090"];
        self.cityTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请选择所在城市" attributes:@{NSForegroundColorAttributeName: color}];
    }
}

- (void)hiddenKeyboard {
    [self.view endEditing:NO];
}

- (void)reloadUIData {
    self.consigneeTF.text = self.addressDetail.consigneeName;
    self.telephoneTF.text = self.addressDetail.telNumber;
    self.cityTF.text = @"";
    if (self.addressDetail.provinceName&&
        self.addressDetail.cityName&&
        self.addressDetail.regionName) {
        self.cityTF.text = [NSString stringWithFormat:@"%@%@%@", self.addressDetail.provinceName, self.addressDetail.cityName, self.addressDetail.regionName];
    }
    self.detailedAddressTF.text = self.addressDetail.address;
    self.defaultAddressSwitch.on = self.addressDetail.isDefaultAddress;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.consigneeTF.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.telephoneTF.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.cityTF.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.detailedAddressTF.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.defaultAddressSwitch.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.submitButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component==0) {
        NSLog(@"%d", self.dataModel.provinceList.count);
        return self.dataModel.provinceList.count;
    }
    if (component==1) {
        NSLog(@"%d", self.dataModel.cityList.count);
        return self.dataModel.cityList.count;
    }
    if (component==2) {
        NSLog(@"%d", self.dataModel.regionList.count);
        return self.dataModel.regionList.count;
    }
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view||![view isKindOfClass:UILabel.class]) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithHexString:@"323232"];
        view = label;
    }
    
    UILabel *label = (UILabel *)view;
    label.text = @"";
    if (component==0&&self.dataModel.provinceList.count>0) {
        label.text = [self.dataModel.provinceList[row] objectForKey:kResultKeyName];
    }
    if (component==1&&self.dataModel.cityList.count>0) {
        label.text = [self.dataModel.cityList[row] objectForKey:kResultKeyName];
    }
    if (component==2&&self.dataModel.regionList.count>0) {
        label.text = [self.dataModel.regionList[row] objectForKey:kResultKeyName];
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component==0) {
        NSString *provinceID= [SupportingClass verifyAndConvertDataToString:[self.dataModel.provinceList[row] objectForKey:kResultKeyID]];
        [self.dataModel updateProvinceID:provinceID cityID:nil regionID:nil];
    }
    if (component==1) {
        NSString *cityID = [SupportingClass verifyAndConvertDataToString:[self.dataModel.cityList[row] objectForKey:kResultKeyID]];
        [self.dataModel updateProvinceID:nil cityID:cityID regionID:nil];
    }
    if (component==2) {
        NSString *regionID = [SupportingClass verifyAndConvertDataToString:[self.dataModel.regionList[row] objectForKey:kResultKeyID]];
        [self.dataModel updateProvinceID:nil cityID:nil regionID:regionID];
    }
}

- (void)comfirmPCRSelection {
//    NSDictionary *provinceDetail = self.dataModel.provinceList[]
//    NSDictionary *cityDetail =
//    NSDictionary *regionDetail =
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField==self.cityTF) {
        [self.selectCityPickerView reloadAllComponents];
        if (!textField.text||[textField.text isEqualToString:@""]) {
            if (self.dataModel.provinceList.count>0&&
                self.dataModel.provinceList.count>self.dataModel.provinceObjIdx&&
                self.dataModel.cityList.count>0&&
                self.dataModel.cityList.count>self.dataModel.cityObjIdx&&
                self.dataModel.regionList.count>0&&
                self.dataModel.regionList.count>self.dataModel.regionObjIdx) {
                NSString *provinceName = [self.dataModel.provinceList[self.dataModel.provinceObjIdx] objectForKey:kResultKeyName];
                NSString *cityName = [self.dataModel.cityList[self.dataModel.cityObjIdx] objectForKey:kResultKeyName];
                if ([provinceName isEqualToString:cityName]) cityName = @"";
                NSString *regionName = [self.dataModel.regionList[self.dataModel.regionObjIdx] objectForKey:kResultKeyName];
                textField.text = [NSString stringWithFormat:@"%@%@%@", provinceName, cityName, regionName];
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField==self.cityTF) {
        [self.selectCityPickerView reloadAllComponents];
        if (self.dataModel.provinceList.count>0&&
            self.dataModel.provinceList.count>self.dataModel.provinceObjIdx&&
            self.dataModel.cityList.count>0&&
            self.dataModel.cityList.count>self.dataModel.cityObjIdx&&
            self.dataModel.regionList.count>0&&
            self.dataModel.regionList.count>self.dataModel.regionObjIdx) {
            NSString *provinceName = [self.dataModel.provinceList[self.dataModel.provinceObjIdx] objectForKey:kResultKeyName];
            NSString *cityName = [self.dataModel.cityList[self.dataModel.cityObjIdx] objectForKey:kResultKeyName];
            if ([provinceName isEqualToString:cityName]) cityName = @"";
            NSString *regionName = [self.dataModel.regionList[self.dataModel.regionObjIdx] objectForKey:kResultKeyName];
            textField.text = [NSString stringWithFormat:@"%@%@%@", provinceName, cityName, regionName];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (([string isEqualToString:@" "]&&textField!=self.detailedAddressTF)||
        (textField.text.length==0&&[string isEqualToString:@" "])) return NO;
    
    if (textField==self.telephoneTF) {
        if (![string isEqualToString:@""]) {
            NSString *newString = [string stringByTrimmingCharactersInSet:NSCharacterSet.decimalDigitCharacterSet.invertedSet];
            range.length = newString.length;
            NSUInteger zeroTurn = newString.integerValue;
            if (textField.text.length==0&&zeroTurn==0) return NO;
            if (textField.text.length>=11) return NO;
            
        }

    }
    
    return YES;
}

- (void)keyboardWillDisappear {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj  {
    UITextField *textField = nil;
    if (self.consigneeTF.isFirstResponder) {
        textField = self.consigneeTF;
    }else if (self.telephoneTF.isFirstResponder) {
        textField = self.telephoneTF;
    }else if (self.cityTF.isFirstResponder) {
        textField = self.cityTF;
        [self.selectCityPickerView reloadAllComponents];
    }else if (self.detailedAddressTF.isFirstResponder) {
        textField = self.detailedAddressTF;
    }
    CGRect keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (textField) {
        CGRect rect = [self.scrollView convertRect:textField.frame fromView:textField.superview];
        CGFloat centerPoint = CGRectGetMidY(rect);
        CGFloat visibleSpace = SCREEN_HEIGHT-64.f-CGRectGetHeight(keyboardRect);
        CGFloat offsetY = centerPoint-visibleSpace/2.0f;
        if (offsetY<=0) offsetY = 0;
        [self.scrollView setContentOffset:CGPointMake(0.0, offsetY) animated:NO];
    }
}

- (IBAction)saveAddressSetting {
    if (!self.consigneeTF.text||[self.consigneeTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入收货人姓名" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.telephoneTF.text||[self.telephoneTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入正确的手机号码" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.cityTF.text||[self.cityTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择所在城市" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.detailedAddressTF.text||[self.detailedAddressTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入详细地址" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    [self.view endEditing:YES];
    if (self.isReviewEditMode) {
        [self submitEditAddressForm];
    }else {
        [self submitAddressForm];
    }
}

#pragma -mark Private Functions
// delay Run Data on MyAddressDisplayTypeOfNormal

- (void)getAddressDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:nil onView:self.view.window];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetShippingAddressDetailWithAccessToken:self.accessToken addressID:self.addressID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        self.addressDetail = [AddressDTO new];
        [self.addressDetail processDataToObject:responseObject[CDZKeyOfResultKey]];
        [self reloadUIData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
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

// 确认增加地址
- (void)submitAddressForm {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUDWithTitle:nil onView:[UIApplication sharedApplication].keyWindow];
    NSLog(@"%@ accessing submit Address request",NSStringFromClass(self.class));
    NSString *provinceID = self.dataModel.provinceID;
    NSString *cityID = self.dataModel.cityID;
    NSString *districtID = self.dataModel.regionID;

    [[APIsConnection shareConnection] personalCenterAPIsPostInsertShippingAddressWithAccessToken:self.accessToken consigneeName:self.consigneeTF.text mobileNumber:self.telephoneTF.text provinceID:provinceID cityID:cityID districtID:districtID detailAddress:self.detailedAddressTF.text isDefaultAddress:self.defaultAddressSwitch.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        [operation setUserInfo:@{@"iden":@3}];
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
}
// 确认更改地址
- (void)submitEditAddressForm {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:nil onView:[UIApplication sharedApplication].keyWindow];
    
    NSLog(@"%@ accessing submit Edit Address request",NSStringFromClass(self.class));
    NSString *provinceID = self.dataModel.provinceID;
    NSString *cityID = self.dataModel.cityID;
    NSString *districtID = self.dataModel.regionID;
    
    [[APIsConnection shareConnection] personalCenterAPIsPatchShippingAddressWithAccessToken:self.accessToken addressID:self.addressDetail.addressID consigneeName:self.consigneeTF.text mobileNumber:self.telephoneTF.text provinceID:provinceID cityID:cityID districtID:districtID detailAddress:self.detailedAddressTF.text isDefaultAddress:self.defaultAddressSwitch.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        [operation setUserInfo:@{@"iden":@4}];
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
}

- (void)deleteUserAddress {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:@"" message:@"是否确定要删除地址？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (btnIdx.integerValue>0) {
            [ProgressHUDHandler showHUD];
            NSLog(@"%@ delete address accessing network request",NSStringFromClass(self.class));
            [[APIsConnection shareConnection] personalCenterAPIsPostDeleteShippingAddressWithAccessToken:self.accessToken addressID:self.addressDetail.addressID success:^(NSURLSessionDataTask *operation, id responseObject) {[operation setUserInfo:@{@"iden":@2}];
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
        }
    }];
}


- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
        
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSNumber *idenNumber = [operation.userInfo objectForKey:@"iden"];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            if (idenNumber.integerValue==3||idenNumber.integerValue==4) {
                [ProgressHUDHandler dismissHUD];
                [self.navigationController popViewControllerAnimated:YES];
            }else if (idenNumber.integerValue==2){
                @weakify(self);
                [ProgressHUDHandler showSuccessWithStatus:@"删除成功" onView:nil completion:^{
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }else {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        }
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
