//
//  RepairShopMembershipTnCVC.h
//  cdzer
//
//  Created by KEns0n on 16/4/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//
typedef void(^RepairShopMembershipSuccessBlock)();

#import "XIBBaseViewController.h"

@interface RepairShopMembershipTnCVC : XIBBaseViewController

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSString *shopID;

@property (nonatomic, copy) RepairShopMembershipSuccessBlock successBlock;

@end
