//
//  MyOrdersCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MyOrdersCellButtonActionBlock)(NSIndexPath *indexPath, NSString *btnType);

@interface MyOrdersCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) MyOrdersCellButtonActionBlock btnActionBlock;

@property (weak, nonatomic) IBOutlet UIView *cellTopView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UIImageView *orderTypeImage;

- (void)updateUIData:(NSDictionary *)sourceData;

@end
