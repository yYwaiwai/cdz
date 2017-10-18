//
//  VEVCTopView.m
//  cdzer
//
//  Created by KEns0n on 12/31/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "VEVCTopView.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VEVCLicenseView : UIView {
    CGFloat rectangleLineWidth;
    CGFloat cornerRadius;
    CGFloat fristLabelHeight;
}

@property (nonatomic, strong) InsetsLabel *licenseFristLabel;

@property (nonatomic, strong) InsetsLabel *licenseSecondLabel;

- (void)setFristLblText:(NSString *)fristLblText;

- (void)setSecondLblText:(NSString *)secondLblText;

@end

@implementation VEVCLicenseView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        rectangleLineWidth = 4.0f;
        cornerRadius = 5.0f;
        fristLabelHeight = 36;
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = CDZColorOfClearColor;
        self.licenseFristLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero];
        _licenseFristLabel.text = @"湘";
        _licenseFristLabel.textAlignment = NSTextAlignmentCenter;
        _licenseFristLabel.textColor = CDZColorOfWhite;
        _licenseFristLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.0f, NO);
        [self addSubview:_licenseFristLabel];
        
        self.licenseSecondLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero];
        _licenseSecondLabel.text = @"A00000";
        _licenseSecondLabel.textAlignment = NSTextAlignmentCenter;
        _licenseSecondLabel.textColor = CDZColorOfWhite;
        _licenseSecondLabel.font = _licenseFristLabel.font;
        [self addSubview:_licenseSecondLabel];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:cornerRadius];
    [self bringSubviewToFront:self.licenseFristLabel];
    [self bringSubviewToFront:self.licenseSecondLabel];
    CGRect rect = CGRectMake(10, (CGRectGetHeight(self.frame)-fristLabelHeight)/2.0f, 44, fristLabelHeight);
    _licenseFristLabel.frame = rect;
    CGFloat secondLabelX = CGRectGetMaxX(rect);
    _licenseSecondLabel.frame = CGRectMake(secondLabelX, rect.origin.y, CGRectGetWidth(self.frame)-rectangleLineWidth-secondLabelX, fristLabelHeight);
    
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    @autoreleasepool {
        
        //// Color Declarations
        UIColor* color = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1];
        UIColor* color3 = [UIColor colorWithRed: 0.169 green: 0.443 blue: 0.953 alpha: 0.95];
        UIColor* color4 = [UIColor colorWithRed: 0.286 green: 0.518 blue: 0.961 alpha: 1];
        UIColor* color5 = [UIColor colorWithRed: 0.169 green: 0.443 blue: 0.953 alpha: 1];
    
        CGRect rect3 = CGRectMake(10, (CGRectGetHeight(rect)-fristLabelHeight)/2.0f, 44, fristLabelHeight);
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)) cornerRadius: 5];
        [color setFill];
        [rectanglePath fill];
        [color3 setStroke];
        rectanglePath.lineWidth = rectangleLineWidth;
        [rectanglePath stroke];
        
        
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(rectangleLineWidth, rectangleLineWidth,
                                                                                           CGRectGetWidth(rect)-rectangleLineWidth*2.0f, CGRectGetHeight(rect)-rectangleLineWidth*2.0f)
                                                                  cornerRadius: cornerRadius];
        [color4 setFill];
        [rectangle2Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: rect3 cornerRadius: cornerRadius];
        [color5 setFill];
        [rectangle3Path fill];
        
    }
}

- (void)setFrame:(CGRect)frame {
    if (frame.size.width<170.0f) frame.size.width = 170.0f;
    if (frame.size.height<50.0f) frame.size.height = 50.0f;
    [super setFrame:frame];
}

- (void)setFristLblText:(NSString *)fristLblText {
    if (!fristLblText||fristLblText.length!=1||[fristLblText isEqualToString:@" "]) {
        fristLblText = @"湘";
    }
    self.licenseFristLabel.text = fristLblText;
}

- (void)setSecondLblText:(NSString *)secondLblText {
    if (!secondLblText||secondLblText.length<6) {
        secondLblText = @"A00000";
    }
    self.licenseSecondLabel.text = secondLblText;
}

@end


@interface VEVCTopView ()

@property (nonatomic, strong) VEVCLicenseView *licenseView;

@property (nonatomic, strong) InsetsLabel *violationNumLabel;

