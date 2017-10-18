//
//  MyCarInsuranceCell.m
//  cdzer
//
//  Created by 车队长 on 16/12/29.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCarInsuranceCell.h"

@implementation MyCarInsuranceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.topBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.middleBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
    [self.insuranceButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    [self.insuranceButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)upUIdataWith:(NSDictionary *)data
{
    self.bottomBgViewLayoutConstraint.constant=0;
    self.insuranceButtonLayoutConstraint.constant=0;
    self.insuranceButton.hidden=YES;
    [self.bottomBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    
    self.dateTimeLabel.text=data[@"appoint_time"];
    self.statusLabel.text=data[@"state"];
    NSString *imgURL = [data objectForKey:@"imgurl"];
    if ([imgURL containsString:@"http"]) {
        [self.autosBrandLogo sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    self.titleLabel.text=[NSString stringWithFormat:@"%@-%@",data[@"company"],data[@"intype"]];
    self.licensePlateLabel.text=[NSString stringWithFormat:@"车牌：%@",data[@"car_number"]];
   CGFloat sum=[NSString stringWithFormat:@"%@",data[@"sum"]].floatValue;
    self.priceLabel.text=[NSString stringWithFormat:@"￥%.2f",sum];
        
        if ([data[@"state"] isEqualToString:@"预约成功"]) {
            [self.bottomBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
            self.bottomBgViewLayoutConstraint.constant=33;
            self.insuranceButtonLayoutConstraint.constant=23;
            self.insuranceButton.hidden=NO;
            [self.insuranceButton setTitle:@"立即支付" forState:UIControlStateNormal];
        }
        if ([data[@"state"] isEqualToString:@"预约失败"]) {
            [self.bottomBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
            self.bottomBgViewLayoutConstraint.constant=33;
            self.insuranceButtonLayoutConstraint.constant=23;
            self.insuranceButton.hidden=NO;
            [self.insuranceButton setTitle:@"重新预约" forState:UIControlStateNormal];
        }
    
    
    
}


- (IBAction)btnAction:(UIButton *)sender {
    if (self.btnActionBlock) {
        self.btnActionBlock(self.indexPath, [sender titleForState:UIControlStateNormal]);
    }
}

@end
