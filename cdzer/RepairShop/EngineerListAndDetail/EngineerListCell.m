//
//  EngineerListCell.m
//  cdzer
//
//  Created by KEns0n on 3/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define view2ViewSpace vAdjustByScreenRatio(4.0f)
#import "EngineerListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EngineerListCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *expertiseSkillsLabel;

@property (nonatomic, strong) UILabel *aptitudeTypeLabel;

//@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@end

@implementation EngineerListCell

- (void)initializationUI {
    @autoreleasepool {
        [self setBackgroundColor:CDZColorOfWhite];
        UIColor *commonTextColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        
        if (!_logoImageView) {
            CGRect rect = CGRectZero;
            rect.size = CGSizeMake(vAdjustByScreenRatio(78.0f), vAdjustByScreenRatio(54.0f));
            rect.origin = CGPointMake(vAdjustByScreenRatio(8.0f), vAdjustByScreenRatio(7.0f));
            [self setLogoImageView:[[UIImageView alloc] initWithFrame:rect]];
            [_logoImageView setImage:[ImageHandler getWhiteLogo]];
            [self addSubview:_logoImageView];
        }
        
        if (!_nameLabel) {
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMaxX(_logoImageView.frame)+vAdjustByScreenRatio(10.0f);
            rect.origin.y = view2ViewSpace;
            rect.size = CGSizeMake(CGRectGetWidth(self.frame)-CGRectGetWidth(_logoImageView.frame), CGRectGetHeight(_logoImageView.frame)*0.5f);
            [self setNameLabel:[[UILabel alloc] initWithFrame:rect]];
            [_nameLabel setText:@"陈大文－高级技师"];
            [_nameLabel setFont:[UIFont boldSystemFontOfSize:vAdjustByScreenRatio(16.0f)]];
            [self addSubview:_nameLabel];
        }
        
//        if (!_starRatingView) {
//            CGRect rect = CGRectZero;
//            rect.origin.x = CGRectGetMinX(_nameLabel.frame);
//            rect.origin.y = CGRectGetMaxY(_nameLabel.frame);
//            rect.size = CGSizeMake(vAdjustByScreenRatio(100.0f), CGRectGetHeight(_logoImageView.frame)*0.5f);
//            [self setStarRatingView:[[HCSStarRatingView alloc] initWithFrame:rect]];
//            [_starRatingView setMaximumValue:5.0f];
//            [_starRatingView setMinimumValue:0.0f];
//            [_starRatingView setValue:3.0f];
//            [_starRatingView setAllowsHalfStars:YES];
//            [_starRatingView setTintColor:[UIColor redColor]];
//            [_starRatingView setUserInteractionEnabled:NO];
//            [starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
//            [self addSubview:_starRatingView];
//        }
        
        if (!_aptitudeTypeLabel) {
            UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMinX(_nameLabel.frame);
            rect.origin.y = CGRectGetMaxY(_nameLabel.frame);
            rect.size = CGSizeMake(vAdjustByScreenRatio(100.0f), CGRectGetHeight(_logoImageView.frame)*0.5f);
            [self setAptitudeTypeLabel:[[UILabel alloc] initWithFrame:rect]];
            [_aptitudeTypeLabel setTextColor:commonTextColor];
            [_aptitudeTypeLabel setFont:font];
            [self addSubview:_aptitudeTypeLabel];
        }
        
        if (!_expertiseSkillsLabel) {
            UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
            CGRect rect = _logoImageView.frame;
            rect.origin.y = CGRectGetMaxY(_logoImageView.frame)+view2ViewSpace;
            rect.size = CGSizeMake(CGRectGetWidth(self.frame)-CGRectGetMinX(_logoImageView.frame)*2.0f, vAdjustByScreenRatio(40.f));
            [self setExpertiseSkillsLabel:[[UILabel alloc] initWithFrame:rect]];
            [_expertiseSkillsLabel setNumberOfLines:0];
            [_expertiseSkillsLabel setTextColor:commonTextColor];
            [_expertiseSkillsLabel setFont:font];
            [self addSubview:_expertiseSkillsLabel];
        }
    
    }
}

- (void)updateUIDataWithData:(NSDictionary *)dataDetail {
    if (!dataDetail) return;
    _nameLabel.text = dataDetail[@"compellation"];
    
    _expertiseSkillsLabel.text = dataDetail[@"speciality_name"];
    
    _aptitudeTypeLabel.text = dataDetail[@"aptitude_type_name"];
    
    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:dataDetail[@"head_img"]] placeholderImage:[ImageHandler getWhiteLogo]];
    
}

@end
