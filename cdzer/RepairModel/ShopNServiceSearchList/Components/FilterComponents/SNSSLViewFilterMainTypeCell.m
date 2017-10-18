//
//  SNSSLViewFilterMainTypeCell.m
//  cdzer
//
//  Created by KEns0n on 24/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSSLViewFilterMainTypeCell.h"



@implementation SNSSLViewFilterMainTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = CDZColorOfWhite;
    [self updateSeletedUIConfig];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateSeletedUIConfig];
}

- (void)updateSeletedUIConfig {
    self.textLabel.highlighted = self.selected;
}

@end
