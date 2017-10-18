//
//  WriteCommentVC.m
//  cdzer
//
//  Created by KEns0n on 6/29/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "WriteCommentVC.h"
#import "InsetsTextField.h"
#import "InsetsLabel.h"
#import "HCSStarRatingView.h"

@interface WriteCommentVC ()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *theID;

@property (nonatomic, strong) NSString *productID;

@property (nonatomic, assign) CommentType commentType;

@property (nonatomic, strong) UITextView *contentsTextView;

@property (nonatomic, strong) UITextField *titleTextField;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@end

@implementation WriteCommentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:sCommonBGColor];
    self.title = getLocalizationString(@"write_comment");
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)setCommentType:(CommentType)type andID:(NSString *)theID productID:(NSString *)productID {
    self.theID = theID;
    self.commentType = type;
    self.productID = productID;
}

- (void)setReactiveRules {
    @weakify(self);
    [_contentsTextView.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.navigationItem.rightBarButtonItem.enabled = @(text.length>=8).boolValue;
        }];
    
//    RACSignal *titleTextSignal = [_titleTextField.rac_textSignal map:^id(NSString *text) {
//        return @(text.length>=8);
//    }];
//    RACSignal *contentsTextSignal = [_contentsTextView.rac_textSignal map:^id(NSString *text) {
//        return @(text.length>=16);
//    }];
//    @weakify(self);
//    [[RACSignal combineLatest:@[titleTextSignal, contentsTextSignal] reduce:^id(NSNumber *titleSignal, NSNumber *contentsSignal){
//        return @(titleSignal.boolValue&&contentsSignal.boolValue);
//    }] subscribeNext:^(NSNumber *isOn) {
//        @strongify(self);
//        self.navigationItem.rightBarButtonItem.enabled = isOn.boolValue;
//    }];
    
}

- (void)componentSetting {
    [self setRightNavButtonWithTitleOrImage:(@"submit") style:UIBarButtonItemStyleDone target:self action:@selector(submitComment) titleColor:nil isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)initializationUI {
    @autoreleasepool {
        self.scrollView.hidden = NO;
        self.scrollView.bounces = NO;
        
        
        CGFloat offset = 20.0f;
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
        
//        
//        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, CGRectGetWidth(self.scrollView.frame), 30.0f)
//                                                  andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, offset, 0.0f, offset)];
//        titleLabel.text = @"评论标题：";
//        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO);
//        [self.scrollView addSubview:titleLabel];
//        
//        CGFloat titleHeight = [SupportingClass getStringSizeWithString:@"测试" font:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17, NO) widthOfView:CGSizeMake(CGRectGetWidth(self.scrollView.frame)-40.0f, CGFLOAT_MAX)].height+6.0f;
//        self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(offset, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.scrollView.frame)-offset*2.0f, titleHeight)];
//        _titleTextField.delegate = self;
//        [_titleTextField setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfBlack withBroderOffset:nil];
//        _titleTextField.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16, NO);
//        _titleTextField.inputAccessoryView = toolBar;
//        _titleTextField.placeholder = @"请输入不少于8位文字标题";
//        [self.scrollView addSubview:_titleTextField];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        InsetsLabel *starLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_titleTextField.frame)+10.0f, CGRectGetWidth(self.scrollView.frame), 30.0f)
                                                 andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, offset, 0.0f, offset)];
        starLabel.text = @"星评：";
        starLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO);
        [self.scrollView addSubview:starLabel];
        
        CGFloat offsetX = [SupportingClass getStringSizeWithString:starLabel.text font:starLabel.font widthOfView:starLabel.frame.size].width;
        
        CGRect rect = CGRectZero;
        rect.origin.x = offsetX+starLabel.edgeInsets.left;
        rect.origin.y = CGRectGetMaxY(_titleTextField.frame)+10.0f;
        rect.size = CGSizeMake(140.0f, 30.0f);
        self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:rect];
        _starRatingView.allowsHalfStars = NO;
        _starRatingView.maximumValue = 5.0f;
        _starRatingView.minimumValue = 0.0f;
        _starRatingView.value = 0.0f;
        _starRatingView.tintColor = CDZColorOfYellow;
        _starRatingView.userInteractionEnabled = YES;
        [self.scrollView addSubview:_starRatingView];
        
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        InsetsLabel *contentsLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(starLabel.frame)+10.0f, CGRectGetWidth(self.scrollView.frame), 30.0f)
                                                     andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, offset, 0.0f, offset)];
        contentsLabel.text = @"内容：";
        contentsLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO);
        [self.scrollView addSubview:contentsLabel];
        
        
        self.contentsTextView = [[UITextView alloc] initWithFrame:CGRectMake(offset, CGRectGetMaxY(contentsLabel.frame), CGRectGetWidth(self.scrollView.frame)-offset*2.0f, CGRectGetHeight(self.scrollView.frame)*0.5)];
        _contentsTextView.delegate = self;
        _contentsTextView.inputAccessoryView = toolBar;
        _contentsTextView.backgroundColor = CDZColorOfLightGray;
        _contentsTextView.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15, NO);
        [_contentsTextView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.scrollView addSubview:_contentsTextView];
        
        InsetsLabel *contentsHistLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_contentsTextView.frame), 30.0f)
                                                          andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        contentsHistLabel.textColor = CDZColorOfDeepGray;
        contentsHistLabel.font =vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        contentsHistLabel.text = @"请输入不少于16位文字内容";
        [_contentsTextView addSubview:contentsHistLabel];
        
        [_contentsTextView.rac_textSignal subscribeNext:^(NSString *string) {
            contentsHistLabel.hidden = (string.length>0);
        }];
    }
}

