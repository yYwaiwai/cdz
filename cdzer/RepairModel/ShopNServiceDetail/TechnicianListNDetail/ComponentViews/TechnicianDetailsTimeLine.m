//
//  TechnicianDetailsTimeLine.m
//  cdzer
//
//  Created by 车队长 on 16/7/26.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "TechnicianDetailsTimeLine.h"

@implementation TechnicianDetailsTimeLine

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* shadowColor = [UIColor colorWithRed: 0.773 green: 0.773 blue: 0.773 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor];
    [shadow setShadowOffset: CGSizeMake(0.1, 1.1)];
    [shadow setShadowBlurRadius: 1];
    NSShadow* shadow2 = [[NSShadow alloc] init];
    [shadow2 setShadowColor: shadowColor];
    [shadow2 setShadowOffset: CGSizeMake(-1.1, 1.1)];
    [shadow2 setShadowBlurRadius: 1];
    
    //// Rectangle Drawing
    CGFloat rectangleOffsetX = 7;
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(rectangleOffsetX, 0,
                                                                                      CGRectGetWidth(rect)-rectangleOffsetX,
                                                                                      CGRectGetHeight(rect)-1) cornerRadius: 5];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Bezier Drawing
    CGFloat arrowOffsetX = 1;
    CGFloat arrowOffsetY = 10;
    CGFloat arrowWidth = 10;
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(rectangleOffsetX, arrowOffsetY)];
    [bezierPath addLineToPoint: CGPointMake(arrowOffsetX, arrowOffsetY+arrowWidth/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(rectangleOffsetX, arrowOffsetY+arrowWidth)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2.shadowOffset, shadow2.shadowBlurRadius, [shadow2.shadowColor CGColor]);
    [color setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);

}
@end
