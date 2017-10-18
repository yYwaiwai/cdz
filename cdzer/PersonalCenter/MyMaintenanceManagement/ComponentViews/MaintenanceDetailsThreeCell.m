//
//  MaintenanceDetailsThreeCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintenanceDetailsThreeCell.h"

@implementation MaintenanceDetailsThreeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectImageView.highlighted = selected;
    // Configure the view for the selected state
}

@end
