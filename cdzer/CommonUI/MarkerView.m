//
//  MarkerView.m
//  cdzer
//
//  Created by KEns0n on 1/8/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define vDefaultWidth 24.0f

#import "MarkerView.h"
#import "InsetsLabel.h"

@interface MarkerView ()

@property (nonatomic, assign) BOOL showFailWarning;

@property (nonatomic, assign) BOOL showSuccessWarning;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) UIColor *mainColor;

@end

@implementation MarkerView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [self initWithTitle:@"" withFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithTitle:@"" withFrame:frame];
    return self;
}

- (instancetype) initWithTitle:(NSString *)title withFrame:(CGRect)frame {
    if (!title) title = @"ABC";
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
        self.title = title;
        self.mainColor = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
        self.backgroundColor = CDZColorOfClearColor;
    }
    
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.frame)/2.0f];
        
        self.titleLabel = [[InsetsLabel alloc] initWithFrame:self.bounds];
        _titleLabel.text = _title;
        _titleLabel.textColor = _mainColor;
        _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15.0f, NO);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self addSubview:_titleLabel];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)showSelected {
    self.mainColor = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
    self.showFailWarning = NO;
    self.showSuccessWarning = NO;
    self.titleLabel.hidden = NO;
    self.titleLabel.textColor = CDZColorOfWhite;
    self.backgroundColor = _mainColor;
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:_mainColor withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)showNormalView {
    [self showNormalViewWithColor:nil];
}

- (void)showNormalViewWithColor:(UIColor *)color {
    if (color) color = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
    self.mainColor = color;
    self.showFailWarning = NO;
    self.showSuccessWarning = NO;
    self.titleLabel.hidden = NO;
    self.titleLabel.textColor = _mainColor;
    self.backgroundColor = CDZColorOfWhite;
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:_mainColor withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)showFailWarningView {
    self.showFailWarning = YES;
    self.showSuccessWarning = NO;
    self.titleLabel.hidden = YES;
    self.titleLabel.textColor = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
    self.backgroundColor = CDZColorOfWhite;
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)showSuccessWarningView {
    self.showFailWarning = NO;
    self.showSuccessWarning = YES;
    self.titleLabel.hidden = YES;
    self.titleLabel.textColor = [UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f];
    self.backgroundColor = CDZColorOfWhite;
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)showFailWarningRedView {
    self.showFailWarning = NO;
    self.showSuccessWarning = NO;
    self.mainColor = [UIColor colorWithRed:0.941 green:0.373 blue:0.380 alpha:1.00];
    self.titleLabel.hidden = NO;
    self.titleLabel.textColor = self.mainColor;
    self.backgroundColor = [UIColor colorWithRed:0.988 green:0.910 blue:0.910 alpha:1.00];
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:self.mainColor withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)showSuccessWarningSkyGreenView {
    self.showFailWarning = NO;
    self.showSuccessWarning = NO;
    self.mainColor = [UIColor colorWithRed:0.345 green:0.769 blue:0.749 alpha:1.00];
    self.titleLabel.hidden = NO;
    self.titleLabel.textColor = self.mainColor;
    self.backgroundColor = [UIColor colorWithRed:0.855 green:0.976 blue:0.973 alpha:1.00];
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:self.mainColor withBroderOffset:nil];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (_showFailWarning) {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color = [UIColor colorWithRed: 0.941 green: 0.373 blue: 0.38 alpha: 1];
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
        [color setFill];
        [ovalPath fill];
        
        
        
        CGFloat baseWidth = CGRectGetWidth(self.frame)*0.1;
        CGFloat baseHeight = CGRectGetWidth(self.frame)*0.5;
        CGRect rectangleRect = CGRectZero;
        rectangleRect.size = CGSizeMake(baseWidth, baseHeight);
        rectangleRect.origin.x = -(baseWidth/2);
        rectangleRect.origin.y = -(baseHeight/2);
        
        //// Rectangle Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetWidth(rect)/2.0f, CGRectGetWidth(rect)/2.0f);
        CGContextRotateCTM(context, 45 * M_PI / 180);
        
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rectangleRect cornerRadius:baseWidth/2.0f];
        [UIColor.whiteColor setFill];
        [rectanglePath fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 2 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetWidth(rect)/2.0f, CGRectGetWidth(rect)/2.0f);
        CGContextRotateCTM(context, -45 * M_PI / 180);
        
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect:rectangleRect cornerRadius:baseWidth/2.0f];
        [UIColor.whiteColor setFill];
        [rectangle2Path fill];
        
        CGContextRestoreGState(context);

    }
    
    if (_showSuccessWarning) {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color = [UIColor colorWithRed: 0.345 green: 0.769 blue: 0.749 alpha: 1];
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
        [color setFill];
        [ovalPath fill];
        
        
        
        CGFloat baseWidth = CGRectGetWidth(self.frame)*0.1;
        CGFloat baseRotateX = CGRectGetWidth(rect)*0.45;
        CGFloat baseRotateY = CGRectGetWidth(rect)*0.74;
        
        //// Rectangle Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, baseRotateX, baseRotateY);
        CGContextRotateCTM(context, 130 * M_PI / 180);
        
        CGRect rectangleRect1 = CGRectZero;
        rectangleRect1.size = CGSizeMake(baseWidth, CGRectGetWidth(self.frame)*0.3);
        rectangleRect1.origin.x = -baseWidth;
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rectangleRect1 cornerRadius:baseWidth/2.0f];
        [UIColor.whiteColor setFill];
        [rectanglePath fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 2 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, baseRotateX, baseRotateY);
        CGContextRotateCTM(context, -135 * M_PI / 180);
        
        CGRect rectangleRect2 = CGRectZero;
        rectangleRect2.size = CGSizeMake(baseWidth, CGRectGetWidth(self.frame)*0.5);
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect:rectangleRect2 cornerRadius:baseWidth];
        [UIColor.whiteColor setFill];
        [rectangle2Path fill];
        
        CGContextRestoreGState(context);
    }
    [super drawRect:rect];
}


- (void)setFrame:(CGRect)frame {
    if (frame.size.width>frame.size.height) frame.size.height = frame.size.width;
    if (frame.size.width<frame.size.height) frame.size.width = frame.size.height;
    if (frame.size.width<vDefaultWidth || frame.size.height<vDefaultWidth) frame.size = CGSizeMake(vDefaultWidth, vDefaultWidth);
    [super setFrame:frame];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
