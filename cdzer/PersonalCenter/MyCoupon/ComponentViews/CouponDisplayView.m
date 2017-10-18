//
//  CouponDisplayView.m
//  cdzer
//
//  Created by KEns0n on 11/2/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "CouponDisplayView.h"
#import "InsetsLabel.h"

@interface CouponDisplayView ()

@property (nonatomic, strong) UIImageView *wasTookIV;

@property (nonatomic, strong) UIImageView *wasExpiredIV;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsLabel *priceLabel;

@property (nonatomic, strong) InsetsLabel *detailLabel;


@end

@implementation CouponDisplayView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UIImage *image = ImageHandler.getCouponOnImage;
    if (CGRectGetWidth(frame)!=image.size.height||CGRectGetHeight(frame)!=image.size.height) {
        frame.size = image.size;
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    CGRect titleFrame = CGRectZero;
    titleFrame.size = CGSizeMake(CGRectGetWidth(self.frame)*0.50f, CGRectGetHeight(self.frame)*0.60f);
    titleFrame.origin.x = CGRectGetWidth(self.frame)*0.5f;
    
    self.titleLabel = [[InsetsLabel alloc] initWithFrame:titleFrame];
    _titleLabel.text = @"优惠劵\n立即领取";
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 13.0f, YES);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    CGRect priceFrame = CGRectZero;
    priceFrame.size = CGSizeMake(CGRectGetWidth(self.frame)*0.50f, CGRectGetHeight(self.frame)*0.60f);
    self.priceLabel = [[InsetsLabel alloc] initWithFrame:priceFrame
                                      andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(10.0f), 0.0f, 0.0f)];
    _priceLabel.text = @"¥100";
    _priceLabel.numberOfLines = 0;
    _priceLabel.textColor = CDZColorOfWhite;
    _priceLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 19.0f, YES);
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_priceLabel];
    
    CGRect detailFrame = CGRectZero;
    detailFrame.origin.y = CGRectGetHeight(self.frame)*0.5;
    detailFrame.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*0.50f);
    self.detailLabel = [[InsetsLabel alloc] initWithFrame:detailFrame
                                       andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(10.0f), 0.0f, vAdjustByScreenRatio(10.0f))];
    _detailLabel.text = @"满¥20减10";
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = CDZColorOfWhite;
    _detailLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, YES);
    _detailLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_detailLabel];
    
    UIImage *wasTookImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"was_took" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:1.0f needToUpdate:YES];
    self.wasTookIV = [[UIImageView alloc] initWithImage:wasTookImage];
    self.wasTookIV.hidden = YES;
    [self addSubview:self.wasTookIV];
    
    UIImage *wasExpiredImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"was_expired" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:1.0f needToUpdate:YES];
    self.wasExpiredIV = [[UIImageView alloc] initWithImage:wasExpiredImage];
    self.wasExpiredIV.hidden = YES;
    [self addSubview:self.wasExpiredIV];
    
    self.showCouponStrOnly = NO;
    self.displayType = CouponDisplayTypeOfColor;
}

- (void)setDisplayType:(CouponDisplayType)displayType {
    _displayType = displayType;
    [self changeDisplayView];
}

- (void)setShowCouponStrOnly:(BOOL)showCouponStrOnly {
    _showCouponStrOnly = showCouponStrOnly;
    _titleLabel.text = _showCouponStrOnly?@"优惠劵":@"优惠劵\n立即领取";
    _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, _showCouponStrOnly?14.0f:13.0f, YES);
}

- (void)changeDisplayView {
    self.wasTookIV.hidden = YES;
    self.wasExpiredIV.hidden = YES;
    if (_displayType==CouponDisplayTypeOfColor||_displayType==CouponDisplayTypeOfColorWithWasTookImg) {
        [self setBackgroundImageByCALayerWithImage:ImageHandler.getCouponOnImage];
        self.titleLabel.textColor = [UIColor colorWithRed:0.976f green:0.910f blue:0.204f alpha:1.00f];
    }
    
    if (_displayType==CouponDisplayTypeOfBlackNWhite||_displayType==CouponDisplayTypeOfBlackNWhiteWithWasTookImg||_displayType==CouponDisplayTypeOfBlackNWhiteWithWasExpiredImg) {
        [self setBackgroundImageByCALayerWithImage:ImageHandler.getCouponOffImage];
        self.titleLabel.textColor = [UIColor colorWithRed:0.498f green:0.498f blue:0.498f alpha:1.00f];
    }
    
    if (_displayType==CouponDisplayTypeOfColorWithWasTookImg||_displayType==CouponDisplayTypeOfBlackNWhiteWithWasTookImg) {
        self.wasTookIV.hidden = NO;
    }
    
    if (_displayType==CouponDisplayTypeOfBlackNWhiteWithWasExpiredImg) {
        self.wasExpiredIV.hidden = NO;
    }
}

- (void)setPriceText:(NSString *)priceTxt andContentText:(NSString *)contentTxt {
    if (!priceTxt) priceTxt = @"--";
    if (!contentTxt) contentTxt = @"--";
    self.priceLabel.text = [@"¥" stringByAppendingString:priceTxt];
    self.detailLabel.text = contentTxt;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
