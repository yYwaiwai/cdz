//
//  UserAutosInfoDTO.h
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseDataToObject.h"

@interface UserAutosInfoDTO : BaseDataToObject

@property (nonatomic, readonly) NSNumber *dbUID;

@property (nonatomic, readonly) NSString *uid;

@property (nonatomic, readonly) NSString *autosUID;

@property (nonatomic, strong) NSString *licensePlate;

@property (nonatomic, strong) NSString *brandName;

@property (nonatomic, strong) NSString *brandImgURL;

@property (nonatomic, strong) NSString *dealershipName;

@property (nonatomic, strong) NSString *seriesName;

@property (nonatomic, strong) NSString *modelName;

@property (nonatomic, strong) NSString *brandID;

@property (nonatomic, strong) NSString *dealershipID;

@property (nonatomic, strong) NSString *seriesID;

@property (nonatomic, strong) NSString *modelID;

@property (nonatomic, strong) NSString *gpsID;

@property (nonatomic, strong) NSString *bodyColor;

@property (nonatomic, strong) NSString *mileage;

@property (nonatomic, strong) NSString *insureTime;

@property (nonatomic, strong) NSString *annualTime;

@property (nonatomic, strong) NSString *maintainTime;

@property (nonatomic, strong) NSString *registrTime;

@property (nonatomic, strong) NSString *frameNumber;

@property (nonatomic, strong) NSString *engineCode;

@property (nonatomic, strong) NSString *tireDefaultSpec;


- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbSourcesData;

- (NSDictionary *)processObjectToDBData;

- (void)processDataToObject:(NSDictionary *)sourcesData optionWithUID:(NSString *)uid;

@end
