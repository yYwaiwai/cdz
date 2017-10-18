//
//  PersonalCenterTVCell.h
//  cdzer
//
//  Created by KEns0nLau on 8/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalCenterTVCell : UITableViewCell

@property (nonatomic, assign) BOOL isSpaceOnly;

@property (nonatomic, assign) UIRectBorder rectBorder;

@property (nonatomic, weak) IBOutlet UIImageView *iconIV;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UILabel *moreInfoLabel;

@end
