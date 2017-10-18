//
//  AddressInfoSectionComponent.h
//  cdzer
//
//  Created by KEns0nLau on 9/22/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressDTO.h"

@interface AddressInfoSectionForRegularParts : UIControl

@property (nonatomic, readonly) AddressDTO *selectedAddressDTO;

@end

@interface AddressInfoSectionForSpecRepair : UIView

- (void)updateUIData:(NSDictionary *)sourceData;

@end

@interface AddressInfoSectionForMaintenanceExpress : UIView

@property (nonatomic, readonly) NSString *repairShopID;

@property (nonatomic, readonly) NSString *repairShopWorkingPrice;

@property (nonatomic, readonly) AddressDTO *selectedAddressDTO;

@property (nonatomic, strong) NSArray *maintainItemList;

- (void)setDefaultRepairShopID:(NSString *)repairShopID andRepairShopName:(NSString *)repairShopName;

@end
