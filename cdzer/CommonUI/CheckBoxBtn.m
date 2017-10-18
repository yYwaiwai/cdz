//
//  CheckBoxBtn.m
//  cdzer
//
//  Created by KEns0n on 4/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#define selectImageSize CGSizeMake(22.0f,22.0f)
#import "CheckBoxBtn.h"

@interface CheckBoxBtn ()
- (void)changeSelectionState;
@end

@implementation CheckBoxBtn


+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    
    CheckBoxBtn *button = [super buttonWithType:buttonType];
    [button setTintColor:CDZColorOfDefaultColor];
    [button setDeselectedImage:[self drawRotundityWithTick:NO
                                                      size:selectImageSize
                                               strokeColor:nil
                                                 fillColor:nil]];
    
    [button setSelectedImage:[self drawRotundityWithTick:YES
                                                      size:selectImageSize
                                               strokeColor:nil
                                                 fillColor:nil]];
    
    [button setImage:button.deselectedImage forState:UIControlStateNormal];
    [button setImage:button.deselectedImage forState:UIControlStateHighlighted];
    [button setImage:button.selectedImage forState:UIControlStateSelected];
    [button setSelected:YES];
    [button addTarget:button action:@selector(changeSelectionState) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)changeSelectionState {
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected {
    UIImage *image = selected?_selectedImage:_deselectedImage;
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [super setSelected:selected];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:YES];
}

+ (UIImage *)drawRotundityWithTick:(BOOL)isSelected
                              size:(CGSize)size
                       strokeColor:(UIColor *)strokColor
                       fillColor:(UIColor *)fillColor{
    
    CGRect rect = CGRectZero;
    rect.origin = CGPointMake(1.0f, 1.0f);
    rect.size.width = size.width-CGRectGetMinX(rect)*2.0f;
    rect.size.height = size.height-CGRectGetMinX(rect)*2.0f;
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGRectGetWidth(rect),
                                                 CGRectGetHeight(rect), 8, 0,
                                                 CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNone|kCGImageAlphaPremultipliedFirst);
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
    CGContextSetShouldAntialias(context, YES);
    UIBezierPath *ovalPath = nil;
    if (!isSelected) {
        if(!strokColor) strokColor = UIColor.grayColor;
        ovalPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        ovalPath.lineWidth = 1.0f;
        [strokColor setStroke];
        [ovalPath stroke];
    }else {
        if(!fillColor) fillColor = CDZColorOfDefaultColor;
        if(!strokColor) strokColor = UIColor.whiteColor;
        
        ovalPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [fillColor setStroke];
        [fillColor setFill];
        [ovalPath fill];
        [ovalPath stroke];

        UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [strokColor setStroke];
        [strokColor setFill];
        [linePath removeAllPoints];
        linePath.lineWidth = 1.0f;
        [linePath moveToPoint:CGPointMake(5.0f, 12.0f)];
        [linePath addLineToPoint:CGPointMake(9.0f, 16.0f)];
        [linePath addLineToPoint:CGPointMake(16.0f, 8.0f)];
        [linePath addLineToPoint:CGPointMake(16.0f, 7.0f)];
        [linePath addLineToPoint:CGPointMake(9.0f, 15.0f)];
        [linePath addLineToPoint:CGPointMake(5.0f, 11.0f)];
        [linePath closePath];
        [linePath stroke];
        [linePath fill];
        
        
        [linePath appendPath:ovalPath];
        [linePath setUsesEvenOddFillRule:YES];
        [linePath addClip];
    }
    CGContextAddPath(context, ovalPath.CGPath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    NSLog(@"%f",image.scale);
    //    NSLog(@"%@",NSStringFromCGSize(image.size));
    CGContextRelease(context);
    UIGraphicsEndImageContext();
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
