//
//  FullScreenAdvertisementVC.h
//  cdzer
//
//  Created by KEns0n on 17/05/2017.
//  Copyright © 2017 CDZER. All rights reserved.
//
typedef void (^FSACloseSignalBlock)();

#import "XIBBaseViewController.h"

@interface FullScreenAdvertisementVC : XIBBaseViewController

@property (nonatomic, copy) FSACloseSignalBlock closingBlock;

- (void)setSuperView:(UIView *)superView;

@end
