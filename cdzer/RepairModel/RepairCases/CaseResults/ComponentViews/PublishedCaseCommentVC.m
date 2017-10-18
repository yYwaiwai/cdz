//
//  PublishedCaseCommentVC.m
//  cdzer
//
//  Created by KEns0n on 03/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PublishedCaseCommentVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import "CaseResultsVC.h"

@interface PublishedCaseCommentVC ()

@property (nonatomic, strong) NSArray *constraints;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UITextView *evaluationTextView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UIView *textViewBgView;

@property (strong, nonatomic) NSString *theCaseID;

@end

@implementation PublishedCaseCommentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.bgView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.textViewBgView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.cancelButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:10.0f];
    [self.confirmButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:10.0f];
    [self.cancelButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:[UIColor colorWithHexString:@"cccccc"] withBroderOffset:nil];
    [self.confirmButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showViewWithCaseID:(NSString *)theCaseID {
    if (!theCaseID||[theCaseID isEqualToString:@""]) return;
    [self.view removeFromSuperview];
    UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (!self.constraints) {
        self.constraints = [self.view addSelfByFourMarginToSuperview:rootVC.view];
    }else {
        [rootVC.view addSubview:self.view];
        [rootVC.view addConstraints:self.constraints];
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.view.alpha = 1;
        
    }];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    
    self.theCaseID = theCaseID;
}

- (IBAction)hideView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.theCaseID = nil;
        self.evaluationTextView.text = @"";
        [self.view removeFromSuperview];
    }];
    
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (!isSuccess) {
        [self hideView];
        UINavigationController *navVC = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        if ([navVC.visibleViewController isKindOfClass:CaseResultsVC.class]) {
            XIBBaseViewController *vc = (XIBBaseViewController *)navVC.visibleViewController;
            vc.shouldReloadData = YES;
            [vc viewWillAppear:YES];
        }
    }
}

- (IBAction)submitCaseComment {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
    }
    
    if (self.evaluationTextView.text.length==0||
        [self.evaluationTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请您输入对该案例的评价" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection repairCaseAPIsPostCaseCommentWithAccessToken:self.accessToken caseID:self.theCaseID commentContent:self.evaluationTextView.text success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        NSLog(@"%@",operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) return;
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        [ProgressHUDHandler showSuccessWithStatus:@"评论发表成功！" onView:nil completion:^{
            [self hideView];
            UINavigationController *navVC = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
            if ([navVC.visibleViewController isKindOfClass:CaseResultsVC.class]) {
                XIBBaseViewController *vc = (XIBBaseViewController *)navVC.visibleViewController;
                vc.shouldReloadData = YES;
                [vc viewWillAppear:YES];
            }
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
