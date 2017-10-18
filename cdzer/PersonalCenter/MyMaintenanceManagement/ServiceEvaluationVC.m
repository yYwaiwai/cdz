//
//  ServiceEvaluationVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/1.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ServiceEvaluationVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HCSStarRatingView.h"
#import "MyMaintenanceManagementVC.h"
#import "MyOrdersVC.h"



@interface ServiceEvaluationVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *startView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *signImageView;
@property (weak, nonatomic) IBOutlet UILabel *littleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UIView *evaluateBgView;
//是否重新加载列表
@property (nonatomic, assign) BOOL isNeedReload;


@end

@implementation ServiceEvaluationVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.fromVCStr isEqualToString:@"产品评价"]||[self.fromVCStr isEqualToString:@"产品评价查看"]) {
        self.title=@"产品评价";
    }else{
        if (self.isCommnetReview) {
            [self viewComments];
        }else {
            [self commentRepair];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_startView setMaximumValue:5.0f];
    [_startView setMinimumValue:0.0f];
    [_startView setAllowsHalfStars:NO];
    [_startView setValue:0.0f];
    [_startView setTintColor:[UIColor orangeColor]];
    
//    [_startView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    if ([self.fromVCStr isEqualToString:@"产品评价"]) {
        self.signImageView.hidden=YES;
        [_startView setUserInteractionEnabled:YES];
        NSString *imgURL = [self.resultDic objectForKey:@"product_img"];
        if ([imgURL containsString:@"http"]) {
            [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        self.littleLabel.text=@"总体评价";
        self.textView.text=self.resultDic[@"content"];
        self.hintLabel.text=@"请写下此次服务您对该产品的服务感受~";
        self.hintLabel.hidden = NO;
    }
    if ([self.fromVCStr isEqualToString:@"产品评价查看"]) {
        self.title=@"产品评价";
        self.signImageView.hidden=YES;
        NSString *imgURL = [self.resultDic objectForKey:@"product_img"];
        if ([imgURL containsString:@"http"]) {
            [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        NSString*ratingValue=self.resultDic[@"star"];
        self.startView.userInteractionEnabled = NO;
        self.startView.value = ratingValue.floatValue;
        self.littleLabel.text=self.resultDic[@"create_time"];
        self.textView.text=self.resultDic[@"content"];
        self.submitButton.hidden=YES;
        self.textView.editable =NO;
    }
    if (![self.fromVCStr isEqualToString:@"产品评价"]&&![self.fromVCStr isEqualToString:@"产品评价查看"]){
        self.title=@"服务评价";
        if (self.isCommnetReview) {
            self.submitButton.hidden = YES;
            self.textView.editable = NO;
            self.textView.userInteractionEnabled = NO;
            self.startView.userInteractionEnabled = NO;
        }else {
            self.littleLabel.text = @"总体评价";
        }

    }
   
    
    self.textView.delegate=self;
    [self.submitButton.layer setCornerRadius:3.0];
    [self.submitButton.layer setMasksToBounds:YES];
    [self.submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_evaluateBgView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.25f withColor:nil withBroderOffset:nil];
    
    
    UIToolbar *toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(resignKeyboard)];
    [toolBar setItems:@[spaceButton, doneButton]];
    _textView.inputAccessoryView = toolBar;
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.evaluateBgView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)resignKeyboard {
    [self.textView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.hintLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.hintLabel.hidden = !(textView.text.length==0);
}

- (void)submitButtonClick {
    if ([self.fromVCStr isEqualToString:@"产品评价"]) {
        [self productReviews];
    }else{
        [self serviceReview];
    }
}
//产品评论
- (void)productReviews {
    if ([self.textView.text isEqualToString:@"请写下此次服务您对该产品的评价~"]||self.textView.text.length==0) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请填写本次服务评价！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }else{
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        NSString*star=[NSString stringWithFormat:@"%f",self.startView.value];
        [ProgressHUDHandler showHUD];
        [[APIsConnection shareConnection] personalCenterAPIsPostSubRepairCommentByorderWithAccessToken:self.accessToken keyID:self.repairID productID:self.resultDic[@"product_id"] productType:self.resultDic[@"product_type"] 
           star:star content:self.textView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
               
            [self requestResultHandle:operation responseObject:responseObject withError:nil];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
           
            [self requestResultHandle:operation responseObject:nil withError:error];
        }];
    }

}
//服务评论
- (void)serviceReview {
    if (self.textView.text.length==0||self.startView.value==0.0) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请对本次服务/产品进行评价！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
        return;
    }
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString*star=[NSString stringWithFormat:@"%f",self.startView.value];
    [ProgressHUDHandler showHUD];
//    [[APIsConnection shareConnection] personalCenterAPIsPostSubRepairCommentWithAccessToken:self.accessToken keyID:self.repairID star:star content:self.textView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];

}

