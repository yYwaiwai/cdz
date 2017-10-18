//
//  MRLBUpperTitleCell.m
//  cdzer
//
//  Created by KEns0n on 12/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MRLBUpperTitleCell.h"

@implementation MRLBUpperTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *borderOffset = [BorderOffsetObject new];
    borderOffset.bottomLeftOffset = 12;
    [self.mainTitleView.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
}

@end
