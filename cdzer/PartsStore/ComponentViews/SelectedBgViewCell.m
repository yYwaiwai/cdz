//
//  SelectedBgViewCell.m
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SelectedBgViewCell.h"

@implementation SelectedBgViewCell

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
    self.bgView.hidden=!selected;
    self.bgView.backgroundColor=[UIColor colorWithHexString:@"f5f5f5"];
    // Configure the view for the selected state
}

@end
