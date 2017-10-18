//
//  CommodityInformationCell.h
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommodityInformationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;

@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *commodityButton;

@property (assign, nonatomic) BOOL isLastCell;

@end
