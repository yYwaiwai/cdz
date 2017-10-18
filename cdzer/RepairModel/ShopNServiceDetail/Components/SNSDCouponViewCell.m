//
//  SNSDCouponViewCell.m
//  cdzer
//
//  Created by KEns0nLau on 8/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSDCouponViewCell.h"
@interface SNSDCouponViewCell ()

@property (nonatomic, weak) IBOutlet UIButton *backgroundImageView;

@property (nonatomic, weak) IBOutlet UILabel *dollarSignLabel;

@property (nonatomic, weak) IBOutlet UILabel *preferentialLabel;

@property (nonatomic, weak) IBOutlet UILabel *preferentialDetailLabel;

@property (nonatomic, weak) IBOutlet UILabel *expiredLabel;

@property (nonatomic) BOOL wasReceivedCoupon;

@end

@implementation SNSDCouponViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUIData:(NSDictionary *)dataDetail {
    NSString *receicedSign = dataDetail[@"is_receive"];
    self.wasReceivedCoupon = [receicedSign isEqualToString:@"yes"];
    self.dollarSignLabel.textColor = [UIColor colorWithHexString:self.wasReceivedCoupon?@"CCCCCC":@"49C7F5"];
    self.preferentialLabel.textColor = self.dollarSignLabel.textColor;
    self.backgroundImageView.selected = self.wasReceivedCoupon;
    
    self.preferentialLabel.text = [SupportingClass verifyAndConvertDataToString:dataDetail[@"amount"]];
    self.preferentialDetailLabel.text = dataDetail[@"content"];
    
    NSString *startDay = dataDetail[@"start_time"];
    NSString *endDay = dataDetail[@"end_time"];
    self.expiredLabel.text = [NSString stringWithFormat:@"有效期：%@至%@", startDay, endDay];
}

@end
