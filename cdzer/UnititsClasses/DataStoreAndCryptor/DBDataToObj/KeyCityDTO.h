//
//  KeyCityDTO.h
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"
#import <CoreLocation/CLLocation.h>

@interface KeyCityDTO : BaseDataToObject<NSCoding>

@property (nonatomic, readonly) NSNumber *dbUID;

@property (nonatomic, readonly) NSNumber *cityID;

@property (nonatomic, readonly) NSString *cityName;

@property (nonatomic, readonly) NSString *cityNamePY;

@property (nonatomic, readonly) NSString *sortedKey;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) BOOL isSelectFormPosition;

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbData;

- (NSDictionary *)processObjectToDBData;

- (void)processDataToObjectWithCityData:(NSDictionary *)addressData;

+ (NSArray *)handleDataListFromDBToDTOList:(NSArray *)cityList;

+ (NSArray *)handleDataListToDTOList:(NSArray *)cityList;

@end
