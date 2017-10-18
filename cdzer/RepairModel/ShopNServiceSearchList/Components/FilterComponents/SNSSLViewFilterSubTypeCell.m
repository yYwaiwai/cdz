//
//  SNSSLViewFilterSubTypeCell.m
//  cdzer
//
//  Created by KEns0n on 24/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSSLViewFilterSubTypeCell.h"

@implementation SNSSLViewFilterSubTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.backgroundColor = CDZColorOfClearColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateSeletedUIConfig];
}

- (void)updateSeletedUIConfig {
    
    self.textLabel.highlighted = self.selected;
    self.backgroundColor = self.selected?CDZColorOfWhite:[UIColor colorWithRed:0.980 green:0.980 blue:0.980 alpha:1.00];
    UIRectBorder rectBorder = self.selected?(UIRectBorderTop|UIRectBorderBottom):UIRectBorderNone;
    if (self.indexPath.row==0) rectBorder = self.selected?UIRectBorderBottom:UIRectBorderNone;
    [self setViewBorderWithRectBorder:rectBorder borderSize:0.5 withColor:nil withBroderOffset:nil];
}
@end
