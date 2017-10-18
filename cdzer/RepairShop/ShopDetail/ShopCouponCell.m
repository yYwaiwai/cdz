//
//
//
//  ShopCouponCell.m
//  cdzer
//
//  Created by KEns0n on 10/31/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "ShopCouponCell.h"
#import "InsetsLabel.h"
#import "CouponDisplayView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShopCouponCell ()

@property (nonatomic, strong) CouponDisplayView *couponDetailView;

@property (nonatomic, strong) InsetsLabel *companyNameLabel;

@property (nonatomic, strong) InsetsLabel *dateTimeLabel;

@end


@implementation ShopCouponCell

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
    _remindLabel.frame = self.bounds;
    CGRect couponDVFrame = self.couponDetailView.frame;
    couponDVFrame.origin = CGPointMake(CGRectGetWidth(self.frame)-CGRectGetWidth(couponDVFrame)-15.0f, 5.0f);
    self.couponDetailView.frame = couponDVFrame;
    
    self.companyNameLabel.frame = CGRectMake(0.0f, CGRectGetMinY(couponDVFrame), CGRectGetMinX(couponDVFrame), CGRectGetHeight(couponDVFrame)/2.0f);
    self.dateTimeLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(_companyNameLabel.frame), CGRectGetMinX(couponDVFrame), CGRectGetHeight(couponDVFrame)/2.0f);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializationUI {
    @autoreleasepool {
        self.couponDetailView = [[CouponDisplayView alloc] init];
        _couponDetailView.showCouponStrOnly = YES;
        [self.contentView addSubview:_couponDetailView];
        
        CGRect companyNameFrame = self.bounds;
        self.companyNameLabel = [[InsetsLabel alloc] initWithFrame:companyNameFrame
                                                andEdgeInsetsValue:DefaultEdgeInsets];
        _companyNameLabel.text = @"湖南百城汽车维修服务有限公司";
        _companyNameLabel.numberOfLines = 0;
        _companyNameLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, YES);
        _companyNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_companyNameLabel];
        
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment  = NSTextAlignmentCenter;
        NSMutableAttributedString *datetimeString = NSMutableAttributedString.new;
        [datetimeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"有效日期：\n" attributes:nil]];
        [datetimeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"2015-10-10" attributes:@{NSParagraphStyleAttributeName:paragraphStyle}]];
        [datetimeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n至\n" attributes:@{NSParagraphStyleAttributeName:paragraphStyle}]];
        [datetimeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"2015-12-31" attributes:@{NSParagraphStyleAttributeName:paragraphStyle}]];
        self.dateTimeLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                              andEdgeInsetsValue:DefaultEdgeInsets];
        _dateTimeLabel.attributedText = datetimeString;
        _dateTimeLabel.numberOfLines = 0;
        _dateTimeLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES);
        _dateTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_dateTimeLabel];
        
        
        self.remindLabel = [[InsetsLabel alloc] initWithFrame:self.bounds
                                           andEdgeInsetsValue:DefaultEdgeInsets];
        _remindLabel.backgroundColor = CDZColorOfWhite;
        _remindLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 18.0f, NO);
        _remindLabel.numberOfLines = 0;
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.text = @"没有更多优惠劵\n请返回维修商详情页";
        [self.contentView addSubview:_remindLabel];
    }
}

- (void)updateUIDataWithData:(NSDictionary *)detailData {
    @autoreleasepool {
        
        NSString *shopName = [SupportingClass verifyAndConvertDataToString:detailData[@"storeName"]];
        self.companyNameLabel.text = shopName;
        
        NSString *startDate = [[SupportingClass verifyAndConvertDataToString:detailData[@"startime"]]
                               stringByReplacingOccurrencesOfString:@":" withString:@"-"];
        NSString *endDate = [[SupportingClass verifyAndConvertDataToString:detailData[@"endtime"]]
                             stringByReplacingOccurrencesOfString:@":" withString:@"-"];
        _dateTimeLabel.text = [NSString stringWithFormat:@"有效日期：%@至%@", startDate, endDate];
        
        BOOL wasTook = [SupportingClass verifyAndConvertDataToNumber:detailData[@"mark"]].boolValue;
        
        NSString *priceStr = [SupportingClass verifyAndConvertDataToString:detailData[@"amount"]];
        NSString *contentStr = detailData[@"content"];
        _couponDetailView.displayType = wasTook?CouponDisplayTypeOfBlackNWhiteWithWasTookImg:CouponDisplayTypeOfColor;
        _couponDetailView.showCouponStrOnly = wasTook;
        [_couponDetailView setPriceText:priceStr andContentText:contentStr];
    }
    
}
@end
