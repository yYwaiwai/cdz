//
//  OrderDetailHeaderView.m
//  cdzer
//
//  Created by 车队长 on 16/9/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "OrderDetailHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OrderDetailHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@property (weak, nonatomic) IBOutlet UILabel *statusNameWithDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userTelLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *userDetailView;



@property (weak, nonatomic) IBOutlet UIView *shopDetailView;

@property (weak, nonatomic) IBOutlet UIImageView *shopLogoImageView;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopAddressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *shopTypeImageView;



@property (weak, nonatomic) IBOutlet UIView *shopDetailTitleView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shopInfoTopConstraint;

@end

@implementation OrderDetailHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.shopLogoImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.shopLogoImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:CDZColorOfLightGray withBroderOffset:nil];
    
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomLeftOffset = 12;
    [self.shopDetailTitleView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    
    BorderOffsetObject *phoneBtnOffset = [BorderOffsetObject new];
    phoneBtnOffset.rightUpperOffset = 15;
    phoneBtnOffset.rightBottomOffset = 15;
    [self.telButton setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:phoneBtnOffset];
    
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateStatusText:(NSString *)statusText andStatusDetail:(NSString *)statusDetail {
    if (!statusText) statusText = @"";
    
    
    NSMutableAttributedString* text = [NSMutableAttributedString new];
    if (statusDetail&&![statusDetail isEqualToString:@""]) {
        [text appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:[statusText stringByAppendingString:@"\n"]
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
        
        [text appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:statusDetail
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        
    }else {
        [text appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:statusText
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    }    
    self.statusNameWithDetailLabel.attributedText = text;
}

- (void)updateUIData {
    if ([_contentDetail[@"state_name"] isEqualToString:@"待付款"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-daifukuan@3x"];
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"订单完成"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-dingdanwancheng@3x"];
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"交易关闭"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-jiaoyiguanbi@3x"];
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"派送中"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-paisongzhong@3x"];
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"已到店"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-yidaodian@3x"];
    }
    if ([_contentDetail[@"state_name"] isEqualToString:@"已付款"]) {
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-yifukuan@3x"];
    }
    else{
        self.statusImageView.image=[UIImage imageNamed:@"ddzt-daifukuan@3x"];
    }
    
    NSString *statusText = self.contentDetail[@"state_name"];
    NSString *statusDetail = self.contentDetail[@"gentle_hint"];;
    [self updateStatusText:statusText andStatusDetail:statusDetail];
    
    if ([self.orderType isEqualToString:@""]||[self.orderType isEqualToString:@"O"]||[self.orderType isEqualToString:@"P"]) {
        self.shopInfoTopConstraint.constant = -CGRectGetHeight(self.shopDetailTitleView.frame);
        self.shopDetailView.hidden = YES;
        self.userDetailView.hidden = NO;
        
        self.userNameLabel.text= _contentDetail[@"contact_name"];
        self.userTelLabel.text= [SupportingClass verifyAndConvertDataToString:_contentDetail[@"contact_tel"]];
        self.addressLabel.text= _contentDetail[@"address_name"];
    }else {
        self.shopInfoTopConstraint.constant = 0;
        self.shopDetailView.hidden = NO;
        self.userDetailView.hidden = YES;
        NSDictionary *wxsInfo=self.contentDetail[@"wxs_info"];
        self.shopLogoImageView.image = [ImageHandler getDefaultWhiteLogo];
        NSString *imgURL = [wxsInfo objectForKey:@"wxs_logo"];
        if ([imgURL containsString:@"http"]) {
            [self.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        
        NSString*wxsKind=wxsInfo[@"wxs_kind"];
        self.shopTypeImageView.highlighted = ![wxsKind isEqualToString:@"专修店"];
        
        self.shopNameLabel.text=wxsInfo[@"wxs_name"];
        self.shopAddressLabel.text=wxsInfo[@"wxs_address"];
    }
    
    
    
    
}

@end
