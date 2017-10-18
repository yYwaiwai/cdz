//
//  DBHandler.h
//  frp_test
//
//  Created by KEns0n on 4/15/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


typedef NS_ENUM(NSInteger, CDZDBUpdateList) {
    CDZDBUpdateListOfKeyCity,
    CDZDBUpdateListOfAutosBrand
};

static NSString *const CDZObjectKeyOfConventionMaintain = @"convention_maintain";
static NSString *const CDZObjectKeyOfDeepnessMaintain = @"deepness_maintain";
#import <Foundation/Foundation.h>
#import "AutosBrandDTO.h"
#import "UserInfosDTO.h"
#import "AddressDTO.h"
#import "KeyCityDTO.h"
#import "BDPushConfigDTO.h"
#import "UserAutosInfoDTO.h"
#import "UserSelectedAutosInfoDTO.h"
#import "OrderStatusDTO.h"
#import "EServiceCancelRecordDTO.h"

@class UserAutosInfoDTO;
@class UserSelectedAutosInfoDTO;
@class AddressDTO;
@class UserInfosDTO;
@class BDPushConfigDTO;
@class OrderStatusDTO;
@class EServiceCancelRecordDTO;

@interface DBHandler : NSObject

+ (DBHandler *)shareInstance;

- (void)resetDBController;

- (NSArray *)queryData:(NSString *)querySql withTableKeyList:(NSArray *)keyLists;

#pragma mark- User Token
- (BOOL)updateUserToken:(NSString *)token userID:(NSString*)uid userType:(NSNumber *)type typeName:(NSString *)typeName csHotline:(NSString *)csHotline;

- (BOOL)clearUserIdentData;

- (NSDictionary *)getUserIdentData;

#pragma mark- User Info
- (BOOL)updateUserInfo:(UserInfosDTO *)dto;

- (BOOL)clearUserInfo;

- (UserInfosDTO *)getUserInfo;

#pragma mark- User Autos Selected History
- (BOOL)updateAutoSelectedHistory:(UserSelectedAutosInfoDTO *)arguments;

- (UserSelectedAutosInfoDTO *)getAutoSelectedHistory;

#pragma mark- User Selected Autos Data
- (BOOL)updateSelectedAutoData:(UserSelectedAutosInfoDTO *)arguments;

- (UserSelectedAutosInfoDTO *)getSelectedAutoData;

- (BOOL)clearSelectedAutoData;

#pragma mark- Repair Shop Type Data
- (BOOL)updateRepairShopTypeList:(NSArray *)argumentList;

- (NSArray *)getRepairShopTypeList;

#pragma mark- Repair Shop Service Type Data
- (BOOL)updateRepairShopSerivceTypeList:(NSArray *)argumentList;

- (NSArray *)getRepairShopServiceTypeList;

#pragma mark- Purchase Order Status List Data
- (BOOL)updatePurchaseOrderStatusList:(NSArray *)argumentList;

- (NSArray *)getPurchaseOrderStatusList;

#pragma mark- Repair Shop Service List Data (old)
//old
- (BOOL)updateRepairShopServiceList:(NSArray *)argumentList;
//old
- (NSDictionary *)getRepairShopServiceList;

#pragma mark- Maintenance Service List Data
- (BOOL)updateMaintenanceServiceList:(NSArray *)argumentList;

- (NSDictionary *)getMaintenanceServiceList;

#pragma mark- Key City List Data
- (BOOL)updateKeyCityList:(NSArray *)argumentList;

- (NSArray *)getKeyCityList;

#pragma mark- Key Brand List Data

- (BOOL)updateAutosBrandList:(NSArray *)argumentList;

- (NSArray <AutosBrandDTO *> *)getAutosBrandList;

#pragma mark- Parts Search History Data
- (BOOL)clearPartsSearchHistory;

- (BOOL)updatePartsSearchHistory:(NSString *)keyword;

- (NSArray *)getPartsSearchHistory;

#pragma mark- Autos GPS Realtime Data
- (BOOL)updateAutoRealtimeData:(NSDictionary *)arguments;

- (BOOL)clearAutoRealtimeData;

- (NSDictionary *)getAutoRealtimeDataWithDataID:(NSInteger)dataID;

#pragma mark- User Autos Detail Data
- (BOOL)updateUserAutosDetailData:(NSDictionary *)arguments;

- (BOOL)clearUserAutosDetailData;

- (UserAutosInfoDTO *)getUserAutosDetail;

#pragma mark- User Default Address Data
- (BOOL)updateUserDefaultAddress:(AddressDTO *)dto;

- (BOOL)clearUserDefaultAddress;

- (AddressDTO *)getUserDefaultAddress;

#pragma mark- Data Next Update Time
- (BOOL)isDataNeedToUpdate:(CDZDBUpdateList)updateTable;

- (BOOL)updateDataNextUpdateDateTime:(NSDate *)nextUpdateDateTime table:(CDZDBUpdateList)updateTable ;

#pragma mark- BD APNS Config Data
- (BOOL)updateBDAPNSConfigData:(BDPushConfigDTO *)dto;

- (BOOL)clearBDAPNSConfigData;

- (BDPushConfigDTO *)getBDAPNSConfigData;
#pragma mark- EService Automatic Cancel Data
- (BOOL)createEServiceCancelRecordTabel;

- (BOOL)insertEServiceCancelRecord:(EServiceCancelRecordDTO *)dto;

- (EServiceCancelRecordDTO *)getEServiceCancelRecordByEServiceID:(NSString *)eServiceID;

- (NSArray <EServiceCancelRecordDTO *> *)getEServiceCancelRecord;

- (BOOL)deleteEServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto;

#pragma mark- Exam Fail Question List
- (BOOL)updateExamFailQuestionListWithQID:(NSNumber *)qid;

- (BOOL)clearDBAllExamFailQuestionListData;

- (BOOL)clearCurrentUserAllExamFailQuestionListData;

- (NSMutableArray *)getExamFailQuestionListData;

#pragma mark- Exam Question Collection
- (BOOL)updateExamQuestionCollectionWithQID:(NSNumber *)qid;

- (BOOL)deleteExamQuestionCollectionWithQID:(NSNumber *)qid;

- (BOOL)clearDBAllExamQuestionCollectionData;

- (BOOL)clearCurrentUserAllExamQuestionCollectionData;

- (NSMutableArray *)getExamQuestionCollectionData;


@end
