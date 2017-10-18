//
//  AutosBrandDTO.m
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "AutosBrandDTO.h"
#define kResultKeyID @"brand_id"
#define kResultKeyImage @"brand_img"
#define kResultKeyName @"brand_name"
#define kResultKeySortedKey @"sorted_key"
@interface AutosBrandDTO ()
{
    NSNumber *_dbUID;
    NSString *_brandID;
    NSString *_brandImg;
    NSString *_brandName;
    NSString *_brandNamePY;
    NSString *_sortedKey;
}

@end

@implementation AutosBrandDTO


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self->_dbUID = @0;
        self->_brandID = @"";
        self->_brandImg = @"";
        self->_brandName = @"";
        self->_sortedKey = @"";
    }
    return self;
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
         *  品牌ID
         */
        NSString *brandID = [SupportingClass verifyAndConvertDataToString:dbData[kResultKeyID]];
        if (!brandID||[brandID isKindOfClass:NSNull.class]) {
            _brandID = @"";
        }else {
            _brandID = brandID;
        }
        
        /**
         *  品牌Logo
         */
        NSString *brandImage = dbData[kResultKeyImage];
        if (!brandImage||[brandImage isKindOfClass:NSNull.class]) {
            _brandImg = @"";
        }else {
            _brandImg = brandImage;
        }
        
        /**
         *  品牌名
         */
        NSString *brandName = dbData[kResultKeyName];
        if (!brandName||[brandName isKindOfClass:NSNull.class]) {
            _brandName = @"";
        }else {
            _brandName = brandName;
        }
        
        
        /**
         *  排序字母
         */
        NSString *sortedKey = dbData[kResultKeySortedKey];
        if (!sortedKey||[sortedKey isKindOfClass:NSNull.class]) {
            _sortedKey = @"#";
        }else {
            _sortedKey = sortedKey;
        }
    }
}

+ (NSArray *)handleDBDataListToDTOList:(NSArray *)brandList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [brandList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AutosBrandDTO *dto = [AutosBrandDTO new];
            [dto processDBDataToObjectWithDBData:obj];
            [dtoList addObject:dto];
        }];
        return dtoList;
    }
    
}

- (NSDictionary *)processObjectToDBData {
    
    return @{kResultKeyID:_brandID,
             kResultKeyImage:_brandImg,
             kResultKeyName:_brandName,
             kResultKeySortedKey:_sortedKey};
    
}

- (void)processDataToObjectWithBrandData:(NSDictionary *)brandData {
    if (brandData) {
        _dbUID = nil;        
        
        /**
         *  品牌ID
         */
        NSString *brandID = [SupportingClass verifyAndConvertDataToString:brandData[@"id"]];
        if (!brandID||[brandID isKindOfClass:NSNull.class]) {
            _brandID = @"";
        }else {
            _brandID = brandID;
        }
        
        
        /**
         *  品牌Logo
         */
        NSString *brandImage = brandData[@"icon"];
        if (!brandImage||[brandImage isKindOfClass:NSNull.class]) {
            _brandImg = @"";
        }else {
            _brandImg = brandImage;
        }
        
        /**
         *  品牌名
         */
        NSString *brandName = brandData[@"name"];
        if (!brandName||[brandName isKindOfClass:NSNull.class]) {
            _brandName = @"";
        }else {
            _brandName = [brandName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        /**
         *  排序字母
         */
        _sortedKey = [brandData[@"letter"] uppercaseString];
        
    }
}

+ (NSArray <AutosBrandDTO *> *)handleDataListFromDBToDTOList:(NSArray *)brandList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [brandList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AutosBrandDTO *dto = [AutosBrandDTO new];
            [dto processDBDataToObjectWithDBData:obj];
            [dtoList addObject:dto];
        }];
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"brandNamePY" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        return dtoList; //[dtoList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
}

+ (NSArray <AutosBrandDTO *> *)handleDataListToDTOList:(NSArray *)brandList {
    @autoreleasepool {
        NSMutableArray *dtoList = [NSMutableArray array];
        [brandList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AutosBrandDTO *dto = [AutosBrandDTO new];
            [dto processDataToObjectWithBrandData:obj];
            [dtoList addObject:dto];
        }];
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"brandNamePY" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        return dtoList;//[dtoList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
}

@end
