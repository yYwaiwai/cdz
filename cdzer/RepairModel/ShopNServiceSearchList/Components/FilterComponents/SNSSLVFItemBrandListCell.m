//
//  SNSSLVFItemBrandListCell.m
//  cdzer
//
//  Created by KEns0n on 24/03/2017.
//  Copyright © 2017 CDZER. All rights reserved.
//

#import "SNSSLVFItemBrandListCell.h"

@implementation SNSSLVFItemBrandListCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.brandLogoImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.brandNameLabel.highlighted = selected;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.brandLogoDefaultImage = self.brandLogoImageView.image;
}

@end
