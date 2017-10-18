//
//  MAIVCTableViewCell.m
//  cdzer
//
//  Created by KEns0n on 10/16/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#define vDefaultFont vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO)

#import "MAIVCTableViewCell.h"
#import "InsetsLabel.h"

@interface MAIVCTableViewCell ()

@property (nonatomic, strong) InsetsLabel *dateTimeLabel;

@property (nonatomic, strong) InsetsLabel *statusLabel;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsLabel *effectDateLabel;

@property (nonatomic, strong) InsetsLabel *expireDateLabel;

@property (nonatomic, strong) InsetsLabel *totalPriceLabel;

@property (nonatomic, strong) InsetsLabel *licensePlateLabel;

@property (nonatomic, strong) UIImageView *autosBrandLogo;

@end

@implementation MAIVCTableViewCell

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat remindHeight = CGRectGetHeight(self.frame)-CGRectGetHeight(_dateTimeLabel.frame)-CGRectGetHeight(_licensePlateLabel.frame);
    CGFloat ivCenterY = remindHeight/2.0f+CGRectGetHeight(_dateTimeLabel.frame);
    
    _autosBrandLogo.center = CGPointMake(_autosBrandLogo.center.x, ivCenterY);
    CGFloat clRemindWidth = CGRectGetWidth(self.frame)-CGRectGetMaxX(_autosBrandLogo.frame);
    
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_autosBrandLogo.frame), CGRectGetMaxY(_dateTimeLabel.frame)+5.0f, clRemindWidth, 46.0f);
    _effectDateLabel.frame = CGRectMake(CGRectGetMaxX(_autosBrandLogo.frame), CGRectGetMaxY(_titleLabel.frame), clRemindWidth, 24.0f);
    _expireDateLabel.frame = CGRectMake(CGRectGetMaxX(_autosBrandLogo.frame), CGRectGetMaxY(_effectDateLabel.frame), clRemindWidth, 24.0f);;
    
    
    self.licensePlateLabel.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame)-26.0f, CGRectGetWidth(self.frame), 26.0f);
    self.totalPriceLabel.frame = _licensePlateLabel.frame;
    [_licensePlateLabel setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
}

- (void)showAllView {
    _dateTimeLabel.hidden = NO;
    _statusLabel.hidden = NO;
    _titleLabel.hidden = NO;
    _effectDateLabel.hidden = NO;
    _expireDateLabel.hidden = NO;
    _licensePlateLabel.hidden = NO;
    _totalPriceLabel.hidden = NO;
    _autosBrandLogo.hidden = NO;
}

- (void)clearAllsetting {
    _dateTimeLabel.text = @"";
    _statusLabel.text = @"";
    _titleLabel.text =  @"";
    _effectDateLabel.text =  @"";
    _expireDateLabel.text =  @"";
    _licensePlateLabel.text =  @"";
    _totalPriceLabel.text =  @"";
    _autosBrandLogo.image = nil;
    
    
    _dateTimeLabel.hidden = YES;
    _statusLabel.hidden = YES;
    _titleLabel.hidden = YES;
    _effectDateLabel.hidden = YES;
    _expireDateLabel.hidden = YES;
    _licensePlateLabel.hidden = YES;
    _totalPriceLabel.hidden = YES;
    _autosBrandLogo.hidden = YES;
}

