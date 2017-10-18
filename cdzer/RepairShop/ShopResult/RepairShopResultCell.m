//
//  RepairShopResultCell.m
//  cdzer
//
//  Created by KEns0nLau on 6/15/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairShopResultCell.h"
#import "HCSStarRatingView.h"

@interface RepairShopResultCell()

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

@property (nonatomic, weak) IBOutlet UILabel *addreeLabel;

@property (nonatomic, weak) IBOutlet UILabel *storeTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *typeLabel;

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@property (nonatomic, weak) IBOutlet UIImageView *couponImageView;

@property (nonatomic, weak) IBOutlet UIImageView *certifiedImageView;

@property (nonatomic, weak) IBOutlet UIImageView *collectedImageView;

@property (nonatomic, weak) IBOutlet UIImageView *memberImageView;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *starRatingView;

@end

@implementation RepairShopResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUIDataWithDetailData:(NSDictionary *)dataDetail {
//    "address":"湖南省长沙市岳麓区麓谷麓天路21号",
//    "checkbox":false,
//    "discount_coupon":"no",
//    "distance":0,
//    "id":"16052010124914672703",
//    "lat":28.226691,
//    "lng":112.901331,
//    "major_brand":"奥迪",
//    "member_hoursprice":"40",
//    "service_time":"星期一至星期天,08:30——18:00",
//    "star":"5.0",
//    "state":"14111811172655228577",
//    "state_name":"审核通过",
//    "user_id":"16051917162364805146",
//    "user_kind_id":"14111810085037185524",
//    "user_kind_name":"4S店",
//    "user_province":"14",
//    "user_region":"1647",
//    "user_shop_logo":"http://www.cdzer.net:80/imgUpload/demo/common/logo/160520103424hWHWX8GtIR.png",
//    "usercity":"197",
//    "wxs_name":"4S维修(测试)店",
//    "wxs_telphone":"0731-88865777"
    
    BOOL noShowCoupon = [[SupportingClass verifyAndConvertDataToString:dataDetail[@"discount_coupon"]] isContainsString:@"no"];
    self.couponImageView.hidden = noShowCoupon;
    
    BOOL uncertifiedShop = !([dataDetail[@"state_name"] isContainsString:@"审核通过"]);
    self.certifiedImageView.hidden = uncertifiedShop;
    
    
    BOOL wasMember = ([[SupportingClass verifyAndConvertDataToString:dataDetail[@"shop_member"]]
                       isContainsString:@"yes"]);
    self.memberImageView.hidden = !wasMember;
    
    if (!wasMember) {
        BOOL wasCollected = ([[SupportingClass verifyAndConvertDataToString:dataDetail[@"shop_love"]]
                              isContainsString:@"yes"]);
        self.collectedImageView.hidden = !wasCollected;
    }
    
    
    NSString *shopLogo = dataDetail[@"user_shop_logo"];
    self.logoImageView.image = [ImageHandler getWhiteLogo];
    if ([shopLogo isContainsString:@"http"]) {
        [self.logoImageView setImageWithURL:[NSURL URLWithString:shopLogo] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    self.storeTitleLabel.text = dataDetail[@"wxs_name"];
    self.typeLabel.text = dataDetail[@"user_kind_name"];
    self.priceLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"member_hoursprice"]];
    self.distanceLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"distance"]];
    self.addreeLabel.text = dataDetail[@"address"];
    self.starRatingView.value = [SupportingClass verifyAndConvertDataToNumber:dataDetail[@"star"]].floatValue;
    
    
}

@end
