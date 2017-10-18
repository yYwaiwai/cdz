//
//  ShopCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ShopCell.h"
#import "HCSStarRatingView.h"

@interface  ShopCell()

@property (nonatomic, weak) IBOutlet UIImageView *repairShopLogoImageView;

@property (nonatomic, weak) IBOutlet UIImageView *specServiceImageView;

@property (nonatomic, weak) IBOutlet UIImageView *brandServiceImageView;

@property (nonatomic, weak) IBOutlet UILabel *repairShopNameLabel;


@property (nonatomic, weak) IBOutlet UIView *phone5BelowMoreInfoView;

@property (nonatomic, weak) IBOutlet UIView *normalMoreInfoView;

@end

@implementation ShopCell

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
//    distance = 1;
//    id = 16090709422166616095;
//    "service_name" = "\U81ea\U52a8\U53d8\U901f\U5668";
//    star = "5.00";
//    volume = 0;
//    "wxs_address" = "\U6e56\U5357\U7701\U957f\U6c99\U5e02\U5cb3\U9e93\U533a\U9e93\U8c37\U9e93\U67ab\U8def28\U53f7";
//    "wxs_id" = 16061411482246479558;
//    "wxs_kind" = "\U4e13\U4fee\U5e97";
//    "wxs_logo" = "http://cdz.cdzer.net:80/imgUpload/demo/common/logo/160920163659S3O0AFApGx.png";
//    "wxs_name" = "\U81ea\U52a8\U53d8\U901f\U5668\U7ef4\U4fee\U5e97";
//    "wxs_price" = 20;

    @weakify(self);
    [@[@200, @201] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull number, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        //评价星
        BOOL showPhone5OrBelow = (isPhone5OrBelow&&number.unsignedIntegerValue==201);
        BOOL showPhone6OrAbove = (!isPhone5OrBelow&&number.unsignedIntegerValue==200);
        UIView *containerView = [self.contentView viewWithTag:number.unsignedIntegerValue];
        containerView.hidden = !(showPhone5OrBelow||showPhone6OrAbove);
        
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
        
        if (showPhone5OrBelow||showPhone6OrAbove) {
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
            NSString *majaorServiceString = dataDetail[@"service_name"];
            if ([majaorServiceString isContainsString:@"http"]) {
                mainRepairBrandLogoIV.hidden = NO;
                [mainRepairBrandLogoIV setImageWithURL:[NSURL URLWithString:majaorServiceString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }else {
                mainRepairServiceLabel.hidden = NO;
                mainRepairServiceLabel.text = majaorServiceString;
            }
            distanceLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"distance"]];
        }
        
    }];
    
}

@end