- (void)initializationUI {
    @autoreleasepool {
        [self clearAllsetting];
        
        _dateTimeLabel.hidden = NO;
        _statusLabel.hidden = NO;
        _titleLabel.hidden = NO;
        _effectDateLabel.hidden = NO;
        _expireDateLabel.hidden = NO;
        _licensePlateLabel.hidden = NO;
        _totalPriceLabel.hidden = NO;
        _autosBrandLogo.hidden = NO;
        
        self.dateTimeLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 30.0f)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _dateTimeLabel.backgroundColor = CDZColorOfGray;
        _dateTimeLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17, NO);
        _dateTimeLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _dateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_dateTimeLabel];
        
        self.statusLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 30.0f)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _statusLabel.textColor = CDZColorOfLightGreen;
        _statusLabel.font = vDefaultFont;
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_statusLabel];
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        UIEdgeInsets insetsValue = DefaultEdgeInsets;
        insetsValue.left = 5.0f;

        self.titleLabel = [[InsetsLabel alloc] initWithEdgeInsetsValue:insetsValue];
        _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO);
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        
        self.effectDateLabel = [[InsetsLabel alloc] initWithEdgeInsetsValue:insetsValue];
        _effectDateLabel.font = vDefaultFont;
        _effectDateLabel.textColor = CDZColorOfLightGreen;
        [self.contentView addSubview:_effectDateLabel];
        
        self.expireDateLabel = [[InsetsLabel alloc] initWithEdgeInsetsValue:insetsValue];
        _expireDateLabel.font = vDefaultFont;
        [self.contentView addSubview:_expireDateLabel];
        
        CGRect imageViewFrame = _autosBrandLogo.frame;
        imageViewFrame.origin.x = DefaultEdgeInsets.left;
        imageViewFrame.size = CGSizeMake(70.0f, 70.0f);
        self.autosBrandLogo = [[UIImageView alloc] initWithFrame:imageViewFrame];
        [self.contentView addSubview:_autosBrandLogo];
        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.licensePlateLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame)-26.0f, CGRectGetWidth(self.frame), 26.0f)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _licensePlateLabel.font = vDefaultFont;
        _licensePlateLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _licensePlateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_licensePlateLabel];
        
        self.totalPriceLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame)-26.0f, CGRectGetWidth(self.frame), 26.0f)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
        _totalPriceLabel.font = vDefaultFont;
        _totalPriceLabel.textColor = CDZColorOfOrangeColor;
        _totalPriceLabel.textAlignment = NSTextAlignmentRight;
        _totalPriceLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _totalPriceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_totalPriceLabel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithDate:(NSDictionary *)detail {
    
//    "carId": "15101313355272339927",
//    "speci": "布加迪 2008款 16.4 8.0T",
//    "state": "已购买",
//    "sum": 5750,
//    "pid": "poh5bnmm4563111223",
//    "endTime": "2016-10-13",
//    "startTime": "2015-10-13",
//    "appointTime": "2015-10-13 13:36:37",
//    "licenseNo": "新A12365",
//    "carImg": "http://x.autoimg.cn/app/image/brand/37_3.png",
//    "fctName": "威航",
//    "company": "阳光保险",
//    "intype": "交强险"
    
    _dateTimeLabel.text = [SupportingClass verifyAndConvertDataToString:detail[@"appointTime"]];
    
    _statusLabel.text = [SupportingClass verifyAndConvertDataToString:detail[@"state"]];
    
    _titleLabel.text = [NSString stringWithFormat:@"%@－%@", detail[@"company"], detail[@"intype"]];
    
    _effectDateLabel.text = [NSString stringWithFormat:@"生效时间：%@", detail[@"startTime"]];

    _expireDateLabel.text = [NSString stringWithFormat:@"到期时间：%@", detail[@"endTime"]];
    
    _licensePlateLabel.text = [NSString stringWithFormat:@"车牌号：%@",[SupportingClass verifyAndConvertDataToString:detail[@"licenseNo"]]];
    
    _totalPriceLabel.text = [NSString stringWithFormat:@"保费总价：¥%@",[SupportingClass verifyAndConvertDataToString:detail[@"sum"]]];
    
    NSString *urlString = detail[@"carImg"];
    if ([urlString rangeOfString:@"http"].location == NSNotFound) {
        [_autosBrandLogo setImage:ImageHandler.getWhiteLogo];
    }else {
        [_autosBrandLogo setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:ImageHandler.getWhiteLogo usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
}

@end
