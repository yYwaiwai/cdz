//
//  AllCommentsCell.h
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCommentsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *contronLabel;


- (void)updateUIData:(NSDictionary *)dataDetail;

@end
