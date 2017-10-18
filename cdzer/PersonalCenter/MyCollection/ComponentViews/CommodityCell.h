//
//  CommodityCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommodityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (weak, nonatomic) IBOutlet UILabel *countText;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *favoriteCount;


@end
