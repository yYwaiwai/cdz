//
//  RepairCasesResultCell.h
//  cdzer
//
//  Created by KEns0n on 6/23/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  InsetsLabel;
@interface RepairCasesResultCell : UITableViewCell

@property (nonatomic, strong) UIButton *moreButton;

- (void)updateUIDataWithData:(NSDictionary *)dataDetail wasFirstCell:(BOOL)wasFirstCell withRepairDetail:(NSDictionary *)repairDetail;

+ (CGFloat)getCellHieght:(NSDictionary *)detail wasFirstCell:(BOOL)wasFirstCell withRepairDetail:(NSDictionary *)repairDetail;
@end
