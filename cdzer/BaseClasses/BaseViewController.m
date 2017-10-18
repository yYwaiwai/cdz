//
//  BaseViewController.m
//  cdzer
//
//  Created by KEns0n on 2/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseViewController.h"
#import "SignInVC.h"
#import "CitySelectionVC.h"
#import "KeyCityDTO.h"
#import "UserAutosSelectonVC.h"
#import "AppDelegate.h"


@interface BaseViewController ()
@end

@implementation BaseViewController


- (void)dealloc {
    
}

- (void)viewDidLoad {
    
    self.reloadFuncWithParaList = [@[] mutableCopy];
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = YES;
    
    if ([SupportingClass isOS7Plus]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
    @autoreleasepool {
        CGRect rect = self.view.bounds;
        if (!self.ignoreViewResize) {
            CGFloat height = vNavBarHeight;
            if (!kShouldHiddenStatusBar) height+= 20.0f;
            if (self.navigationController&&!self.navigationController.navigationBarHidden) {
                rect.size.height -= height;
            }
            if(self.tabBarController){
                rect.size.height -= CGRectGetHeight(self.tabBarController.tabBar.frame);
                BOOL wasNavBeforeSet = NO;
                SEL selector = NSSelectorFromString(@"getRemindNavBeforeSet");
                if ([self.tabBarController respondsToSelector:selector]) {
                    NSLog(@"%@",[self.tabBarController valueForKey:@"getRemindNavBeforeSet"]);
                    wasNavBeforeSet = [[self.tabBarController valueForKey:@"getRemindNavBeforeSet"] boolValue];
                }
                if (!self.tabBarController.navigationController.navigationBarHidden&&!self.navigationController&&
                    (self.tabBarController.navigationController||wasNavBeforeSet)) {
                    rect.size.height -= height;
                }
                
            }
        }
        self.contentView = [[UIView alloc]initWithFrame:rect];
        _contentView.backgroundColor = CDZColorOfWhite;
        [self.view addSubview:_contentView];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:_contentView.bounds];
        _scrollView.backgroundColor = CDZColorOfWhite;
        _scrollView.bounces = NO;
        _scrollView.hidden = YES;
        [self.contentView addSubview:self.scrollView];
        self.view.frame = self.contentView.bounds;
    }
    [self pageObjectToDefault];
    // Do any additional setup after loading the view.
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.integerValue+1);
}

- (void)pageObjectMinusOne {
    if (self.pageNums.integerValue==1) {
        return;
    }
    self.pageNums = @(self.pageNums.integerValue-1);
}

- (void)pageObjectToDefault {
     self.pageNums = @1;
     self.pageSizes = @10;
     self.totalPageSizes = @0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!CGRectEqualToRect(self.view.bounds, self.contentView.bounds)) {
        self.contentView.frame = self.view.bounds;
    }
}

- (NSString *)accessToken {
    return vGetUserToken;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadViewData {
    
}


/*
#pragma mark- Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    
    return kShouldHiddenStatusBar;
}

- (void)setReloadFuncWithAction:(SEL)action parametersList:(NSArray *)parametersList {
    @autoreleasepool {
        if (!self.reloadFuncWithParaList) self.reloadFuncWithParaList = [@[] mutableCopy];
        if ([self respondsToSelector:action]) {
            NSString *selectorStr = NSStringFromSelector(action);
            if (self.reloadFuncWithParaList.count>0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.action LIKE[cd] %@", selectorStr];
                NSArray *result = [self.reloadFuncWithParaList filteredArrayUsingPredicate:predicate];
                if (result&&result.count>0) {
                    return;
                }
            }
            if (!parametersList||parametersList.count==0) {
                parametersList = nil;
                parametersList = @[];
            }
            
            NSDictionary *detail = @{@"action":selectorStr, @"paraList":parametersList};
            [self.reloadFuncWithParaList addObject:detail];
        }
    }
}

- (BOOL)executeReloadFunction {
    if (self.reloadFuncWithParaList.count>0) {
        @autoreleasepool {
            [self.reloadFuncWithParaList enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                SEL selector = NSSelectorFromString(detail[@"action"]);
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
                [inv setSelector:selector];
                [inv setTarget:self];
                NSArray *reloadParameterList = detail[@"paraList"];
                if (reloadParameterList.count>0&&reloadParameterList) {
                    for (int i=0; i<reloadParameterList.count; i++) {
                        id obj = reloadParameterList[i];
                        [inv setArgument:&obj atIndex:2+i]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
                    }
                }
                [inv invoke];
            }];
        }
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)handleMissingTokenAction {
    [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
        
    }];
}

@end
