//
//  RepairShopResultCell.m
//  cdzer
//
//  Created by KEns0n on 3/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairShopResultCell.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RepairShopResultCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) InsetsLabel *addreeLabel;

@property (nonatomic, strong) UILabel *storeTitleLabel;

@property (nonatomic, strong) UILabel *typeLabel;

@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UIImageView *couponImageView;

@property (nonatomic, strong) UIImageView *certifiedImageView;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@end

@implementation RepairShopResultCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.addreeLabel.frame;
    rect.origin.x = 0.0f;
    rect.size.width = CGRectGetWidth(self.frame);
    rect.size.height = CGRectGetHeight(self.frame)-CGRectGetMinY(rect);
    self.addreeLabel.frame = rect;
}

- (void)initializationUI {
    @autoreleasepool {
        [self setBackgroundColor:CDZColorOfWhite];
        UIColor *commonTextColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        
        if (!_logoImageView) {
            CGRect rect = CGRectZero;
            rect.size = CGSizeMake(70.0f, 70.0f);
            rect.origin = CGPointMake(15.0f, 7.0f);
            [self setLogoImageView:[[UIImageView alloc] initWithFrame:rect]];
            [_logoImageView setImage:[ImageHandler getWhiteLogo]];
            [self.contentView addSubview:_logoImageView];
        }
        
        if (!_storeTitleLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMaxX(_logoImageView.frame)+10.0f;
            rect.origin.y = CGRectGetMinY(_logoImageView.frame);
            rect.size = CGSizeMake(150.f, CGRectGetHeight(_logoImageView.frame)*0.6f);
            [self setStoreTitleLabel:[[UILabel alloc] initWithFrame:rect]];
            [_storeTitleLabel setText:@"(滑县服务区)大广高速滑县汽修服务站"];
            [_storeTitleLabel setNumberOfLines:0];
            [_storeTitleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [self.contentView addSubview:_storeTitleLabel];
        }
        
        if (!_distanceLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMinX(_logoImageView.frame);
            rect.origin.y = CGRectGetMaxY(_logoImageView.frame)+6.0f;
            rect.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(_logoImageView.frame)*0.2f);
            [self setDistanceLabel:[[UILabel alloc] initWithFrame:rect]];
            [_distanceLabel setText:@"5KM"];
            [_distanceLabel setTextColor:commonTextColor];
            [_distanceLabel setTextAlignment:NSTextAlignmentLeft];
            [_distanceLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.contentView addSubview:_distanceLabel];
            
        }
        
        if (!_certifiedImageView) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"certification" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:1.0f needToUpdate:YES];
            self.certifiedImageView = [[UIImageView alloc] initWithImage:image];
            _certifiedImageView.hidden = YES;
            _certifiedImageView.center = CGPointMake(_certifiedImageView.center.x, _distanceLabel.center.y);
            [self.contentView addSubview:_certifiedImageView];
            
            CGRect frame = _certifiedImageView.frame;
            frame.origin.x = 20.0f+CGRectGetMinX(_storeTitleLabel.frame);
            _certifiedImageView.frame = frame;
            
        }
        
        if (!_couponImageView) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"coupon_icon_mini" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:1.0f needToUpdate:YES];
            self.couponImageView = [[UIImageView alloc] initWithImage:image];
            _couponImageView.hidden = YES;
            [self.contentView addSubview:_couponImageView];
            
            CGRect frame = _couponImageView.frame;
            frame.origin.x = 5.0f+CGRectGetMaxX(_certifiedImageView.frame);
            _couponImageView.frame = frame;
            _couponImageView.center = CGPointMake(_couponImageView.center.x, _certifiedImageView.center.y);
            
        }
        
        if (!_addreeLabel) {
            CGRect rect = _distanceLabel.frame;
            rect.origin.y = CGRectGetMaxY(_distanceLabel.frame)+6.0f;
            [self setAddreeLabel:[[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:DefaultEdgeInsets]];
            [_addreeLabel setText:@"地址：长沙市岳麓区岳麓大道50号"];
            [_addreeLabel setTextColor:commonTextColor];
            [_addreeLabel setFont:[UIFont systemFontOfSize:13.0f]];
            _addreeLabel.numberOfLines = 0;
            [self.contentView addSubview:_addreeLabel];
        }
        
        if (!_starRatingView) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMinX(_storeTitleLabel.frame);
            rect.origin.y = CGRectGetMaxY(_storeTitleLabel.frame);
            rect.size = CGSizeMake(CGRectGetWidth(_storeTitleLabel.frame)*0.5f, CGRectGetHeight(_logoImageView.frame)*0.4f);
            [self setStarRatingView:[[HCSStarRatingView alloc] initWithFrame:rect]];
            [_starRatingView setAllowsHalfStars:NO];
            [_starRatingView setMaximumValue:5.0f];
            [_starRatingView setMinimumValue:0.0f];
            [_starRatingView setValue:3.0f];
            [_starRatingView setTintColor:[UIColor redColor]];
            [_starRatingView setUserInteractionEnabled:NO];
//            [starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
             [self.contentView addSubview:_starRatingView];
        }
        
        if (!_typeLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMidX(_storeTitleLabel.frame);
            rect.origin.y = CGRectGetMaxY(_storeTitleLabel.frame);
            rect.size = CGSizeMake(CGRectGetWidth(_storeTitleLabel.frame)/2, CGRectGetHeight(_logoImageView.frame)*0.4f);
            [self setTypeLabel:[[UILabel alloc] initWithFrame:rect]];
            [_typeLabel setText:@"四级维修店"];
            [_typeLabel setTextColor:commonTextColor];
            [_typeLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [_typeLabel setTextAlignment:NSTextAlignmentRight];
            [self.contentView addSubview:_typeLabel];
        }

        if (!_priceLabel) {
            CGRect rect = CGRectZero;
            rect.size = CGSizeMake(75.0f, CGRectGetHeight(_logoImageView.frame));
            rect.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - (CGRectGetWidth(rect)+5.0f);
            rect.origin.y = CGRectGetMaxY(_logoImageView.frame)-CGRectGetHeight(rect);
            [self setPriceLabel:[[UILabel alloc] initWithFrame:rect]];
            NSMutableAttributedString* message = [NSMutableAttributedString new];
            [message appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@"50"
                                             attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                          NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]
                                                          }]];
            [message appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@"元/工时"
                                             attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                          NSFontAttributeName:[UIFont systemFontOfSize:12.0f]
                                                          }]];
            [_priceLabel setAttributedText:message];
            [_priceLabel setNumberOfLines:-1];
            [_priceLabel setTextAlignment:NSTextAlignmentRight];
            [self.contentView addSubview:_priceLabel];
        }
    }
}

