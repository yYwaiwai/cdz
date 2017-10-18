//
//  UIView+ShareAction.m
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "UIView+ShareAction.h"
#import "AppDelegate.h"
#import "SignInVC.h"
#import "UIColor+ShareAction.h"
#import "UIView+Borders.h"
#import "UIViewController+ShareAction.h"

@implementation UIView (ShareAction)
@dynamic shapeLayer;
static char key;


@dynamic borderOffset;
static char borderKey;
static NSString *borderTop = @"BorderTop";
static NSString *borderLeft = @"BorderLeft";
static NSString *borderBottom = @"BorderBottom";
static NSString *borderRight = @"BorderRight";
- (void)layoutSubviews {
    __weak UIView *weakSelf = self;
    NSArray <CALayer *> *sublayer = self.layer.sublayers;
    [sublayer enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = CGRectGetWidth(weakSelf.frame);
        CGFloat height = CGRectGetHeight(weakSelf.frame);
        if ([layer.name isEqualToString:borderTop]) {
            CGRect frame = layer.frame;
            frame.origin.x = weakSelf.borderOffset.upperLeftOffset;
            frame.origin.y = weakSelf.borderOffset.upperOffset;
            frame.size.width = width-weakSelf.borderOffset.upperLeftOffset-weakSelf.borderOffset.upperRightOffset;
            layer.frame = frame;
            
        }else if ([layer.name isEqualToString:borderLeft]) {
            CGRect frame = layer.frame;
            frame.origin.x = weakSelf.borderOffset.leftOffset;
            frame.origin.y = weakSelf.borderOffset.leftUpperOffset;
            frame.size.height = height-weakSelf.borderOffset.leftUpperOffset-weakSelf.borderOffset.leftBottomOffset;
            layer.frame = frame;
            
        }else if ([layer.name isEqualToString:borderBottom]) {
            CGRect frame = layer.frame;
            frame.origin.x = weakSelf.borderOffset.bottomLeftOffset;
            frame.origin.y = height-frame.size.height+weakSelf.borderOffset.bottomOffset;
            frame.size.width = width-weakSelf.borderOffset.bottomLeftOffset-weakSelf.borderOffset.bottomRightOffset;
            layer.frame = frame;
            
        }else if ([layer.name isEqualToString:borderRight]) {
            CGRect frame = layer.frame;
            frame.origin.x = width-frame.size.width+weakSelf.borderOffset.rightOffset;
            frame.origin.y = weakSelf.borderOffset.rightUpperOffset;
            frame.size.height = height-weakSelf.borderOffset.rightUpperOffset-weakSelf.borderOffset.rightBottomOffset;
            layer.frame = frame;
            
        }
    }];
    
}

