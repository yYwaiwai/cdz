//
//  DiagnosticResultsCell.m
//  cdzer
//
//  Created by 车队长 on 16/10/28.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "DiagnosticResultsCell.h"

@interface DiagnosticResultsCell ()

@property (weak, nonatomic) IBOutlet UIView *labelBgView;

@property (weak, nonatomic) IBOutlet UIImageView *seleImage;

@end

@implementation DiagnosticResultsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.labelBgView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.0 withColor:nil withBroderOffset:nil];
    [self.labelBgView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.seleImage.hidden = !selected;
    if (selected) {
         [self.labelBgView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    }else{
         [self.labelBgView setViewBorderWithRectBorder:UIRectBorderNone borderSize:0 withColor:nil withBroderOffset:nil];
    }
    
    // Configure the view for the selected state
}

@end
