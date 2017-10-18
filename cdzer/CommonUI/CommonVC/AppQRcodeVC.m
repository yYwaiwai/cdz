//
//  AppQRcodeVC.m
//  cdzer
//
//  Created by KEns0n on 1/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "AppQRcodeVC.h"
#import "AppDelegate.h"

@interface AppQRcodeVC ()

@end

@implementation AppQRcodeVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CDZColorOfClearColor;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.contentView.bounds;
    [button addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    
    UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"appqr" type:FMImageTypeOfPNG needToUpdate:NO];
    
    UIImageView *imageVC = [[UIImageView alloc] initWithImage:image];
    imageVC.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2, CGRectGetHeight(self.contentView.frame)/2);
    [self.contentView addSubview:imageVC];
    
    // Do any additional setup after loading the view.
}

- (void)dismissSelf {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        BaseNavigationController *navigationController = [(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
        navigationController.tmpVCHolder = nil;
    }];
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
