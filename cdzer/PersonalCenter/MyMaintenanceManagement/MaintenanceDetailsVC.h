//
//  MaintenanceDetailsVC.h
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "RepairDetailDToModel.h"


@interface MaintenanceDetailsVC : XIBBaseViewController

//@property (nonatomic, strong) RepairDetailDToModel *repairDetail;
//
//@property (nonatomic, strong) NSString *couponID;
//
//@property (nonatomic, strong) NSString *couponName;
//
//@property (nonatomic, strong) NSString *couponAmount;
//
//@property (nonatomic, assign) BOOL haveBindCoupon;
//
//@property (nonatomic, strong) NSString *statusName;
//
//@property (nonatomic, strong) NSNumber *paymentStatus;
@property (nonatomic, strong) NSString *repairID;
/// 当前的类型
@property (nonatomic, assign) CDZMaintenanceStatusType currentStatusType;
// 处理状态
@property (nonatomic, strong) NSString *processID;

@property (nonatomic, strong) NSDictionary *contentDetail;
@end
