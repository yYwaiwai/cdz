//
//  CommentMiniView.m
//  cdzer
//
//  Created by KEns0n on 3/11/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vMinHeight 32.0f
#import "CommentMiniView.h"
#import "HCSStarRatingView.h"
#import "InsetsLabel.h"

@interface CommentMiniView ()

@property (nonatomic, strong) UIButton *serviceCommentBtn;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@property (nonatomic, strong) UIImageView *arrowIV;

@property (nonatomic, strong) UILabel *totalBookmark;

@end


@implementation CommentMiniView

- (void)initializationUI {
    @autoreleasepool {
        
        if (CGRectGetHeight(self.frame)<vMinHeight) {
            CGRect rect = self.frame;
            rect.size.height = vMinHeight;
            [self setFrame:rect];
        }
        
        
        [self setBackgroundColor:CDZColorOfWhite];
        [self setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
        
        CGRect srvRect = CGRectZero;
        srvRect.origin.x = 100.0f;
        srvRect.size = CGSizeMake(70.0f, CGRectGetHeight(self.bounds));
        self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:srvRect];
        [_starRatingView setMaximumValue:5.0f];
        [_starRatingView setMinimumValue:0.0f];
        [_starRatingView setAllowsHalfStars:NO];
        [_starRatingView setValue:3.0f];
        [_starRatingView setTintColor:[UIColor redColor]];
        [_starRatingView setUserInteractionEnabled:NO];
        //            [starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_starRatingView];
        
        
        
        UIFont *font = [UIFont systemFontOfSize:15.0f];
        NSString *text = @"（00000人评价）";
        CGRect tbRect = srvRect;
        tbRect.origin.x = CGRectGetMaxX(srvRect);
        tbRect.size.width = [SupportingClass getStringSizeWithString:text font:font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
        self.totalBookmark = [[UILabel alloc] initWithFrame:tbRect];
        [_totalBookmark setText:text];
        [_totalBookmark setTextColor:[UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f]];
        [_totalBookmark setFont:font];
        [self addSubview:_totalBookmark];
        
        CGFloat width = 12.0f*vWidthRatio;
        self.arrowIV= [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-width-14.0f,
                                                                            (CGRectGetHeight(self.frame)-width)/2.0f,
                                                                            width,
                                                                            width)];
         _arrowIV.image = ImageHandler.getRightArrow;
        [self addSubview:_arrowIV];
        
        
        
        [self setServiceCommentBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
        [_serviceCommentBtn setFrame:self.bounds];
        [_serviceCommentBtn setBackgroundColor:[UIColor clearColor]];
        [_serviceCommentBtn setTitle:@"服务评论" forState:UIControlStateNormal];
        [_serviceCommentBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_serviceCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_serviceCommentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 0.0f)];
        [_serviceCommentBtn setTitleColor:[UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f] forState:UIControlStateNormal];
        _serviceCommentBtn.userInteractionEnabled = NO;
        [self addSubview:_serviceCommentBtn];
       
    }
}


- (void)setNumberOfComment:(NSString *)comment withRatingValue:(NSString *)ratingValue {
    _arrowIV.hidden = NO;
    if ([SupportingClass verifyAndConvertDataToNumber:comment].unsignedIntegerValue==0) {
        _arrowIV.hidden = YES;
    }
    _totalBookmark.text = [NSString stringWithFormat:@"（%@人评价）",comment];
    _starRatingView.value = ratingValue.floatValue*5.0f;
}

@end
