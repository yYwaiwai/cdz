//
//  VRLVTableViewCell.m
//  cdzer
//
//  Created by KEns0n on 1/5/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "VRLVTableViewCell.h"
#import "InsetsLabel.h"
@interface VRLVTableViewCell ()

@property (nonatomic, strong) NSNumber *fullSize;
/// 警告标记
@property (nonatomic, strong) InsetsLabel *warningLabel;
/// 违章排名
@property (nonatomic, strong) UIButton *rankView;
/// 违章地址
@property (nonatomic, strong) InsetsLabel *contentsLabel;
/// 总共违章的次数
@property (nonatomic, strong) InsetsLabel *vnumLabel;

@end

static UIImage *locationIconImg = nil;
@implementation VRLVTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect imgRect = self.imageView.frame;
    imgRect.origin.x = DefaultEdgeInsets.left;
    self.imageView.frame = imgRect;
    CGPoint ivCenter = self.imageView.center;
    ivCenter.y = CGRectGetHeight(self.frame)/2.0f;
    self.imageView.center = ivCenter;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
    [_rankView sizeToFit];
    CGRect rankViewRect = self.rankView.frame;
    rankViewRect.size.width = [SupportingClass getStringSizeWithString:@"第22名" font:_rankView.titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    rankViewRect.origin.x = CGRectGetWidth(self.frame)-DefaultEdgeInsets.right-CGRectGetWidth(rankViewRect);
    self.rankView.frame = rankViewRect;
    
    CGPoint rankViewCenter = self.rankView.center;
    rankViewCenter.y = CGRectGetHeight(self.bounds)/2.0f;
    self.rankView.center = rankViewCenter;
    
    CGRect vnLblRect = self.vnumLabel.frame;
    vnLblRect.size.width = CGRectGetWidth(self.bounds)*0.2;
    vnLblRect.size.height = CGRectGetHeight(self.bounds);
    vnLblRect.origin.x = CGRectGetMinX(self.rankView.frame)-CGRectGetWidth(vnLblRect);
    self.vnumLabel.frame = vnLblRect;
    
    CGRect lpLblRect = self.contentsLabel.frame;
    lpLblRect.origin.x = CGRectGetMaxX(self.imageView.frame);
    lpLblRect.size.width = CGRectGetWidth(self.bounds)*0.55;//CGRectGetMinX(self.vnumLabel.frame)-CGRectGetMaxY(self.imageView.frame);
    lpLblRect.size.height = CGRectGetHeight(self.bounds);
    self.contentsLabel.frame = lpLblRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!locationIconImg) {
        locationIconImg = [ImageHandler.getSKIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat defaultHeight = [_contentsLabel heightThatFitsWithSpaceOffset:10.0f];
    if (defaultHeight<=60.0f){
        defaultHeight = 60.0f;
    }
    size.height = round(defaultHeight);
    if (_fullSize) {
        size.height = _fullSize.floatValue;
    }
    return size;
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.imageView.image = locationIconImg;
        self.imageView.tintColor = CDZColorOfDefaultColor;
        
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, IS_IPHONE_5_ABOVE?15.0f:14.0f, NO);
        
        self.rankView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rankView.userInteractionEnabled = NO;
        _rankView.titleLabel.font = font;//vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
        [_rankView setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [self.contentView addSubview:_rankView];
        
        self.contentsLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                                 andEdgeInsetsValue:DefaultEdgeInsets];
        _contentsLabel.text = @"";
        _contentsLabel.numberOfLines = 0;
        _contentsLabel.font = font;//vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
        [self.contentView addSubview:_contentsLabel];
        
        CGRect lpLblRect = self.contentsLabel.frame;
        lpLblRect.origin.x = CGRectGetMaxX(self.imageView.frame);
        lpLblRect.size.width = CGRectGetWidth(self.bounds)*0.5;
        lpLblRect.size.height = CGRectGetHeight(self.bounds);
        self.contentsLabel.frame = lpLblRect;
        
        
        self.vnumLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                         andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        _vnumLabel.text = @"";
        _vnumLabel.numberOfLines = 0;
        _vnumLabel.textColor = CDZColorOfTureRed;
        _vnumLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);  //vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
        _vnumLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_vnumLabel];
        
        
        self.warningLabel = [[InsetsLabel alloc] initWithFrame:self.contentView.bounds
                                            andEdgeInsetsValue:DefaultEdgeInsets];
        _warningLabel.text = @"";
        _warningLabel.hidden = YES;
        _warningLabel.numberOfLines = 0;
        _warningLabel.backgroundColor = CDZColorOfWhite;
        _warningLabel.textAlignment = NSTextAlignmentCenter;
        _warningLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _warningLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_warningLabel];
    }
}

- (void)updateUIData:(NSDictionary *)detailData withWarningLabel:(NSString *)warningText fullSzie:(NSNumber *)fullSize {
    @autoreleasepool {
        self.fullSize = fullSize;
        if (detailData.count==0) {
            self.imageView.image = nil;
            _warningLabel.hidden = NO;
            _warningLabel.text = warningText;
        }else {
            _warningLabel.hidden = YES;
            
            NSNumber *rankCount = @([SupportingClass verifyAndConvertDataToNumber:detailData[@"rank"]].integerValue+1);
            [_rankView setTitle:nil forState:UIControlStateNormal];
            [_rankView setImage:nil forState:UIControlStateNormal];
            if (rankCount.integerValue>0&&rankCount.integerValue<=3) {
                NSString *imageName = [NSString stringWithFormat:@"rank%@", rankCount.stringValue];
                UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:imageName type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
                [_rankView setImage:image forState:UIControlStateNormal];
            }else {
                NSString *rankName = [NSString stringWithFormat:@"第%@名", rankCount.stringValue];
                [_rankView setTitle:rankName forState:UIControlStateNormal];
            }
            
            self.contentsLabel.text = detailData[@"place_name"];
            NSString *vNumString = [NSString stringWithFormat:@"总违章\n%@条",[SupportingClass verifyAndConvertDataToString:detailData[@"num"]]];
            self.vnumLabel.text = vNumString;
        }
    }
}

@end

