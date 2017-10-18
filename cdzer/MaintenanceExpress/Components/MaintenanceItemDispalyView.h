//
//  MaintenanceItemDispalyView.h
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaintenanceItemObjectComponent.h"

@class MaintenanceItemDispalyView;
typedef void(^MIDVReloadResponsBlock)();
typedef NSUInteger(^MIDVOtherDataSourceCountingBlock)(MaintenanceItemDispalyView *displayView);

@interface MaintenanceItemDispalyView : UIView

@property (nonatomic, copy) MIDVReloadResponsBlock reloadResponsBlock;

@property (nonatomic, copy) MIDVOtherDataSourceCountingBlock otherSourceCountingBlock;

@property (nonatomic, readonly) float getTotalPrice;

@property (nonatomic) BOOL isDeepMaintenanceItem;

@property (nonatomic, strong, readonly) NSArray <MaintenanceTypeDTO *> *maintenanceItemList;

@property (nonatomic, strong, readonly) NSArray <MaintenanceTypeDTO *> *selelctedMaintenanceItemList;

- (void)reloadDataSource:(NSMutableArray <MaintenanceTypeDTO *> *)maintenanceItemList;

@end
