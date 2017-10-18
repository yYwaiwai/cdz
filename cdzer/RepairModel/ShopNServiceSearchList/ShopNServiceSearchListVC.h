//
//  ShopNServiceSearchListVC.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface ShopNServiceSearchListVC : XIBBaseViewController

@property (nonatomic, strong) NSIndexPath *selelctedSpecShopIndexPath;

@property (nonatomic, strong) NSArray <NSDictionary *> *specShopServiceTypeList;

@end
