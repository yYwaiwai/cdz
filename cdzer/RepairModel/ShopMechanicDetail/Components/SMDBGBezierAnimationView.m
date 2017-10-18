//
//  SMDBGBezierAnimationView.m
//  cdzer
//
//  Created by KEns0n on 18/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMDBGBezierAnimationView.h"
#import <QuartzCore/QuartzCore.h>

#define variableMin 1
#define variableMax 2

@interface SMDBGBezierAnimationView(){
    
    CGFloat waveAmplitude;  // 波纹振幅
    CGFloat waveCycle;      // 波纹周期
    CGFloat waveSpeed;      // 波纹速度
    CGFloat waveGrowth;     // 波纹上升速度
    
    CGFloat waterWaveHeight;
    CGFloat waterWaveWidth;
    CGFloat offsetX;           // 波浪x位移
    CGFloat currentWavePointY; // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    
    float variable;     //可变参数 更加真实 模拟波纹
    BOOL increase;      // 增减变化
}

@property (nonatomic, assign) CGFloat percent;            // 百分比

@property (nonatomic, strong) CADisplayLink *waveDisplaylink;

@property (nonatomic, strong) CAShapeLayer *firstWaveLayer;

@property (nonatomic, strong) CAShapeLayer *secondWaveLayer;

@property (nonatomic, assign) CAAnimation *animationConfig;

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) NSUInteger height;

@end

@implementation SMDBGBezierAnimationView

- (void)dealloc {
    [self reset];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.percent = 0.25;
    self.height = roundf(SCREEN_WIDTH/2.76);
    [self setUp];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 创建Quartz上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 创建色彩空间对象
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    // 创建起点颜色
    UIColor *startColor = [UIColor colorWithRed:0.239 green:0.757 blue:0.945 alpha:1.00];//[UIColor colorWithRed:0.286 green:0.780 blue:0.961 alpha:1.00];
    
    // 创建终点颜色
    UIColor *endColor = [UIColor colorWithRed:0.000 green:0.686 blue:0.937 alpha:1.00];
    
    // 创建颜色数组
    CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor.CGColor, endColor.CGColor}, 2, nil);
    
    // 创建渐变对象
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpaceRef, colorArray, (CGFloat[]){
        0.0f,       // 对应起点颜色位置
        1.0f        // 对应终点颜色位置
    });
    
    // 释放颜色数组
    CFRelease(colorArray);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpaceRef);
    CGContextDrawLinearGradient(context, gradientRef, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, self.height), 0);
    
    // 释放渐变对象
    CGGradientRelease(gradientRef);
    CGRect frame = rect;
    rect.origin.x = 0;
    rect.origin.y = self.height;
    rect.size.height = CGRectGetHeight(rect)-self.height;
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:frame];
    [endColor setFill];
    [rectanglePath fill];

}

- (void)setScrollView:(UIScrollView *)scrollView {
    [self removeObservers];
    _scrollView = scrollView;
    [self addObservers];
}

- (void)addObservers {
    if (self.scrollView) {
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
        [self.scrollView addObserver:self forKeyPath:@"contentInset" options:options|NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)removeFromSuperview {
    self.scrollView = nil;
    [super removeFromSuperview];
}

- (void)removeObservers {
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentInset"]) {
        self.contentInset = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
    }
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldContentOffset = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newContentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        
        CGFloat offsetY = newContentOffset.y+self.contentInset.top;
        CGRect frame = self.frame;
        NSUInteger height = frame.size.height-offsetY;
        if (offsetY>=0) offsetY = 0;
        
        CGFloat ratio = (offsetY/self.height);
        CGFloat waveSpeedRatio = 0.4-ratio*0.14;
        waveSpeed = waveSpeedRatio/M_PI;
        
        variable = variable-ratio;
        if (oldContentOffset.y<newContentOffset.y) {
            variable = variable+oldContentOffset.y/self.height;
        }
        
        if (variableMax>=variable) {
            variable = variableMax;
        }else if (variable>=7) {
            variable = 7;
        }
        
        if (offsetY==0) {
            height = self.height;
            waveSpeed = 0.4/M_PI;
        }
        frame.size.height = height;
        self.frame = frame;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateSize];
    NSLog(@"%@",NSStringFromCGSize(bounds.size));
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateSize];
}

