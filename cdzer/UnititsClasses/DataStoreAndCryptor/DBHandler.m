//
//  DBHandler.m
//  frp_test
//
//  Created by KEns0n on 4/15/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "DBHandler.h"
#import <FMDB/FMDB.h>
// 数据库
@interface DBHandler ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation DBHandler

#define kDBFileName @"cdzer.sqlite"
static DBHandler *_dbHandleInstance = nil;
static FMDatabase *_fmdb = nil;
//Handler 管理者
+ (DBHandler *)shareInstance {
    
    if (!_dbHandleInstance) {
        _dbHandleInstance = [DBHandler new];
        [_dbHandleInstance setFMDBInstance];
        _dbHandleInstance.dateFormatter = [NSDateFormatter new];
        [_dbHandleInstance.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
    }
    
    return _dbHandleInstance;
}

- (FMDatabase *)setFMDBInstance {
    
    if (_fmdb) {
        BOOL closeSuccess = [_fmdb close];
        NSLog(@"FMDBClose:::::%d",closeSuccess);
    }
    NSString *lastVersionString = [NSUserDefaults.standardUserDefaults valueForKey:@"CFBundleVersion"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kDBFileName];
    
    if (!lastVersionString||[lastVersionString compare:@"1.3.3"]==NSOrderedSame||[lastVersionString compare:@"1.3.3"]==NSOrderedAscending) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
         [NSUserDefaults.standardUserDefaults setObject:version forKey:@"CFBundleVersion"];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:kDBFileName ofType:nil] toPath:filePath error:nil];
    }
    _fmdb = nil;
    _fmdb = [FMDatabase databaseWithPath:filePath];
    
    [_fmdb open];
    
    return _fmdb;
}

- (void)resetDBController {
    [_dbHandleInstance setFMDBInstance];
}

- (NSArray *)queryData:(NSString *)querySql withTableKeyList:(NSArray *)keyLists {
    
    if (!querySql||(!keyLists && [keyLists count]==0)) {
        return nil;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
    }
    return arrM;
}

#pragma mark- User Token
- (BOOL)updateUserToken:(NSString *)token userID:(NSString*)uid userType:(NSNumber *)type typeName:(NSString *)typeName csHotline:(NSString *)csHotline {
    NSString *encryptedToken = [[SecurityCryptor shareInstance] tokenEncryption:token];
    NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO user_ident_data(id, uid, type_id, type_name, user_token_id, cs_hotline, last_datetime) VALUES(1, '%@', '%@', '%@', '%@', '%@', CURRENT_TIMESTAMP);",uid, type, typeName, encryptedToken, csHotline];
    BOOL isDone = [_fmdb executeUpdate:querySql];
    return isDone;
}

- (BOOL)clearUserIdentData {
    NSString *querySql = @"DELETE FROM user_ident_data WHERE id=1;";
    BOOL isDone = [_fmdb executeUpdate:querySql];
    if (isDone) {
        [self executeVACUUMCommand];
    }
    return isDone;
}

- (NSDictionary *)getUserIdentData {
    NSDictionary *userIdentData = nil;
    NSString * querySql = @"SELECT uid, type_id, type_name, user_token_id, cs_hotline FROM user_ident_data;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        userIdentData = @{@"uid":[result stringForColumn:@"uid"],
                          @"token":[result stringForColumn:@"user_token_id"],
                          @"type":@([result intForColumn:@"type_id"]),
                          @"typeName":[result stringForColumn:@"type_name"],
                          @"csHotline":[result stringForColumn:@"cs_hotline"]};
    }

    return userIdentData;
    
}


#pragma mark- User Info
- (BOOL)updateUserInfo:(UserInfosDTO *)dto {
    @autoreleasepool {
        NSMutableDictionary * arguments = [[dto processObjectToDBData] mutableCopy];
        
        NSArray *key = [arguments allKeys];
        if ([key indexOfObject:@"id"] == NSNotFound) {
            NSLog(@"Key ID Was Not Found");
            return NO;
        }
        __block NSMutableString *tableKey = [NSMutableString string];
        __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
        [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableKey appendString:obj];
            [valueKey appendString:obj];
            if (![[key lastObject] isEqual:obj]) {
                [tableKey appendString:@", "];
                [valueKey appendString:@", :"];
            }
        }];
        
        NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO user_info(last_datetime, %@) VALUES(CURRENT_TIMESTAMP, %@);", tableKey, valueKey];
        
        return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
    }
}

- (BOOL)clearUserInfo {
    NSString *querySql = @"DELETE FROM user_info WHERE `id`= 1";
    // @"INSERT OR REPLACE INTO user_info(id, birthday, email, face_img, nichen, credits, qq, sex, spec_name, telphone, last_datetime) VALUES(1, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, CURRENT_TIMESTAMP);";
    BOOL isDone = [_fmdb executeUpdate:querySql];
    return isDone;
}

