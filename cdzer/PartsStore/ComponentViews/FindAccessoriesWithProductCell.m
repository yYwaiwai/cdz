//
//  FindAccessoriesWithProductCell.m
//  cdzer
//
//  Created by 车队长 on 16/9/7.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "FindAccessoriesWithProductCell.h"

@implementation FindAccessoriesWithProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
