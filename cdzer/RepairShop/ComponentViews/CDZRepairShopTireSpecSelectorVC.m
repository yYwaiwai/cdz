//
//  CDZRepairShopTireSpecSelectorVC.m
//  cdzer
//
//  Created by KEns0nLau on 7/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CDZRepairShopTireSpecSelectorVC.h"

@interface CDZRepairShopTireSpecSelectorVC ()

@end

@implementation CDZRepairShopTireSpecSelectorVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
    }
}

- (void)initializationUI {
    @autoreleasepool {
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