- (UserInfosDTO *)getUserInfo{
    NSDictionary *historyDic = nil;
    NSString *querySql = @"SELECT * FROM user_info WHERE `id`= 1;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        historyDic = @{@"id":@([result intForColumn:@"id"]),
                       @"birthday":[result stringForColumn:@"birthday"],
                       @"email":[result stringForColumn:@"email"],
                       @"face_img":[result stringForColumn:@"face_img"],
                       @"nichen":[result stringForColumn:@"nichen"],
                       @"credits":[result stringForColumn:@"credits"],
                       @"realname":[result stringForColumn:@"realname"],
                       @"qq":[result stringForColumn:@"qq"],
                       @"sex":@([result intForColumn:@"sex"]),
                       @"spec_name":[result stringForColumn:@"spec_name"],
                       @"telphone":[result stringForColumn:@"telphone"],
                       @"last_datetime":@([result intForColumn:@"last_datetime"])
                       };
    }
    UserInfosDTO *dto = nil;
    
    if (historyDic) {
        dto = [UserInfosDTO new];
        [dto processDataToObjectWithData:historyDic isFromDB:YES];
    }
    return dto;
    
    
}

#pragma mark- User Autos Selected History

- (BOOL)checkAndUpdateAutoSelectedHistoryColumn {
    BOOL isExist = YES;
    if (![_fmdb columnExists:@"tire_default_spec" inTableWithName:@"auto_selected_history"]) {
        NSString *querySql = @"ALTER TABLE auto_selected_history ADD tire_default_spec CHAR(25)";
        isExist =  [_fmdb executeUpdate:querySql];
        NSLog(@"success add column::%d", isExist);
    }
    return isExist;
}

- (BOOL)updateAutoSelectedHistory:(UserSelectedAutosInfoDTO *)dto {
    @autoreleasepool {
        NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateAutoSelectedHistoryColumn]);
        NSDictionary *arguments = [dto processObjectToDBData];
        NSArray *key = [arguments allKeys];
        if ([key indexOfObject:@"id"] == NSNotFound) {
            NSLog(@"Key ID Was Not Found");
            return NO;
        }
        __block NSMutableString *tableKey = [NSMutableString string];
        __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
        [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableKey appendString:obj];
            [valueKey appendString:obj];
            if (![[key lastObject] isEqual:obj]) {
                [tableKey appendString:@", "];
                [valueKey appendString:@", :"];
            }
        }];
        
        NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO auto_selected_history(%@, last_datetime) VALUES(%@, CURRENT_TIMESTAMP);", tableKey,valueKey];
        
        return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
    }
}

- (UserSelectedAutosInfoDTO *)getAutoSelectedHistory {
    NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateAutoSelectedHistoryColumn]);
    UserSelectedAutosInfoDTO *dto = nil;
    NSDictionary *historyDic = nil;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [@"SELECT * FROM auto_selected_history " stringByAppendingFormat:@" WHERE `id`= \"%@\";",userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        historyDic = result.resultDictionary;
    }
    
    if (historyDic) {
        dto = [UserSelectedAutosInfoDTO new];
        [dto processDBDataToObjectWithDBData:historyDic];
    }
    return dto;
    
    
}

#pragma mark- User Selected Autos Data

- (BOOL)checkAndUpdateSelectedAutoDataColumn {
    BOOL isExist = YES;
    if (![_fmdb columnExists:@"tire_default_spec" inTableWithName:@"selected_auto"]) {
        NSString *querySql = @"ALTER TABLE selected_auto ADD tire_default_spec CHAR(25)";
        isExist =  [_fmdb executeUpdate:querySql];
        NSLog(@"success add column::%d", isExist);
    }
    
    if (![_fmdb columnExists:@"selected_tire_spec" inTableWithName:@"selected_auto"]) {
        NSString *querySql = @"ALTER TABLE selected_auto ADD selected_tire_spec CHAR(25)";
        isExist =  [_fmdb executeUpdate:querySql];
        NSLog(@"success add column::%d", isExist);
    }
    return isExist;
}

- (BOOL)updateSelectedAutoData:(UserSelectedAutosInfoDTO *)dto {
    @autoreleasepool {
        NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateSelectedAutoDataColumn]);
        NSDictionary *arguments = [dto processObjectToDBData];
        NSArray *key = [arguments allKeys];
        if ([key indexOfObject:@"id"] == NSNotFound) {
            NSLog(@"Key ID Was Not Found");
            return NO;
        }
        __block NSMutableString *tableKey = [NSMutableString string];
        __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
        [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableKey appendString:obj];
            [valueKey appendString:obj];
            if (![[key lastObject] isEqual:obj]) {
                [tableKey appendString:@", "];
                [valueKey appendString:@", :"];
            }
        }];
        
        NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO selected_auto(%@, last_datetime) VALUES(%@, CURRENT_TIMESTAMP);", tableKey,valueKey];
        
        return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
    }
}

- (UserSelectedAutosInfoDTO *)getSelectedAutoData {
    
    NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateSelectedAutoDataColumn]);
    UserSelectedAutosInfoDTO *dto = nil;
    NSDictionary *autoDataDic = nil;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [@"SELECT * FROM selected_auto " stringByAppendingFormat:@" WHERE `id`= \"%@\";",userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        autoDataDic = result.resultDictionary;
    }
    dto = [UserSelectedAutosInfoDTO new];
    if (autoDataDic) {
        [dto processDBDataToObjectWithDBData:autoDataDic];
    }
    return dto;
    
    
}

