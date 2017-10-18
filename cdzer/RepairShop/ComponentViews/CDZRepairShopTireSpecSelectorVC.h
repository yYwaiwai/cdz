//
//  CDZRepairShopTireSpecSelectorVC.h
//  cdzer
//
//  Created by KEns0nLau on 7/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

typedef void(^CDZRSTSSReponseBlock)(NSUInteger tireWidthSpec, NSUInteger tireRatioSpec, NSUInteger tireDiameterSpec);
#import "XIBBaseViewController.h"

@interface CDZRepairShopTireSpecSelectorVC : XIBBaseViewController

@property (nonatomic, assign) NSUInteger tireWidthSpec;//轮胎面宽

@property (nonatomic, assign) NSUInteger tireRatioSpec;//轮胎扁平比

@property (nonatomic, assign) NSUInteger tireDiameterSpec;//轮胎直径

@end
