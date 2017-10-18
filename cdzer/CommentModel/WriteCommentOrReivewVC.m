//
//  WriteCommentOrReivewVC.m
//  cdzer
//
//  Created by KEns0n on 30/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "WriteCommentOrReivewVC.h"
#import "MyMaintenanceManagementVC.h"
#import "MyOrdersVC.h"
#import "HCSStarRatingView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WriteCommentOrReivewVC ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *startView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIImageView *signImageView;

@property (weak, nonatomic) IBOutlet UILabel *littleLabel;

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UIView *evaluateBgView;

@end

@implementation WriteCommentOrReivewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.evaluateBgView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)repairTypeSetting {
    NSString *imgURL = [self.commentInfoData objectForKey:@"wxs_logo"];
    if ([imgURL containsString:@"http"]) {
        [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    
    if (self.typeOfReivew) {
        self.title = @"查看评价";
        self.submitButton.hidden = YES;
        self.textView.editable = NO;
        self.textView.userInteractionEnabled = NO;
        self.startView.userInteractionEnabled = NO;
    }else {
        
        self.submitButton.hidden = NO;
        self.hintLabel.hidden = NO;
        self.startView.userInteractionEnabled = YES;
        self.textView.userInteractionEnabled = YES;
        self.textView.editable = YES;
        
        
        
    }
}


- (void)commentUISetting {
    
    NSString *imgURL = self.commentInfoData[@"product_img"];
    if (self.commentForRepair) {
        imgURL = self.commentInfoData[@"wxs_logo"];
    }
    if ([imgURL containsString:@"http"]) {
        [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    
    NSNumber *commentType = [SupportingClass verifyAndConvertDataToNumber:self.commentInfoData[@"product_type"]];
    CGFloat rectCornerSize = 0;
    NSString *wxsKind = self.commentInfoData[@"wxs_kind"];
    if ((self.commentForRepair&&[wxsKind isEqualToString:@""])||
        (commentType.integerValue==2&&!self.commentForRepair)) {
        rectCornerSize = (CGRectGetHeight(self.titleImageView.frame)/2.0f);
    }
    [self.titleImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:rectCornerSize];
    
    
    
    if (self.typeOfReivew) {
        self.submitButton.hidden = YES;
        self.hintLabel.hidden = YES;
        self.startView.userInteractionEnabled = NO;
        self.textView.userInteractionEnabled = NO;
        self.textView.editable = NO;
        self.title = @"查看评价";
        
        
        NSString *ratingValue = [SupportingClass verifyAndConvertDataToString:self.commentInfoData[@"star"]];
        self.startView.value = ratingValue.floatValue;
        self.littleLabel.text = self.commentInfoData[@"create_time"];
        self.textView.text = self.commentInfoData[@"content"];
        
    }else {
        self.submitButton.hidden = NO;
        self.hintLabel.hidden = NO;
        self.startView.userInteractionEnabled = YES;
        self.textView.userInteractionEnabled = YES;
        self.textView.editable = YES;
        NSString *hintString = @"请写下此次您对该服务的感受和评价~";
        self.title = @"评价";
        
        if (self.commentForRepair) {
            NSString *wxsKind = self.commentInfoData[@"wxs_kind"];
            if (![wxsKind isEqualToString:@""]) {
                self.title = @"商家评价";
                hintString = @"请写下此次您对该商家服务的感受和评价~";
            }else if ([wxsKind isEqualToString:@""]) {
                self.title = @"技师评价";
                hintString = @"请写下此次您对该技师服务的感受和评价~";
            }
            
        }else {
            NSNumber *commentType = [SupportingClass verifyAndConvertDataToNumber:self.commentInfoData[@"product_type"]];
            if (commentType.integerValue==0) {
                self.title = @"商家评价";
                hintString = @"请写下此次您对该商家服务的感受和评价~";
            }else if (commentType.integerValue==1) {
                self.title = @"产品评价";
                hintString = @"请写下此次您对该产品的感受和评价~";
            }else if (commentType.integerValue==2) {
                self.title = @"技师评价";
                hintString = @"请写下此次您对该技师服务的感受和评价~";
            }
        }
        
        
        self.littleLabel.text = @"满意度评价";
        self.hintLabel.text = hintString;
        
    }

}

- (void)componentSetting {
    self.startView.maximumValue = 5.0f;
    self.startView.minimumValue = 0.0f;
    self.startView.allowsHalfStars = NO;
    self.startView.value = 0.0f;
    self.startView.tintColor = UIColor.orangeColor;
    self.startView.userInteractionEnabled = NO;
    
    NSString *wxsKind = self.commentInfoData[@"wxs_kind"];
    self.signImageView.hidden = YES;
    if (![wxsKind isEqualToString:@""]&&wxsKind) {
        self.signImageView.hidden = NO;
        self.signImageView.highlighted = [wxsKind isContainsString:@"专修"];
    }
    
    [self commentUISetting];
    
    self.textView.delegate=self;
    [self.submitButton.layer setCornerRadius:3.0];
    [self.submitButton.layer setMasksToBounds:YES];
    [self.submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.textView.inputAccessoryView = toolBar;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.commentForRepair) {
        [self serviceReview];
    }else{
        [self productReviews];
    }
}

//产品评论
- (void)productReviews {
    if ([self.textView.text isEqualToString:@"请写下此次服务您对该产品的评价~"]||self.textView.text.length==0) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请填写本次服务评价！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *star = [NSString stringWithFormat:@"%f",self.startView.value];
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostSubRepairCommentByorderWithAccessToken:self.accessToken keyID:self.commentGroupID productID:self.commentInfoData[@"product_id"] productType:self.commentInfoData[@"product_type"] star:star content:self.textView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
    
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
    NSString *star = [NSString stringWithFormat:@"%f",self.startView.value];
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostSubRepairCommentWithAccessToken:self.accessToken keyID:self.commentGroupID productID:self.commentInfoData[@"product_id"] star:star content:self.textView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
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
            self.shouldReloadData = YES;
            [ProgressHUDHandler showSuccessWithStatus:message onView:nil completion:^{
                
                [self wasCancelPopBackAction:NO];
            }];
        }
    }
    
}

- (void)wasCancelPopBackAction:(BOOL)isCancel {
    if (isCancel) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        if (self.commentsRemainCount==1) {
            if (!self.commentForRepair) {
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
                    vc.shouldReloadData = self.shouldReloadData;
                    [self.navigationController popToViewController:vc animated:YES];
                    return;
                }
                
                vc = [MyOrdersVC new];
                vc.shouldReloadData = self.shouldReloadData;
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
                vc.shouldReloadData = self.shouldReloadData;
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
            
            vc = [MyMaintenanceManagementVC new];
            vc.shouldReloadData = self.shouldReloadData;
            vc.currentStatusType = CDZMaintenanceStatusTypeOfAppointment;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)handleNavBackBtnPopOtherAction {
    [self wasCancelPopBackAction:YES];
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
