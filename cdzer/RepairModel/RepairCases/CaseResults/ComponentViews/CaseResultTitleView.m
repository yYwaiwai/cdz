//
//  CaseResultTitleView.m
//  cdzer
//
//  Created by KEns0n on 23/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CaseResultTitleView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface CaseResultTitleView ()
@property (nonatomic, assign) NSInteger contentWidth;

@property (nonatomic, assign) NSInteger contentOriginX;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@property (weak, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *mainTitleIV;

@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation CaseResultTitleView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat widthRaito = 0.893719806763285;
    self.contentWidth = roundf(CGRectGetWidth(self.frame)*widthRaito);
    if (self.contentWidth%2==1) self.contentWidth +=1;
    self.contentOriginX = (CGRectGetWidth(self.frame)-self.contentWidth)/2;
    self.contentViewWidthConstraint.constant = self.contentWidth;
}

// Only override drawRect:if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat height = CGRectGetHeight(rect)-8;
    CGSize cornerRadii = CGSizeMake(6, 6);
    UIRectCorner rectCorner = UIRectCornerBottomLeft|UIRectCornerBottomRight;
    CGRect bkRect = CGRectMake(self.contentOriginX, 0, self.contentWidth, height);
    
    CGFloat shadowWidthOffset = 6;
    CGRect shadowRect = CGRectZero;
    shadowRect.size.width = self.contentWidth-shadowWidthOffset;
    shadowRect.size.height = 20;
    shadowRect.origin.x = self.contentOriginX+shadowWidthOffset/2;
    shadowRect.origin.y = CGRectGetMaxY(bkRect)-CGRectGetHeight(shadowRect);
    
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* shadowColor = [UIColor colorWithRed:0.122 green:0.475 blue:1 alpha:0.38];
    UIColor* color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cr_title_bkg_img@3x"]];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[shadowColor colorWithAlphaComponent:CGColorGetAlpha(shadowColor.CGColor) * 0.44]];
    [shadow setShadowOffset:CGSizeMake(0.1, 1.1)];
    [shadow setShadowBlurRadius:7];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:shadowRect byRoundingCorners:rectCorner cornerRadii:cornerRadii];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect:bkRect byRoundingCorners:rectCorner cornerRadii:cornerRadii];
    [rectangle2Path closePath];
    [color setFill];
    [rectangle2Path fill];

}

+ (CaseResultTitleView *)setTitleViewWithSearchTitle:(NSString *)searchTitle andSuperView:(UIView *)superView {
    CaseResultTitleView *titleView = nil;
    if (superView&&searchTitle&&![searchTitle isEqualToString:@""]) {
        titleView = [[UINib nibWithNibName:@"CaseResultTitleView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
        [titleView addSelfByFourMarginToSuperview:superView withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeTrailing|LayoutHelperAttributeLeading];
        [titleView updateTitleWithSearchTitle:searchTitle];
    }
    return titleView;
}

+ (CaseResultTitleView *)setTitleViewWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle andSuperView:(UIView *)superView scrollView:(UIScrollView *)scrollView {
    CaseResultTitleView *titleView = nil;
    if (mainTitle&&![mainTitle isEqualToString:@""]&&superView&&
        subTitle&&![subTitle isEqualToString:@""]&&scrollView) {
        titleView = [[UINib nibWithNibName:@"CaseResultTitleView" bundle:nil] instantiateWithOwner:nil options:nil].lastObject;
        [titleView addSelfByFourMarginToSuperview:superView withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeTrailing|LayoutHelperAttributeLeading];
        titleView.scrollView = scrollView;
        [titleView updateTitleWithMainTitle:mainTitle subTitle:subTitle];
    }
    return titleView;
}

- (void)updateTitleWithSearchTitle:(NSString *)searchTitle {
    NSLog(@"%@", self.accessibilityIdentifier);
    if ([self.accessibilityIdentifier isEqualToString:@"CRTV"]||(self.subTitleLabel&&!self.mainTitleLabel)) {
        self.subTitleLabel.text = searchTitle;
    }
}

- (void)updateTitleWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle {
    if ([self.accessibilityIdentifier isEqualToString:@"CRTVWI"]||(self.subTitleLabel&&self.mainTitleLabel)) {
        self.mainTitleLabel.text = mainTitle;
        self.subTitleLabel.text = subTitle;
        NSString *imgName = nil;
        if ([mainTitle isContainsString:@"保养配件"]){
            imgName = @"cr_parts_title_icon@3x";
        }else if ([mainTitle isContainsString:@"车身及附件"]){
            imgName = @"cr_body_title_icon@3x";
        }else if ([mainTitle isContainsString:@"发动机"]){
            imgName = @"cr_engine_title_icon@3x";
        }else if ([mainTitle isContainsString:@"电子、电器"]){
            imgName = @"cr_device_title_icon@3x";
        }else if ([mainTitle isContainsString:@"底盘"]){
            imgName = @"cr_gears_title_icon@3x";
        }
        if (imgName&&![imgName isEqualToString:@""]) {
            self.mainTitleIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"png"]];
        }
    }
}


- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    @weakify(self);
    [RACObserve(self, scrollView.contentOffset) subscribeNext:^(id offset) {
        @strongify(self);
        CGPoint contentOffset = [offset CGPointValue];
        NSLog(@"%@", offset);
    }];

}

@end
