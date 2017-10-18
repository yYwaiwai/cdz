//
//  RepairItemCell.m
//  cdzer
//
//  Created by KEns0nLau on 8/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairItemCell.h"

@interface RepairItemCell ()

@property (nonatomic, weak) IBOutlet UIImageView *partsItemImageView;

@property (nonatomic, weak) IBOutlet UILabel *partsItemNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsItemPriceLabel;

@property (nonatomic, weak) IBOutlet UIView *phone5BelowMoreInfoView;

@property (nonatomic, weak) IBOutlet UIView *normalMoreInfoView;


@property (nonatomic, weak) IBOutlet UILabel *repairShopNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIView *distanceNShopNameContainerView;


@end

@implementation RepairItemCell

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.partsItemImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
//    [self.partsItemImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
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
    
    self.partsItemNameLabel.text = dataDetail[@"name"];
    
    self.partsItemImageView.image = [ImageHandler getWhiteLogo];
    NSString *logoURLString = dataDetail[@"logo"];
    if ([logoURLString isContainsString:@"http"]) {
        [self.partsItemImageView setImageWithURL:[NSURL URLWithString:logoURLString] placeholderImage:[ImageHandler getWhiteLogo]  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    NSString *priceString = [SupportingClass verifyAndConvertDataToString:dataDetail[@"price"]];
    self.partsItemPriceLabel.text = [NSString stringWithFormat:@"%0.2f", priceString.floatValue];
    
    self.repairShopNameLabel.text = dataDetail[@"wxs_name"];
    
    NSString *distanceString = [SupportingClass verifyAndConvertDataToString:dataDetail[@"distance"]];
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f", distanceString.floatValue];
    
    BOOL isPhone5OrBelow = (CGRectGetWidth(UIScreen.mainScreen.bounds)==320);
//    "id":"16070214542031470736",
//    "name":"玻璃",
//    "logo":"http://he.bccar.net:80/imgUpload/demo/common/product/1607021454081C2TTfNEg2.png",
//    "price":"50",
//    "sales":"38",
//    "comment_len":0,
//    "star":"5.0",
//    "wxs_name":"汽车玻璃专修店"
//    "distance":1
    
    @weakify(self);
    [@[@200, @201] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull number, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        //评价星
        BOOL showPhone5OrBelow = (isPhone5OrBelow&&number.unsignedIntegerValue==201);
        BOOL showPhone6OrAbove = (!isPhone5OrBelow&&number.unsignedIntegerValue==200);
        UIView *containerView = [self.contentView viewWithTag:number.unsignedIntegerValue];
        containerView.hidden = !(showPhone5OrBelow||showPhone6OrAbove);
        
        //销售额
        UILabel *serviceVolumeCountLabel = (UILabel *)[containerView viewWithTag:100];
        serviceVolumeCountLabel.text = @"0";
        
        //评价数
        UILabel *commentCountLabel = (UILabel *)[containerView viewWithTag:101];
        commentCountLabel.text = @"0";
        
        //评价分
        UILabel *commentRemarkCountLabel = (UILabel *)[containerView viewWithTag:102];
        commentRemarkCountLabel.text = @"0.0";
        
        
        if (showPhone5OrBelow||showPhone6OrAbove) {
            serviceVolumeCountLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"sales"]];
            commentCountLabel.text =  [SupportingClass verifyAndConvertDataToString:dataDetail[@"comment_len"]];
            commentRemarkCountLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"star"]];
        }
        
    }];
    
}

- (void)setHiddenDistanceNShopNameView:(BOOL)hiddenDistanceNShopNameView {
    _hiddenDistanceNShopNameView = hiddenDistanceNShopNameView;
    self.distanceNShopNameContainerView.hidden = hiddenDistanceNShopNameView;
}

@end
