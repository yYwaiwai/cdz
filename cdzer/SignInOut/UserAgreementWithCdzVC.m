//
//  UserAgreementWithCdzVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "UserAgreementWithCdzVC.h"
#import "WKWebViewController.h"
#import "UIView+LayoutConstraintHelper.h"

@interface UserAgreementWithCdzVC ()
@property (nonatomic, strong) WKWebViewController *webView;

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation UserAgreementWithCdzVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *urlString = [kTNCURLPrefix stringByAppendingString:@"agreement.html"];
    NSURL *url = [NSURL URLWithString:urlString];
    self.webView = [[WKWebViewController alloc] initWithURL:url];
    self.webView.webViewContentScale = 250;
    self.webView.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView.view addSelfByFourMarginToSuperview:self.contentView];
}


- (IBAction)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.navBar.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
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
