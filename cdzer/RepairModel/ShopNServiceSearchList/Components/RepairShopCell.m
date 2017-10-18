//
//  RepairShopCell.m
//  cdzer
//
//  Created by KEns0nLau on 8/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairShopCell.h"
#import "HCSStarRatingView.h"

@interface  RepairShopCell()

@property (nonatomic, weak) IBOutlet UIImageView *repairShopLogoImageView;

@property (nonatomic, weak) IBOutlet UIImageView *specServiceImageView;

@property (nonatomic, weak) IBOutlet UIImageView *brandServiceImageView;

@property (nonatomic, weak) IBOutlet UILabel *repairShopNameLabel;


@property (nonatomic, weak) IBOutlet UIView *phone5BelowMoreInfoView;

@property (nonatomic, weak) IBOutlet UIView *normalMoreInfoView;

@end

@implementation RepairShopCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.repairShopLogoImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.repairShopLogoImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)dataDetail {
    
    self.repairShopNameLabel.text = dataDetail[@"wxs_name"];
    
    self.repairShopLogoImageView.image = [ImageHandler getDefaultWhiteLogo];
    NSString *logoURLString = dataDetail[@"wxs_logo"];
    if ([logoURLString isContainsString:@"http"]) {
        [self.repairShopLogoImageView setImageWithURL:[NSURL URLWithString:logoURLString] placeholderImage:[ImageHandler getDefaultWhiteLogo] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    NSString *wxsType = dataDetail[@"wxs_kind"];
    self.specServiceImageView.hidden = ![wxsType isContainsString:@"专修"];
    self.brandServiceImageView.hidden = ![wxsType isContainsString:@"品牌"];
    
    BOOL isPhone5OrBelow = (CGRectGetWidth(UIScreen.mainScreen.bounds)==320);
//    "id":"16061410312746890185",
//    "wxs_name":"车世界维修店",
//    "wxs_logo":"http://cdz.cdzer.net:80/imgUpload/demo/common/logo/160711092747yVxhdL5Gil.png",
//    "wxs_kind":"专修店",
//    "wxs_price":"20",
//    "discount_coupon":"yes",
//    "major_service":"普通维修",
//    "star":"5.0",
//    "distance":"0.0",
//    "volume":"16",
//    "wxs_address":"湖南省长沙市岳麓区麓谷麓天路12号",
//    "lng":"112.905907",
//    "lat":"28.227455"
    UIView *containerView = self.phone5BelowMoreInfoView;
    if (isPhone5OrBelow) {
        [self.normalMoreInfoView removeFromSuperview];
        self.normalMoreInfoView = nil;
    }else {
        containerView = self.normalMoreInfoView;
        [self.phone5BelowMoreInfoView removeFromSuperview];
        self.phone5BelowMoreInfoView = nil;
    }
    if (containerView) {
        //评价星
        HCSStarRatingView *starView = (HCSStarRatingView *)[containerView viewWithTag:100];
        starView.value = 0;
        
        //评价分
        UILabel *commentRemarkCountLabel = (UILabel *)[[containerView viewWithTag:101] viewWithTag:10];
        commentRemarkCountLabel.text = @"0.0";
        
        //销售额
        UILabel *serviceVolumeCountLabel = (UILabel *)[[containerView viewWithTag:102] viewWithTag:10];
        serviceVolumeCountLabel.text = @"0";
        
        //工时
        UIView *repiarPriceContainerView = [containerView viewWithTag:103];
        repiarPriceContainerView.hidden = YES;
        UILabel *repiarPriceLabel = (UILabel *)[repiarPriceContainerView viewWithTag:10];
        repiarPriceLabel.text = @"0.00";
        
        //主修品牌
        UIImageView *mainRepairBrandLogoIV = (UIImageView *)[containerView viewWithTag:104];
        mainRepairBrandLogoIV.hidden = YES;
        mainRepairBrandLogoIV.image = nil;
        
        //主修服务
        UILabel *mainRepairServiceLabel = (UILabel *)[containerView viewWithTag:105];
        mainRepairServiceLabel.hidden = YES;
        mainRepairServiceLabel.text = @"";
        
        //距离
        UILabel *distanceLabel = (UILabel *)[containerView viewWithTag:106];
        distanceLabel.text = @"";
        
        
        starView.value = [SupportingClass verifyAndConvertDataToString:dataDetail[@"star"]].floatValue;
        commentRemarkCountLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"star"]];
        serviceVolumeCountLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"volume"]];
        NSString *priceString =[SupportingClass verifyAndConvertDataToString:dataDetail[@"wxs_price"]];
        repiarPriceContainerView.hidden = YES;
        if (priceString&&![priceString isEqualToString:@""]) {
            repiarPriceContainerView.hidden = NO;
            repiarPriceLabel.text = [NSString stringWithFormat:@"%.02f", priceString.floatValue];
        }
        mainRepairBrandLogoIV.image = nil;
        mainRepairBrandLogoIV.hidden = YES;
        mainRepairServiceLabel.hidden = YES;
        NSString *majaorServiceString = dataDetail[@"major_service"];
        if ([majaorServiceString isContainsString:@"http"]) {
            mainRepairBrandLogoIV.hidden = NO;
            [mainRepairBrandLogoIV setImageWithURL:[NSURL URLWithString:majaorServiceString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }else {
            mainRepairServiceLabel.hidden = NO;
            mainRepairServiceLabel.text = majaorServiceString;
        }
        distanceLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"distance"]];
    }
    
}

@end
