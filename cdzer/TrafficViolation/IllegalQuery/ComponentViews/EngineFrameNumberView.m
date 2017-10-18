//
//  EngineFrameNumberView.m
//  cdzer
//
//  Created by 车队长 on 16/12/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "EngineFrameNumberView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface EngineFrameNumberView ()
@property (nonatomic, strong) NSArray *constraints;
@end

@implementation EngineFrameNumberView
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)EngineFrameNumberViewBGView:(id)sender {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];

    
}
- (void)showView {
    [self removeFromSuperview];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    [window addSubview:self];
    if (!self.constraints) {
        self.constraints = [self addSelfByFourMarginToSuperview:window];
    }else {
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
@end
