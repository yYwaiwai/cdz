//
//  MainViewEServiceViewComponent.m
//  cdzer
//
//  Created by KEns0nLau on 6/16/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MainViewEServiceViewComponent.h"

@implementation MainViewEServiceViewComponent


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.layer.shouldRasterize = YES;
    // Drawing code
    
    double lineWidthRatio = 0.33816425120773;
    double diagonalWidthRatio = 0.07971014492754;
    
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    CGFloat lineWidth = round(width*lineWidthRatio);
    CGFloat diagonalWidth = round(width*diagonalWidthRatio);
    CGFloat centerPointY = height/2.0f;
    CGFloat centerPointYOffset = 0.5f;
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, centerPointY-centerPointYOffset)];
    [bezierPath addLineToPoint: CGPointMake(lineWidth, centerPointY-centerPointYOffset)];
    
    [bezierPath moveToPoint: CGPointMake(lineWidth, centerPointY)];
    [bezierPath addLineToPoint: CGPointMake(lineWidth+diagonalWidth, 0)];
    
    [bezierPath moveToPoint: CGPointMake(lineWidth, centerPointY)];
    [bezierPath addLineToPoint: CGPointMake(lineWidth+diagonalWidth, height)];
    
    
    
    [bezierPath moveToPoint: CGPointMake(width, centerPointY-centerPointYOffset)];
    [bezierPath addLineToPoint: CGPointMake(width-lineWidth, centerPointY-centerPointYOffset)];
    
    [bezierPath moveToPoint: CGPointMake(width-lineWidth, centerPointY)];
    [bezierPath addLineToPoint: CGPointMake(width-lineWidth-diagonalWidth, 0)];
    
    [bezierPath moveToPoint: CGPointMake(width-lineWidth, centerPointY)];
    [bezierPath addLineToPoint: CGPointMake(width-lineWidth-diagonalWidth, height)];
    
    
    [[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] setStroke];
    bezierPath.lineWidth = 0.5f;
    [bezierPath stroke];
    
}


@end
