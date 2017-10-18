//
//  OCVCOptionView.m
//  cdzer
//
//  Created by KEns0n on 08/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "OCVCOptionView.h"
#import <pop/POP.h>


@interface OCVCOLineDrawingView : UIView
@property (nonatomic, assign) CGPoint faStartPoint;
@property (nonatomic, assign) CGPoint faEndPoint;

@property (nonatomic, assign) CGPoint dianStartPoint;
@property (nonatomic, assign) CGPoint dianEndPoint;

@property (nonatomic, assign) CGPoint cheStartPoint;
@property (nonatomic, assign) CGPoint cheEndPoint;

@property (nonatomic, assign) CGPoint peiStartPoint;
@property (nonatomic, assign) CGPoint peiEndPoint;

@property (nonatomic, assign) CGPoint pan1StartPoint;
@property (nonatomic, assign) CGPoint pan1EndPoint;

@property (nonatomic, assign) CGPoint pan2StartPoint;
@property (nonatomic, assign) CGPoint pan2EndPoint;

@property (nonatomic, assign) BOOL showTheLine;

@end

@implementation OCVCOLineDrawingView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.showTheLine) {
        [[UIColor colorWithHexString:@"49C7F5"] setStroke];
        
        UIBezierPath* faBezierPath = [UIBezierPath bezierPath];
        [faBezierPath moveToPoint:self.faStartPoint];
        [faBezierPath addLineToPoint:self.faEndPoint];
        faBezierPath.lineWidth = 1;
        [faBezierPath stroke];
        
        UIBezierPath* dianBezierPath = [UIBezierPath bezierPath];
        [dianBezierPath moveToPoint:self.dianStartPoint];
        [dianBezierPath addLineToPoint:self.dianEndPoint];
        dianBezierPath.lineWidth = 1;
        [dianBezierPath stroke];
        
        UIBezierPath* cheBezierPath = [UIBezierPath bezierPath];
        [cheBezierPath moveToPoint:self.cheStartPoint];
        [cheBezierPath addLineToPoint:self.cheEndPoint];
        cheBezierPath.lineWidth = 1;
        [cheBezierPath stroke];
        
        UIBezierPath* peiBezierPath = [UIBezierPath bezierPath];
        [peiBezierPath moveToPoint:self.peiStartPoint];
        [peiBezierPath addLineToPoint:self.peiEndPoint];
        peiBezierPath.lineWidth = 1;
        [peiBezierPath stroke];
        
        UIBezierPath* pan1BezierPath = [UIBezierPath bezierPath];
        [pan1BezierPath moveToPoint:self.pan1StartPoint];
        [pan1BezierPath addLineToPoint:self.pan1EndPoint];
        pan1BezierPath.lineWidth = 1;
        [pan1BezierPath stroke];
        
        UIBezierPath* pan2BezierPath = [UIBezierPath bezierPath];
        [pan2BezierPath moveToPoint:self.pan2StartPoint];
        [pan2BezierPath addLineToPoint:self.pan2EndPoint];
        pan2BezierPath.lineWidth = 1;
        [pan2BezierPath stroke];
    }
}

@end

@interface OCVCOptionView() {
    CGPoint _startPoint;
    CGPoint _ivCenterPoint;
    CGPoint _faCenterPoint;
    CGPoint _dianCenterPoint;
    CGPoint _cheCenterPoint;
    CGPoint _peiCenterPoint;
    CGPoint _pan2CenterPoint;
    BOOL isSetDefaultPoint;
}

@property (nonatomic, weak) IBOutlet OCVCOLineDrawingView *bgLineDrawingView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroudIV;

@property (nonatomic, weak) IBOutlet UIImageView *faPointMark;
@property (nonatomic, weak) IBOutlet UIImageView *dianPointMark;
@property (nonatomic, weak) IBOutlet UIImageView *chePointMark;
@property (nonatomic, weak) IBOutlet UIImageView *peiPointMark;
@property (nonatomic, weak) IBOutlet UIImageView *pan1PointMark;
@property (nonatomic, weak) IBOutlet UIImageView *pan2PointMark;

@property (weak, nonatomic) IBOutlet UIButton *engineButton;//发动机
@property (weak, nonatomic) IBOutlet UIButton *electricApplianceButton;//电子电器
@property (weak, nonatomic) IBOutlet UIButton *bodyAndAccessoriesButton;//车身及附件
@property (weak, nonatomic) IBOutlet UIButton *maintenanceAccessoriesButton;//保养配件
@property (weak, nonatomic) IBOutlet UIButton *chassisButton;//底盘

@end


@implementation OCVCOptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateLinePosition];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLinePosition];
}

- (BOOL)showTheLine {
    return self.bgLineDrawingView.showTheLine;
}

- (void)setShowTheLine:(BOOL)showTheLine {
    self.bgLineDrawingView.showTheLine = showTheLine;
}

