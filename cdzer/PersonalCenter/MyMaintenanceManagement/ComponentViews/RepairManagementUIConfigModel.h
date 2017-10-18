//
//  RepairManagementUIConfigModel.h
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kCellTypeOfSpace @"spaceCell"
#define kCellTypeOfTitle @"titleCell"
#define kCellTypeOfNormalContent @"normalContentCell"
#define kCellTypeOfDetailContent @"detailContentCell"
#define kCellTypeOfPriceContent @"priceContentCell"
#import <Foundation/Foundation.h>

@interface RepairManagementUIConfigModel : NSObject <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) CDZMaintenanceStatusType currentStatusType;

@property (nonatomic, strong) NSString *processID;

@property (nonatomic, strong) NSDictionary *contentDetail;

@property (nonatomic, readonly) NSString *selectedItemsString;



@end
