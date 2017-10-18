//
//  AutosBrandDTO.h
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"

@interface AutosBrandDTO : BaseDataToObject

@property (nonatomic, readonly) NSNumber *dbUID;

@property (nonatomic, readonly) NSString *brandID;

@property (nonatomic, readonly) NSString *brandImg;

@property (nonatomic, readonly) NSString *brandName;

@property (nonatomic, readonly) NSString *sortedKey;

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbData;

- (NSDictionary *)processObjectToDBData;

- (void)processDataToObjectWithBrandData:(NSDictionary *)brandData;

+ (NSArray <AutosBrandDTO *> *)handleDataListFromDBToDTOList:(NSArray *)brandList;

+ (NSArray <AutosBrandDTO *> *)handleDataListToDTOList:(NSArray *)brandList;

@end
