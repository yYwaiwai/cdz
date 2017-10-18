//
//  SelfDiagnosisResultCell.m
//  cdzer
//
//  Created by KEns0n on 3/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "SelfDiagnosisResultCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SelfDiagnosisResultCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *addreeLabel;

@property (nonatomic, strong) UILabel *storeTitleLabel;

@property (nonatomic, strong) UILabel *businessTimeLabel;

@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@end

@implementation SelfDiagnosisResultCell

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
            [self addSubview:_logoImageView];
        }
        
        if (!_storeTitleLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMaxX(_logoImageView.frame)+10.0f;
            rect.origin.y = CGRectGetMinY(_logoImageView.frame);
            rect.size = CGSizeMake(180.f, CGRectGetHeight(_logoImageView.frame)*0.6f);
            [self setStoreTitleLabel:[[UILabel alloc] initWithFrame:rect]];
            [_storeTitleLabel setText:@"(滑县服务区)大广高速滑县汽修服务站"];
            [_storeTitleLabel setNumberOfLines:0];
            [_storeTitleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [self addSubview:_storeTitleLabel];
        }
        
        if (!_businessTimeLabel) {CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMinX(_logoImageView.frame);
            rect.origin.y = CGRectGetMaxY(_logoImageView.frame)+6.0f;
            rect.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(_logoImageView.frame)*0.2f);
            self.businessTimeLabel = [[UILabel alloc] initWithFrame:rect];
            [_businessTimeLabel setText:@""];
            [_businessTimeLabel setTextColor:commonTextColor];
            [_businessTimeLabel setTextAlignment:NSTextAlignmentLeft];
            [_businessTimeLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self addSubview:_businessTimeLabel];
            
        }
        
        if (!_addreeLabel) {
            CGRect rect = _businessTimeLabel.frame;
            rect.origin.y = CGRectGetMaxY(_businessTimeLabel.frame)+6.0f;
            [self setAddreeLabel:[[UILabel alloc] initWithFrame:rect]];
            [_addreeLabel setText:@"地址：长沙市岳麓区岳麓大道50号"];
            [_addreeLabel setTextColor:commonTextColor];
            [_addreeLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [self addSubview:_addreeLabel];
        }
        
        if (!_starRatingView) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMinX(_storeTitleLabel.frame);
            rect.origin.y = CGRectGetMaxY(_storeTitleLabel.frame);
            rect.size = CGSizeMake(CGRectGetWidth(_storeTitleLabel.frame)*0.4f, CGRectGetHeight(_logoImageView.frame)*0.4f);
            [self setStarRatingView:[[HCSStarRatingView alloc] initWithFrame:rect]];
            [_starRatingView setAllowsHalfStars:NO];
            [_starRatingView setMaximumValue:5.0f];
            [_starRatingView setMinimumValue:0.0f];
            [_starRatingView setValue:3.0f];
            [_starRatingView setTintColor:[UIColor redColor]];
            [_starRatingView setUserInteractionEnabled:NO];
//            [starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
             [self addSubview:_starRatingView];
        }
        
        if (!_distanceLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMaxX(_starRatingView.frame);
            rect.origin.y = CGRectGetMaxY(_storeTitleLabel.frame);
            rect.size = CGSizeMake(CGRectGetWidth(_storeTitleLabel.frame)*0.6f, CGRectGetHeight(_logoImageView.frame)*0.4f);
            self.distanceLabel = [[UILabel alloc] initWithFrame:rect];
            [_distanceLabel setText:@"四级维修店"];
            [_distanceLabel setTextColor:commonTextColor];
            [_distanceLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [_distanceLabel setTextAlignment:NSTextAlignmentRight];
            [self addSubview:_distanceLabel];
        }
    }
}

- (void)setAddreeLabelText:(NSString *)address {
    _addreeLabel.text = [NSString stringWithFormat:@"地址：%@",address];
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

- (void)setBusinessTimeLabelText:(NSString *)time {
    _businessTimeLabel.text = [NSString stringWithFormat:@"营业时间：%@",time];
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
            _starRatingView.value = [starValue floatValue];;
        }
    }
}

- (void)setUIDataWithDetailData:(NSDictionary *)detailData {
    if (!detailData) return;
    @autoreleasepool {

        
//        address = "\U6e56\U5357\U7701\U957f\U6c99\U5e02";
//        distance = 1341;
//        id = 15040116020428537348;
//        lat = "39.92";
//        len = 5;
//        lng = "116.46";
//        "service_time" = "\U661f\U671f\U4e00\U81f3\U661f\U671f\U5929,08:00\U2014\U201419:30";
//        star = "1.0";
//        "wxs_logo" = "";
//        "wxs_name" = "\U767e\U57ce\U7ef4\U4fee\U5546\U6d4b\U8bd52";
        
        [self setAddreeLabelText:detailData[@"address"]];
        [self setDistanceLabelText:detailData[@"distance"]];
        
        [self setLogoImageViewText:detailData[@"wxs_logo"]];
        [self setBusinessTimeLabelText:detailData[@"service_time"]];
        [self setStoreTitleLabelText:detailData[@"wxs_name"]];
        [self setStarValue:detailData[@"star"]];
    }
}

@end
