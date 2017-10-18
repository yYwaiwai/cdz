//
//  MaintenanceItemDispalyViewCell.h
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MaintenanceItemObjectComponent.h"


typedef NS_ENUM(NSUInteger, MIDVCButtonAction) {
    MIDVCButtonActionOfProductCountMinus,
    MIDVCButtonActionOfProductCountPlus,
    MIDVCButtonActionOfProductDelete,
    MIDVCButtonActionOfProductExchange,
};
typedef void(^MIDVCButtonResponeBlock)(MIDVCButtonAction buttonAction, NSIndexPath *indexPath);

@interface MaintenanceItemDispalyViewCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) MIDVCButtonResponeBlock actionBlock;

- (void)updateUIData:(MaintenanceProductItemDTO *)dto wasEditingMode:(BOOL)editingMode;

@end
