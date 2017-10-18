//
//  MyEServiceComment.m
//  cdzer
//
//  Created by KEns0n on 16/4/7.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyEServiceComment.h"
#import "HCSStarRatingView.h"

@interface MyEServiceComment () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet HCSStarRatingView *consultantRatingView;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *serviceRatingView;

@property (nonatomic, weak) IBOutlet UIImageView *consultantIV;

@property (nonatomic, weak) IBOutlet UILabel *serviceConsultantLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantPhoneLabel;

@property (nonatomic, weak) IBOutlet UITextView *textView;

//@property (nonatomic, weak) IBOutlet UIButton *submitButton;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) CGRect keyboardRect;


@end

@implementation MyEServiceComment

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self.textView];
    self.title = _commentDisplayOnly?@"查看评论":@"服务评价" ;
    if (!_commentDisplayOnly) {
        [self setRightNavButtonWithTitleOrImage:@"确认提交" style:UIBarButtonItemStylePlain target:self action:@selector(submitEServiceComment) titleColor:[UIColor colorWithHexString:@"323232"] isNeedToSet:YES];
    }
    [self.consultantIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(self.consultantIV.frame)/2];
    [self.consultantIV setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    self.consultantIV.image = [ImageHandler getDefaultWhiteLogo];
    self.consultantRatingView.tintColor = [UIColor colorWithHexString:@"f8af30"];
    self.serviceRatingView.tintColor = [UIColor colorWithHexString:@"f8af30"];
    [self.textView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.textView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
//    [self.submitButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:CDZColorOfDeepGray withBroderOffset:nil];
    self.textView.editable = !_commentDisplayOnly;
//    self.textView.textColor=[UIColor colorWithHexString:@"bfbfbf"];
//    self.textView.backgroundColor = _commentDisplayOnly?CDZColorOfClearColor:CDZColorOfWhite;
    self.serviceRatingView.userInteractionEnabled = !_commentDisplayOnly;
//    self.submitButton.hidden = _commentDisplayOnly;
    UIToolbar * toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self.textView
                                                                 action:@selector(resignFirstResponder)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [toolbar setItems:buttonsArray];
    self.textView.inputAccessoryView = toolbar;
    // Do any additional setup after loading the view from its nib.
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    CGRect keyboardRect = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (CGRectEqualToRect(_keyboardRect, CGRectZero)||!CGRectEqualToRect(_keyboardRect, keyboardRect)) {
        self.keyboardRect = keyboardRect;
    }
    NSTimeInterval duration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    @weakify(self);
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        CGFloat midY = CGRectGetMidY(self.textView.frame);
        CGFloat contentSizeHight = CGRectGetMinY(keyboardRect)-64.0f;
        CGPoint theOffset = CGPointZero;
        theOffset.y = midY - roundf(contentSizeHight/2.0f);
        self.scrollView.contentOffset = theOffset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    NSTimeInterval duration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    @weakify(self);
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        self.scrollView.contentOffset = CGPointZero;
    }];
    
}

- (void)textViewTextDidChange:(NSNotification *)notifObj {
    UITextView *textView = (UITextView *)notifObj.object;
    if (textView==self.textView) {
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView==self.textView) {
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
//        if ([text stringByTrimmingCharactersInSet:NSCharacterSet.symbolCharacterSet.invertedSet].length>0) {
//            
//         return NO;
//        } 
        if (textView.text.length==0&&([textView.text isContainsString:@" "]||[textView.text isContainsString:@"\n"])) {
            return NO;
        }
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getConsultantInfo];
    if (_commentDisplayOnly) {
        [self getCommentedDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)phoneButtonClick:(id)sender {
    if ([self.consultantPhoneLabel.text isEqualToString:@""]||!self.consultantPhoneLabel.text) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"此案例暂无提供维修商电话" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }else {
        [SupportingClass makeACall:self.consultantPhoneLabel.text];
    }
}


- (void)getConsultantInfo {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if ([_eServiceID isEqualToString:@""]) {
        NSLog(@"missing eServiceID ");
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceConsultantSimpleDetail4CommentWithAccessToken:self.accessToken eServiceID:_eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
//        "real_name": "谢尔",
//        "telphone": "18169427170",
//        "star": 5,
//        "img": ""
        
        [ProgressHUDHandler dismissHUD];
        NSDictionary *detail = responseObject[CDZKeyOfResultKey];
        NSString *imageURL = detail[@"img"];
        if (imageURL.length>0) {
            imageURL=imageURL;
        }else{
            imageURL=self.carImagString;
        }
        if ([imageURL isContainsString:@"http"]) {
            [self.consultantIV setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        NSString *name = detail[@"real_name"];
        self.serviceConsultantLabel.text = name;
        
        NSString *phoneNum = [SupportingClass verifyAndConvertDataToString:detail[@"telphone"]];
        self.consultantPhoneLabel.text = phoneNum;
        
        NSNumber *starsValue = detail[@"star"];
        self.consultantRatingView.value = starsValue.floatValue;
        
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

- (void)getCommentedDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    if ([_eServiceID isEqualToString:@""]) {
        NSLog(@"missing eServiceID ");
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceServiceCommentWithAccessToken:self.accessToken eServiceID:_eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        NSDictionary *detail = responseObject[CDZKeyOfResultKey];
        NSString *name = detail[@"sign"];
        self.textView.text = name;
        
        NSNumber *starsValue = detail[@"car_shop_num"];
        self.serviceRatingView.value = starsValue.floatValue;
        
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

- (void)submitEServiceComment {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    if ([_eServiceID isEqualToString:@""]) {
        NSLog(@"missing eServiceID ");
        return;
    }
    NSString *textResult = [_textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (textResult.length==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入评价信息" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (_serviceRatingView.value==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择服务评分分数" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceServiceCommentWithAccessToken:self.accessToken eServiceID:_eServiceID rateNumber:@(_serviceRatingView.value) comment:_textView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        [self.navigationController popViewControllerAnimated:YES];
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
