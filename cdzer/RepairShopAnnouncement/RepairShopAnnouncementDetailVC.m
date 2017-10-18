//
//  RepairShopAnnouncementDetailVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairShopAnnouncementDetailVC.h"

@interface RepairShopAnnouncementDetailVC ()

@end

@implementation RepairShopAnnouncementDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    self.title = @"公告详情";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)reloadWebPage {
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)obj reload];
            
        }
    }];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebPage) isNeedToSet:YES];
    }
}

- (void)initializationUI {
    
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
