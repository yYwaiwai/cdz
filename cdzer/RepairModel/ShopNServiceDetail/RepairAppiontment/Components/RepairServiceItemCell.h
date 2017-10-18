//
//  RepairServiceItemCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairServiceItemCell : UITableViewCell

@property (nonatomic) UIRectBorder rectBorder;

@property (nonatomic) BOOL allIVHighlighted;

@property (weak, nonatomic) IBOutlet UIView *workingPriceContainerView;

@property (weak, nonatomic) IBOutlet UILabel *workingPriceLabel;

- (void)updateItemName:(NSString *)itemName;

@end

@interface RepairServiceItemSpaceCell : UITableViewCell

@end
