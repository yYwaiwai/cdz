//
//  AnimationHandler.m
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "AnimationHandler.h"

@implementation AnimationHandler

+ (void)makeBarChartAnimationWithView:(UIView *)view totalCount:(CGFloat)totalCount currentCount:(CGFloat)currentCount {
    CGFloat scaleRatio = 1.0f;
    CGFloat ratio = currentCount/totalCount;
    if (totalCount==0&&currentCount==0) ratio = 0;
    
    CGRect rect = view.bounds;
    rect.size.width = CGRectGetWidth(rect)*ratio*scaleRatio;
    
    //1.获取图形上下文
    CGMutablePathRef path = CGPathCreateMutable();
    //2.绘图（画线）
    //设置起点
    CGPathMoveToPoint(path, nil, 0.0f, CGRectGetHeight(rect)/2.0f);
    //设置终点
    CGPathAddLineToPoint(path, nil, CGRectGetWidth(rect), CGRectGetHeight(rect)/2.0f);
     //
    CGPathCloseSubpath(path);
    
    
    CAShapeLayer *lineChart = [CAShapeLayer layer];
    lineChart.path = path;
    lineChart.fillColor = [UIColor clearColor].CGColor;
    lineChart.strokeColor = [UIColor colorWithRed:0.286 green:0.780 blue:0.961 alpha:1.00].CGColor;
    lineChart.lineWidth = CGRectGetHeight(rect);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.5f;
    animation.removedOnCompletion = NO;
    animation.autoreverses = NO;
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [lineChart addAnimation:animation forKey:@"drawChartAnimation"];
    
    [view.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [view.layer addSublayer:lineChart];
}
@end
