//
//  PCRDataModel.h
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kResultKeyID @"region_id"
#define kResultKeyName @"region_name"
typedef void(^PCRDDMDataUpdateCompleteBlock)();

#import <Foundation/Foundation.h>

@interface PCRDataModel : NSObject

@property (nonatomic, strong, readonly) NSArray *provinceList;

@property (nonatomic, strong, readonly) NSArray *cityList;

@property (nonatomic, strong, readonly) NSArray *regionList;

@property (nonatomic, strong, readonly) NSString *provinceID;

@property (nonatomic, strong, readonly) NSString *cityID;

@property (nonatomic, strong, readonly) NSString *regionID;

@property (nonatomic, readonly) NSUInteger provinceObjIdx;

@property (nonatomic, readonly) NSUInteger cityObjIdx;

@property (nonatomic, readonly) NSUInteger regionObjIdx;

@property (nonatomic, copy) PCRDDMDataUpdateCompleteBlock completeBlock;

- (void)updateProvinceID:(NSString *)provinceID cityID:(NSString *)cityID regionID:(NSString *)regionID;

@end
