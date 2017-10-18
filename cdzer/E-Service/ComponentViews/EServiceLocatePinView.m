//
//  EServiceLocatePinView.m
//  cdzer
//
//  Created by KEns0nLau on 6/4/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define vMinHeight 50.0f
#define vMinWidth vMinHeight*2.0f
#define vMaxWidth 200.0f
#import "EServiceLocatePinView.h"

@interface EServiceLocatePinView ()

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *addressNoArrowConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *addressWithArrowConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *arrowIV;

@property (nonatomic, weak) IBOutlet UILabel *theAddressLabel;

@property (nonatomic, strong) NSLayoutConstraint *centerHorizontalConstraint;

@property (nonatomic, strong) NSLayoutConstraint *centerVerticalConstraint;

@property (nonatomic, strong) NSLayoutConstraint *moreWidthConstraint;

@property (nonatomic, strong) NSLayoutConstraint *lessWidthConstraint;

@property (nonatomic, strong) NSLayoutConstraint *moreHeightConstraint;

@end

@implementation EServiceLocatePinView

- (UILabel *)addressLabel {
    return self.theAddressLabel;
}

- (void)dealloc {
    
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.addressNoArrowConstraint.active = !self.showArrow;
    self.addressWithArrowConstraint.active = self.showArrow;
    self.arrowIV.hidden = !self.showArrow;
    
    if (self.superview) {
        if (!self.centerHorizontalConstraint) {
            self.centerHorizontalConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.superview
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0];
            [self.superview addConstraint:self.centerHorizontalConstraint];
        }
        
        CGFloat yOffset = -(((NSInteger)CGRectGetHeight(self.frame)-self.centerPointOffset.vertical)/2.0f);
        
        if (!self.centerVerticalConstraint) {
            self.centerVerticalConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:yOffset];
            [self.superview addConstraint:self.centerVerticalConstraint];
        }else {
            self.centerVerticalConstraint.constant = yOffset;
        }
    }
    [self setNeedsDisplay];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.showArrow = NO;
    self.addressNoArrowConstraint.active = !self.showArrow;
    self.addressWithArrowConstraint.active = self.showArrow;
    self.arrowIV.hidden = !self.showArrow;
    
    self.moreWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:vMinWidth];
    
    self.lessWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:vMaxWidth];
    
    self.moreHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:vMinHeight];
    [self addConstraints:@[self.moreWidthConstraint,
                           self.lessWidthConstraint,
                           self.moreHeightConstraint,]];
    self.arrowIV.image = [self.arrowIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setFrame:(CGRect)frame {
    if (frame.size.width<vMinWidth) frame.size.width = vMinWidth;
    if (frame.size.width>vMaxWidth) frame.size.width = vMaxWidth;
    if (frame.size.height<vMinHeight) frame.size.height = vMinHeight;
    [super setFrame:frame];
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)setShowArrow:(BOOL)showArrow {
    _showArrow = showArrow;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.7];
    
    //// Oval Drawing
    CGFloat pointerHeight = 14.0f;
    CGFloat roundHeight = roundf(CGRectGetHeight(rect)-pointerHeight);
    if ((NSInteger)roundHeight%2==1) {
        pointerHeight ++;
        roundHeight = roundf(CGRectGetHeight(rect)-pointerHeight);
    }
    
    CGRect ovalRect = CGRectMake(0, 0, roundHeight, roundHeight);
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)) radius: CGRectGetWidth(ovalRect) / 2 startAngle: 90 * M_PI/180 endAngle: -90 * M_PI/180 clockwise: YES];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect))];
    [ovalPath closePath];
    
    [color setFill];
    [ovalPath fill];
    
    
    //// Oval 2 Drawing
    CGRect oval2Rect = CGRectMake(CGRectGetWidth(rect)-roundHeight, 0, roundHeight, roundHeight);
    UIBezierPath* oval2Path = [UIBezierPath bezierPath];
    [oval2Path addArcWithCenter: CGPointMake(CGRectGetMidX(oval2Rect), CGRectGetMidY(oval2Rect)) radius: CGRectGetWidth(oval2Rect) / 2 startAngle: 270 * M_PI/180 endAngle: 90 * M_PI/180 clockwise: YES];
    [oval2Path addLineToPoint: CGPointMake(CGRectGetMidX(oval2Rect), CGRectGetMidY(oval2Rect))];
    [oval2Path closePath];
    
    [color setFill];
    [oval2Path fill];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(roundHeight/2.0f, 0, CGRectGetWidth(rect)-roundHeight, roundHeight)];
    [color setFill];
    [rectanglePath fill];
    
    
    //// Bezier 2 Drawing
    CGFloat centerPiont = CGRectGetWidth(rect)/2.0f;
    CGFloat topPointY = roundHeight;
    CGFloat bottomPointY = CGRectGetHeight(rect);
    CGFloat triangleWidth = 13.0f;
    CGFloat triangleHalfWidth = triangleWidth/2.0f;
    CGFloat triangleHeight = 5.0f;
    
    
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(centerPiont-triangleHalfWidth, topPointY)];
    [bezier2Path addLineToPoint: CGPointMake(centerPiont+triangleHalfWidth, topPointY)];
    [bezier2Path addLineToPoint: CGPointMake(centerPiont+1, topPointY+triangleHeight)];
    [bezier2Path addLineToPoint: CGPointMake(centerPiont-1, topPointY+triangleHeight)];
    [bezier2Path addLineToPoint: CGPointMake(centerPiont-triangleHalfWidth, topPointY)];
    [bezier2Path closePath];
    [color setFill];
    [bezier2Path fill];
    
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(centerPiont, topPointY+triangleHeight)];
    [bezier3Path addLineToPoint: CGPointMake(centerPiont, bottomPointY)];
    [bezier3Path closePath];
    bezier3Path.lineWidth = 2.0f;
    [color setStroke];
    [bezier3Path stroke];
}


@end
