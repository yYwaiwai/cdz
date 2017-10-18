//
//  DocumentPhotoDisplayView.m
//  cdzer
//
//  Created by 车队长 on 17/1/3.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "DocumentPhotoDisplayView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface DocumentPhotoDisplayView ()

@property (nonatomic, strong) NSArray *constraints;

@end

@implementation DocumentPhotoDisplayView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (IBAction)DocumentPhotoDisplayBGView:(id)sender {
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




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
