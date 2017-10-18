//
//  InsetsLabel.m
//  cdzer
//
//  Created by KEns0n on 3/20/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#import "InsetsLabel.h"
IB_DESIGNABLE
@interface InsetsLabel ()

@property (nonatomic) NSAttributedString *attributedDefaultString;

@end

@implementation InsetsLabel


- (instancetype)init {
    self = [self initWithEdgeInsetsValue:UIEdgeInsetsZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame andEdgeInsetsValue:UIEdgeInsetsZero];
    return self;
}

- (instancetype)initWithEdgeInsetsValue:(UIEdgeInsets)insets {
    self = [self initWithFrame:CGRectZero andEdgeInsetsValue:insets];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andEdgeInsetsValue:(UIEdgeInsets)insets {
    self = [super initWithFrame:frame];
    if(self){
        //边缘插图
        self.edgeInsets = insets;
        self.strikeThroughEnabled = NO;
    }
    return self;
}
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setStrikeThroughEnabled:(BOOL)strikeThroughEnabled {
    _strikeThroughEnabled = strikeThroughEnabled;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    self.attributedDefaultString = self.attributedText;
}

- (CGFloat)heightThatFitsWithSpaceOffset:(CGFloat)spaceOffset {
    if (spaceOffset<=0) {
        spaceOffset = 0;
    }
    CGSize size = [SupportingClass getStringSizeWithString:self.text font:self.font widthOfView:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX) withEdgeInset:self.edgeInsets];
    if (self.attributedText!=self.attributedDefaultString) {
        size = [SupportingClass getAttributedStringSizeWithString:self.attributedText widthOfView:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX) withEdgeInset:self.edgeInsets];
    }
    return round(size.height+spaceOffset+_edgeInsets.top+_edgeInsets.bottom);
}

- (CGFloat)widthThatFitsWithSpaceOffset:(CGFloat)spaceOffset {
    if (spaceOffset<=0) {
        spaceOffset = 0;
    }
    CGSize size = [SupportingClass getStringSizeWithString:self.text font:self.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)) withEdgeInset:self.edgeInsets];
    if (self.attributedText!=self.attributedDefaultString) {
        size = [SupportingClass getAttributedStringSizeWithString:self.attributedText widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)) withEdgeInset:self.edgeInsets];
    }
    return round(size.width+spaceOffset+_edgeInsets.left+_edgeInsets.right);
}


- (void)drawTextInRect:(CGRect)rect {
    
    CGRect newRect = UIEdgeInsetsInsetRect(rect, _edgeInsets);
    
    [super drawTextInRect:newRect];
    CGSize textSize ;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        textSize = [[self text] sizeWithAttributes:@{NSFontAttributeName:[self font]}];
        
    }else {
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        textSize = [[self text] sizeWithFont:[self font]];
#pragma clang diagnostic pop
        
    }
    CGFloat strikeWidth = textSize.width;
    CGRect lineRect;
    
    if ([self textAlignment] == NSTextAlignmentRight) {
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
    } else if ([self textAlignment] == NSTextAlignmentCenter) {
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
    } else {
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
    }
    
    if (_strikeThroughEnabled) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, lineRect);
    }
}
@end
