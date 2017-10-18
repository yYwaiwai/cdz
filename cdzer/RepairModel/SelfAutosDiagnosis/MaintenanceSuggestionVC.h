//
//  MaintenanceSuggestionVC.h
//  cdzer
//
//  Created by 车队长 on 16/10/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface MaintenanceSuggestionVC : XIBBaseViewController

@property (nonatomic, strong) NSDictionary *resultData;

@property (nonatomic, strong) NSString *procedureDetailID;

@property (nonatomic, strong) NSString *titleName;

@property (nonatomic, strong) NSString *repairItem;


@end