- (BOOL)clearSelectedAutoData {
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [@"DELETE FROM selected_auto " stringByAppendingFormat:@" WHERE `id`= \"%@\";",userID];
    BOOL isDone = [_fmdb executeUpdate:querySql];
    return isDone;
}

#pragma mark- Repair Shop Type Data
- (BOOL)updateRepairShopTypeList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getRepairShopTypeList]) {
        querySql = @"DELETE FROM repair_shop_type;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO repair_shop_type(id, name) VALUES(:id, :name);"];
            if (![_fmdb executeUpdate:querySql withParameterDictionary:obj]) {
                isSuccess = NO;
            }
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSArray *)getRepairShopTypeList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM repair_shop_type;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        [storeTypeList addObject:@{@"id":[result stringForColumn:@"id"],
                                   @"name":[result stringForColumn:@"name"]}];
    }
    
    if(storeTypeList.count == 0)return nil;
    
    return storeTypeList;
    
    
}

#pragma mark- Repair Shop Service Type Data
- (BOOL)updateRepairShopSerivceTypeList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getRepairShopServiceTypeList]) {
        querySql = @"DELETE FROM repair_shop_service_type;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO repair_shop_service_type(id, name) VALUES(:id, :name);"];
            if (obj[@"imgurl"]) {
                querySql = [NSString stringWithFormat:@"INSERT INTO repair_shop_service_type(id, name, imgurl) VALUES(:id, :name, :imgurl);"];
            }
            if (![_fmdb executeUpdate:querySql withParameterDictionary:obj]) {
                isSuccess = NO;
            }
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSArray *)getRepairShopServiceTypeList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM repair_shop_service_type;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        NSString *icon = @"";
        if ([result stringForColumn:@"imgurl"]) {
            icon = [result stringForColumn:@"imgurl"];
        }
        [storeTypeList addObject:@{@"id":[result stringForColumn:@"id"],
                                   @"name":[result stringForColumn:@"name"],
                                   @"imgurl":icon}];
    }
    
    if(storeTypeList.count == 0)return nil;
    
    return storeTypeList;
    
    
}

#pragma mark- Purchase Order Status List Data
- (BOOL)updatePurchaseOrderStatusList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getPurchaseOrderStatusList]) {
        querySql = @"DELETE FROM order_status;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self resetTableSequence:@"order_status"];
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO order_status(id, name) VALUES(:id, :name);"];
            if (![_fmdb executeUpdate:querySql withParameterDictionary:obj]) {
                isSuccess = NO;
            }
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSArray *)getPurchaseOrderStatusList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM order_status;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        @autoreleasepool {
            OrderStatusDTO *dto = [OrderStatusDTO new];
            [dto processDataToObjectWithData:[result resultDictionary]];
            [storeTypeList addObject:dto];
        }
    }
    
    if(storeTypeList.count == 0)return nil;
    
    return storeTypeList;
    
    
}

#pragma mark- Repair Shop Service List Data
- (BOOL)updateRepairShopServiceList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getRepairShopServiceList]) {
        querySql = @"DELETE FROM service_maintenance_list;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self resetTableSequence:@"service_maintenance_list"];
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO service_maintenance_list(id, main_name, imgurl, main_type) VALUES(:id, :main_name, :imgurl, :main_type);"];
            if (![_fmdb executeUpdate:querySql withParameterDictionary:obj]) {
                isSuccess = NO;
            }
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSDictionary *)getRepairShopServiceList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM service_maintenance_list;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        [storeTypeList addObject:[result resultDictionary]];
    }
    
    if(storeTypeList.count == 0)return nil;
    NSDictionary *dataDetail = nil;
    NSPredicate *normalPredicate = [NSPredicate predicateWithFormat:@"SELF.main_type LIKE[cd] %@", CDZObjectKeyOfConventionMaintain];
    NSPredicate *deepPredicate = [NSPredicate predicateWithFormat:@"SELF.main_type LIKE[cd] %@", CDZObjectKeyOfDeepnessMaintain];
    
    dataDetail = @{CDZObjectKeyOfConventionMaintain:[storeTypeList filteredArrayUsingPredicate:normalPredicate],
                   CDZObjectKeyOfDeepnessMaintain:[storeTypeList filteredArrayUsingPredicate:deepPredicate]};
    
    return dataDetail;
    
    
}

#pragma mark- Repair Service List Data
- (BOOL)creatMaintenanceServiceList {
    NSString *querySql = @"CREATE TABLE \"service_maintenance_describe_list\" (\"key_id\" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \"id\" TEXT(50,0) DEFAULT 0, \"name\" TEXT(50,0), \"describle\" TEXT, \"uncheck_icon\" TEXT, \"check_icon\" TEXT, \"main_type\" TEXT, \"mark\" TEXT); INSERT INTO \"main\".sqlite_sequence (name, seq) VALUES (\"service_maintenance_describe_list\", '0');";
    
    BOOL result = [_fmdb executeUpdate:querySql];
    if (result) {
        NSLog(@"创表成功 \"%@\";", [_fmdb lastErrorMessage]);
        
    }else {
        NSLog(@"创表失败 \"%@\";", [_fmdb lastErrorMessage]);
    }
    
    
    return result;
}

