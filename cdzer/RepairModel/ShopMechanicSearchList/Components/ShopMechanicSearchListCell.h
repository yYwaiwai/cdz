//
//  ShopMechanicSearchListCell.h
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SMSLCellSelectionBlock)(NSIndexPath *indexPath);

@class SMSLResultDTO;
@interface ShopMechanicSearchListCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) SMSLCellSelectionBlock actionBlock;

@property (nonatomic, assign) BOOL showSelection;

- (void)updateUIData:(SMSLResultDTO *)dataModel;

@end
