//
//  EServiceCancelRecordDTO.h
//  cdzer
//
//  Created by KEns0n on 16/4/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"
#import "EServiceConfig.h"

@interface EServiceCancelRecordDTO : BaseDataToObject

@property (nonatomic, strong, readonly, nullable) NSNumber *dbUID;

@property (nonatomic, assign, readonly) EServiceType serviceType;

@property (nonatomic, strong, readonly, nonnull) NSString *userID;

@property (nonatomic, strong, readonly, nonnull) NSString *eServiceID;

@property (nonatomic, strong, readonly, nonnull) NSDate *createdDateTime;

+ (nullable EServiceCancelRecordDTO *)createDataToObjectWithEServiceType:(EServiceType)serviceType
                                                                   dbUID:(nullable NSNumber *)dbUID
                                                              eServiceID:(nonnull NSString *)eServiceID
                                                                  userID:(nonnull NSString *)userID
                                                         createdDateTime:(NSTimeInterval)createdDateTime;

+ (nullable EServiceCancelRecordDTO *)createDataToObjectByDBRecord:(nonnull NSDictionary *)dbRecord;

- (nullable NSDictionary *)convertObjectToDBDataRecord;

@end