- (void)commentRepair {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostCommentRepairWithAccessToken:self.accessToken keyID:self.repairID  success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"commentRepair"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"commentRepair"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];

}

- (void)viewComments {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
//    [[APIsConnection shareConnection] personalCenterAPIsPostShowRepairGroupCommentInfoWithAccessToken:self.accessToken keyID:self.repairID  success:^(NSURLSessionDataTask *operation, id responseObject) {
//        operation.userInfo = @{@"ident":@"commentReview"};
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        operation.userInfo = @{@"ident":@"commentReview"};
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];
    
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
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
               NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (operation.userInfo&&([operation.userInfo[@"ident"] isEqualToString:@"commentRepair"]||
                                 [operation.userInfo[@"ident"] isEqualToString:@"commentReview"])) {
            NSDictionary *resultDic=[responseObject objectForKey:CDZKeyOfResultKey];
            NSString *imgURL = [resultDic objectForKey:@"wxs_logo"];
            if ([imgURL containsString:@"http"]) {
                [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
            NSString*wxsKind=resultDic[@"wxs_kind"];
            if ([wxsKind isEqualToString:@"专修店"]) {
                self.signImageView.image=[UIImage imageNamed:@"snsslvc_spec_service_icon@3x"];
            }else {
                self.signImageView.image=[UIImage imageNamed:@"snsslvc_brand_shop_icon@3x"];
            }
            self.littleLabel.text = @"总体评价";
            if ([operation.userInfo[@"ident"] isEqualToString:@"commentReview"]) {
                self.littleLabel.text = resultDic[@"create_time"];
                self.textView.text = resultDic[@"content"];
                self.startView.value = [SupportingClass verifyAndConvertDataToString:resultDic[@"star"]].floatValue;
            }
            [ProgressHUDHandler dismissHUD];
        }else {
            self.isNeedReload = YES;
            [ProgressHUDHandler showSuccessWithStatus:message onView:nil completion:^{
                
                [self handleNavBackBtnPopOtherAction];
            }];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNavBackBtnPopOtherAction {
    if (self.isPushFromOrder) {
        MyOrdersVC *vc = nil;
        
        NSPredicate *predicateTabBarVC = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
        NSArray *theResult = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicateTabBarVC];
        if (theResult&&theResult.count>0) {
            [(BaseTabBarController *)theResult.lastObject setSelectedIndex:3];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyOrdersVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            vc = result.lastObject;
            vc.shouldReloadData = self.isNeedReload;
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
        
        vc = [MyOrdersVC new];
        vc.shouldReloadData = self.isNeedReload;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        

        return;
    }
    MyMaintenanceManagementVC *vc = nil;
    
    NSPredicate *predicateTabBarVC = [NSPredicate predicateWithFormat:@"SELF.class == %@", BaseTabBarController.class];
    NSArray *theResult = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicateTabBarVC];
    if (theResult&&theResult.count>0) {
        [(BaseTabBarController *)theResult.lastObject setSelectedIndex:3];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyMaintenanceManagementVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        vc = result.lastObject;
        vc.shouldReloadData = self.isNeedReload;
        [self.navigationController popToViewController:vc animated:YES];
        return;
    }
    
    vc = [MyMaintenanceManagementVC new];
    vc.shouldReloadData = self.isNeedReload;
    vc.currentStatusType = CDZMaintenanceStatusTypeOfAppointment;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    
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