#pragma UITextViewDelegate


#pragma UITextFieldDelegate

- (void)resignKeyboard {
    [_titleTextField resignFirstResponder];
    [_contentsTextView resignFirstResponder];
}

- (void)submitComment {
    [self resignKeyboard];
    if (_commentType == CommentTypeOfOrderCommment) {
        [self submitOrderComment];
    }else {
        [self submitShopComment];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submitOrderComment {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSLog(@"%@", self.navigationController.viewControllers);
    if (!self.accessToken||!_theID||[_theID isEqualToString:@""]||!_productID||[_productID isEqualToString:@""]) return;
    [ProgressHUDHandler showHUDWithTitle:@"提交评论中...." onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPostCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:self.accessToken orderMainID:_theID itemNumber:_productID content:_contentsTextView.text rating:@(roundf(_starRatingView.value)).stringValue success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if ([message rangeOfString:@"已经评论"].location!=NSNotFound) {
                    [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfSelectOrderViewInTabBarVC object:nil];
                    if (self.popToSecondVC) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }];
            return ;
        }
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"提交成功" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfSelectOrderViewInTabBarVC object:nil];
            if (self.popToSecondVC) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else {
                [NSNotificationCenter.defaultCenter postNotificationName:@"MODBSReloadData" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [ProgressHUDHandler dismissHUD];
        
        
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

- (void)submitShopComment {
    if (!self.accessToken||!_theID) return;
    [ProgressHUDHandler showHUDWithTitle:@"提交评论中...." onView:nil];
    [[APIsConnection shareConnection] personalCenterAPIsPostCommentForShopRepairFinishWithAccessToken:self.accessToken makeNumber:_theID content:_contentsTextView.text rating:@(roundf(_starRatingView.value)).stringValue success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"提交成功" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            Class detailClass = NSClassFromString(@"MyRepairVC");
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", detailClass];
            id theVC = [[self.navigationController.viewControllers filteredArrayUsingPredicate:predicate] lastObject];
            if (detailClass&&theVC&&self.popToSecondVC) {
                [NSNotificationCenter.defaultCenter postNotificationName:@"MRVCReloadDataWhenViewAppear" object:nil];
                [self.navigationController popToViewController:theVC animated:YES];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [ProgressHUDHandler dismissHUD];
        
        
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
