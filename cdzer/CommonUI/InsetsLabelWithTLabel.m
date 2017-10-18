//
//  InsetsLabelWithTLabel.m
//  cdzer
//
//  Created by KEns0n on 11/23/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "InsetsLabelWithTLabel.h"

@implementation InsetsLabelWithTLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame andEdgeInsetsValue:(UIEdgeInsets)insets {
    self = [super initWithFrame:frame andEdgeInsetsValue:insets];
    if (self) {
        self.titleNContenWidth = 0.0f;
        CGRect titleRect = self.bounds;
        titleRect.size.width = insets.left;
        self.titleLabel = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:insets];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self addSubview:_titleLabel];
        [self setReactiveRules];
    }
    return self;
}

- (void)setTitleLabel:(InsetsLabel *)titleLabel {
    @autoreleasepool {
        _titleLabel = nil;
        _titleLabel = titleLabel;
    }
}

- (void)updateTitleWidth {
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, titleLabel.text) subscribeNext:^(NSString *text) {
        @strongify(self);
        [self updateInsetValue:self.defaultInsets];
    }];
    
    [RACObserve(self, titleLabel.font) subscribeNext:^(UIFont *font) {
        @strongify(self);
        [self updateInsetValue:self.defaultInsets];
    }];
}

- (void)setTitleNContenWidth:(CGFloat)titleNContenWidth {
    _titleNContenWidth = round(titleNContenWidth);
}

- (CGFloat)getTitleWidth {
    CGSize size = [SupportingClass getStringSizeWithString:self.titleLabel.text font:self.titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.titleLabel.frame))];
    return round(size.width);
}

- (void)updateInsetValue:(UIEdgeInsets)edgeInsets {
    self.defaultInsets = edgeInsets;
    self.insetsForTitle = edgeInsets;
    _insetsForTitle.left = edgeInsets.left+self.getTitleWidth+_titleNContenWidth;
    
    UIEdgeInsets leftInsets = edgeInsets;
    leftInsets.right = 0;
    self.titleLabel.edgeInsets = leftInsets;
    CGRect frame = self.titleLabel.frame;
    frame.size.width = self.getTitleWidth+self.defaultInsets.left;
    self.titleLabel.frame = frame;
    
    [super setEdgeInsets:(self.titleLabel.hidden)?_defaultInsets:_insetsForTitle];
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    [self updateInsetValue:edgeInsets];
}

@end
