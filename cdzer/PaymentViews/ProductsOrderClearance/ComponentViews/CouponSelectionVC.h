//
//  CouponSelectionVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void (^SelectedCouponResultBlock)(NSDictionary * couponDetail);

@interface CouponSelectionVC : XIBBaseViewController

@property (nonatomic, strong) NSString *repairShopName;

@property (nonatomic, strong) NSMutableArray *couponList;

@property (nonatomic, copy) SelectedCouponResultBlock resultBlock;

@end
