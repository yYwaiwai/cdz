//
//  VRUVTableViewCell.m
//  cdzer
//
//  Created by KEns0n on 1/5/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "VRUVTableViewCell.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VRUVTableViewCell ()

@property (nonatomic, strong) NSNumber *fullSize;
/// 警告标记
@property (nonatomic, strong) InsetsLabel *warningLabel;
/// 违章排序
@property (nonatomic, strong) UIButton *rankingSortView;
/// 违章排名
@property (nonatomic, strong) UIButton *rankView;
/// 违章车牌照
@property (nonatomic, strong) InsetsLabel *licensePlateLabel;
/// 总共违章的次数
@property (nonatomic, strong) InsetsLabel *vnumLabel;

@end

static UIImage *rankNoChangeImg = nil;
static UIImage *rankArrowImg = nil;
@implementation VRUVTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(DefaultEdgeInsets.left, 0.0f, 60.0f, 60.0f);
    CGPoint ivCenter = self.imageView.center;
    ivCenter.y = CGRectGetHeight(self.frame)/2.0f;
    self.imageView.center = ivCenter;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
    CGRect lpLblRect = self.licensePlateLabel.frame;
    lpLblRect.origin.x = CGRectGetMaxX(self.imageView.frame);
    lpLblRect.size.width = CGRectGetWidth(self.bounds)*0.3;
    lpLblRect.size.height = CGRectGetHeight(self.bounds);
    self.licensePlateLabel.frame = lpLblRect;
    
    CGRect lnLblRect = self.vnumLabel.frame;
    lnLblRect.origin.x = CGRectGetMaxX(self.licensePlateLabel.frame);
    lnLblRect.size.width = CGRectGetWidth(self.bounds)*0.2;
    lnLblRect.size.height = CGRectGetHeight(self.bounds);
    self.vnumLabel.frame = lnLblRect;
    
    
    [_rankingSortView sizeToFit];
    CGRect rankSortRect = self.rankingSortView.frame;
    rankSortRect.origin.x = CGRectGetWidth(self.frame)-DefaultEdgeInsets.right-CGRectGetWidth(rankSortRect);
    self.rankingSortView.frame = rankSortRect;
    
    CGPoint rankSortCenter = self.rankingSortView.center;
    rankSortCenter.y = CGRectGetHeight(self.frame)/2.0f;
    self.rankingSortView.center = rankSortCenter;
    
    [_rankView sizeToFit];
    CGRect rankViewRect = self.rankView.frame;
    rankViewRect.size.width = [SupportingClass getStringSizeWithString:@"第2名" font:_rankView.titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    rankViewRect.origin.x = CGRectGetMinX(_rankingSortView.frame)-6.0f-CGRectGetWidth(rankViewRect);
    self.rankView.frame = rankViewRect;
    
    CGPoint rankViewCenter = self.rankView.center;
    rankViewCenter.y = self.rankingSortView.center.y;
    self.rankView.center = rankViewCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!rankArrowImg) {
        rankArrowImg = [[ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"ranking_arrow" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if (!rankNoChangeImg) {
        rankNoChangeImg = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"ranking_no_change" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
    }
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.height = 80.0f;
    if (_fullSize) {
        size.height = _fullSize.floatValue;
    }
    return size;
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.rankView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rankView.userInteractionEnabled = NO;
        _rankView.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
        [_rankView setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [self.contentView addSubview:_rankView];
        
        self.rankingSortView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rankingSortView setTitle:@"1" forState:UIControlStateNormal];
        [_rankingSortView setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [_rankingSortView setImage:rankArrowImg forState:UIControlStateNormal];
        _rankingSortView.userInteractionEnabled = NO;
        [self.contentView addSubview:_rankingSortView];
        
        self.licensePlateLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                                 andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        _licensePlateLabel.text = @"";
        _licensePlateLabel.numberOfLines = 0;
        _licensePlateLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, YES);
        _licensePlateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_licensePlateLabel];
        
        
        self.vnumLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                         andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f)];
        _vnumLabel.text = @"";
        _vnumLabel.numberOfLines = 0;
        _vnumLabel.textColor = CDZColorOfTureRed;
        _vnumLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
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
            
            NSString *sortNum = [SupportingClass verifyAndConvertDataToString:detailData[@"sort"]];
            NSNumber *rankChange = [SupportingClass verifyAndConvertDataToNumber:detailData[@"mark"]];
            UIImage *tmpImage = rankArrowImg;
            _rankingSortView.imageView.transform = CGAffineTransformRotate(_rankingSortView.transform, 0);
            _rankingSortView.imageView.tintColor = CDZColorOfTureRed;
            if (rankChange.integerValue==0) {
                tmpImage = nil;
                tmpImage = rankNoChangeImg;
                _rankingSortView.imageView.tintColor = CDZColorOfClearColor;
            }
            if (rankChange.integerValue<0) {
                _rankingSortView.imageView.transform = CGAffineTransformRotate(_rankingSortView.transform, M_PI);
                _rankingSortView.imageView.tintColor = CDZColorOfDefaultColor;
            }
            [_rankingSortView setImage:tmpImage forState:UIControlStateNormal];
            [_rankingSortView setTitle:sortNum forState:UIControlStateNormal];
            
            

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
            
            
            
            NSString *imgURLString = detailData[@"faceImg"];
            self.imageView.image = [ImageHandler getDefaultRankingUserLogo];
            if ([imgURLString rangeOfString:@"http"].location!=NSNotFound) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgURLString] placeholderImage:[ImageHandler getDefaultRankingUserLogo]];
            }
            
            
            
            self.licensePlateLabel.text = detailData[@"carNumber"];
            NSString *vNumString = [NSString stringWithFormat:@"共有%@条违章",[SupportingClass verifyAndConvertDataToString:detailData[@"num"]]];
            self.vnumLabel.text = vNumString;
        }
    }
}

@end
