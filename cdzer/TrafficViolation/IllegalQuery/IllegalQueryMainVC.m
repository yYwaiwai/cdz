//
//  IllegalQueryMainVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "IllegalQueryMainVC.h"
#import "IllegalQueryVC.h"
#import "IllegalRankingVC.h"

#import "HighViolationLocationVC.h"

@interface IllegalQueryMainVC ()<UITabBarControllerDelegate>
{
    BOOL _getRemindNavBeforeSet;
    BOOL _wasSet;
    NSNumber *_presetIndex;
}
@end

@implementation IllegalQueryMainVC

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
        self.tabBar.tintColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        
    }
}

- (void)setUpTabBariCons {
    @autoreleasepool {
        
        UIImage *imageTabOneOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"weizhangchaxunSelected@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabOneOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"weizhangchaxunUnSelect@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"违章查询" image:imageTabOneOff selectedImage:imageTabOneOn];
        tabBarItem1.tag = 0;

        
        UIImage *imageTabTwoOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"zhoubiangaofaSelected@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabTwoOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"zhoubiangaofaUnselect@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"周边高发"  image:imageTabTwoOff selectedImage:imageTabTwoOn];
        tabBarItem2.tag = 1;
        
        
        UIImage *imageTabThreeOn = [[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"weizhangpaihangSelected@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageTabThreeOff = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"weizhangpaihangUnselect@3x" ofType:@"png"]];
        UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"违章排行"  image:imageTabThreeOff selectedImage:imageTabThreeOn];
        tabBarItem3.tag = 2;

        
        
        NSArray * tabBarItems = [NSArray arrayWithObjects:tabBarItem1, tabBarItem2, tabBarItem3, nil];
        
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[BaseViewController class]]||
                [obj isKindOfClass:[XIBBaseViewController class]]) {
                [obj setTabBarItem:tabBarItems[idx]];
            }        }];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (void)initializationUI {
    @autoreleasepool {
        
        IllegalQueryVC *VC1 = [[IllegalQueryVC alloc] init];
//        VC1.title=@"违章查询";
        
        HighViolationLocationVC *VC2 = [[HighViolationLocationVC alloc] init];
        
        IllegalRankingVC *VC3 = [[IllegalRankingVC alloc] init];
        
        NSArray* controllers = [NSArray arrayWithObjects:VC1, VC2, VC3, nil];
        self.viewControllers = controllers;
        [self setUpTabBariCons];
        if (_presetIndex.unsignedIntegerValue!=self.selectedIndex) {
            [self setSelectedIndex:_presetIndex.unsignedIntegerValue];
        }
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
