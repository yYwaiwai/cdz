//
//  DRVCCircularMenu.m
//  cdzer
//
//  Created by KEns0n on 09/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "DRVCCircularMenu.h"
#import <pop/POP.h>
#import <QuartzCore/QuartzCore.h>
@interface DRVCCircularMenu()

@property (nonatomic, assign) BOOL showFullCircular;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *fillLayer;

@end

@implementation DRVCCircularMenu

- (void)awakeFromNib {
    [super awakeFromNib];
    self.showFullCircular = NO;
    self.fillLayer = [CAShapeLayer new];
    self.fillLayer.fillColor = self.fillColor.CGColor;
    self.fillLayer.fillRule = kCAFillRuleEvenOdd;
    
    // add fill path to superlayer
    [self.layer addSublayer:self.fillLayer];
    
    // configure masking layer
    self.maskLayer = [CAShapeLayer new];
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.layer.mask = self.maskLayer;
    self.fillColor = [UIColor colorWithRed:0.282 green:0.718 blue:0.871 alpha:1.00];
    [self addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showMenu {
    self.showFullCircular = !self.showFullCircular;
    [self setNeedsLayout];
    UIColor *color = [UIColor colorWithRed:0.282 green:0.718 blue:0.871 alpha:1.00];
    CABasicAnimation *animcolor = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animcolor.fromValue = (id)UIColor.greenColor.CGColor;
    animcolor.toValue = (id)UIColor.orangeColor.CGColor;
    animcolor.duration = 1.0;
    animcolor.repeatCount = 0;
    [self.fillLayer addAnimation:animcolor forKey:@"fillColor"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *startOvalPath = nil;
    UIBezierPath *endOvalPath = nil;
    
    if (self.showFullCircular) {
        startOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake((198-44)/2, (198-44)/2, 44, 44)];
        endOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 198, 198)];
    }else {
        startOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 198, 198)];
        endOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake((198-44)/2, (198-44)/2, 44, 44)];
    }
    self.fillLayer.path = endOvalPath.CGPath;
    self.maskLayer.path = endOvalPath.CGPath;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}

@end
