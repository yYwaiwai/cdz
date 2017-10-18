//
//  ServiceEvaluationVC.h
//  cdzer
//
//  Created by 车队长 on 16/9/1.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface ServiceEvaluationVC : XIBBaseViewController

@property (nonatomic, strong) NSString *repairID;

@property (nonatomic) BOOL isPushFromOrder;

@property (nonatomic) BOOL isCommnetReview;

@property (nonatomic, strong) NSDictionary *resultDic;

@property (nonatomic, strong) NSString *fromVCStr;

@end
