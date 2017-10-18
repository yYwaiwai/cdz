//
//  ShopServiceSearchListSelectionVC.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//


typedef void (^SSSLSResultBlock)(NSString *shopID, NSString *shopName);
#import "XIBBaseViewController.h"

@interface ShopServiceSearchListSelectionVC : XIBBaseViewController

@property (nonatomic, strong) NSString *repairItem;

@property (nonatomic, copy) SSSLSResultBlock resultBlock;

@end
