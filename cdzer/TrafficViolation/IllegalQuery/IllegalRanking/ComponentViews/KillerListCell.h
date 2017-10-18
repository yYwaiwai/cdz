//
//  KillerListCell.h
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KillerListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;//

@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;

@property (weak, nonatomic) IBOutlet UILabel *vnumLabel;//条数

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;//排名

@property (weak, nonatomic) IBOutlet UIImageView *markImageView;//箭头图片

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;//数

- (void)updateUIData:(NSDictionary *)detailData;

@end
