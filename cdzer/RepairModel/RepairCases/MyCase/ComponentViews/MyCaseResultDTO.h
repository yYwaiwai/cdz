//
//  MyCaseResultDTO.h
//  cdzer
//
//  Created by KEns0n on 03/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"

@interface MyCasePartDetailDTO : BaseDataToObject

@property (nonatomic, strong) NSString *partName;

@property (nonatomic, strong) NSString *counting;

@property (nonatomic, strong) NSString *partPrice;

+ (NSMutableArray <MyCasePartDetailDTO *> *)createPartsDataObjectWithPartSourceList:(NSArray <NSDictionary *>*)caseDetailList;

@end

@interface MyCaseAutosInfoDTO : BaseDataToObject

@property (nonatomic, readonly) NSString *brandName;

@property (nonatomic, readonly) NSString *brandImgURL;

@property (nonatomic, readonly) NSString *brandID;

@property (nonatomic, readonly) NSString *dealershipName;

@property (nonatomic, readonly) NSString *dealershipID;

@property (nonatomic, readonly) NSString *seriesName;

@property (nonatomic, readonly) NSString *seriesID;

@property (nonatomic, readonly) NSString *modelName;

@property (nonatomic, readonly) NSString *modelID;

+ (MyCaseAutosInfoDTO *)createAutoDataObjectWithCaseSourceData:(NSDictionary *)sourceData;

+ (MyCaseAutosInfoDTO *)createAutoDataObjectFromUserSelectedAutosInfoDTO:(UserSelectedAutosInfoDTO *)autosData;

@end


@interface MyCaseResultDTO : BaseDataToObject

@property (nonatomic, readonly) NSString *theCaseID;

@property (nonatomic, readonly) NSString *licensePlate;

@property (nonatomic, readonly) NSString *stateName;

@property (nonatomic, strong) MyCaseAutosInfoDTO *autosInfo;

@property (nonatomic, readonly) NSString *createDatetime;

@property (nonatomic, readonly) NSString *theCaseReason;

@property (nonatomic, readonly) NSString *workingPrice;

@property (nonatomic, readonly) NSString *workingHrs;

@property (nonatomic, readonly) NSString *repairDateTime;

@property (nonatomic, readonly) NSString *totalPrice;

@property (nonatomic, readonly) NSString *repairShopID;

@property (nonatomic, readonly) NSString *repairShopName;

@property (nonatomic, readonly) NSString *repairShopPhone;

@property (nonatomic, readonly) NSString *repairShopAddress;

@property (nonatomic, readonly) NSArray <MyCasePartDetailDTO *> *repairPartsList;

@property (nonatomic, readonly) NSString *caseRepairReceiptsImg;


@property (nonatomic, assign) BOOL isExpandPriceDetail;

@property (nonatomic, assign) BOOL isExpandRepairReceiptsDetail;

@property (nonatomic, readonly) BOOL haveReceiptsDetailRecord;


+ (MyCaseResultDTO *)createCaseDataObjectWithCaseSourceData:(NSDictionary *)sourceData;

+ (NSArray <MyCaseResultDTO *>*)createCaseDataObjectWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList;


@end















