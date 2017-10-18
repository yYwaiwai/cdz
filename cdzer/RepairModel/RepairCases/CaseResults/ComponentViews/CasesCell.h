//
//  CasesCell.h
//  cdzer
//
//  Created by 车队长 on 16/11/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

typedef NS_ENUM(NSUInteger, RCCellAction) {
    RCCellActionOfWriteAComment,
    RCCellActionOfRepairDetailDisplay,
    RCCellActionOfCommentDisplay,
    RCCellActionOfPushCommentList,
    RCCellActionOfPushToRepairShop,
};

typedef void(^RCCellActionBlock)(RCCellAction action, NSIndexPath *indexPath);

#import <UIKit/UIKit.h>
@class RepairCaseResultDTO;
@interface CasesCell : UITableViewCell

@property (copy, nonatomic) RCCellActionBlock actionBlock;

@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)updateUIData:(RepairCaseResultDTO *)dataObject;

@end
