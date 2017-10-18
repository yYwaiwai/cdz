//
//  NoBusinessView.m
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "NoBusinessView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface NoBusinessView()
@property (nonatomic, strong) NSArray *constraints;

@end
@implementation NoBusinessView
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    [self.bgView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)buttonClick:(id)sender {
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
