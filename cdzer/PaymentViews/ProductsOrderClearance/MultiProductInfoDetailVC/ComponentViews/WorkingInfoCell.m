//
//  WorkingInfoCell.m
//  cdzer
//
//  Created by KEns0nLau on 9/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "WorkingInfoCell.h"

@implementation WorkingInfoCell

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomLeftOffset = self.fullBottomBorderLine?0:12;
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
