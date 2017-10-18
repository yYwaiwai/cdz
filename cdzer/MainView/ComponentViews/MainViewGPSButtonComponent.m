//
//  MainViewGPSButtonComponent.m
//  cdzer
//
//  Created by KEns0nLau on 6/16/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MainViewGPSButtonComponent.h"
#import "XIBBaseViewController.h"
#import "BaseTableViewController.h"
#import "GPSMainVC.h"

@interface MainViewGPSButtonComponent ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSLayoutConstraint *leadindConstraint;

@property (nonatomic, strong) NSLayoutConstraint *topConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, assign) CGPoint startTouchPoint;

@property (nonatomic, assign) CGPoint lastSelfOriginPoint;

@end

@implementation MainViewGPSButtonComponent

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)addSelfToSuperView:(UIView *)superview {
    if (superview) {
        if (self.superview&&self.leadindConstraint) {
            if ([self.superview.constraints containsObject:self.leadindConstraint]) {
                [self.superview removeConstraint:self.leadindConstraint];
            }
        }
        self.leadindConstraint = nil;
        self.leadindConstraint = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:superview
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0];
        
        
        if (self.superview&&self.topConstraint) {
            if ([self.superview.constraints containsObject:self.topConstraint]) {
                [self.superview removeConstraint:self.topConstraint];
            }
        }
        
        self.topConstraint = nil;
        self.topConstraint = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0];
        
        [superview addSubview:self];
        [superview addConstraints:@[self.leadindConstraint, self.topConstraint]];
        return YES;
    }
    self.leadindConstraint = nil;
    self.topConstraint = nil;
    
    return NO;
}


- (void)awakeFromNib {
    @autoreleasepool {
        [super awakeFromNib];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:CGRectGetWidth(self.frame)];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:CGRectGetHeight(self.frame)];
        
        
        [self addConstraints:@[widthConstraint, heightConstraint]];
        
        __block NSMutableArray *imagesList = [NSMutableArray arrayWithCapacity:13];
        for (int i = 1; i<14; i++) {
            NSString *imageName = [NSString stringWithFormat:@"GPS_icon_list_%02d@3x", i];
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
            [imagesList addObject:image];
        }
        
        self.imageView.image = [UIImage animatedImageWithImages:imagesList duration:5.2];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToGPSMain)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.leadindConstraint) {
        self.leadindConstraint.constant = CGRectGetMinX(frame);
    }
    if (self.topConstraint) {
        self.topConstraint.constant = CGRectGetMinY(frame);
    }
}

- (void)pushToGPSMain {
    @autoreleasepool {
        if ([UIApplication.sharedApplication.keyWindow.rootViewController isKindOfClass:BaseNavigationController.class]) {
//            if (!vGetUserToken) {
//                [self presentLoginView];
//                return;
//            }
            BaseNavigationController *nav = (BaseNavigationController*)UIApplication.sharedApplication.keyWindow.rootViewController;
            if ([nav.topViewController respondsToSelector:@selector(setNavBackButtonTitleOrImage:titleColor:)]) {
                [nav.topViewController setDefaultNavBackButtonWithoutTitle];
            }
            GPSMainVC *vc = [GPSMainVC new];
            [nav pushViewController:vc animated:YES];
        }
    }
}

- (void)presentLoginView {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController*)UIApplication.sharedApplication.keyWindow.rootViewController;
        
        if ([nav.topViewController isKindOfClass:BaseTabBarController.class]){
            if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[BaseViewController class]]) {
                BaseViewController *bvc = (BaseViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([bvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [bvc setViewWillDisappearShoulPassIt:YES];
                }
                [bvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
                
            }else if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[XIBBaseViewController class]]) {
                XIBBaseViewController *xbvc = (XIBBaseViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([xbvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [xbvc setViewWillDisappearShoulPassIt:YES];
                }
                [xbvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
                
            }else if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[BaseTableViewController class]]) {
                BaseTableViewController *btvc = (BaseTableViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([btvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [btvc setViewWillDisappearShoulPassIt:YES];
                }
                [btvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            }
            
        }else if ([nav.topViewController isKindOfClass:[BaseViewController class]]) {
            BaseViewController *bvc = (BaseViewController *)nav.topViewController;
            if ([bvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [bvc setViewWillDisappearShoulPassIt:YES];
            }
            [bvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            
        }else if ([nav.topViewController isKindOfClass:[XIBBaseViewController class]]) {
            XIBBaseViewController *xbvc = (XIBBaseViewController *)nav.topViewController;
            if ([xbvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [xbvc setViewWillDisappearShoulPassIt:YES];
            }
            [xbvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            
        }else if ([nav.topViewController isKindOfClass:[BaseTableViewController class]]) {
            BaseTableViewController *btvc = (BaseTableViewController *)nav.topViewController;
            if ([btvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [btvc setViewWillDisappearShoulPassIt:YES];
            }
            [btvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.allObjects.lastObject;
    self.lastSelfOriginPoint = self.frame.origin;
    self.startTouchPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (CGPointEqualToPoint(self.startTouchPoint, CGPointZero)) return;
    UITouch *touch = touches.allObjects.lastObject;
    CGPoint currentTouchPoint = [touch locationInView:self];
    [self handleTouchMovement:currentTouchPoint];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.startTouchPoint = CGPointZero;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.startTouchPoint = CGPointZero;
    CGRect frame = self.frame;
    frame.origin = self.lastSelfOriginPoint;
    self.frame = frame;
}

- (void)handleTouchMovement:(CGPoint)currentTouchPoint {
    CGRect frame = self.frame;
    
    CGFloat horizontalSwipeValue = currentTouchPoint.x-self.startTouchPoint.x;
    CGFloat movedOriginXValue = roundf(frame.origin.x+horizontalSwipeValue);
    CGFloat maxhorizontalActiveArea = CGRectGetWidth(self.superview.frame)- CGRectGetWidth(self.frame);
    if (movedOriginXValue<0) movedOriginXValue = 0;
    if (movedOriginXValue>maxhorizontalActiveArea) movedOriginXValue = maxhorizontalActiveArea;
    frame.origin.x = movedOriginXValue;
    
    CGFloat verticalSwipeValue = currentTouchPoint.y-self.startTouchPoint.y;
    CGFloat movedOriginYValue = roundf(frame.origin.y+verticalSwipeValue);
    CGFloat maxVerticalActiveArea = CGRectGetHeight(self.superview.frame)- CGRectGetHeight(self.frame);
    if (movedOriginYValue<0) movedOriginYValue = 0;
    if (movedOriginYValue>maxVerticalActiveArea) movedOriginYValue = maxVerticalActiveArea;
    frame.origin.y = movedOriginYValue;
    
    self.frame = frame;
}

@end
