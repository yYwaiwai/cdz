//
//  CommentListCell.m
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vMinHeight vAdjustByScreenRatio(115.0f)
#import "CommentListCell.h"

@interface CommentListCell ()

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@property (nonatomic, strong) UILabel *dateTimeLabel;

@property (nonatomic, strong) UILabel *commentDescriptionLabel;

@end

@implementation CommentListCell

- (void)initializationUI {
    CGFloat positionX = vAdjustByScreenRatio(16.0f);
    CGFloat positionY = vAdjustByScreenRatio(4.0f);
    
    if (!_userNameLabel) {
        NSString *nameText = @"ahdsl挥洒历史的哈";
        UIFont *font = [UIFont boldSystemFontOfSize:vAdjustByScreenRatio(16.0f)];
        UIColor *textColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        
        CGRect rect = CGRectZero;
        rect.origin.x = positionX;
        rect.origin.y = positionY;
        rect.size = [SupportingClass getStringSizeWithString:nameText font:font widthOfView:CGSizeMake(CGFLOAT_MAX, 100)];
        [self setUserNameLabel:[[UILabel alloc] initWithFrame:rect]];
        [_userNameLabel setText:nameText];
        [_userNameLabel setTextColor:textColor];
        [_userNameLabel setFont:font];
        [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_userNameLabel];
        
    }
    
    if (!_dateTimeLabel) {
        NSString *timeText = @"2015-03-19\n25:10:10";
        UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(12.0f)];
        
        CGRect rect = CGRectZero;
        rect.size = [SupportingClass getStringSizeWithString:timeText font:font widthOfView:CGSizeMake(CGFLOAT_MAX, 100.0f)];
        rect.origin.x = CGRectGetWidth(self.frame)-CGRectGetWidth(rect)-positionX;
        rect.origin.y = CGRectGetMinY(_userNameLabel.frame);
        [self setDateTimeLabel:[[UILabel alloc] initWithFrame:rect]];
        [_dateTimeLabel setText:timeText];
        [_dateTimeLabel setFont:font];
        [_dateTimeLabel setNumberOfLines:-1];
        [_dateTimeLabel setTextColor:[UIColor lightGrayColor]];
        [_dateTimeLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_dateTimeLabel];
        
    }
    
    
    if (!_starRatingView) {
        CGRect rect = CGRectZero;
        rect.origin.x = CGRectGetMinX(_userNameLabel.frame);
        rect.origin.y = CGRectGetMaxY(_userNameLabel.frame);
        rect.size = CGSizeMake(vAdjustByScreenRatio(80.0f), vAdjustByScreenRatio(25.0f));
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
    
    if (!_commentDescriptionLabel) {
        NSString *timeText = @"环境还不错，有无线上网，价格比较划算！值得推存，服务态度更加别提了，极好，给个赞！！！！";
        UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
        CGFloat maxWidth = CGRectGetWidth(self.frame)-positionX*2.0f;
        
        CGRect rect = _starRatingView.frame;
        rect.size = [SupportingClass getStringSizeWithString:timeText font:font widthOfView:CGSizeMake(maxWidth, 100.0f)];
        rect.origin.y = CGRectGetMaxY(_starRatingView.frame)+vAdjustByScreenRatio(6.0f);
        [self setCommentDescriptionLabel:[[UILabel alloc] initWithFrame:rect]];
        [_commentDescriptionLabel setText:timeText];
        [_commentDescriptionLabel setFont:font];
        [_commentDescriptionLabel setNumberOfLines:-1];
        [_commentDescriptionLabel setTextColor:[UIColor blackColor]];
        [_commentDescriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_commentDescriptionLabel];
        
    }
    CGRect cellRect = self.frame;
    cellRect.size.height = vMinHeight;
    [self setFrame:cellRect];
}

- (void)updateUIDataWithData:(NSDictionary *)dataDetail {
    @autoreleasepool {
        NSMutableString *dateString = [NSMutableString stringWithString:[dataDetail[@"create_time"] stringByReplacingOccurrencesOfString:@" " withString:@"\n"]];
        if ([[dateString substringWithRange:NSMakeRange(dateString.length-1, 1)] isEqualToString:@"\n"]) {
            [dateString deleteCharactersInRange:NSMakeRange(dateString.length-1, 1)];
        }
        _dateTimeLabel.text = dateString;
        _userNameLabel.text = dataDetail[@"reviewer_name"];
        _starRatingView.value = [dataDetail[@"star"] floatValue];
        _commentDescriptionLabel.text = dataDetail[@"content"];
    }
    
}

@end
