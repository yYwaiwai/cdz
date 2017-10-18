//
//  ViolationDetailsVC.h
//  cdzer
//
//  Created by 车队长 on 16/12/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface ViolationDetailsVC : XIBBaseViewController

@property (nonatomic, strong) NSDictionary *tvDetail;

@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSDictionary *violationDetail;

@property (nonatomic, assign) NSInteger isType;

@end
