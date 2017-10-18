//
//  CommodityInformationCell.m
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CommodityInformationCell.h"

@implementation CommodityInformationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *offsetObj = nil;
    if (!self.isLastCell) {
        offsetObj = [BorderOffsetObject new];
        offsetObj.bottomLeftOffset = CGRectGetMinX(self.commodityNameLabel.frame);
    }
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offsetObj];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
