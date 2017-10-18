//
//  UIView+LayoutConstraintHelper.h
//  baseproject
//
//  Created by KEns0nLau on 8/2/16.
//  Copyright © 2016 cdzer. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, LayoutHelperAttribute) {
    LayoutHelperAttributeTop            = 1 << 0,
    LayoutHelperAttributeBottom         = 1 << 1,
    LayoutHelperAttributeLeading        = 1 << 2,
    LayoutHelperAttributeTrailing       = 1 << 3,
    LayoutHelperAttributeCenterX        = 1 << 4,
    LayoutHelperAttributeCenterY        = 1 << 5,
    LayoutHelperAttributeFourEdge       = ~0UL,
};
#import <UIKit/UIKit.h>

@interface UIView (LayoutConstraintHelper)

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview;

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview withEdgeConstant:(UIEdgeInsets)edgeConstant;

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview withEdgeConstant:(UIEdgeInsets)edgeConstant andLayoutAttribute:(LayoutHelperAttribute)layoutAttribute;

- (NSMutableArray <NSLayoutConstraint *> *)addSelfViewSize:(CGSize)size;

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByCenterOffsetToSuperview:(UIView *)superview withOffsetPoint:(CGPoint)offsetPoint multiplierPoint:(CGPoint)multiplierPoint andLayoutAttribute:(LayoutHelperAttribute)layoutAttribute;
@end