- (void)updateSize {
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
    if (waterWaveWidth > 0) {
        waveCycle =  1.29 * M_PI / waterWaveWidth;
    }
    
    if (currentWavePointY <= 0) {
        currentWavePointY = self.frame.size.height;
    }

}

- (void)setUp {
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
    _firstWaveColor = [UIColor colorWithWhite:1 alpha:0.2];
    _secondWaveColor = [UIColor colorWithWhite:1 alpha:0.2];
    
    waveGrowth = 0.88;
    waveSpeed = 0.4/M_PI;
    
    [self resetProperty];
}

- (void)resetProperty {
    currentWavePointY = self.frame.size.height;
    
    variable = variableMax;
    increase = NO;
    
    offsetX = 0;
}

- (void)setFirstWaveColor:(UIColor *)firstWaveColor {
    _firstWaveColor = firstWaveColor;
    _firstWaveLayer.fillColor = firstWaveColor.CGColor;
}

- (void)setSecondWaveColor:(UIColor *)secondWaveColor {
    _secondWaveColor = secondWaveColor;
    _secondWaveLayer.fillColor = secondWaveColor.CGColor;
}

- (void)setPercent:(CGFloat)percent {
    if (percent < _percent) {
        // 下降
        waveGrowth = waveGrowth > 0 ? -waveGrowth : waveGrowth;
    }else if (percent > _percent) {
        // 上升
        waveGrowth = waveGrowth > 0 ? waveGrowth : -waveGrowth;
    }
    _percent = percent;
}

- (void)startWave {
    
    if (_firstWaveLayer == nil) {
        // 创建第一个波浪Layer
        _firstWaveLayer = [CAShapeLayer layer];
        _firstWaveLayer.fillColor = _firstWaveColor.CGColor;
        [self.layer addSublayer:_firstWaveLayer];
    }
    
    if (_secondWaveLayer == nil) {
        // 创建第二个波浪Layer
        _secondWaveLayer = [CAShapeLayer layer];
        _secondWaveLayer.fillColor = _secondWaveColor.CGColor;
        [self.layer addSublayer:_secondWaveLayer];
    }
    
    if (_waveDisplaylink == nil) {
        // 启动定时调用
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
//        _waveDisplaylink.frameInterval = 1/200;
        [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
}

- (void)reset {
    [self stopWave];
    [self resetProperty];
    
    if (_firstWaveLayer) {
        [_firstWaveLayer removeFromSuperlayer];
        _firstWaveLayer = nil;
    }
    
    if (_secondWaveLayer) {
        [_secondWaveLayer removeFromSuperlayer];
        _secondWaveLayer = nil;
    }
}

- (void)animateWave {
    if (increase) {
        variable += 0.01;
    }else{
        variable -= 0.01;
    }
    
    if (variable<=variableMin) {
        increase = YES;
    }
    
    if (variable>=variableMax) {
        increase = NO;
    }
    
    waveAmplitude = variable*5;
}

- (void)getCurrentWave:(CADisplayLink *)displayLink {
    
    [self animateWave];
    
    if ( waveGrowth > 0 && currentWavePointY > 2 * waterWaveHeight *(1-_percent)) {
        // 波浪高度未到指定高度 继续上涨
        currentWavePointY -= waveGrowth;
    }else if (waveGrowth < 0 && currentWavePointY < 2 * waterWaveHeight *(1-_percent)){
        currentWavePointY -= waveGrowth;
    }
    
    // 波浪位移
    offsetX += waveSpeed;
    
    [self setCurrentFirstWaveLayerPath];
    
    [self setCurrentSecondWaveLayerPath];
}

- (void)setCurrentFirstWaveLayerPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = waveAmplitude * sin(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _firstWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)setCurrentSecondWaveLayerPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 余弦波浪公式
        y = waveAmplitude * cos(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _secondWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)stopWave {
    if (_waveDisplaylink) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
    }
}


@end
