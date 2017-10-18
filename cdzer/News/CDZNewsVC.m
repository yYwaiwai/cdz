//
//  CDZNewsVC.m
//  cdzer
//
//  Created by KEns0n on 12/28/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  新闻VC

#import "CDZNewsVC.h"
#import <DZNWebViewController/DZNWebViewController.h>

@interface CDZNewsVC ()<DZNNavigationDelegate>
/// 左边按钮
@property (nonatomic, strong) UIBarButtonItem *leftBarBtn;

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;

/// 网页视图
@property (nonatomic, strong) DZNWebViewController *currentWebView;

@end

@implementation CDZNewsVC

- (void)dealloc {
    self.currentWebView.webView.navDelegate = nil;
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = getLocalizationString(@"news");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
    self.tabBarController.title = self.title;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.automaticallyAdjustsScrollViewInsets = YES;
    self.tabBarController.extendedLayoutIncludesOpaqueBars = NO;
    self.tabBarController.navigationController.navigationBar.hidden = NO;
    [self.tabBarController.view setNeedsLayout];
    [self.navigationController.view setNeedsLayout];
    if(self.currentWebView.webView.canGoBack){
        self.tabBarController.navigationItem.leftBarButtonItem = _leftBarBtn;
    }
    self.tabBarController.navigationItem.rightBarButtonItem = _rightBarBtn;
}


#pragma mark UI Init
- (void)componentSetting {
    @autoreleasepool {
        self.rightBarBtn = [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView) isNeedToSet:YES];
        UIImage *img = [UIImage imageNamed:@"back_icon"];
        self.leftBarBtn = [self setLeftNavButtonWithTitleOrImage:img style:UIBarButtonItemStylePlain target:self action:@selector(returnWebView)                                                     titleColor:nil isNeedToSet:YES];
    }
}

#pragma mark - 按钮的点击
- (void)reloadWebView {
    [self.currentWebView.webView reload];
    self.currentWebView.webView.scrollView.contentOffset = CGPointZero;
}

- (void)returnWebView{
    [self.currentWebView.webView goBack];
    self.tabBarController.navigationItem.leftBarButtonItem = self.currentWebView.webView.canGoBack?_leftBarBtn:nil;
}





- (void)initializationUI {
    @autoreleasepool {
        self.currentWebView = [[DZNWebViewController alloc] initWithURL:[NSURL URLWithString:kNewsURLPrefix]];
        self.currentWebView.webView.navDelegate = self;
        self.currentWebView.showPageTitleAndURL = NO;
        self.currentWebView.hideBarsWithGestures = NO;
        self.currentWebView.supportedWebNavigationTools = DZNWebNavigationToolNone;
        self.currentWebView.supportedWebActions = DZNWebActionNone;
        self.currentWebView.view.frame = self.view.bounds;
        [self.currentWebView.view addSelfByFourMarginToSuperview:self.view];
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
}



- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress {
    if (progress>=1) {
        NSString *scaleHTML = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\100\'";
        [webView evaluateJavaScript:scaleHTML completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
        self.tabBarController.navigationItem.leftBarButtonItem = self.currentWebView.webView.canGoBack?self.leftBarBtn:nil;
    }
}

@end
