//
//  MaintenanceDetailHeaderView.m
//  cdzer
//
//  Created by 车队长 on 2017/2/24.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "MaintenanceDetailHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MaintenanceDetailHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *explainLabel;

@property (weak, nonatomic) IBOutlet UIView *shopDetailView;

@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopAddressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *signImageView;



@end

@implementation MaintenanceDetailHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.shopImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.shopImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:CDZColorOfLightGray withBroderOffset:nil];
    
    BorderOffsetObject *phoneBtnOffset = [BorderOffsetObject new];
    phoneBtnOffset.leftUpperOffset = 11;
    phoneBtnOffset.leftBottomOffset = 11;
    [self.phoneButton setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:nil withBroderOffset:phoneBtnOffset];
    
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)updateUIData:(NSDictionary*)contentDetail {
    
    self.titleLabel.text=contentDetail[@"state_name"];
    self.explainLabel.text=contentDetail[@"hint"];
    if ([contentDetail[@"state_name"] isEqualToString:@"已预约"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-yiyuyue@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"预约成功"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-yuyuechenggong@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"预约失败"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-yuyueshibai@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"诊断完成"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-zhenduanwancheng@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"委托中"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-weituozhong@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"已结算"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-yijiesuan@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"取消维修"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-quxiaoweixiu@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"待付款"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-daifukuan@3x"];
    }
    if ([contentDetail[@"state_name"] isEqualToString:@"诊断中"]) {
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-zhenduanzhong@3x"];
    }else{
        self.titleImageView.image=[UIImage imageNamed:@"wxgl-yiyuyue@3x"];
    }

    [self.phoneButton setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:CDZColorOfLightGray withBroderOffset:nil];
//    [addressButton setBackgroundImage:[UIImage imageNamed:@"ddzt_address.png"] forState:UIControlStateNormal];
    self.shopImageView.image = [ImageHandler getDefaultWhiteLogo];
    NSString *imgURL = [contentDetail objectForKey:@"wxs_logo"];
    if ([imgURL containsString:@"http"]) {
        [self.shopImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    NSString*wxsKind=contentDetail[@"wxs_kind"];
    if ([wxsKind isEqualToString:@"专修店"]) {
        self.signImageView.image=[UIImage imageNamed:@"snsslvc_spec_service_icon@3x"];
    }else
    {
        self.signImageView.image=[UIImage imageNamed:@"snsslvc_brand_shop_icon@3x"];
    }
    
    self.shopNameLabel.text=contentDetail[@"wxs_name"];
    self.shopAddressLabel.text=contentDetail[@"wxs_address"];
    self.shopAddressLabel.font=[UIFont systemFontOfSize:13];
    self.shopNameLabel.font=[UIFont systemFontOfSize:15];
}





@end
