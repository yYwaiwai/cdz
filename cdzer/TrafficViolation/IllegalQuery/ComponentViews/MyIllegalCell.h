//
//  MyIllegalCell.h
//  cdzer
//
//  Created by 车队长 on 16/12/7.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyIllegalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *line1;

@property (weak, nonatomic) IBOutlet UILabel *line2;

@property (weak, nonatomic) IBOutlet UIView *contronView;

@property (weak, nonatomic) IBOutlet UIView *messageTopView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *resonLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *isHandleImageView;//是否处理的图片


@property (weak, nonatomic) IBOutlet UIView *messageBottomView;

@property (weak, nonatomic) IBOutlet UILabel *markLabel;//扣分

@property (weak, nonatomic) IBOutlet UILabel *forfeitLabel;//罚款

- (void)updateUIData:(NSDictionary *)detailData;
















@end
