//
//  BadgeButtonView.m
//  cdzer
//
//  Created by KEns0n on 3/24/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vFont systemFontBoldWithoutRatio(12.0f)
#define vBtnMinWidth 50.0f
#define vLblMinWidth 14.0f
#import "BadgeButtonView.h"

@interface BadgeButtonView ()

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UILabel *badgeLabel;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *title;

@end

@implementation BadgeButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
    }
    return self;
}
- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    self.button.tag = tag;
}

- (void)initializationUI {
    if (!_button) {
//        if (!_image) {
//            self.image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"tmp_icon" type:FMImageTypeOfPNG scaleWithPhone4:NO needToUpdate:YES];
//        }
        if (!_title) {
            self.title = @"";
        }
        CGSize titleSize = [SupportingClass getStringSizeWithString:_title
                                                               font:vFont
                                                        widthOfView:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/2.0f)];
        self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setFrame:self.bounds];
        [_button.titleLabel setFont:vFont];
        [_button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_button setImage:_image forState:UIControlStateNormal];
        [_button setImage:_image forState:UIControlStateHighlighted];
        [_button setTitle:_title forState:UIControlStateNormal];
        [_button setTitle:_title forState:UIControlStateHighlighted];
        [_button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        CGFloat imageOffsetX = (CGRectGetWidth(self.frame)-_image.size.width)/2.0f;
        [_button setImageEdgeInsets:UIEdgeInsetsMake((2.0f), imageOffsetX, 0.0f, 0.0f)];
        
        CGPoint titleOffset = CGPointZero;
        titleOffset.y = CGRectGetHeight(self.frame)-titleSize.height;
        titleOffset.x = _image.size.width;
        [_button setTitleEdgeInsets:UIEdgeInsetsMake(titleOffset.y, -titleOffset.x, 0.0f, 0.0f)];
        
        [_button setTintColor:[UIColor colorWithRed:0.404f green:0.404f blue:0.404f alpha:1.00f]];
        [self addSubview:_button];
    }
    
    if (!_badgeLabel) {
        self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-vLblMinWidth, 0.0f, vLblMinWidth, vLblMinWidth)];
        [_badgeLabel.layer setCornerRadius:vLblMinWidth/2.0f];
        [_badgeLabel.layer setMasksToBounds:YES];
        [_badgeLabel setBackgroundColor:[UIColor redColor]];
        [_badgeLabel setTextColor:[UIColor whiteColor]];
        [_badgeLabel setTextAlignment:NSTextAlignmentCenter];
        [_badgeLabel setFont:[UIFont systemFontOfSize:(10.0f)]];
        [self addSubview:_badgeLabel];
        [self setBadgeCount:1];
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [_button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setBadgeCount:(NSUInteger)badgeCount {
    _badgeCount = badgeCount;
    [_badgeLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)badgeCount]];
    if (badgeCount<=0) {
        [_badgeLabel setHidden:YES];
    }
}

- (void)setFrame:(CGRect)frame{
    if (CGRectGetWidth(frame)<vBtnMinWidth) {
        frame.size.width = vBtnMinWidth;
    }
    if (CGRectGetHeight(frame)<vBtnMinWidth) {
        frame.size.height = vBtnMinWidth;
    }
    [super setFrame:frame];
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setImage:(UIImage *)image andTitle:(NSString *)title {
    self.image = image;
    self.title = title;
    CGSize titleSize = [SupportingClass getStringSizeWithString:_title
                                                           font:vFont
                                                    widthOfView:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/2.0f)];
    [_button setImage:_image forState:UIControlStateNormal];
    [_button setImage:_image forState:UIControlStateHighlighted];
    [_button setTitle:_title forState:UIControlStateNormal];
    [_button setTitle:_title forState:UIControlStateHighlighted];
    [_button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    CGFloat imageOffsetX = (CGRectGetWidth(self.frame)-_image.size.width)/2.0f;
    [_button setImageEdgeInsets:UIEdgeInsetsMake((2.0f), imageOffsetX, 0.0f, 0.0f)];
    
    CGPoint titleOffset = CGPointZero;
    titleOffset.y = CGRectGetHeight(self.frame)-titleSize.height;
    titleOffset.x = _image.size.width;
    [_button setTitleEdgeInsets:UIEdgeInsetsMake(titleOffset.y, -titleOffset.x, 0.0f, 0.0f)];
}


@end
