//
//  MaintenanceItemDispalyViewHeaderCell.h
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaintenanceItemObjectComponent.h"

typedef NS_ENUM(NSUInteger, MIDVHCButtonAction) {
    MIDVHCButtonActionOfEditing,
    MIDVHCButtonActionOfUpdateChange,
    MIDVHCButtonActionOfDetailExpand,
};

typedef void(^MIDVHCButtonResponeBlock)(MIDVHCButtonAction buttonAction, NSUInteger sectionIdx);

@interface MaintenanceItemDispalyViewHeaderCell : UITableViewHeaderFooterView

@property (nonatomic) NSUInteger sectionIdx;

@property (nonatomic, copy) MIDVHCButtonResponeBlock actionBlock;

- (void)updateUIData:(MaintenanceTypeDTO *)dto;

@end