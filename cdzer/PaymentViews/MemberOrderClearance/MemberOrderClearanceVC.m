//
//  MemberOrderClearanceVC.m
//  cdzer
//
//  Created by KEns0n on 31/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberOrderClearanceVC.h"
#import "PaymentCenterVC.h"

@interface MemberOrderClearanceVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *reminderView;

@property (weak, nonatomic) IBOutlet UILabel *centerNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalProductPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UISwitch *invoiceSwitch;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *payeeNameViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *payeeNameTF;
@property (weak, nonatomic) IBOutlet UIView *payeeNameContainerView;

@property (strong, nonatomic) NSString *productID;

@end

@implementation MemberOrderClearanceVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"确认订单";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.reminderView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:[UIColor colorWithHexString:@"F5F5F5"] withBroderOffset:nil];
    [self.centerNameLabel.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.invoiceSwitch.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.payeeNameContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.totalProductPriceLabel.superview.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.totalPriceLabel.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.payeeNameTF];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        
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
        self.payeeNameTF.inputAccessoryView = toolbar;
    }
}

- (void)initializationUI {
    @autoreleasepool {
//    store_name: "车队长科技",
//    product_id: "14102809083946223647",
//    product_name: "白金会员年费2400元",
//    product_img: "http://tes.cdzer.net:80/imgUpload/uploads/20161027165213Cz49ezGe7z.png",
//    product_price: "0.2"
        self.productID = [SupportingClass verifyAndConvertDataToString:self.memberOrderDetail[@"product_id"]];
        self.centerNameLabel.text = self.memberOrderDetail[@"store_name"];
        self.productNameLabel.text = self.memberOrderDetail[@"product_name"];
        NSString *productImgURLStr = self.memberOrderDetail[@"product_img"];
        if ([productImgURLStr isContainsString:@"http"]) {
            [self.productImageView setImageWithURL:[NSURL URLWithString:productImgURLStr] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        NSString *productPriceStr = [SupportingClass verifyAndConvertDataToString:self.memberOrderDetail[@"product_price"]];
        self.productPriceLabel.text = [NSString stringWithFormat:@"%0.2f",productPriceStr.floatValue];
        self.totalProductPriceLabel.text =  self.productPriceLabel.text;
        self.totalPriceLabel.text =  self.productPriceLabel.text;
    }
}

- (void)setReactiveRules {
//    @weakify(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPayeeNameTF:(UISwitch *)theSwitch {
    self.payeeNameViewTopConstraint.constant = (theSwitch.on?0:-(CGRectGetHeight(self.payeeNameContainerView.frame)));
    self.payeeNameContainerView.hidden = !theSwitch.on;
}

- (void)hiddenKeyboard {
    [self.payeeNameTF resignFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    if ([self.payeeNameTF isFirstResponder]) {
        UITextField *textField = (UITextField *)notiObj.userInfo[@"tf"];
        CGRect keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        if (textField) {
            CGRect rect = [self.scrollView convertRect:textField.frame fromView:textField.superview];
            CGFloat centerPoint = CGRectGetMidY(rect);
            CGFloat visibleSpace = SCREEN_HEIGHT-64.f-CGRectGetHeight(keyboardRect);
            [self.scrollView setContentOffset:CGPointMake(0.0, centerPoint-visibleSpace/2) animated:NO];
        }


    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 8;
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

- (IBAction)submitPayment {
    if (self.invoiceSwitch.on) {
        if (self.payeeNameTF.text.length==0||[self.payeeNameTF.text isEqualToString:@""]) {
            [SupportingClass showAlertViewWithTitle:@"" message:@"请填写发票收款人" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
    }
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostMemberPaymentSubmitPaymentWithAccessToken:self.accessToken memberProductID:self.productID invoicePayeeName:self.payeeNameTF.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode==0) {
            @autoreleasepool {
                PaymentCenterVC *vc = [PaymentCenterVC new];
                vc.paymentDetail = responseObject[CDZKeyOfResultKey];
                vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfUserMember;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
            return;
        }
        if (errorCode==1&&[message isContainsString:@"请支付"]) {
            
            return;
        }
        [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
    }];
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
