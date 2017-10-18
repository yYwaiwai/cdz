//
//  TrafficViolationMainVC.m
//  cdzer
//
//  Created by KEns0n on 12/30/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "TrafficViolationMainVC.h"
#import "HighViolationLocationVC.h"

@interface TrafficViolationMainVC ()<UITabBarControllerDelegate>
{
    BOOL _getRemindNavBeforeSet;
    BOOL _wasSet;
    NSNumber *_presetIndex;
}
@end

@implementation TrafficViolationMainVC

- (BOOL)getRemindNavBeforeSet {
    return _getRemindNavBeforeSet;
}

- (void)setRemindNavBeforeSet:(BOOL)set {
    _getRemindNavBeforeSet = set;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (!_presetIndex) {
        _presetIndex = @(selectedIndex);
    }
    [super setSelectedIndex:selectedIndex];
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self componentSetting];
    
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_wasSet) {
        [self initializationUI];
        [self setReactiveRules];
        _wasSet = YES;
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
  
    }
}

- (void)setUpTabBariCons {
    @autoreleasepool {
        UIImage *imageTab1 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                                fileName:@"ve_icon"
                                                                                    type:FMImageTypeOfPNG
                                                                            needToUpdate:YES];
        UIImage *imageTab2 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                                fileName:@"hv_icon"
                                                                                    type:FMImageTypeOfPNG
                                                                            needToUpdate:YES];
        UIImage *imageTab3 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                                fileName:@"vr_icon"
                                                                                    type:FMImageTypeOfPNG
                                                                            needToUpdate:YES];
        
        UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"违章查询"
                                                                  image:imageTab1
                                                                    tag:0];
        tabBarItem1.tag = 0;
        UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"违章高发地"
                                                                  image:imageTab2
                                                                    tag:1];
        tabBarItem2.tag = 1;
        UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"违章排行榜"
                                                                  image:imageTab3
                                                                    tag:2];
        tabBarItem3.tag = 2;
        
        NSArray * tabBarItems = [NSArray arrayWithObjects:tabBarItem1, tabBarItem2, tabBarItem3, nil];
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[BaseViewController class]]) {
                [obj setTabBarItem:tabBarItems[idx]];
            }
        }];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (void)initializationUI {
    @autoreleasepool {
        
        ViolationEnquiryVC *VC1 = [[ViolationEnquiryVC alloc] init];
        
        HighViolationLocationVC *VC2 = [[HighViolationLocationVC alloc] init];
        
        ViolationRankingVC *VC3 = [[ViolationRankingVC alloc] init];
        
        NSArray* controllers = [NSArray arrayWithObjects:VC1, VC2, VC3, nil];
        self.viewControllers = controllers;
        [self setUpTabBariCons];
        if (_presetIndex.unsignedIntegerValue!=self.selectedIndex) {
            [self setSelectedIndex:_presetIndex.unsignedIntegerValue];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