- (void)setBorderOffset:(BorderOffsetObject *)borderOffset {
    @autoreleasepool {
        objc_setAssociatedObject(self, &borderKey, borderOffset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BorderOffsetObject *)borderOffset {
    return (BorderOffsetObject *)objc_getAssociatedObject(self, &borderKey);
}


- (void)setShapeLayer:(CAShapeLayer *)shapeLayer {
    objc_setAssociatedObject(self,&key,shapeLayer,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)shapeLayer {
     return (id)objc_getAssociatedObject(self, &key);
}

- (void)setBackgroundImageByCALayerWithImage:(UIImage *)image wasSizeByImage:(BOOL)sizeByImage {
    @autoreleasepool {
        if (!image) return;
        
        if (self.layer.contents) self.layer.contents = nil;
        
        CGRect frame = CGRectZero;
        
        frame.size = (sizeByImage?image.size:self.bounds.size);
        
        self.layer.frame = frame;
        
        self.layer.contents = (id) image.CGImage;
    }
}

- (void)setBackgroundImageByCALayerWithImage:(UIImage *)image {
    @autoreleasepool {
        [self setBackgroundImageByCALayerWithImage:image wasSizeByImage:NO];
    }
}

- (void)setBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width {
    if (!color) color = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    
}

- (void)setViewCornerWithRectCorner:(UIRectCorner)rectCorner cornerSize:(CGFloat)cornerSize {
    @autoreleasepool {
        static NSString *cornerSetting  = @"CornerSetting";
        self.layer.masksToBounds = YES;
        if (self.layer.mask&&[self.layer.mask.name isEqualToString:cornerSetting]) {
            [self.layer.mask removeFromSuperlayer];
        }
        if (rectCorner == UIRectCornerAllCorners||rectCorner==(UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerTopRight)) {
            self.layer.cornerRadius = cornerSize;
            return;
        }
        if (cornerSize<=0) {
            cornerSize = 5.0f;
        }
        self.layer.mask = nil;
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:rectCorner
                                               cornerRadii:CGSizeMake(cornerSize, cornerSize)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.name = cornerSetting;
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
    
}

- (void)setViewBorderWithRectBorder:(UIRectBorder)rectBorder borderSize:(CGFloat)borderSize withColor:(UIColor *)color withBroderOffset:(BorderOffsetObject *)borderOffset {
    @autoreleasepool {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0.0f;
        if (!color) color = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
        
        NSArray *array = @[borderTop, borderLeft, borderBottom, borderRight];
        NSArray *sublayer = self.layer.sublayers;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            __block BOOL isExsit = NO;
            if ([evaluatedObject isKindOfClass:CALayer.class]) {
                [array enumerateObjectsUsingBlock:^(NSString *identString, NSUInteger idx, BOOL *stop) {
                    if ([[(CALayer *)evaluatedObject name] isEqualToString:identString]) {
                        isExsit = YES;
                        *stop = YES;
                    }
                }];
                
            }
            return isExsit;
        }];
        
        NSArray *result = [sublayer filteredArrayUsingPredicate:predicate];
        for (int i=0; i<result.count; i++) {
            [(CALayer *)result[i] removeFromSuperlayer];
        }
        
        if (rectBorder&UIRectBorderNone&&rectBorder!=UIRectBorderAllBorderEdge) {
            [self setBorderWithColor:CDZColorOfClearColor borderWidth:0.0f];
            self.borderOffset = nil;
            return;
        }
        self.borderOffset = borderOffset;
        
        if (rectBorder == UIRectBorderAllBorderEdge||rectBorder==(UIRectBorderTop|UIRectBorderLeft|UIRectBorderBottom|UIRectBorderRight)) {
            [self setBorderWithColor:color borderWidth:borderSize];
            return;
        }
        if (!borderOffset) {
            borderOffset = [BorderOffsetObject new];
        }
        if (UIRectBorderLeft&rectBorder) {
            CALayer *layer = [self createLeftBorderWithWidth:borderSize color:color
                                                  leftOffset:borderOffset.leftOffset
                                                   topOffset:borderOffset.leftUpperOffset
                                             andBottomOffset:borderOffset.leftBottomOffset ];
            layer.name = borderLeft;
            [self.layer addSublayer:layer];
        }
        if (UIRectBorderRight&rectBorder) {
            CALayer *layer = [self createRightBorderWithWidth:borderSize color:color
                                                  rightOffset:borderOffset.rightOffset
                                                    topOffset:borderOffset.rightUpperOffset
                                              andBottomOffset:borderOffset.rightBottomOffset ];
            layer.name = borderRight;
            [self.layer addSublayer:layer];
            
        }
        if (UIRectBorderBottom&rectBorder) {
            CALayer *layer = [self createBottomBorderWithHeight:borderSize color:color
                                                     leftOffset:borderOffset.bottomLeftOffset
                                                    rightOffset:borderOffset.bottomRightOffset
                                                andBottomOffset:borderOffset.bottomOffset];
            layer.name = borderBottom;
            [self.layer addSublayer:layer];
            
        }
        if (UIRectBorderTop&rectBorder) {
            CALayer *layer = [self createTopBorderWithHeight:borderSize color:color
                                                  leftOffset:borderOffset.upperLeftOffset
                                                 rightOffset:borderOffset.upperRightOffset
                                                andTopOffset:borderOffset.upperOffset];
            layer.name = borderTop;
            [self.layer addSublayer:layer];
            
        }
        
    }
    
}

- (UIColor *)getDefaultBGColor {
    return [UIColor colorWithHexString:@"EEEEEE"];
}

- (UIColor *)getDefaultSeparatorLineColor {
    return [UIColor colorWithHexString:@"E5E5E5"];
}

- (UIColor *)getDefaultSeparatorLineDarkColor {
    return [UIColor colorWithHexString:@"CCCCCC"];
}

- (UIColor *)getDefaultTextColor {
    return [UIColor colorWithHexString:@"666666"];
}

- (UIColor *)getDefaultTextDarkColor {
    return [UIColor colorWithHexString:@"333333"];
}

- (UIColor *)getDefaultTimeTextColor {
    return [UIColor colorWithHexString:@"999999"];
}

- (void)presentLoginViewWithBackTitle:(NSString *)backTitle animated:(BOOL)flag completion:(void (^)(void))completion{
    BaseNavigationController *navVC = (BaseNavigationController *)[(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
    if ([self isKindOfClass:navVC.visibleViewController.class]) {
        return;
    }
    @autoreleasepool {
        
        
        SignInVC *vc = [SignInVC new];
        vc.ignoreViewResize = YES;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nav.navigationBarHidden = YES;
        [navVC presentViewController:nav animated:flag completion:completion];
    }
}

- (void)handleMissingTokenAction:(LoginResultBlockForUIView)resulyBlock {
    @weakify(self);
    if (UserBehaviorHandler.shareInstance.wasShowLoginAlert) {return;}
    [UserBehaviorHandler.shareInstance setShowLoginAlert:YES];
    BaseNavigationController *navVC = (BaseNavigationController *)[(AppDelegate *)UIApplication.sharedApplication.delegate navViewController];
    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"你登录凭证已失效请重新登录已取得跟多功能" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        NSLog(@"%@", navVC.visibleViewController.class);
        if (resulyBlock) {
            resulyBlock(YES);
        }
        @strongify(self);
        if (btnIdx.integerValue>0) {
            [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
            
            }];
            
        }else {
            [UserBehaviorHandler.shareInstance userLogoutWasPopupDialog:NO andCompletionBlock:^{
                if ([navVC.visibleViewController respondsToSelector:@selector(handleUserLoginResult:fromAlert:)]&&![(BaseViewController *)navVC.visibleViewController loginAfterShouldPopToRoot]) {
                    [navVC.visibleViewController handleUserLoginResult:NO fromAlert:YES];
                }else {
                    [navVC popToRootViewControllerAnimated:YES];
                }
            }];
        }
        [UserBehaviorHandler.shareInstance setShowLoginAlert:NO];
    }];

}

@end

@implementation BorderOffsetObject

- (instancetype)init {
    self = [super init];
    if (self) {
        
        
        self.upperOffset = 0.0f;
        
        self.upperLeftOffset = 0.0f;
        
        self.upperRightOffset = 0.0f;
        
        
        self.bottomOffset = 0.0f;
        
        self.bottomLeftOffset = 0.0f;
        
        self.bottomRightOffset = 0.0f;
        
        
        self.leftOffset = 0.0f;
        
        self.leftUpperOffset = 0.0f;
        
        self.leftBottomOffset = 0.0f;
        
        
        self.rightOffset = 0.0f;
        
        self.rightUpperOffset = 0.0f;
        
        self.rightBottomOffset = 0.0f;

    }
    return self;
}

@end

