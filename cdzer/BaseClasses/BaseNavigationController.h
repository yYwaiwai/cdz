//
//  BaseNavigationController.h
//  cdzer
//
//  Created by KEns0n on 2/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseConfigLoadingHeader.h"

@interface BaseNavigationController : UINavigationController

@property (nonatomic, assign) BOOL shouldReloadData;

@property (nonatomic, strong) BaseViewController *tmpVCHolder;

@end
