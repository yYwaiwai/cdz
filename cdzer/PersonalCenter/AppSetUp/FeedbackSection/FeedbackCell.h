//
//  FeedbackCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *userTelephone;
@property (weak, nonatomic) IBOutlet UIView *userBgView;
@property (weak, nonatomic) IBOutlet UILabel *userContentLabel;
@property (weak, nonatomic) IBOutlet UIView *cdzerBgView;
@property (weak, nonatomic) IBOutlet UILabel *cdzerContentLabel;

@end
