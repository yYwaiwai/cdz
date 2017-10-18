//
//  InsetsLabel.h
//  cdzer
//
//  Created by KEns0n on 3/20/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface InsetsLabel : UILabel

@property (nonatomic) UIEdgeInsets edgeInsets;

@property (nonatomic) IBInspectable BOOL strikeThroughEnabled;

- (instancetype)initWithEdgeInsetsValue:(UIEdgeInsets)insets;

- (instancetype)initWithFrame:(CGRect)frame andEdgeInsetsValue:(UIEdgeInsets)insets;

- (CGFloat)heightThatFitsWithSpaceOffset:(CGFloat)spaceOffset;

- (CGFloat)widthThatFitsWithSpaceOffset:(CGFloat)spaceOffset;

@end
