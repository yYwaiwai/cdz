//
//  MyMaintenanceManagementVC.h
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "RepairDetailDToModel.h"



@interface MyMaintenanceManagementVC : XIBBaseViewController

/// 当前的类型
@property (nonatomic, assign) CDZMaintenanceStatusType currentStatusType;

@property (nonatomic, strong) NSString *repairID;

@end
