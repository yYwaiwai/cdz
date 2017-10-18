
//
//  NewsVC.m
//  cdzer
//
//  Created by KEns0n on 06/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "NewsVC.h"
@interface NewsVC () <DZNNavigationDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftBarBtn;

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;


@end

@implementation NewsVC

- (void)dealloc {
    self.webView.navDelegate = nil;
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.URL = [NSURL URLWithString:kNewsURLPrefix];
    self.rightBarBtn = [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView) isNeedToSet:YES];
    UIImage *img = [UIImage imageNamed:@"back_icon"];
    self.leftBarBtn = [self setLeftNavButtonWithTitleOrImage:img style:UIBarButtonItemStylePlain target:self action:@selector(returnWebView)                                                     titleColor:nil isNeedToSet:YES];
    self.showPageTitleAndURL = NO;
    self.hideBarsWithGestures = NO;
    self.supportedWebNavigationTools = WKWebNavigationToolNone;
    self.supportedWebActions = WKWebActionNone;
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
    if(self.webView.canGoBack){
        self.tabBarController.navigationItem.leftBarButtonItem = _leftBarBtn;
    }
    self.tabBarController.navigationItem.rightBarButtonItem = _rightBarBtn;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.bounds = self.view.bounds;
}

#pragma mark - 按钮的点击
- (void)reloadWebView {
    [self.webView reload];
    self.webView.scrollView.contentOffset = CGPointZero;
}

- (void)returnWebView{
    [self.webView goBack];
    self.tabBarController.navigationItem.leftBarButtonItem = self.webView.canGoBack?_leftBarBtn:nil;
}


- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress {
    [super webView:webView didUpdateProgress:progress];
    if (progress>=1) {
        self.tabBarController.navigationItem.leftBarButtonItem = self.webView.canGoBack?self.leftBarBtn:nil;
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
