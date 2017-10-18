//
//  BaseTableViewController.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self pageObjectToDefault];
}

- (NSString *)accessToken {
    return vGetUserToken;
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
    [self setAccessToken:vGetUserToken];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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

- (void)handleMissingTokenAction {
    [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
        
    }];
}

- (void)dealloc {
    
}
@end
