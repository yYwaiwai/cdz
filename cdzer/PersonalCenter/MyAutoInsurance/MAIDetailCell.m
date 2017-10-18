//
//  MAIDetailCell.m
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "MAIDetailCell.h"
#import "InsetsLabel.h"


@interface MAIDetailCell ()

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsLabel *coverageCostLabel;

@property (nonatomic, strong) InsetsLabel *premiumCostLabel;

@property (nonatomic, strong) UIImageView *checkMarkIV;

@property (nonatomic, strong) UIImageView *uncheckCheckMarkIV;

@end

@implementation MAIDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
        self.isShowFinalResult = NO;
        if (!_checkMarkIV) {
            UIImage *checkMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark" type:FMImageTypeOfPNG needToUpdate:YES];
            self.checkMarkIV = [[UIImageView alloc] initWithImage:checkMarkImage];
        }
        if (!_uncheckCheckMarkIV) {
            UIImage *uncheckCheckMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark_unchecked" type:FMImageTypeOfPNG needToUpdate:YES];
            self.uncheckCheckMarkIV = [[UIImageView alloc] initWithImage:uncheckCheckMarkImage];
        }
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    if (self.accessoryView) {
        width = CGRectGetMinX(self.accessoryView.frame);
    }
    self.titleLabel.frame = CGRectMake(0.0f, 0.0f, width, 30.0f);
    self.coverageCostLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(_titleLabel.frame), width/2.0f, 24.0f);
    self.premiumCostLabel.frame = CGRectMake(width/2.0f, CGRectGetMaxY(_titleLabel.frame), width/2.0f, 24.0f);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.accessoryView = nil;
    self.accessoryView = _isShowFinalResult?nil:(selected?_checkMarkIV:_uncheckCheckMarkIV);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    self.accessoryView = nil;
    self.accessoryView = _isShowFinalResult?nil:(selected?_checkMarkIV:_uncheckCheckMarkIV);
}


- (void)initializationUI {
    
    self.titleLabel = [InsetsLabel new];
    _titleLabel.edgeInsets = UIEdgeInsetsMake(DefaultEdgeInsets.top, DefaultEdgeInsets.left, DefaultEdgeInsets.bottom, 0.0f);
    _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.0f, NO);
    [self.contentView addSubview:_titleLabel];
    
    self.coverageCostLabel = [InsetsLabel new];
    _coverageCostLabel.edgeInsets = UIEdgeInsetsMake(DefaultEdgeInsets.top, DefaultEdgeInsets.left, DefaultEdgeInsets.bottom, 0.0f);
    _coverageCostLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
    [self.contentView addSubview:_coverageCostLabel];
    
    self.premiumCostLabel = [InsetsLabel new];
    _premiumCostLabel.edgeInsets = UIEdgeInsetsMake(DefaultEdgeInsets.top, 0.0f, DefaultEdgeInsets.bottom, DefaultEdgeInsets.right);
    _premiumCostLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
    [self.contentView addSubview:_premiumCostLabel];
    
    self.titleLabel.text = @"险种：－－";
    
    NSMutableAttributedString *coverageCostString = [NSMutableAttributedString new];
    [coverageCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"保额：" attributes:@{NSForegroundColorAttributeName:CDZColorOfTxtDeepGaryColor}]];
    [coverageCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
    self.coverageCostLabel.attributedText = coverageCostString;
    
    NSMutableAttributedString *premiumCostString = [NSMutableAttributedString new];
    [premiumCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"保费：" attributes:@{NSForegroundColorAttributeName:CDZColorOfTxtDeepGaryColor}]];
    [premiumCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
    self.premiumCostLabel.attributedText = premiumCostString;
}

- (void)updateUIDataWithTitle:(NSString *)title isSelected:(BOOL)isSelected coverageCost:(NSString *)coverageCost coverageCostIsTitle:(BOOL)isTitle premiumCost:(NSNumber *)premiumCost {
    if (!title) title = @"";
    if (!coverageCost||[coverageCost isEqualToString:@""]) coverageCost = @"0.00";
    if (!premiumCost) premiumCost = @(0.00);
    
    NSMutableAttributedString *coverageCostString = [NSMutableAttributedString new];
    [coverageCostString appendAttributedString:[[NSAttributedString alloc] initWithString:isTitle?@"类型：":@"保额：" attributes:@{NSForegroundColorAttributeName:CDZColorOfTxtDeepGaryColor}]];
    
    NSMutableAttributedString *premiumCostString = [NSMutableAttributedString new];
    [premiumCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"保费：" attributes:@{NSForegroundColorAttributeName:CDZColorOfTxtDeepGaryColor}]];
    
    if (isSelected) {
        [coverageCostString appendAttributedString:[[NSAttributedString alloc] initWithString:isTitle?coverageCost:[@"¥" stringByAppendingString:coverageCost]
                                                                                   attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
        [premiumCostString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%0.2f", premiumCost.doubleValue]
                                                                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
    }else {
        [coverageCostString appendAttributedString:[[NSAttributedString alloc] initWithString:isTitle?@"－－":@"¥0.00"
                                                                                   attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
        [premiumCostString appendAttributedString:[[NSAttributedString alloc] initWithString:@"¥0.00"
                                                                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfOrangeColor}]];
    }
    self.titleLabel.text = [NSString stringWithFormat:@"险种：%@", title];
    self.coverageCostLabel.attributedText = coverageCostString;
    self.premiumCostLabel.attributedText = premiumCostString;
}

@end
