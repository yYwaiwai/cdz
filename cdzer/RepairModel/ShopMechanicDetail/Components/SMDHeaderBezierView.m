//
//  SMDHeaderBezierView.m
//  cdzer
//
//  Created by KEns0n on 17/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMDHeaderBezierView.h"
@interface SMDHeaderBezierView()

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) CGFloat transformRatio;

@end

@implementation SMDHeaderBezierView

- (void)awakeFromNib {
    [super awakeFromNib];
    _theHeight = roundf(SCREEN_WIDTH/7.392857142857143);
    self.transformRatio = 1;
}

- (void)setTransformRatio:(CGFloat)transformRatio {
    if (transformRatio>1) transformRatio = 1;
    if (transformRatio<0) transformRatio = 0;
    _transformRatio = [NSString stringWithFormat:@"%0.2f", transformRatio].floatValue;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIColor *color = [UIColor whiteColor];
    [color set]; //设置线条颜色
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, 0)];
//    [aPath addQuadCurveToPoint:CGPointMake(CGRectGetWidth(rect), 0)
//                  controlPoint:CGPointMake(CGRectGetWidth(rect)/2.0f, 42)];
    NSUInteger height = roundf(self.theHeight*self.transformRatio);
    [aPath addCurveToPoint:CGPointMake(CGRectGetWidth(rect), 0)
             controlPoint1:CGPointMake(CGRectGetWidth(rect)*0.29f, height)
             controlPoint2:CGPointMake(CGRectGetWidth(rect)*0.71f, height)];
    
    [aPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [aPath addLineToPoint:CGPointMake(0, CGRectGetHeight(rect))];
    [aPath closePath];

    
    [aPath fill];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    [self removeObservers];
    _scrollView = scrollView;
    [self addObservers];
}

- (void)addObservers {
    if (self.scrollView) {
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
        [self.scrollView addObserver:self forKeyPath:@"contentInset" options:options|NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)removeFromSuperview {
    self.scrollView = nil;
    [super removeFromSuperview];
}

- (void)removeObservers {
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentInset"]) {
        self.contentInset = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
    }
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint newContentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        NSUInteger currentOffsetY = 0;
        if (newContentOffset.y<(self.contentInset.top*-1)) newContentOffset.y = (self.contentInset.top*-1);
        if (newContentOffset.y<0) currentOffsetY = (newContentOffset.y*-1);
        self.transformRatio = currentOffsetY/self.contentInset.top;
    }
}



@end
