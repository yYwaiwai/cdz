//
//  EServiceCancelRecordDTO.m
//  cdzer
//
//  Created by KEns0n on 16/4/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "EServiceCancelRecordDTO.h"
@interface EServiceCancelRecordDTO ()
{
    EServiceType _serviceType;
    NSNumber *_dbUID;
    NSString *_eServiceID;
    NSString *_userID;
    NSTimeInterval _createdDateTime;
}

@end

@implementation EServiceCancelRecordDTO
+ (EServiceCancelRecordDTO *)createDataToObjectWithEServiceType:(EServiceType)serviceType
                                                                   dbUID:(nullable NSNumber *)dbUID
                                                              eServiceID:(nonnull NSString *)eServiceID
                                                                  userID:(nonnull NSString *)userID
                                                         createdDateTime:(NSTimeInterval)createdDateTime {
    EServiceCancelRecordDTO *dto = nil;
    if (![eServiceID isEqualToString:@""]&&![userID isEqualToString:@""]&&
        (serviceType==EServiceTypeOfERepair||serviceType==EServiceTypeOfEInspect||serviceType==EServiceTypeOfEInsurance)) {
        dto = [EServiceCancelRecordDTO new];
        dto.serviceType = serviceType;
        dto.dbUID = dbUID;
        dto.eServiceID = eServiceID;
        dto.userID = userID;
        dto.createdDateTime = createdDateTime;
        
    }
    
    return dto;
}

+ (EServiceCancelRecordDTO *)createDataToObjectByDBRecord:(NSDictionary *)dbRecord {
    EServiceType serviceType = [dbRecord[@"serivce_type"] integerValue];
    NSNumber *dbUID = [SupportingClass verifyAndConvertDataToNumber:dbRecord[@"id"]];
    NSString *eServiceID = [SecurityCryptor.shareInstance tokenDecryption:[SupportingClass verifyAndConvertDataToString:dbRecord[@"serivce_id"]]];
    NSString *userID = [SecurityCryptor.shareInstance tokenDecryption:[SupportingClass verifyAndConvertDataToString:dbRecord[@"user_id"]]];
    NSNumber *unConvertedDate = [SupportingClass verifyAndConvertDataToNumber:dbRecord[@"add_time"]];
    return [self createDataToObjectWithEServiceType:serviceType dbUID:dbUID eServiceID:eServiceID userID:userID createdDateTime:unConvertedDate.doubleValue];
}

- (NSDictionary *)convertObjectToDBDataRecord {
    NSMutableDictionary *dataDetail = [NSMutableDictionary dictionary];
    [dataDetail addEntriesFromDictionary:@{@"serivce_type":@(self.serviceType),
                                           @"user_id":_userID,
                                           @"serivce_id":_eServiceID,
                                           @"add_time":@(_createdDateTime),}];
    return dataDetail;
}

- (NSString * _Nonnull)eServiceID {
    return [SecurityCryptor.shareInstance tokenDecryption:_eServiceID];;
}

- (NSString * _Nonnull)userID {
    return [SecurityCryptor.shareInstance tokenDecryption:_userID];
}


- (NSDate * _Nonnull)createdDateTime {
    return [NSDate dateWithTimeIntervalSince1970:_createdDateTime];
}

- (void)setServiceType:(EServiceType)serviceType {
    _serviceType = serviceType;
}

- (void)setDbUID:(NSNumber * _Nullable)dbUID {
    _dbUID = dbUID;
}

- (void)setEServiceID:(NSString * _Nonnull)eServiceID {
    _eServiceID = [SecurityCryptor.shareInstance tokenEncryption:eServiceID];
    
}

- (void)setUserID:(NSString * _Nonnull)userID {
    _userID = [SecurityCryptor.shareInstance tokenEncryption:userID];
}

- (void)setCreatedDateTime:(NSTimeInterval)createdDateTime {
    _createdDateTime = createdDateTime;
}

@end
