//
//  MyShoppingCartCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuantityControlView.h"

@interface MyShoppingCartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *priceLable;

@property (weak, nonatomic) IBOutlet QuantityControlView *stepper;

@property (assign, nonatomic) BOOL fullBottomLine;

@end
