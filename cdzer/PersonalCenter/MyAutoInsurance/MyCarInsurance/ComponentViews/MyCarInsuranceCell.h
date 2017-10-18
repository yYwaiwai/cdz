//
//  MyCarInsuranceCell.h
//  cdzer
//
//  Created by 车队长 on 16/12/29.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MyCarInsuranceCellButtonActionBlock)(NSIndexPath *indexPath, NSString *btnType);

@interface MyCarInsuranceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *topBgView;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *middleBgView;

@property (weak, nonatomic) IBOutlet UIImageView *autosBrandLogo;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *licensePlateLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (weak, nonatomic) IBOutlet UIButton *insuranceButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBgViewLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *insuranceButtonLayoutConstraint;

@property (nonatomic, copy) MyCarInsuranceCellButtonActionBlock btnActionBlock;

@property (nonatomic, strong) NSIndexPath *indexPath;


-(void)upUIdataWith:(NSDictionary *)data;

@end
