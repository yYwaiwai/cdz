//
//  BaseTableViewController.h
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseConfigLoadingHeader.h"

@interface BaseTableViewController : UITableViewController
///请求的accessToken
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL shouldReloadData;
/// 重新刷新列表
@property (nonatomic, strong) NSMutableArray *reloadFuncWithParaList;

@property (nonatomic, assign) BOOL viewWillDisappearShoulPassIt;

@property (nonatomic, strong) NSNumber *pageNums;
@property (nonatomic, strong) NSNumber *pageSizes;
@property (nonatomic, strong) NSNumber *totalPageSizes;

- (void)pageObjectPlusOne;
- (void)pageObjectMinusOne;
- (void)pageObjectToDefault;

- (void)handleMissingTokenAction;

- (BOOL)executeReloadFunction;

- (void)setReloadFuncWithAction:(SEL)action parametersList:(NSArray *)parametersList;

@end
