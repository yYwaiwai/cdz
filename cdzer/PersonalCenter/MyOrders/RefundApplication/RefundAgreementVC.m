//
//  RefundAgreementVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/22.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RefundAgreementVC.h"

@interface RefundAgreementVC ()

@end

@implementation RefundAgreementVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *urlString = [kTNCRepairURLPrefix stringByAppendingString:@"member/returnProtocol.html"];
    self.URL = [NSURL URLWithString:urlString];
    self.title = @"车队长退款协议";
    [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload) isNeedToSet:YES];
    self.showLoadingProgress = NO;
    self.hideBarsWithGestures = NO;
    self.supportedWebNavigationTools = WKWebNavigationToolNone;
    self.supportedWebActions = WKWebActionNone;
    self.webViewContentScale = 300;
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