- (void)setAddreeLabelText:(NSString *)address {
    _addreeLabel.text = [NSString stringWithFormat:@"地址：%@",address];
}

- (void)setPriceLabelText:(id)priceValue {
    
    NSString *price = @"0";
    if ([priceValue isKindOfClass:[NSNumber class]]) {
        price = [priceValue stringValue];
    }else if ([priceValue isKindOfClass:[NSString class]]) {
        if(![priceValue isEqualToString:@""]) price = priceValue;
    }
    
    @autoreleasepool {
        UIColor *commonTextColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        NSMutableAttributedString* message = [NSMutableAttributedString new];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:price
                                         attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]
                                                      }]];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:@"元/工时"
                                         attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                      NSFontAttributeName:[UIFont systemFontOfSize:12.0f]
                                                      }]];
        [_priceLabel setAttributedText:message];
    }
}

- (void)setDistanceLabelText:(id)distanceValue {
    NSString *distance = @"0";
    if ([distanceValue isKindOfClass:[NSNumber class]]) {
        distance = [distanceValue stringValue];
    }else if ([distanceValue isKindOfClass:[NSString class]]) {
        distance = distanceValue;
    }
    _distanceLabel.text = [NSString stringWithFormat:@"%@：%@KM",getLocalizationString(@"distance"),distance];
}

- (void)setLogoImageViewText:(NSString *)theURLString {
    if ([theURLString isEqualToString:@""]||!theURLString||[theURLString rangeOfString:@"http"].location==NSNotFound) {
        _logoImageView.image = [ImageHandler getWhiteLogo];
    }else {
        [_logoImageView sd_setImageWithURL:[NSURL URLWithString:theURLString] placeholderImage:[ImageHandler getWhiteLogo]];
    }
    
}

- (void)setTypeLabelText:(NSString *)type {
    _typeLabel.text = type;
}

- (void)setStoreTitleLabelText:(NSString *)storeTitle {
    _storeTitleLabel.text = storeTitle;
}

- (void)setStarValue:(id)starValue {
    if ([starValue isKindOfClass:[NSNumber class]]) {
        _starRatingView.value = [starValue floatValue];
    }else if ([starValue isKindOfClass:[NSString class]]) {
        if ([starValue isEqualToString:@""]) {
            _starRatingView.value = 0.0f;
        }else {
            _starRatingView.value = [starValue floatValue]*5.0f;
        }
    }
}

- (void)setUIDataWithDetailData:(NSDictionary *)detailData {
    if (!detailData) return;
    @autoreleasepool {
        
//        @"address"
//        @"member_hoursprice"
//        @"distance"
//        @"user_shop_logo"
//        @"user_kind_name"
//        @"wxs_name"
//        @"star"
//        @"id"
//        @"lat"
//        @"lng"
//        @"major_brand"
//        @"service_time"
//        @"state"
//        @"state_name"
//        @"user_id"
//        @"user_kind_id"
//        @"user_province"
//        @"user_region"
//        @"usercity"
//        @"wxs_telphone"
        BOOL noShowCoupon = [[SupportingClass verifyAndConvertDataToString:detailData[@"discount_coupon"]] isEqualToString:@"no"];
        self.couponImageView.hidden = noShowCoupon;
        
        BOOL uncertifiedShop = [detailData[@"state_name"] isEqualToString:@"未认领"];
        self.certifiedImageView.hidden = uncertifiedShop;
        [self setAddreeLabelText:detailData[@"address"]];
        [self setPriceLabelText:detailData[@"member_hoursprice"]];
        [self setDistanceLabelText:detailData[@"distance"]];
        
        [self setLogoImageViewText:detailData[@"user_shop_logo"]];
        [self setTypeLabelText:detailData[@"user_kind_name"]];
        [self setStoreTitleLabelText:detailData[@"wxs_name"]];
        [self setStarValue:detailData[@"star"]];
    }
}

@end
