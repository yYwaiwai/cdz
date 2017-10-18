//
//  GroupCommentListCell.m
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "GroupCommentListCell.h"

@implementation GroupCommentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.commodityButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:
     [UIColor colorWithRed:0.973 green:0.686 blue:0.188 alpha:1.00] withBroderOffset:nil];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