- (void)updateLinePosition {
    self.bgLineDrawingView.faStartPoint =self.engineButton.center;
    self.bgLineDrawingView.faEndPoint = self.faPointMark.center;
    
    self.bgLineDrawingView.dianStartPoint =self.electricApplianceButton.center;
    self.bgLineDrawingView.dianEndPoint = self.dianPointMark.center;
    
    self.bgLineDrawingView.cheStartPoint =self.bodyAndAccessoriesButton.center;
    self.bgLineDrawingView.cheEndPoint = self.chePointMark.center;
    
    self.bgLineDrawingView.peiStartPoint =self.maintenanceAccessoriesButton.center;
    self.bgLineDrawingView.peiEndPoint = self.peiPointMark.center;
    
    self.bgLineDrawingView.pan1StartPoint =self.chassisButton.center;
    self.bgLineDrawingView.pan1EndPoint = self.pan1PointMark.center;
    
    self.bgLineDrawingView.pan2StartPoint =self.pan1PointMark.center;
    self.bgLineDrawingView.pan2EndPoint = self.pan2PointMark.center;
    [self.bgLineDrawingView setNeedsDisplay];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    _startPoint = [touch locationInView:self];
    if (!isSetDefaultPoint) {
        isSetDefaultPoint = YES;
        _ivCenterPoint = self.backgroudIV.center;
        _faCenterPoint = self.faPointMark.center;
        _dianCenterPoint = self.dianPointMark.center;
        _cheCenterPoint = self.chePointMark.center;
        _peiCenterPoint = self.peiPointMark.center;
        _pan2CenterPoint = self.pan2PointMark.center;
    }
    [self.backgroudIV pop_removeAllAnimations];
    [self.faPointMark pop_removeAllAnimations];
    [self.dianPointMark pop_removeAllAnimations];
    [self.chePointMark pop_removeAllAnimations];
    [self.peiPointMark pop_removeAllAnimations];
    [self.pan2PointMark pop_removeAllAnimations];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    NSInteger xDistanceRange = roundf(SCREEN_WIDTH*0.7)-roundf(SCREEN_WIDTH*0.3);
    CGPoint point = [touch locationInView:self];
    CGFloat xdistance = point.x-_startPoint.x;
    if (xdistance<=-xDistanceRange) xdistance = -xDistanceRange;
    if (xdistance>=xDistanceRange) xdistance = xDistanceRange;
    CGFloat ydistance = point.y-_startPoint.y;
    if (ydistance<=-xDistanceRange) ydistance = -xDistanceRange;
    if (ydistance>=xDistanceRange) ydistance = xDistanceRange;
    
    self.backgroudIV.center = CGPointMake(_ivCenterPoint.x+xdistance, _ivCenterPoint.y+ydistance);
    self.faPointMark.center = CGPointMake(_faCenterPoint.x+xdistance, _faCenterPoint.y+ydistance);
    self.dianPointMark.center = CGPointMake(_dianCenterPoint.x+xdistance, _dianCenterPoint.y+ydistance);
    self.chePointMark.center = CGPointMake(_cheCenterPoint.x+xdistance, _cheCenterPoint.y+ydistance);
    self.peiPointMark.center = CGPointMake(_peiCenterPoint.x+xdistance, _peiCenterPoint.y+ydistance);
    self.pan2PointMark.center = CGPointMake(_pan2CenterPoint.x+xdistance, _pan2CenterPoint.y+ydistance);
    [self updateLinePosition];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGFloat springBounciness = 20;
    
    
    POPSpringAnimation *bgIVSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    bgIVSpring.toValue = [NSValue valueWithCGPoint:_ivCenterPoint];
    bgIVSpring.beginTime = CACurrentMediaTime();
    bgIVSpring.springBounciness = springBounciness;
    @weakify(self);
    bgIVSpring.animationDidStartBlock = ^(POPAnimation *anim){
        @strongify(self);
        [self updateLinePosition];
    };
    
    bgIVSpring.animationDidReachToValueBlock = ^(POPAnimation *anim){
        @strongify(self);
        [self updateLinePosition];
    };
    bgIVSpring.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        @strongify(self);
        [self updateLinePosition];
    };
    
    bgIVSpring.animationDidApplyBlock = ^(POPAnimation *anim){
        @strongify(self);
        [self updateLinePosition];
    };
    
    POPSpringAnimation *faPointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    faPointSpring.toValue = [NSValue valueWithCGPoint:_faCenterPoint];
    faPointSpring.beginTime = CACurrentMediaTime();
    faPointSpring.springBounciness = springBounciness;
    
    POPSpringAnimation *dianPointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    dianPointSpring.toValue = [NSValue valueWithCGPoint:_dianCenterPoint];
    dianPointSpring.beginTime = CACurrentMediaTime();
    dianPointSpring.springBounciness = springBounciness;
    
    POPSpringAnimation *chePointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    chePointSpring.toValue = [NSValue valueWithCGPoint:_cheCenterPoint];
    chePointSpring.beginTime = CACurrentMediaTime();
    chePointSpring.springBounciness = springBounciness;
    
    POPSpringAnimation *peiPointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    peiPointSpring.toValue = [NSValue valueWithCGPoint:_peiCenterPoint];
    peiPointSpring.beginTime = CACurrentMediaTime();
    peiPointSpring.springBounciness = springBounciness;
    
    POPSpringAnimation *pan2PointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    pan2PointSpring.toValue = [NSValue valueWithCGPoint:_pan2CenterPoint];
    pan2PointSpring.beginTime = CACurrentMediaTime();
    pan2PointSpring.springBounciness = springBounciness;
    
    [self.backgroudIV pop_addAnimation:bgIVSpring forKey:@"position"];
    [self.faPointMark pop_addAnimation:faPointSpring forKey:@"position"];
    [self.dianPointMark pop_addAnimation:dianPointSpring forKey:@"position"];
    [self.chePointMark pop_addAnimation:chePointSpring forKey:@"position"];
    [self.peiPointMark pop_addAnimation:peiPointSpring forKey:@"position"];
    [self.pan2PointMark pop_addAnimation:pan2PointSpring forKey:@"position"];
    
}

@end
