//
//  KeyCityDTO.m
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "KeyCityDTO.h"
#define kResultKeyID @"region_id"
#define kResultKeyName @"region_name"
#define kResultKeyNamePY @"city_name_pinyin"
#define kResultKeySortedKey @"sorted_key"
@interface KeyCityDTO ()
{
    NSNumber *_dbUID;
    NSNumber *_cityID;
    NSString *_cityName;
    NSString *_cityNamePY;
    NSString *_sortedKey;
}

@end

@implementation KeyCityDTO


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self->_dbUID = [decoder decodeObjectForKey:@"dbUID"];
    self->_cityID = [decoder decodeObjectForKey:@"cityID"];
    self->_cityName = [decoder decodeObjectForKey:@"cityName"];
    self->_cityNamePY = [decoder decodeObjectForKey:@"cityNamePY"];
    self->_sortedKey = [decoder decodeObjectForKey:@"sortedKey"];
    self.isSelectFormPosition = [decoder decodeBoolForKey:@"isPosition"];
//    id coordinateObj = [decoder decodeObjectForKey:@"coordinate"];
//    self.coordinate = [(NSValue *)coordinateObj MKCoordinateValue];
    
    return self;
}
//NSCoding是一个你需要在数据类上要实现的协议以支持数据类和数据流间的编码和解码。数据流可以持久化到硬盘
// encodeWithCoder和initWithEncoder。encodeWithCoder就是编码，initWithCoder就是解码。 encodeWithCoder方法传入的是一个NSCoder对象，实现的时候我们就可以调用encodeObject、encodeFloat、 encodeInt等各种方法并通过指定键值进行编码。
- (void)encodeWithCoder:(NSCoder *)encoder {
    //NSKeyedArchiver使用encodeObject方法报错
    [encoder encodeObject:_dbUID forKey:@"dbUID"];
    [encoder encodeObject:_cityID forKey:@"cityID"];
    [encoder encodeObject:_cityName forKey:@"cityName"];
    [encoder encodeObject:_cityNamePY forKey:@"cityNamePY"];
    [encoder encodeObject:_sortedKey forKey:@"sortedKey"];
    [encoder encodeBool:_isSelectFormPosition forKey:@"isPosition"];
//    [encoder encodeObject:[NSValue valueWithMKCoordinate:_coordinate] forKey:@"coordinate"];
}

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbData{
    if (dbData) {
        NSString *dbUID = dbData[@"id"];
        if (!dbUID||[dbUID isKindOfClass:NSNull.class]) {
            _dbUID = nil;
        }else {
            _dbUID = @(dbUID.longLongValue);
        }
        
        
        /**
         *  城市ID
         */
        NSString *cityID = dbData[kResultKeyID];
        if (!cityID||[cityID isKindOfClass:NSNull.class]) {
            _cityID = @(0);
        }else {
            _cityID = @(cityID.longLongValue);
        }
        
        /**
         *  城市名
         */
        NSString *cityName = dbData[kResultKeyName];
        if (!cityName||[cityName isKindOfClass:NSNull.class]) {
            _cityName = @"";
        }else {
            _cityName = cityName;
        }
        
        /**
         *  城市拼音名
         */
        NSString *cityNamePY = dbData[kResultKeyNamePY];
        if (!cityNamePY||[cityNamePY isKindOfClass:NSNull.class]) {
            _cityNamePY = @"";
        }else {
            _cityNamePY = cityNamePY;
        }
        
        
        /**
         *  城市拼音名
         */
        NSString *sortedKey = dbData[kResultKeySortedKey];
        if (!sortedKey||[sortedKey isKindOfClass:NSNull.class]) {
            _sortedKey = @"";
        }else {
            _sortedKey = sortedKey;
        }
    }
}

+ (NSArray *)handleDBDataListToDTOList:(NSArray *)cityList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [cityList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KeyCityDTO *dto = [KeyCityDTO new];
            [dto processDBDataToObjectWithDBData:obj];
            [dtoList addObject:dto];
        }];
        return dtoList;
    }
    
}

- (NSDictionary *)processObjectToDBData {
    
    return @{kResultKeyID:_cityID,
             kResultKeyName:_cityName,
             kResultKeyNamePY:_cityNamePY,
             kResultKeySortedKey:_sortedKey};
    
}

- (void)processDataToObjectWithCityData:(NSDictionary *)cityData {
    if (cityData) {
        _dbUID = nil;        
        
        /**
         *  城市ID
         */
        NSString *cityID = cityData[kResultKeyID];
        if (!cityID||[cityID isKindOfClass:NSNull.class]) {
            _cityID = @(0);
        }else {
            _cityID = @(cityID.longLongValue);
        }
        
        /**
         *  城市名
         */
        NSString *cityName = cityData[kResultKeyName];
        if (!cityName||[cityName isKindOfClass:NSNull.class]) {
            _cityName = @"";
        }else {
            _cityName = [cityName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        /**
         *  城市拼音名
         */
        NSString *pinYin = [SupportingClass chineseStringConvertToPinYinStringWithString:_cityName];
        _cityNamePY = pinYin;
        
        /**
         *  城市拼音关键词
         */
        
        _sortedKey = [[pinYin substringToIndex:1] uppercaseString];
        
    }
}

+ (NSArray *)handleDataListFromDBToDTOList:(NSArray *)cityList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [cityList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KeyCityDTO *dto = [KeyCityDTO new];
            [dto processDBDataToObjectWithDBData:obj];
            [dtoList addObject:dto];
        }];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityNamePY" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        return [dtoList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
}

+ (NSArray *)handleDataListToDTOList:(NSArray *)cityList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [cityList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KeyCityDTO *dto = [KeyCityDTO new];
            [dto processDataToObjectWithCityData:obj];
            [dtoList addObject:dto];
        }];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityNamePY" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        return [dtoList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
}

@end
