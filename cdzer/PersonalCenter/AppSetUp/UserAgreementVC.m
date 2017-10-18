//
//  UserAgreementVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/22.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "UserAgreementVC.h"

@interface UserAgreementVC ()

@end

@implementation UserAgreementVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *urlString = [kTNCURLPrefix stringByAppendingString:@"agreement.html"];
    self.URL = [NSURL URLWithString:urlString];
    [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload) isNeedToSet:YES];
    self.title = @"用户协议";
    self.showPageTitleAndURL = YES;
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
