//
//  SMSLCellIndicatorBarView.m
//  cdzer
//
//  Created by KEns0n on 17/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMSLCellIndicatorBarView.h"

@implementation SMSLCellIndicatorBarView

- (void)awakeFromNib {
    _currentValue = 0;
}

- (void)setCurrentValue:(CGFloat)currentValue {
    if (currentValue>1) currentValue = 1;
    if (currentValue<0) currentValue = 0;
    _currentValue = currentValue;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.frame)/2.0f];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed:0.965 green:0.682 blue:0.251 alpha:1.00];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = nil;
    rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))
                                               cornerRadius: CGRectGetHeight(rect)/2.0f];
    CGContextSaveGState(context);
    [color setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    CGContextRestoreGState(context);
    rectanglePath = nil;
    NSUInteger width = round(CGRectGetWidth(rect)*_currentValue);
    rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, width, CGRectGetHeight(rect))
                                               cornerRadius: CGRectGetHeight(rect)/2.0f];
    [color setFill];
    [rectanglePath fill];
}

@end