- (BOOL)updateMaintenanceServiceList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    if (![_fmdb tableExists:@"service_maintenance_describe_list"]){
        NSLog(@"create OK?:%d", [self creatMaintenanceServiceList]);
    }
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getRepairShopServiceList]) {
        querySql = @"DELETE FROM service_maintenance_describe_list;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self resetTableSequence:@"service_maintenance_describe_list"];
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO service_maintenance_describe_list(id, name, describle, uncheck_icon, check_icon, main_type, mark) VALUES(:id, :name, :describle, :uncheck_icon, :check_icon, :main_type, :mark);"];
            if (![_fmdb executeUpdate:querySql withParameterDictionary:obj]) {
                isSuccess = NO;
            }
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSDictionary *)getMaintenanceServiceList {
    if (![_fmdb tableExists:@"service_maintenance_describe_list"]){
        NSLog(@"create OK?:%d", [self creatMaintenanceServiceList]);
    }
    
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM service_maintenance_describe_list;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        [storeTypeList addObject:[result resultDictionary]];
    }
    
    if(storeTypeList.count == 0)return nil;
    NSDictionary *dataDetail = nil;
    NSPredicate *normalPredicate = [NSPredicate predicateWithFormat:@"SELF.main_type LIKE[cd] %@", CDZObjectKeyOfConventionMaintain];
    NSPredicate *deepPredicate = [NSPredicate predicateWithFormat:@"SELF.main_type LIKE[cd] %@", CDZObjectKeyOfDeepnessMaintain];
    
    dataDetail = @{CDZObjectKeyOfConventionMaintain:[storeTypeList filteredArrayUsingPredicate:normalPredicate],
                   CDZObjectKeyOfDeepnessMaintain:[storeTypeList filteredArrayUsingPredicate:deepPredicate]};
    
    return dataDetail;
    
    
}

#pragma mark- Key City List Data
- (BOOL)updateKeyCityList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    if ([self getKeyCityList]) {
        querySql = @"DELETE FROM key_city;";
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self resetTableSequence:@"key_city"];
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KeyCityDTO class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO key_city(region_id, region_name, city_name_pinyin, sorted_key) VALUES(:region_id, :region_name, :city_name_pinyin, :sorted_key);"];
            NSDictionary *cityDetail = [(KeyCityDTO*)obj processObjectToDBData];
            isSuccess = [_fmdb executeUpdate:querySql withParameterDictionary:cityDetail];
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSArray *)getKeyCityList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *querySql = @"SELECT * FROM key_city;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        [storeTypeList addObject:@{@"id":[result stringForColumn:@"id"],
                                   @"region_id":[result stringForColumn:@"region_id"],
                                   @"region_name":[result stringForColumn:@"region_name"],
                                   @"city_name_pinyin":[result stringForColumn:@"city_name_pinyin"],
                                   @"sorted_key":[result stringForColumn:@"sorted_key"]}
         ];
    }
    if (storeTypeList.count==0) {
        return storeTypeList;
    }
    return [KeyCityDTO handleDataListFromDBToDTOList:storeTypeList];
    
    
}

#pragma mark- Key Brand List Data
- (BOOL)creatAutosBrandTable {
    NSString *deteleQuerySql = @"DROP TABLE IF EXISTS 'auto_brand_list';";
    BOOL result = [_fmdb executeUpdate:deteleQuerySql];
    NSString *querySql = @"CREATE TABLE IF NOT EXISTS auto_brand_list ( id INTEGER NOT NULL, brand_id text NOT NULL, brand_img text NOT NULL DEFAULT 0, brand_name TEXT NOT NULL, sorted_key TEXT NOT NULL, PRIMARY KEY(id));";
    result = [_fmdb executeUpdate:querySql];
    
    if (result) {
        NSLog(@"创表成功 \"%@\";", [_fmdb lastErrorMessage]);
        
    }else {
        NSLog(@"创表失败 \"%@\";", [_fmdb lastErrorMessage]);
    }
    
    
    return result;
}

