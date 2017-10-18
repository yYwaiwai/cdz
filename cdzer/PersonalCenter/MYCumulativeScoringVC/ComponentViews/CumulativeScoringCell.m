//
//  CumulativeScoringCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CumulativeScoringCell.h"

@implementation CumulativeScoringCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
