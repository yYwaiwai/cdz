//
//  OrderDetailsVC.h
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface OrderDetailsVC : XIBBaseViewController
@property (nonatomic, strong) NSString *orderID;
@property (nonatomic, strong) NSDictionary *contentDetail;
@property (nonatomic, strong) NSString *orderType;
@property (nonatomic, strong) NSString *orderBack;
@property (nonatomic, strong) NSNumber *regTag;
@end