- (BOOL)updateAutosBrandList:(NSArray *)argumentList {
    if (!argumentList||argumentList.count==0) return NO;
    __block BOOL isSuccess = YES;
    NSString *querySql = @"";
    NSString *tableName = [self getTableName:CDZDBUpdateListOfAutosBrand];
    if (![_fmdb tableExists:tableName]||[_fmdb columnExists:@"brand_name_pinyin" inTableWithName:tableName]) {
        [self creatAutosBrandTable];
    }
    NSLog(@"%d", [_fmdb tableExists:tableName]);
    if ([self getAutosBrandList]) {
        querySql = [NSString stringWithFormat:@"DELETE FROM %@;" ,tableName];
        if ([_fmdb executeUpdate:querySql]) {
            NSLog(@"Clear All Records is Done");
            [self resetTableSequence:tableName];
            [self executeVACUUMCommand];
        }
    }
    
    [argumentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AutosBrandDTO class]]) {
            NSString *querySql = [NSString stringWithFormat:@"INSERT INTO %@(brand_id, brand_img, brand_name, sorted_key) VALUES(:brand_id, :brand_img, :brand_name, :sorted_key);", tableName];
            NSDictionary *cityDetail = [(AutosBrandDTO*)obj processObjectToDBData];
            isSuccess = [_fmdb executeUpdate:querySql withParameterDictionary:cityDetail];
        }else {
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

- (NSArray <AutosBrandDTO *> *)getAutosBrandList {
    NSMutableArray *storeTypeList = [NSMutableArray array];
    NSString *tableName = [self getTableName:CDZDBUpdateListOfAutosBrand];
    if (![_fmdb tableExists:tableName]||[_fmdb columnExists:@"brand_name_pinyin" inTableWithName:tableName]) {
        [self creatAutosBrandTable];
    }

    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@;" , tableName];
    NSLog(@"break");
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        AutosBrandDTO *dto = [AutosBrandDTO new];
        [dto processDBDataToObjectWithDBData:result.resultDictionary];
        [storeTypeList addObject:dto];
    }
    if (storeTypeList.count==0) {
        return nil;
    }
    return storeTypeList;//[AutosBrandDTO handleDataListFromDBToDTOList:storeTypeList];
    
}

#pragma mark- Parts Search History Data
- (BOOL)clearPartsSearchHistory {
    NSString *querySql = @"DELETE FROM parts_search_history;";
    BOOL isDone = [_fmdb executeUpdate:querySql];
    if (isDone) {
        [self executeVACUUMCommand];
    }
    return isDone;
}

- (BOOL)updatePartsSearchHistory:(NSString *)keyword {
    if (keyword&&![keyword isEqualToString:@""]) {
        NSDictionary *obj = @{@"keyword":keyword};
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO parts_search_history(keyword, last_datetime) VALUES(:keyword, CURRENT_TIMESTAMP);"];
        return [_fmdb executeUpdate:querySql withParameterDictionary:obj];
    }
    return NO;
}

- (NSArray *)getPartsSearchHistory {
    NSMutableArray *historyArray = [NSMutableArray array];
    NSString *querySql = @"SELECT DISTINCT keyword FROM parts_search_history ORDER BY last_datetime DESC;";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        [historyArray addObject:[result stringForColumn:@"keyword"]];
    }
    
    return historyArray;
}

#pragma mark- Autos GPS Realtime Data
- (BOOL)updateAutoRealtimeData:(NSDictionary *)arguments {
    @autoreleasepool {
        
        NSArray *key = [arguments allKeys];
        if ([key indexOfObject:@"id"] == NSNotFound) {
            NSLog(@"Key ID Was Not Found");
            return NO;
        }
        __block NSMutableString *tableKey = [NSMutableString string];
        __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
        [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableKey appendString:obj];
            [valueKey appendString:obj];
            if (![[key lastObject] isEqual:obj]) {
                [tableKey appendString:@", "];
                [valueKey appendString:@", :"];
            }
        }];
        
        NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO auto_gps_realtime_data(%@, last_datetime) VALUES(%@, CURRENT_TIMESTAMP);", tableKey, valueKey];
        
        return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
    }
}

- (BOOL)clearAutoRealtimeData {
    NSString *querySql = @"INSERT OR REPLACE INTO auto_gps_realtime_data"
    "(id, acc, direction, gpsNum, gsm, imei, lat, lon, mileage, speed, time, last_datetime) VALUES"
    "(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, CURRENT_TIMESTAMP);";
    BOOL isDone = [_fmdb executeUpdate:querySql];
    return isDone;
}

- (NSDictionary *)getAutoRealtimeDataWithDataID:(NSInteger)dataID {
    NSDictionary *historyDic = nil;
    if (dataID<=1) dataID = 1;
    NSString *querySql = [@"SELECT * FROM auto_gps_realtime_data;" stringByAppendingFormat:@" WHERE `id`= %ld;",(long)dataID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        historyDic = @{@"id":@([result intForColumn:@"id"]),
                       @"acc":@([result intForColumn:@"acc"]),
                       @"direction":@([result doubleForColumn:@"direction"]),
                       @"gpsNum":@([result intForColumn:@"gpsNum"]),
                       @"gsm":@([result intForColumn:@"gsm"]),
                       @"imei":@([result intForColumn:@"imei"]),
                       @"lat":@([result doubleForColumn:@"lat"]),
                       @"lon":@([result doubleForColumn:@"lon"]),
                       @"mileage":@([result doubleForColumn:@"mileage"]),
                       @"speed":@([result doubleForColumn:@"speed"]),
                       @"time":[result stringForColumn:@"time"],
                       @"last_datetime":@([result intForColumn:@"last_datetime"])
                       };
    }
    
    return historyDic;
    
    
}

#pragma mark- User Autos Detail Data

