//
//  UIView+ShareAction.h
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef void(^LoginResultBlockForUIView)(BOOL isSuccess);

typedef NS_OPTIONS(NSUInteger, UIRectBorder) {
    UIRectBorderTop             = 1 << 0,
    UIRectBorderLeft            = 1 << 1,
    UIRectBorderBottom          = 1 << 2,
    UIRectBorderRight           = 1 << 3,
    UIRectBorderAllBorderEdge   = ~0UL,
    UIRectBorderNone            = 1 << 4,
};

#import <UIKit/UIKit.h>
#import "UIView+Toast.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

@interface BorderOffsetObject : NSObject

@property (nonatomic, assign) CGFloat upperOffset;

@property (nonatomic, assign) CGFloat upperLeftOffset;

@property (nonatomic, assign) CGFloat upperRightOffset;


@property (nonatomic, assign) CGFloat bottomOffset;

@property (nonatomic, assign) CGFloat bottomLeftOffset;

@property (nonatomic, assign) CGFloat bottomRightOffset;


@property (nonatomic, assign) CGFloat leftOffset;

@property (nonatomic, assign) CGFloat leftUpperOffset;

@property (nonatomic, assign) CGFloat leftBottomOffset;


@property (nonatomic, assign) CGFloat rightOffset;

@property (nonatomic, assign) CGFloat rightUpperOffset;

@property (nonatomic, assign) CGFloat rightBottomOffset;

@end

@interface UIView (ShareAction)

@property (nonatomic, strong, readonly) BorderOffsetObject *borderOffset;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

- (void)setBackgroundImageByCALayerWithImage:(UIImage *)image;

- (void)setBackgroundImageByCALayerWithImage:(UIImage *)image wasSizeByImage:(BOOL)sizeByImage;

- (void)setBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width;

- (void)setViewCornerWithRectCorner:(UIRectCorner)rectCorner cornerSize:(CGFloat)cornerSize;

- (void)setViewBorderWithRectBorder:(UIRectBorder)rectBorder borderSize:(CGFloat)borderSize withColor:(UIColor *)color withBroderOffset:(BorderOffsetObject *)borderOffset;

- (UIColor *)getDefaultBGColor;

- (UIColor *)getDefaultSeparatorLineColor;

- (UIColor *)getDefaultSeparatorLineDarkColor;

- (UIColor *)getDefaultTextColor;

- (UIColor *)getDefaultTextDarkColor;

- (UIColor *)getDefaultTimeTextColor;

- (void)handleMissingTokenAction:(LoginResultBlockForUIView)resulyBlock;

@end
