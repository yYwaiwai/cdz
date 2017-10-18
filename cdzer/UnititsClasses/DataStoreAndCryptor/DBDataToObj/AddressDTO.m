//
//  AddressDTO.m
//  cdzer
//
//  Created by KEns0n on 7/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "AddressDTO.h"

@interface AddressDTO ()
{
    NSString *_dbUID;
    NSString *_addressID;
}
@end

@implementation AddressDTO

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbData {
    if (dbData) {
        /**
         *  收货地址ID
         */
        
        NSString *dbUID = dbData[@"id"];
        if (!dbUID||[dbUID isKindOfClass:NSNull.class]) {
            _dbUID = nil;
        }else {
            _dbUID = dbUID;
        }
        
        NSString *addressID = dbData[@"address_id"];
        if (!addressID||[addressID isKindOfClass:NSNull.class]) {
            _addressID = @"";
        }else {
            _addressID = addressID;
        }
        
        /**
         *  城市ID
         */
        NSString *cityID = dbData[@"city_id"];
        if (!cityID||[cityID isKindOfClass:NSNull.class]) {
            self.cityID = @"";
        }else {
            self.cityID = cityID;
        }
        
        /**
         *  城市名
         */
        NSString *cityName = dbData[@"city_name"];
        if (!cityName||[cityName isKindOfClass:NSNull.class]) {
            self.cityName = @"";
        }else {
            self.cityName = cityName;
        }
        
        /**
         *  省ID
         */
        NSString *provinceID = dbData[@"province_id"];
        if (!provinceID||[provinceID isKindOfClass:NSNull.class]) {
            self.provinceID = @"";
        }else {
            self.provinceID = provinceID;
        }
        
        /**
         *  省名
         */
        NSString *provinceName = dbData[@"province_name"];
        if (!provinceName||[provinceName isKindOfClass:NSNull.class]) {
            self.provinceName = @"";
        }else {
            self.provinceName = provinceName;
        }
        
        /**
         *  地区ID
         */
        NSString *regionID = dbData[@"region_id"];
        if (!regionID||[regionID isKindOfClass:NSNull.class]) {
            self.regionID = @"";
        }else {
            self.regionID = regionID;
        }
        
        /**
         *  地区名
         */
        NSString *regionName = dbData[@"region_name"];
        if (!regionName||[regionName isKindOfClass:NSNull.class]) {
            self.regionName = @"";
        }else {
            self.regionName = regionName;
        }
        
        /**
         *  电话号码
         */
        NSString *telNumber = dbData[@"tel"];
        if (!telNumber||[telNumber isKindOfClass:NSNull.class]) {
            self.telNumber = @"";
        }else {
            self.telNumber = telNumber;
        }
        
        /**
         *  收货人
         */
        NSString *consigneeName = dbData[@"name"];
        if (!consigneeName||[consigneeName isKindOfClass:NSNull.class]) {
            self.consigneeName = @"";
        }else {
            self.consigneeName = consigneeName;
        }
        
        /**
         *  详细地址
         */
        NSString *address = dbData[@"address"];
        if (!address||[address isKindOfClass:NSNull.class]) {
            self.address = @"";
        }else {
            self.address = address;
        }
        
        
    }
}

- (NSDictionary *)processObjectToDBData {
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    if (!_addressID||!userID||[userID isEqualToString:@""]) {
        return nil;
    }
    NSDictionary *dataDetil = @{@"id":userID,
                                @"address_id":_addressID,
                                @"province_id":_provinceID,
                                @"province_name":_provinceName,
                                @"city_id":_cityID,
                                @"city_name":_cityName,
                                @"region_id":_regionID,
                                @"region_name":_regionName,
                                @"tel":_telNumber,
                                @"name":_consigneeName,
                                @"address":_address};
    return dataDetil;
}

- (void)processDataToObject:(NSDictionary *)addressData {
    //    city_id: "274",
    //    id: "15042913501537413721",
    //    province_id: "20",
    //    address: "平安街12号",
    //    province_id_name: "安徽省",
    //    tel: "14814889904",
    //    name: "陈豪的",
    //    city_id_name: "蚌埠市",
    //    region_id: "2288",
    //    region_id_name: "中市区"

    
    /**
     *  收货地址ID
     */
    NSString *addressID = addressData[@"id"];
    if (!addressID||[addressID isKindOfClass:NSNull.class]) {
        _addressID = @"";
    }else {
        _addressID = addressID;
    }

    /**
     *  城市ID
     */
    NSString *cityID = addressData[@"city_id"];
    if (!cityID||[cityID isKindOfClass:NSNull.class]) {
        self.cityID = @"";
    }else {
        self.cityID = cityID;
    }
    
    /**
     *  城市名
     */
    NSString *cityName = addressData[@"city_id_name"];
    if (!cityName||[cityName isKindOfClass:NSNull.class]) {
        self.cityName = @"";
    }else {
        self.cityName = cityName;
    }
    
    /**
     *  省ID
     */
    NSString *provinceID = addressData[@"province_id"];
    if (!provinceID||[provinceID isKindOfClass:NSNull.class]) {
        self.provinceID = @"";
    }else {
        self.provinceID = provinceID;
    }
    
    /**
     *  省名
     */
    NSString *provinceName = addressData[@"province_id_name"];
    if (!provinceName||[provinceName isKindOfClass:NSNull.class]) {
        self.provinceName = @"";
    }else {
        self.provinceName = provinceName;
    }
    
    /**
     *  地区ID
     */
    NSString *regionID = addressData[@"region_id"];
    if (!regionID||[regionID isKindOfClass:NSNull.class]) {
        self.regionID = @"";
    }else {
        self.regionID = regionID;
    }
    
    /**
     *  地区名
     */
    NSString *regionName = addressData[@"region_id_name"];
    if (!regionName||[regionName isKindOfClass:NSNull.class]) {
        self.regionName = @"";
    }else {
        self.regionName = regionName;
    }
    
    /**
     *  电话号码
     */
    NSString *telNumber = addressData[@"tel"];
    if (!telNumber||[telNumber isKindOfClass:NSNull.class]) {
        self.telNumber = @"";
    }else {
        self.telNumber = telNumber;
    }

    /**
     *  收货人
     */
    NSString *consigneeName = addressData[@"name"];
    if (!consigneeName||[consigneeName isKindOfClass:NSNull.class]) {
        self.consigneeName = @"";
    }else {
        self.consigneeName = consigneeName;
    }
    
    /**
     *  详细地址
     */
    NSString *address = addressData[@"address"];
    if (!address||[address isKindOfClass:NSNull.class]) {
        self.address = @"";
    }else {
        self.address = address;
    }
    
    /**
     *  默认地址
     */
    BOOL defaultAddress = [SupportingClass verifyAndConvertDataToNumber:addressData[@"state"]].boolValue;
    _isDefaultAddress = !defaultAddress;
}

+ (NSArray *)handleDataListToDTOList:(NSArray *)addressList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [addressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AddressDTO *dto = [AddressDTO new];
            [dto processDataToObject:obj];
            [dtoList addObject:dto];
        }];
        return dtoList;
    }
}
@end