//
//  CumulativeScoringCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CumulativeScoringCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;

@end
