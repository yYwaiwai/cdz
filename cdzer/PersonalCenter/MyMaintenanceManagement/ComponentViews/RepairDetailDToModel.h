//
//  RepairDetailDToModel.h
//  cdzer
//
//  Created by KEns0n on 6/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepairDetailDToModel : NSObject

+ (instancetype)createModelWithStatus:(CDZMaintenanceStatusType)statusType andData:(NSDictionary *)data;
/* 维修商 */
@property (nonatomic, readonly) NSString *repairNmuber;

@property (nonatomic, readonly) NSString *shopName;

@property (nonatomic, readonly) NSString *shopAddress;

@property (nonatomic, readonly) NSString *shopTel;

@property (nonatomic, readonly) NSString *appointmentTime;

@property (nonatomic, readonly) NSString *technician;


/* 客户 */
@property (nonatomic, readonly) NSString *repairType;

@property (nonatomic, readonly) NSString *autosAppearance;

@property (nonatomic, readonly) NSString *autosBrandName;

@property (nonatomic, readonly) NSString *autosDealershipName;

@property (nonatomic, readonly) NSString *autosSeries;

@property (nonatomic, readonly) NSString *autosModel;

@property (nonatomic, readonly) NSString *autosColor;

@property (nonatomic, readonly) NSString *autosEngineCode;

@property (nonatomic, readonly) NSString *autosBodyCode;

@property (nonatomic, readonly) NSString *licensePlateNumber;

@property (nonatomic, readonly) NSString *userName;

@property (nonatomic, readonly) NSString *autosOwnerName;

@property (nonatomic, readonly) NSString *contactName;

@property (nonatomic, readonly) NSString *handlerName;

@property (nonatomic, readonly) NSString *remarkString;

@property (nonatomic, readonly) NSString *handleTime;

@property (nonatomic, readonly) NSString *insuranceTime;

@property (nonatomic, readonly) NSNumber *contactsNumber;

@property (nonatomic, readonly) NSNumber *mileageCounts;

@property (nonatomic, readonly) NSNumber *oilReadingData;

/* 详细费用 */
@property (nonatomic, readonly) BOOL isHavePriceDetail;

@property (nonatomic, readonly) NSNumber *diagnoseAmount;

@property (nonatomic, readonly) NSNumber *estimatedManagementCost;

@property (nonatomic, readonly) NSNumber *estimatedMaterialCost;

@property (nonatomic, readonly) NSNumber *estimatedTotalAmount;

@property (nonatomic, readonly) NSNumber *discount;

@property (nonatomic, readonly) NSNumber *workingHour;

@property (nonatomic, readonly) NSNumber *totalWorkingHour;

@property (nonatomic, readonly) NSNumber *workingHourPrice;

@property (nonatomic, readonly) NSString *userCredits;

/* 维修项目 */ /* 维修材料 */
@property (nonatomic, readonly) NSMutableArray *repairmentNComponentList;

@property (nonatomic, readonly) CDZMaintenanceStatusType statusType;

@end
