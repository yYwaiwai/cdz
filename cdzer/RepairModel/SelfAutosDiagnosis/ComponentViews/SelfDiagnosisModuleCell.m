//
//  SelfDiagnosisModuleCell.m
//  cdzer
//
//  Created by 车队长 on 16/10/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SelfDiagnosisModuleCell.h"
@interface SelfDiagnosisModuleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *seleImageView;

@end

@implementation SelfDiagnosisModuleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.seleImageView.hidden = !selected;

    // Configure the view for the selected state
}

@end
