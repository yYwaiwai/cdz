//
//  CustomerServiceCell.h
//  cdzer
//
//  Created by 车队长 on 16/10/11.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerServiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;

@property (weak, nonatomic) IBOutlet UIImageView *answerImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBgViewLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBgViewBottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *imageViewBgView;


@end
