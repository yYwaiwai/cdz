//
//  ExperienceCell.h
//  cdzer
//
//  Created by 车队长 on 16/7/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TechnicianDetailsTimeLine.h"
@interface ExperienceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *upperLineIV;

@property (weak, nonatomic) IBOutlet UIImageView *timeLine;

@property (weak, nonatomic) IBOutlet UIImageView *bottomLineIV;


@property (weak, nonatomic) IBOutlet TechnicianDetailsTimeLine *technicianDetailsTimeLinebg;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;



@end
