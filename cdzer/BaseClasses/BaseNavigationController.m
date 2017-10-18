//
//  BaseNavigationController.m
//  cdzer
//
//  Created by KEns0n on 2/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseNavigationController.h"
#import <unistd.h>


@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    __block UIScreenEdgePanGestureRecognizer *gestureRecognizer = nil;
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIScreenEdgePanGestureRecognizer.class]) {
            gestureRecognizer = obj;
            *stop = YES;
        };
    }];
    
    [self.view removeGestureRecognizer:gestureRecognizer];
    UIColor *barBKC = [UIColor colorWithHexString:@"FAFAFA"];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"]};
    self.navigationBar.barTintColor = barBKC;
    self.navigationBar.backgroundColor = barBKC;
    self.navigationBar.tintColor = [UIColor colorWithHexString:@"323232"];
    self.navigationBar.layer.borderWidth = 1;
    self.navigationBar.layer.borderColor = [barBKC CGColor];
    [self.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];

    // Do any additional setup after loading the view.

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    [self.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithGradient:(NSNotification *)notifi {
    NSString *message = @"加载中";
    if ([notifi object] && [[notifi object] isKindOfClass:[NSString class]]) {
       message = [[notifi object] stringValue];
    }
}

- (void)hideHUD:(NSNotification *)notifi {
    
}

/*
#pragma mark- Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    
    return kShouldHiddenStatusBar;
}

- (BOOL)shouldAutorotate {
    UIViewController *vc = self.topViewController;
    NSLog(@"shouldAutorotate::%d",[vc respondsToSelector:@selector(shouldAutorotate)]);
    if ([vc respondsToSelector:@selector(shouldAutorotate)]) {
        return [vc shouldAutorotate];
    }
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.topViewController;
    NSLog(@"preferredInterfaceOrientationForPresentation::%d",[vc respondsToSelector:@selector(preferredInterfaceOrientationForPresentation)]);
    if ([vc respondsToSelector:@selector(preferredInterfaceOrientationForPresentation)]) {
        return [vc preferredInterfaceOrientationForPresentation];
    }

    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.topViewController;
    NSLog(@"supportedInterfaceOrientations::%d",[vc respondsToSelector:@selector(supportedInterfaceOrientations)]);
    if ([vc respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [vc supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    UIViewController *vc = self.topViewController;
    NSLog(@"viewWillTransitionToSize:withTransitionCoordinator::%d",[vc respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]);
    if ([vc respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        [vc viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }
}
@end
