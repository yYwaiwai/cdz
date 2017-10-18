//
//  ProjectCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ProjectCell.h"
@implementation ProjectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.checkMarkIV.highlighted = selected;
    self.titleImageView.highlighted = selected;
    // Configure the view for the selected state
}

- (IBAction)buttonAction {
    if (self.indexPath&&self.detailBlock) {
        self.detailBlock(self.indexPath);
    }
}

@end
