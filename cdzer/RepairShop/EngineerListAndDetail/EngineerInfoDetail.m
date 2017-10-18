//
//  EngineerInfoDetail.m
//  cdzer
//
//  Created by KEns0n on 3/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define view2ViewSpace vAdjustByScreenRatio(4.0f)
#import "EngineerInfoDetail.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface EngineerInfoDetail()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *jobRankingLabel;

@property (nonatomic, strong) UILabel *workExperienceLabel;

@property (nonatomic, strong) UIImageView *phoneLogoImageView;

@property (nonatomic, strong) UIButton *phoneNumberBtn;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;
@end

@implementation EngineerInfoDetail

- (void)initializationUI {
    @autoreleasepool {
        [self setBackgroundColor:CDZColorOfWhite];
        [self setBorderWithColor:[UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.00f] borderWidth:0.5f];
        
        CGFloat screenWidth = SCREEN_WIDTH;
        UIColor *commonTextColor = CDZColorOfDefaultColor;
        NSTextAlignment standardAlignment = NSTextAlignmentLeft;
        
        if (!_logoImageView) {
            CGRect rect = CGRectZero;
            rect.size = CGSizeMake(vAdjustByScreenRatio(94.0f), vAdjustByScreenRatio(58.0f));
            rect.origin = CGPointMake(vAdjustByScreenRatio(11.0f), vAdjustByScreenRatio(10.0f));
            [self setLogoImageView:[[UIImageView alloc] initWithFrame:rect]];
            [_logoImageView setBackgroundColor:[UIColor blackColor]];
            [self addSubview:_logoImageView];
        }
        
        if (!_nameLabel) {
            UIFont *font = [UIFont boldSystemFontOfSize:vAdjustByScreenRatio(19.0f)];
            NSString *text = @"陈大文";
            CGSize standardSize = CGSizeMake(screenWidth, vAdjustByScreenRatio(20.0f));
            CGRect rect = CGRectZero;
            rect.origin = CGPointMake(CGRectGetMaxX(_logoImageView.frame)+view2ViewSpace*1.5f,vAdjustByScreenRatio(10.0f));
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height;
            rect.size.width = CGRectGetWidth(self.frame)-CGRectGetMinX(rect);
            
            [self setNameLabel:[[UILabel alloc] initWithFrame:rect]];
            [_nameLabel setText:text];
            [_nameLabel setFont:font];
            [_nameLabel setTextAlignment:standardAlignment];
            [self addSubview:_nameLabel];
        }
                
        if (!_jobRankingLabel) {
            UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
            NSString *text = @"资质：高级维修师";
            CGRect rect = _nameLabel.frame;
            CGSize standardSize = CGSizeMake(screenWidth  , vAdjustByScreenRatio(20.0f));
            rect.origin.y = CGRectGetMaxY(_nameLabel.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height;
            
            [self setJobRankingLabel:[[UILabel alloc] initWithFrame:rect]];
            [_jobRankingLabel setText:text];
            [_jobRankingLabel setTextColor:commonTextColor];
            [_jobRankingLabel setFont:font];
            [_jobRankingLabel setTextAlignment:standardAlignment];
            [self addSubview:_jobRankingLabel];
        }
        
        if (!_workExperienceLabel) {
            UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
            NSString *text = @"工龄：26";
            CGRect rect = _nameLabel.frame;
            CGSize standardSize = CGSizeMake(screenWidth  , vAdjustByScreenRatio(20.0f));
            rect.origin.y = CGRectGetMaxY(_jobRankingLabel.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height;
            
            [self setWorkExperienceLabel:[[UILabel alloc] initWithFrame:rect]];
            [_workExperienceLabel setText:text];
            [_workExperienceLabel setTextColor:commonTextColor];
            [_workExperienceLabel setFont:font];
            [self addSubview:_workExperienceLabel];
        }
        
        if (!_phoneLogoImageView) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                 fileName:@"mobile_phone"
                                                                                     type:FMImageTypeOfPNG
                                                                          scaleWithPhone4:NO
                                                                              offsetRatioForP4:1.0f
                                                                             needToUpdate:YES];
            CGRect rect = _nameLabel.frame;
            rect.origin.y = CGRectGetMaxY(_workExperienceLabel.frame)+view2ViewSpace;
            rect.size = IS_IPHONE_4_OR_LESS?CGSizeMake(20.0f, 20.0f):image.size;
            [self setPhoneLogoImageView:[[UIImageView alloc] initWithImage:image]];
            [_phoneLogoImageView setFrame:rect];
            [self addSubview:_phoneLogoImageView];
        }
        
        
        if (!_phoneNumberBtn) {
            UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
            NSString *text = @"000000000000";
            CGRect rect = _phoneLogoImageView.frame;
            CGSize standardSize = CGSizeMake(screenWidth  , vAdjustByScreenRatio(20.0f));
            rect.origin.x = CGRectGetMaxX(_phoneLogoImageView.frame)+view2ViewSpace;
            rect.size = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize];
            
            [self setPhoneNumberBtn:[UIButton buttonWithType:UIButtonTypeSystem]];
            [_phoneNumberBtn setFrame:rect];
            [_phoneNumberBtn setTitle:text forState:UIControlStateNormal];
            [_phoneNumberBtn setTitleColor:commonTextColor forState:UIControlStateNormal];
            [_phoneNumberBtn.titleLabel setFont:font];
            [_phoneNumberBtn setCenter:CGPointMake(_phoneNumberBtn.center.x,
                                                _phoneLogoImageView.center.y)];
            [self addSubview:_phoneNumberBtn];
        }
        
        
        CGRect rect = self.frame;
        rect.size.height = CGRectGetMaxY(_phoneLogoImageView.frame)+vAdjustByScreenRatio(10.0f);
        [self setFrame:rect];
        [_logoImageView setCenter:CGPointMake(_logoImageView.center.x,
                                              CGRectGetHeight(rect)/2.0f)];
    }
}


- (void)updateUIDataWithData:(NSDictionary *)dataDetail {
    if (!dataDetail) return;
    _nameLabel.text = dataDetail[@"compellation"];
    
    _jobRankingLabel.text = [@"资质：" stringByAppendingString:dataDetail[@"aptitude_type_name"]];
    
    _workExperienceLabel.text = [@"工龄：" stringByAppendingString:dataDetail[@"seniority_name"]];
    
    [_phoneNumberBtn setTitle:dataDetail[@"tel"] forState:UIControlStateNormal];
    
    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:dataDetail[@"head_img"]] placeholderImage:[ImageHandler getWhiteLogo]];
    
}

@end
