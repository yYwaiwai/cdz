//
//  InsetsTextField.m
//  cdzer
//
//  Created by KEns0n on 3/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "InsetsTextField.h"

@implementation InsetsTextField

- (void)dealloc {
//    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)setandEdgeInsetsValue:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame andEdgeInsetsValue:(UIEdgeInsets)edgeInsets {
    self = [super initWithFrame:frame];
    if (self) {
        self.shouldStopPCDAction = YES;
        self.edgeInsets = edgeInsets;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder andEdgeInsetsValue:(UIEdgeInsets)edgeInsets {
    self = [super initWithCoder:aDecoder];
    if(self){
        self.shouldStopPCDAction = YES;
        self.edgeInsets = edgeInsets;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.shouldStopPCDAction = YES;
        self.edgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        self.shouldStopPCDAction = YES;
        self.edgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    UIEdgeInsets tmpInsetsValue = self.edgeInsets;
    if (self.leftView) tmpInsetsValue.left = 0.0f;
    if (self.rightView) tmpInsetsValue.right = 0.0f;
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, tmpInsetsValue)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    UIEdgeInsets tmpInsetsValue = self.edgeInsets;
    if (self.leftView) tmpInsetsValue.left = 0.0f;
    if (self.rightView) tmpInsetsValue.right = 0.0f;
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, tmpInsetsValue)];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    UIEdgeInsets tmpInsetsValue = self.edgeInsets;
    if (self.leftView) tmpInsetsValue.left = 0.0f;
    if (self.rightView) tmpInsetsValue.right = 0.0f;
    return [super clearButtonRectForBounds:UIEdgeInsetsInsetRect(bounds, tmpInsetsValue)];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    UIEdgeInsets tmpInsetsValue = self.edgeInsets;
    tmpInsetsValue.right = 4.0f;
    CGRect rect = UIEdgeInsetsInsetRect(bounds, tmpInsetsValue);
    return [super leftViewRectForBounds:rect];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    UIEdgeInsets tmpInsetsValue = self.edgeInsets;
    tmpInsetsValue.left = 4.0f;
    CGRect rect = UIEdgeInsetsInsetRect(bounds, tmpInsetsValue);
    return [super rightViewRectForBounds:rect];
}

@end