- (BOOL)checkAndUpdateUserAutosDetailColumn {
    BOOL isExist = YES;
    if (![_fmdb columnExists:@"tire_default_spec" inTableWithName:@"user_autos_detail"]) {
        NSString *querySql = @"ALTER TABLE user_autos_detail ADD tire_default_spec CHAR(25)";
        isExist =  [_fmdb executeUpdate:querySql];
        NSLog(@"success add column::%d", isExist);
    }
    return isExist;
}

- (BOOL)updateUserAutosDetailData:(NSDictionary *)arguments {
    @autoreleasepool {
        NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateUserAutosDetailColumn]);
        
        NSArray *key = [arguments allKeys];
        if ([key indexOfObject:@"id"] == NSNotFound) {
            NSLog(@"Key ID Was Not Found");
            return NO;
        }
        __block NSMutableString *tableKey = [NSMutableString string];
        __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
        [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableKey appendString:obj];
            [valueKey appendString:obj];
            if (![[key lastObject] isEqual:obj]) {
                [tableKey appendString:@", "];
                [valueKey appendString:@", :"];
            }
        }];
        
        NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO user_autos_detail(%@, last_datetime) VALUES(%@, CURRENT_TIMESTAMP);", tableKey, valueKey];
        
        return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
    }
}

- (BOOL)clearUserAutosDetailData {
    NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateUserAutosDetailColumn]);
    
//    NSString *querySql = @"INSERT OR REPLACE INTO user_autos_detail"
//    "(db_uid, uid, id, car_number, brand_name, brand_img, factory_name, fct_name, spec_name, brandId, factoryId, fctId, specId, imei, color, mileage, insure_time, annual_time, maintain_time, registr_time, frame_no, engine_code, tire_default_spec, last_datetime)  VALUES"
//    "(1, '', '', '', '', '', '', '', '', '0', '0', '0', '0', '', '', '', '', '', '', '', '', '', '', CURRENT_TIMESTAMP);";
    
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM user_autos_detail WHERE `id`= \"%@\";", userID];
    BOOL isDone = [_fmdb executeUpdate:querySql];
    return isDone;
}

- (UserAutosInfoDTO *)getUserAutosDetail {
    @autoreleasepool {
        NSLog(@"On %@ check N update success::%d ", NSStringFromSelector(_cmd), [self checkAndUpdateUserAutosDetailColumn]);
        
        UserAutosInfoDTO *dto = nil;
        NSDictionary *historyDic = nil;
        NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
        NSString *querySql = [@"SELECT * FROM user_autos_detail" stringByAppendingFormat:@" WHERE `id`= \"%@\"",userID];
        FMResultSet *result = [_fmdb executeQuery:querySql];
        
        if ([result next]) {
            historyDic = result.resultDictionary;
            
        }
        if (historyDic) {
            dto = [UserAutosInfoDTO new];
            [dto processDBDataToObjectWithDBData:historyDic];
        }
        
        return dto;
    }
    
    
}

#pragma mark- User Default Address Data
- (BOOL)updateUserDefaultAddress:(AddressDTO *)dto {
    NSDictionary *arguments = [dto processObjectToDBData];
    if (!arguments) {
        return NO;
    }
    NSArray *key = [arguments allKeys];
    if ([key indexOfObject:@"id"] == NSNotFound) {
        NSLog(@"Key ID Was Not Found");
        return NO;
    }
    __block NSMutableString *tableKey = [NSMutableString string];
    __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
    [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tableKey appendString:obj];
        [valueKey appendString:obj];
        if (![[key lastObject] isEqual:obj]) {
            [tableKey appendString:@", "];
            [valueKey appendString:@", :"];
        }
    }];
    
    NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO user_default_address(%@, last_datetime) VALUES(%@, CURRENT_TIMESTAMP);", tableKey, valueKey];

    return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
}

- (BOOL)clearUserDefaultAddress {
    BOOL isSuccess = NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM user_default_address WHERE `id`= \"%@\";",userID];
    isSuccess = [_fmdb executeUpdate:querySql];
    return isSuccess;
}

- (AddressDTO *)getUserDefaultAddress {
    AddressDTO *dto = nil;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    
    NSDictionary *addressDetail = nil;
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM user_default_address WHERE `id`= \"%@\";",userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        addressDetail = @{@"id":[result stringForColumn:@"id"],
                          @"address_id":[result stringForColumn:@"address_id"],
                          @"province_id":[result stringForColumn:@"province_id"],
                          @"province_name":[result stringForColumn:@"province_name"],
                          @"city_id":[result stringForColumn:@"city_id"],
                          @"city_name":[result stringForColumn:@"city_name"],
                          @"region_id":[result stringForColumn:@"region_id"],
                          @"region_name":[result stringForColumn:@"region_name"],
                          @"tel":[result stringForColumn:@"tel"],
                          @"name":[result stringForColumn:@"name"],
                          @"address":[result stringForColumn:@"address"]};
    }
    if (addressDetail) {
        dto = [AddressDTO new];
        [dto processDBDataToObjectWithDBData:addressDetail];
    }
    return dto;
}

#pragma mark- Data Next Update Time

