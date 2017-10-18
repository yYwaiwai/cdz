//
//  RepairShopMembershipTnCVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairShopMembershipTnCVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import <DZNWebViewController/DZNWebView.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
@interface RepairShopMembershipTnCVC ()<DZNNavigationDelegate, UIWebViewDelegate, WKUIDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, strong) DZNWebView *webView;

@property (nonatomic, weak) IBOutlet NJKWebViewProgressView *progressView;

@end

@implementation RepairShopMembershipTnCVC

- (void)dealloc {
    self.webView.navDelegate = nil;
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员协议";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (!isSuccess) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)componentSetting {
    [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebPage) isNeedToSet:YES];
    
    self.webView = [[DZNWebView alloc] initWithFrame:self.contentView.bounds configuration:[WKWebViewConfiguration new]];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.UIDelegate = self;
    self.webView.navDelegate = self;
    self.webView.scrollView.bounces = NO;
    [self.webView addSelfByFourMarginToSuperview:self.contentView];
    [self.contentView bringSubviewToFront:self.progressView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress {
    if (progress>=1) {
        NSString *scaleHTML = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='200%'"; 
        [webView evaluateJavaScript:scaleHTML completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }
    [self.progressView setProgress:progress animated:YES];
}

- (void)setReactiveRules {
    
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    if (self.webView) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)reloadWebPage {
    [self.webView reload];
}

- (void)initializationUI {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinAndAggressTnC {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    
    [[APIsConnection shareConnection] personalCenterAPIsPostUserJoinRepairShopMembershipWithAccessToken:self.accessToken repairShopID:self.shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            if ([message isContainsString:@"重复添加"]) {
                [SupportingClass showToast:@"您已经是该维修商的会员了，请勿重复添加！"];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            if ([message isContainsString:@"添加失败"]) {
                message = @"加入会员失败，请稍后再试";
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"加入成功" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            if (self.successBlock) {
                self.successBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
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
