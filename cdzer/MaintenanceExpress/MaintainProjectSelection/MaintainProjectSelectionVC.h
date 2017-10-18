//
//  MaintainProjectSelectionVC.h
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kMaintenanceItemListObject @"MaintenanceItemListObject"
#import "XIBBaseViewController.h"

@interface MaintainProjectSelectionVC : XIBBaseViewController

typedef void (^MaintainProjectSelectionBlock)(NSMutableSet <NSIndexPath *> *regularMaintenanceSelectedList,
                                              NSMutableSet <NSIndexPath *> *deepMaintenanceSelectedList,
                                              NSMutableArray <NSArray *> *dataSourceList);

@property (nonatomic, copy) MaintainProjectSelectionBlock maintainProjectSelectionBlock;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *regularMaintenanceSelectedList;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *deepMaintenanceSelectedList;

@property (nonatomic, strong) NSMutableArray <NSArray *> *dataSourceList;

@property (nonatomic, copy) MaintainProjectSelectionBlock selectionBlock;

@end