- (NSString *)getTableName:(CDZDBUpdateList)updateTable {
    NSString *tableName = nil;
    
    switch (updateTable) {
        case CDZDBUpdateListOfKeyCity:
            tableName = @"key_city";
            break;
        case CDZDBUpdateListOfAutosBrand:
            tableName = @"auto_brand_list";
            break;
            
        default:
            tableName = @"";
            break;
    }
    
    return tableName;
    
}

- (BOOL)isDataNeedToUpdate:(CDZDBUpdateList)updateTable {
    BOOL isNeedUpdate = NO;
    NSString *tableName = [self getTableName:updateTable];
    if (tableName&&![tableName isEqualToString:@""]) {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM data_update_scheduling WHERE table_name Like \"%@\"", tableName];
        FMResultSet *result = [_fmdb executeQuery:query];
        NSTimeInterval timeInterval = 0;
        if ([result next]) {
            timeInterval = [result doubleForColumn:@"next_update_datetime"];
        }

        NSDate *nextUpdateDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        if ([[NSDate date] compare:nextUpdateDate]==NSOrderedDescending) {
            return YES;
        }
        
    }
    return isNeedUpdate;
}

- (BOOL)updateDataNextUpdateDateTime:(NSDate *)nextUpdateDateTime table:(CDZDBUpdateList)updateTable {
    NSString *tableName = [self getTableName:updateTable];
    BOOL updateSuccess = NO;
    if (tableName&&![tableName isEqualToString:@""]) {
        NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO data_update_scheduling VALUES (\"%@\", %f )", tableName, [nextUpdateDateTime timeIntervalSince1970]];
        if ([_fmdb executeUpdate:query]) {
            NSLog(@"Update Table:%@ Next Update DateTime Success!", tableName);
        }
    }
    return updateSuccess;
}


#pragma mark- BD APNS Config Data
- (BOOL)updateBDAPNSConfigData:(BDPushConfigDTO *)dto {
    if (!dto) return NO;
    NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO bd_apns_config (id, device_token, channel_id, bdp_user_id) VALUES(1, \"%@\", \"%@\", \"%@\");", dto.deviceToken, dto.channelID, dto.bdpUserID];
    
    return [_fmdb executeUpdate:querySql];
}

- (BOOL)clearBDAPNSConfigData {
    
    NSString *querySql = @"INSERT OR REPLACE INTO bd_apns_config  (id, device_token, channel_id, bdp_user_id) VALUES(1, NULL, NULL, NULL);";
    
    return [_fmdb executeUpdate:querySql];
}

- (BDPushConfigDTO *)getBDAPNSConfigData {

    NSString *querySql = @"SELECT * FROM bd_apns_config WHERE id = 1";
    FMResultSet *result = [_fmdb executeQuery:querySql];
    BDPushConfigDTO *dto = nil;
    dto = [BDPushConfigDTO new];
    if ([result next]) {
        dto.deviceToken = [result stringForColumn:@"device_token"];
        dto.channelID = [result stringForColumn:@"channel_id"];
        dto.bdpUserID = [result stringForColumn:@"bdp_user_id"];
    }
    return dto;
}


#pragma mark- EService Automatic Cancel Data
- (BOOL)createEServiceCancelRecordTabel {
    NSString *dropTable = @"DROP TABLE IF EXISTS eService_auto_cancel";
    BOOL result = [_fmdb executeUpdate:dropTable];
    NSString *querySql = @"CREATE TABLE eService_auto_cancel (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id text, serivce_type integer NOT NULL ON CONFLICT ROLLBACK DEFAULT 0, serivce_id text, add_time integer NOT NULL ON CONFLICT ROLLBACK DEFAULT 0)";
    result = [_fmdb executeUpdate:querySql];
    if (result) {
        NSLog(@"创表成功 \"%@\";", [_fmdb lastErrorMessage]);
        
    }else {
        NSLog(@"创表失败 \"%@\";", [_fmdb lastErrorMessage]);
    }
    [_fmdb executeUpdate:@"INSERT INTO main.sqlite_sequence (name, seq) VALUES (eService_auto_cancel, '1')"];
    
    return result;
}

- (BOOL)insertEServiceCancelRecord:(EServiceCancelRecordDTO *)dto {
    if (!dto) return NO;
    if (![_fmdb tableExists:@"eService_auto_cancel"]) {
        [self createEServiceCancelRecordTabel];
    }
    NSDictionary *arguments = [dto convertObjectToDBDataRecord];
    if (!arguments) {
        return NO;
    }
    NSArray *key = [arguments allKeys];
    __block NSMutableString *tableKey = [NSMutableString string];
    __block NSMutableString *valueKey = [NSMutableString stringWithString:@":"];
    [key enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tableKey appendString:obj];
        [valueKey appendString:obj];
        if (![[key lastObject] isEqual:obj]) {
            [tableKey appendString:@", "];
            [valueKey appendString:@", :"];
        }
    }];
    
    NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO eService_auto_cancel(%@) VALUES(%@);", tableKey, valueKey];
    
    return [_fmdb executeUpdate:querySql withParameterDictionary:arguments];
}

