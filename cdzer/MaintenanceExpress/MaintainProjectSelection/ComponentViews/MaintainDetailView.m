//
//  MaintainDetailView.m
//  cdzer
//
//  Created by KEns0nLau on 9/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintainDetailView.h"
#import "UIView+LayoutConstraintHelper.h"
@interface MaintainDetailView ()

@property (nonatomic, strong) NSArray *constraints;


@end

@implementation MaintainDetailView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.contentLabel.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:14];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}


- (void)showView {
    [self removeFromSuperview];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!self.constraints) {
        self.constraints = [self addSelfByFourMarginToSuperview:window];
    }else {
        [window addSubview:self];
        [window addConstraints:self.constraints];
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1;
        
    }];
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
    [self setNeedsLayout];

}

- (IBAction)hiddenView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];
    
}


@end
