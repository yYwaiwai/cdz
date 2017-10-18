//
//  ApplyRefundVC.h
//  cdzer
//
//  Created by 车队长 on 16/9/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void(^ApplyRefundVCSuccessBlock)();

@interface ApplyRefundVC : XIBBaseViewController

@property (nonatomic, copy) ApplyRefundVCSuccessBlock successBlock;

@property (nonatomic, assign) NSInteger idxID;

@property (nonatomic, strong) NSString *orderID;

@property (nonatomic, strong) NSString *productID;

@property (nonatomic, strong) NSString *stateName;

@end