- (NSArray <EServiceCancelRecordDTO *> *)getEServiceCancelRecord {
    if (![_fmdb tableExists:@"eService_auto_cancel"]) {
        [self createEServiceCancelRecordTabel];
    }
    NSMutableArray *dtoList = [NSMutableArray array];
    NSString *userID = [SecurityCryptor.shareInstance tokenEncryption:UserBehaviorHandler.shareInstance.getUserID];
    NSString *querySql = [@"SELECT * FROM eService_auto_cancel" stringByAppendingFormat:@" WHERE `user_id`= \"%@\"",userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    while ([result next]) {
        EServiceCancelRecordDTO *dto = [EServiceCancelRecordDTO createDataToObjectByDBRecord:result.resultDictionary];
        if (dto) {
            [dtoList addObject:dto];
        }
    }
    
    return dtoList;
}

- (EServiceCancelRecordDTO *)getEServiceCancelRecordByEServiceID:(NSString *)eServiceID {
    if (![_fmdb tableExists:@"eService_auto_cancel"]) {
        [self createEServiceCancelRecordTabel];
    }
    EServiceCancelRecordDTO *dto = nil;
    NSString *encID = [SecurityCryptor.shareInstance tokenEncryption:eServiceID];
    NSString *querySql = [@"SELECT * FROM eService_auto_cancel" stringByAppendingFormat:@" WHERE `serivce_id`= \"%@\"",encID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    
    if ([result next]) {
        dto = [EServiceCancelRecordDTO createDataToObjectByDBRecord:result.resultDictionary];
    }
    
    return dto;
}

- (BOOL)deleteEServiceCancelRecordWithDto:(EServiceCancelRecordDTO *)dto {
    if (![_fmdb tableExists:@"eService_auto_cancel"]) {
        [self createEServiceCancelRecordTabel];
    }
    BOOL isSuccess = NO;
    
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM eService_auto_cancel WHERE id = \"%@\"", dto.dbUID];
    if (!dto.dbUID) {
        NSString *eServiceID = [SecurityCryptor.shareInstance tokenEncryption:dto.eServiceID];
        querySql = [NSString stringWithFormat:@"DELETE FROM eService_auto_cancel WHERE serivce_id = \"%@\"", eServiceID];
    }
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Delete EQC Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

#pragma mark- Exam Fail Question List
- (BOOL)updateExamFailQuestionListWithQID:(NSNumber *)qid {
    if (!qid) return NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"INSERT INTO exam_fail_question (qid, uid) VALUES(\"%@\", \"%@\");", qid, userID];
    
    return [_fmdb executeUpdate:querySql];
}

- (BOOL)clearDBAllExamFailQuestionListData {
    BOOL isSuccess = NO;
    NSString *querySql = @"DELETE FROM exam_fail_question";
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Clear All Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

- (BOOL)clearCurrentUserAllExamFailQuestionListData {
    BOOL isSuccess = NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM exam_fail_question WHERE uid = \"%@;\"", userID];
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Clear Current User Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

- (NSMutableArray *)getExamFailQuestionListData {
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM exam_fail_question WHERE uid = \"%@\"", userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    NSMutableArray *list = [@[] mutableCopy];
    while (result.next) {
        [list addObject:result.resultDictionary];
    }
    return list;
}

#pragma mark- Exam Question Collection

- (BOOL)updateExamQuestionCollectionWithQID:(NSNumber *)qid {
    if (!qid) return NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO exam_question_collection (qid, uid) VALUES(\"%@\", \"%@\");", qid, userID];
    
    return [_fmdb executeUpdate:querySql];
}

- (BOOL)deleteExamQuestionCollectionWithQID:(NSNumber *)qid {
    BOOL isSuccess = NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM exam_question_collection  WHERE uid = \"%@\";", userID];
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Delete EQC Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

- (BOOL)clearDBAllExamQuestionCollectionData {
    BOOL isSuccess = NO;
    NSString *querySql = @"DELETE FROM exam_question_collection";
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Clear All Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

- (BOOL)clearCurrentUserAllExamQuestionCollectionData {
    BOOL isSuccess = NO;
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"DELETE FROM exam_question_collection WHERE uid = \"%@\";", userID];
    isSuccess = [_fmdb executeUpdate:querySql];
    if (isSuccess) {
        NSLog(@"Clear Current User Records is Done");
        [self executeVACUUMCommand];
    }
    return isSuccess;
}

- (NSMutableArray *)getExamQuestionCollectionData {
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM exam_question_collection WHERE uid = \"%@\";", userID];
    FMResultSet *result = [_fmdb executeQuery:querySql];
    NSMutableArray *list = [@[] mutableCopy];
    while (result.next) {
        [list addObject:result.resultDictionary];
    }
    return list;
}

- (void)executeVACUUMCommand {
    if ([_fmdb executeUpdate:@"VACUUM;"]) {
        NSLog(@"VACUUM Command Success Executed!");
    }
}

- (void)resetTableSequence:(NSString *)tableName {
    if (!tableName||[tableName isEqualToString:@""]) {
        NSLog(@"tableName is empty");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"Update sqlite_sequence set seq= \"0\"  WHERE name = \"%@\";", tableName];
    if ([_fmdb executeUpdate:sql]) {
        NSLog(@"Update Table:%@ Sequence Success!", tableName);
    }
}

@end
