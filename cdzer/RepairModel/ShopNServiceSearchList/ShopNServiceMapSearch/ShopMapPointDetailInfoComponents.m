//
//  ShopMapPointDetailInfoComponents.m
//  cdzer
//
//  Created by KEns0nLau on 9/28/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMapPointDetailInfoComponents.h"
#import "UIView+LayoutConstraintHelper.h"

@interface ShopMapPointDetailInfoView ()

@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (weak, nonatomic) IBOutlet UILabel *serviceTitleLabel;

@end

@implementation ShopMapPointDetailInfoView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setIsTypeOfSpecShop:(BOOL)isTypeOfSpecShop {
    _isTypeOfSpecShop = isTypeOfSpecShop;
    self.serviceTitleLabel.text = isTypeOfSpecShop?@"专修服务：":@"主修品牌：";
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* brandShopBtnColor = [UIColor colorWithRed:0.373 green:0.792 blue:0.945 alpha:1.00];
    UIColor* specShopBtnColor = [UIColor colorWithRed:0.973 green:0.686 blue:0.188 alpha:1.00];
    UIColor* color2 = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.00];
    UIColor* shadowColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 3];
    
    UIEdgeInsets contentOffset = UIEdgeInsetsMake(4.0f, 3.0f, 11.0f, 3.0f);
    CGSize contentSize = CGSizeMake(CGRectGetWidth(rect)-contentOffset.left-contentOffset.right,
                                    CGRectGetHeight(rect)-contentOffset.top-contentOffset.bottom);
    
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(contentOffset.left, contentOffset.top, contentSize.width, contentSize.height) cornerRadius: 8];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [UIColor.whiteColor setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    [color2 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    
    //// Rectangle 2 Drawing
    CGFloat buttonHeight = 40.0f;
    CGFloat offsetX = CGRectGetWidth(rect)-contentOffset.right-buttonHeight;
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(offsetX, contentOffset.top, buttonHeight, contentSize.height) byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: CGSizeMake(8, 8)];
    [rectangle2Path closePath];
    [self.isTypeOfSpecShop?specShopBtnColor:brandShopBtnColor setFill];
    [rectangle2Path fill];
    
    
    //// Bezier 2 Drawing
    CGFloat centerPoint = roundf(CGRectGetWidth(rect)/2.0);
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(centerPoint, CGRectGetHeight(rect)-contentOffset.bottom)];
    [bezier2Path addLineToPoint: CGPointMake(centerPoint-10.0f, CGRectGetHeight(rect)-3.0f)];
    [bezier2Path addLineToPoint: CGPointMake(centerPoint-7.0f, CGRectGetHeight(rect)-contentOffset.bottom)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [UIColor.whiteColor setFill];
    [bezier2Path fill];
    CGContextRestoreGState(context);
    
    [color2 setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(centerPoint+2.0f, CGRectGetHeight(rect)-contentOffset.bottom-1.0f)];
    [bezierPath addLineToPoint: CGPointMake(centerPoint-10.0f, CGRectGetHeight(rect)-3.0f)];
    [bezierPath addLineToPoint: CGPointMake(centerPoint-7.0f, CGRectGetHeight(rect)-contentOffset.bottom-1.0f)];
    [UIColor.whiteColor setFill];
    [bezierPath fill];

}


@end


@implementation ShopDetailInfoPaopaoView

- (instancetype)initWithSMPDIV {
    ShopMapPointDetailInfoView *infoView = [[[UINib nibWithNibName:@"ShopMapPointDetailInfoView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    if (self = [super initWithCustomView:infoView]) {
        _infoView = infoView;
        [_infoView addSelfByFourMarginToSuperview:self withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeBottom|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
        [self.infoView.selectedBtn addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonAction {
    if (self.btnAction) {
        self.btnAction(self.objectIdx);
    }
}

@end

@implementation ShopInfoPointAnnotation

@end