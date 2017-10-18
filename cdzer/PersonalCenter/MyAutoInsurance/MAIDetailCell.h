//
//  MAIDetailCell.h
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAIDetailCell : UITableViewCell

@property (nonatomic, assign) BOOL isShowFinalResult;

- (void)updateUIDataWithTitle:(NSString *)title isSelected:(BOOL)isSelected coverageCost:(NSString *)coverageCost coverageCostIsTitle:(BOOL)isTitle premiumCost:(NSNumber *)premiumCost;

@end
