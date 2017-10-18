//
//  MaintenanceGuideButtonView.m
//  cdzer
//
//  Created by 车队长 on 16/10/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintenanceGuideButtonView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface MaintenanceGuideButtonView()
@property (nonatomic, strong) NSArray *constraints;

@end

@implementation MaintenanceGuideButtonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    [self.bgView.layer setCornerRadius:8.0];
    [self.bgView.layer setMasksToBounds:YES];
    
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

- (IBAction)buttonClick:(id)sender {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
        self.titleLabel.text=@"";
        self.contentLabel.text=@"";
        self.titleImageView.image=[UIImage imageNamed:@""];
      
        
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];

    
}

@end
