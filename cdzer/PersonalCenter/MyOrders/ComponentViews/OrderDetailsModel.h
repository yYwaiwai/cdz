//
//  OrderDetailsModel.h
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kCellTypeOfSpace @"spaceCell"
#define kCellTypeOfTitle @"titleCell"
#define kCellTypeOfNormalContent @"normalContentCell"
#define kCellTypeOfPriceContent @"priceContentCell"

#define kCellTypeOfCommodityInformation @"commodityInformationCell"
#define kCellTypeOfTimeCostInformation @"timeCostInformationCell"

#import <Foundation/Foundation.h>
#import "CDZOPCObjectComponents.h"
#import "ApplyRefundVC.h"

@interface OrderDetailsModel : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) ApplyRefundVCSuccessBlock applySuccessBlock;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *contentDetail;

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;
@end
