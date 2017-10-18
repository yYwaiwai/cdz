//
//  MyCouponCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCouponCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;//优惠价格

@property (weak, nonatomic) IBOutlet UILabel *preferentialQuotaLabel;//优惠额度

@property (weak, nonatomic) IBOutlet UILabel *businessLabel;//商家

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;//有效日期

@property (weak, nonatomic) IBOutlet UIImageView *overdueImageView;

@end
