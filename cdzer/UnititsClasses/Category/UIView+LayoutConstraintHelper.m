//
//  UIView+LayoutConstraintHelper.m
//  baseproject
//
//  Created by KEns0nLau on 8/2/16.
//  Copyright © 2016 cdzer. All rights reserved.
//

#import "UIView+LayoutConstraintHelper.h"

@implementation UIView (LayoutConstraintHelper)

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview {
    return [self addSelfByFourMarginToSuperview:superview withEdgeConstant:UIEdgeInsetsZero];
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview withEdgeConstant:(UIEdgeInsets)edgeConstant {
   return [self addSelfByFourMarginToSuperview:superview withEdgeConstant:edgeConstant andLayoutAttribute:LayoutHelperAttributeFourEdge];
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview withEdgeConstant:(UIEdgeInsets)edgeConstant andLayoutAttribute:(LayoutHelperAttribute)layoutAttribute {
    NSMutableArray <NSLayoutConstraint *> *constraintsList = nil;
    if (superview&&self) {
        constraintsList = [@[] mutableCopy];
        [superview addSubview:self];
//        __block NSLayoutConstraint *superviewHeightConstraint = nil;
//        @weakify(superview);
//        [superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
//            @strongify(superview);
//            if (constraint.firstItem==superview&&constraint.firstAttribute==NSLayoutAttributeHeight) {
//                superviewHeightConstraint = constraint;
//            }
//        }];
//        if (superviewHeightConstraint) {
//            [superview removeConstraint:superviewHeightConstraint];
//            superviewHeightConstraint = nil;
//        }
        if (layoutAttribute&LayoutHelperAttributeTop) {
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:edgeConstant.top]];
        }
        
        if (layoutAttribute&LayoutHelperAttributeBottom) {
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:superview
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:edgeConstant.bottom]];
        }
        
        if (layoutAttribute&LayoutHelperAttributeLeading) {
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:edgeConstant.left]];
        }
        
        if (layoutAttribute&LayoutHelperAttributeTrailing) {
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:superview
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:edgeConstant.right]];
        }
        
        [superview addConstraints:constraintsList];
    }
    return constraintsList;
    
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfViewSize:(CGSize)size {
    NSMutableArray <NSLayoutConstraint *> *constraintsList = [@[] mutableCopy];
    __block NSLayoutConstraint *superviewWidthConstraint = nil;
    __block NSLayoutConstraint *superviewHeightConstraint = nil;
    @weakify(self);
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (constraint.firstItem==self&&constraint.firstAttribute==NSLayoutAttributeWidth) {
            superviewHeightConstraint = constraint;
        }
        if (constraint.firstItem==self&&constraint.firstAttribute==NSLayoutAttributeHeight) {
            superviewHeightConstraint = constraint;
        }
    }];
    if (superviewWidthConstraint) {
        [self removeConstraint:superviewWidthConstraint];
        superviewWidthConstraint = nil;
    }
    if (superviewHeightConstraint) {
        [self removeConstraint:superviewHeightConstraint];
        superviewHeightConstraint = nil;
    }
    [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:size.width]];
    [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:size.height]];
    [self addConstraints:constraintsList];
    return constraintsList;
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByCenterOffsetToSuperview:(UIView *)superview withOffsetPoint:(CGPoint)offsetPoint multiplierPoint:(CGPoint)multiplierPoint andLayoutAttribute:(LayoutHelperAttribute)layoutAttribute {
    NSMutableArray <NSLayoutConstraint *> *constraintsList = nil;
    if (superview&&self) {
        constraintsList = [@[] mutableCopy];
        [superview addSubview:self];
        if (layoutAttribute&LayoutHelperAttributeCenterX) {
            if (multiplierPoint.x<=0) multiplierPoint.x = 1;
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:multiplierPoint.x
                                                                     constant:offsetPoint.x]];
        }
        
        if (layoutAttribute&LayoutHelperAttributeCenterY) {
            if (multiplierPoint.y<=0) multiplierPoint.y = 1;
            [constraintsList addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:multiplierPoint.y
                                                                     constant:offsetPoint.y]];
        }
        
        [superview addConstraints:constraintsList];
    }
    return constraintsList;
    
}

@end
