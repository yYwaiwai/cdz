//
//  AddressDTO.h
//  cdzer
//
//  Created by KEns0n on 7/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"

@interface AddressDTO : BaseDataToObject

@property (nonatomic, readonly) NSString *dbUID;

@property (nonatomic, readonly) NSString *addressID;

@property (nonatomic, strong) NSString *cityID;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) NSString *provinceID;

@property (nonatomic, strong) NSString *provinceName;

@property (nonatomic, strong) NSString *regionID;

@property (nonatomic, strong) NSString *regionName;

@property (nonatomic, strong) NSString *telNumber;

@property (nonatomic, strong) NSString *consigneeName;

@property (nonatomic, strong) NSString *address;

@property (nonatomic, assign) BOOL isDefaultAddress;

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbData;

- (NSDictionary *)processObjectToDBData;

- (void)processDataToObject:(NSDictionary *)addressData;

+ (NSArray *)handleDataListToDTOList:(NSArray *)addressList;

@end