@property (nonatomic, strong) InsetsLabel *fineNumLabel;

@property (nonatomic, strong) InsetsLabel *violationPointsNumLabel;

@end

@implementation VEVCTopView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = ImageHandler.getDefaultWhiteLogo;
        [self initializationUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect ivFrame = self.imageView.frame;
    ivFrame.size = CGSizeMake(70.0f, 70.0f);
    ivFrame.origin = CGPointMake(10.0f, (CGRectGetHeight(self.frame)-CGRectGetHeight(ivFrame))/2.0f);
    self.imageView.frame = ivFrame;
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    
    self.licenseView.frame = CGRectMake(0.0f, 10.0f, 170.0f, 40.0f);
    CGFloat lincensePX = (CGRectGetWidth(self.frame)-CGRectGetMaxX(self.imageView.frame))/2.0f+CGRectGetMaxX(self.imageView.frame);
    self.licenseView.center = CGPointMake(lincensePX, self.licenseView.center.y);
    
    NSInteger remindWidth = CGRectGetWidth(self.frame)-CGRectGetMaxX(self.imageView.frame)-10.0f;
    NSInteger height = 40.0f;
    NSInteger quotient = remindWidth%3;
    NSInteger width = (remindWidth-quotient)/3;
    self.violationNumLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxY(_licenseView.frame)+6, width, height);
    self.fineNumLabel.frame = CGRectMake(CGRectGetMaxX(self.violationNumLabel.frame), CGRectGetMinY(_violationNumLabel.frame), width+quotient, height);
    self.violationPointsNumLabel.frame = CGRectMake(CGRectGetMaxX(self.fineNumLabel.frame), CGRectGetMinY(_violationNumLabel.frame), width, height);
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = CDZColorOfWhite;
        [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        
        self.licenseView = VEVCLicenseView.new;
        [self addSubview:_licenseView];
        
        self.violationNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_violationNumLabel];
        
        self.fineNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_fineNumLabel];
        
        self.violationPointsNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_violationPointsNumLabel];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLabelText:(NSString *)text withLabel:(UILabel *)labelView {
    @autoreleasepool {
        if (!labelView||!(_violationNumLabel==labelView||_fineNumLabel==labelView||_violationPointsNumLabel==labelView)||!text) return;
        text = [SupportingClass verifyAndConvertDataToString:text];
        NSString *title = @"\n违章";
        if (_violationPointsNumLabel==labelView) title = @"\n扣分";
        if (_fineNumLabel==labelView) title = @"\n罚款";
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.numberOfLines = 0;
        NSMutableAttributedString *mainString = NSMutableAttributedString.new;
        [mainString appendAttributedString:[[NSAttributedString alloc] initWithString:text
                                                                           attributes:@{NSForegroundColorAttributeName:CDZColorOfTureRed,
                                                                                        NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO)}]];
        [mainString appendAttributedString:[[NSAttributedString alloc] initWithString:title
                                                                           attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                        NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16, NO)}]];
        labelView.attributedText = mainString;
    }
}

- (void)updateUIDataWithDetailData:(NSDictionary *)detailData {
    if (detailData.count==0) return;
    NSString *imgURLStr = detailData[@"img"];
    self.imageView.image = nil;
    self.imageView.image = ImageHandler.getDefaultWhiteLogo;
    if (imgURLStr&&![imgURLStr isEqualToString:@""]&&[imgURLStr isContainsString:@"http"]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgURLStr] placeholderImage:self.imageView.image];
    }
    NSString *licensePlate = detailData[@"carNumber"];
    NSString *fristStr = nil;
    NSString *lastStr = nil;
    if (licensePlate.length>=7) {
        fristStr = [licensePlate substringToIndex:1];
        lastStr = [licensePlate substringFromIndex:1];
    }
    [_licenseView setFristLblText:fristStr];
    [_licenseView setSecondLblText:lastStr];
    
    [self setLabelText:@"0" withLabel:_violationNumLabel];
    [self setLabelText:@"0" withLabel:_fineNumLabel];
    [self setLabelText:@"0" withLabel:_violationPointsNumLabel];
    
    [self setLabelText:detailData[@"num"] withLabel:_violationNumLabel];
    [self setLabelText:detailData[@"price"] withLabel:_fineNumLabel];
    [self setLabelText:detailData[@"points"] withLabel:_violationPointsNumLabel];
}

@end
