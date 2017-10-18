//
//  ProjectCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ProjectCellDetailBlock)(NSIndexPath *indexPath);

@interface ProjectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIV;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (copy, nonatomic) ProjectCellDetailBlock detailBlock;

@end
