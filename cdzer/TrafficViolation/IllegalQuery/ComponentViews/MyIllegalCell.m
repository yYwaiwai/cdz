//
//  MyIllegalCell.m
//  cdzer
//
//  Created by 车队长 on 16/12/7.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyIllegalCell.h"

@implementation MyIllegalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.contronView.layer setCornerRadius:5];
    [self.contronView.layer setMasksToBounds:YES];
    [self.contronView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.messageBottomView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
    self.line1.backgroundColor=[UIColor colorWithHexString:@"cdced4" alpha:1.0];
    self.line2.backgroundColor=[UIColor colorWithHexString:@"cdced4" alpha:1.0];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)updateUIData:(NSDictionary *)detailData{
@autoreleasepool {
    if (detailData.count==0) {
        _timeLabel.text = @"";
        _resonLabel.text = @"";
        _addressLabel.text = @"";
        _markLabel.text =  @"";
        _forfeitLabel.text = @"";
        
    }else {
        _timeLabel.text = detailData[@"violation_time"];
        _resonLabel.text = detailData[@"violation_content"];
        _addressLabel.text = detailData[@"violation_place"];
        _markLabel.text = detailData[@"violation_point"];
        _forfeitLabel.text = detailData[@"violation_price"];
    }
}
}
@end
