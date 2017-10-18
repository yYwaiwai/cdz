//
//  MyCaseCell.h
//  cdzer
//
//  Created by 车队长 on 16/11/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MCCellAction) {
    MCCellActionOfRepairDetailDisplay,
    MCCellActionOfRepairReceiptsDisplay,
    MCCellActionOfEditCase,
    MCCellActionOfDeleteCase,
    MCCellActionOfPushToRepairShop,
};

typedef void(^MCCellActionBlock)(MCCellAction action, NSIndexPath *indexPath);


#import <UIKit/UIKit.h>
@class MyCaseResultDTO;
@interface MyCaseCell : UITableViewCell

@property (nonatomic, assign) BOOL isEditMode;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (copy, nonatomic) MCCellActionBlock actionBlock;

- (void)updateUIData:(MyCaseResultDTO *)dataObject;

@end
