//
//  MyRepairShopMemberCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyRepairShopMemberCell.h"

@implementation MyRepairShopMemberCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0 withColor:nil withBroderOffset:nil];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *offsets = [BorderOffsetObject new];
    offsets.leftUpperOffset = round(offsets.leftBottomOffset = CGRectGetHeight(self.setTopButton.frame)*0.3);
    offsets.rightUpperOffset=offsets.rightUpperOffset;
    [self.setTopButton setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:offsets];
    
    [self.shopLogo setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:2.0f];
    [self.shopLogo setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)setMemberToTop:(UIButton *)sender {
    if (self.buttonResponseBlock) {
        self.buttonResponseBlock(NO, YES, self.indexPath);
    }
}

- (IBAction)cancelMember:(id)sender {
    if (self.buttonResponseBlock) {
        self.buttonResponseBlock(YES, NO, self.indexPath);
    }

}
@end
