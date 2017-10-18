//
//  MyShoppingCartCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyShoppingCartCell.h"
@interface MyShoppingCartCell ()

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end

@implementation MyShoppingCartCell

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *offset = BorderOffsetObject.new;
    offset.bottomLeftOffset = CGRectGetMinX(self.titleLable.frame);
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:self.fullBottomLine?nil:offset];
}

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
