//
//  MaintenanceRecordCell.h
//  cdzer
//
//  Created by KEns0nLau on 10/11/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MaintenanceRecordCellEditBlock)(NSIndexPath *indexPath);

@interface MaintenanceRecordCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) MaintenanceRecordCellEditBlock editBlock;

- (void)updateUIDate:(NSDictionary *)dataDetail;

@end
