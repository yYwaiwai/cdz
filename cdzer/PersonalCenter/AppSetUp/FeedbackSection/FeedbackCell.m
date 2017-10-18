//
//  FeedbackCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "FeedbackCell.h"

@implementation FeedbackCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userBgView.layer.cornerRadius=3.0;
    self.userBgView.layer.masksToBounds=YES;
    self.cdzerBgView.layer.cornerRadius=3.0;
    self.cdzerBgView.layer.masksToBounds=YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
