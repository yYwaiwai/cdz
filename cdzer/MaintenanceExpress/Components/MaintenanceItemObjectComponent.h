//
//  MaintenanceItemObjectComponent.h
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaintenanceProductItemDTO : NSObject

@property (nonatomic, strong, readonly) NSString *productID;

@property (nonatomic, strong, readonly) NSString *productName;

@property (nonatomic, strong, readonly) NSString *productLogo;

@property (nonatomic, strong, readonly) NSString *productPrice;

@property (nonatomic, readonly) NSUInteger productStockCount;

@property (nonatomic, strong, readonly) NSString *autopartInfoID;

@property (nonatomic) NSUInteger currentSelectedCount;

@property (nonatomic, strong, readonly) NSString *productStandard;

@property (nonatomic, strong, readonly) NSString *productCenter;

- (void)productItemReplacementBySourceData:(NSDictionary *)sourceData;

@end


@interface MaintenanceTypeDTO : NSObject

@property (nonatomic) BOOL isSelectedItem;

@property (nonatomic) BOOL isEditing;

@property (nonatomic, strong, readonly) NSString *maintenanceTypeID;

@property (nonatomic, strong, readonly) NSString *maintenanceType;

@property (nonatomic, strong, readonly) NSString *maintenanceTypeName;

@property (nonatomic, strong, readonly) NSString *maintenanceManHour;

@property (nonatomic, strong, readonly) NSString *maintenanceTypeCheckIcon;

@property (nonatomic, strong, readonly) NSString *maintenanceTypeUncheckIcon;

@property (nonatomic, strong, readonly) NSString *remarkInfo;

@property (nonatomic, strong, readonly) NSArray <MaintenanceProductItemDTO *> *maintenanceProductItemList;

+ (MaintenanceTypeDTO *)getMaintenanceTypeDTOBySourceData:(NSDictionary *)sourceData;

- (BOOL)removeProductItemFormByIndex:(NSUInteger)itemIndex;

- (BOOL)replaceProductItemFormByIndex:(NSUInteger)itemIndex withProductItemDTO:(MaintenanceProductItemDTO *)productItemDTO;

@end
