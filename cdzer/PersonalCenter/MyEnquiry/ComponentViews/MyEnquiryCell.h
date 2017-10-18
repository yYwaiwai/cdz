//
//  MyEnquiryCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEnquiryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productPortraitIV;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *inquiryReplyLabel;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userDetailLabel;

@end
