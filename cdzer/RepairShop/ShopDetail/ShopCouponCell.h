//
//  ShopCouponCell.h
//  cdzer
//
//  Created by KEns0n on 10/31/15.
//  Copyright © 2015 CDZER. All rights reserved.
//
#import <UIKit/UIKit.h>

@class InsetsLabel;

@interface ShopCouponCell : UITableViewCell

@property (nonatomic, strong) InsetsLabel *remindLabel;

- (void)updateUIDataWithData:(NSDictionary *)detailData;

@end
