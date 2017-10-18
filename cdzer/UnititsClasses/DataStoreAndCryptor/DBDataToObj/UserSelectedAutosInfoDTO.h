//
//  UserSelectedAutosInfoDTO.h
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

@class UserAutosInfoDTO;
#import "BaseDataToObject.h"

@interface UserSelectedAutosInfoDTO : BaseDataToObject

@property (nonatomic, readonly) NSString *dbUID;

@property (nonatomic, assign, readonly) BOOL isSelectFromOnline;

@property (nonatomic, strong) NSString *brandName;

@property (nonatomic, strong) NSString *brandImgURL;

@property (nonatomic, strong) NSString *dealershipName;

@property (nonatomic, strong) NSString *seriesName;

@property (nonatomic, strong) NSString *modelName;

@property (nonatomic, strong) NSString *brandID;

@property (nonatomic, strong) NSString *dealershipID;

@property (nonatomic, strong) NSString *seriesID;

@property (nonatomic, strong) NSString *modelID;

@property (nonatomic, strong) NSString *tireDefaultSpec;

@property (nonatomic, strong) NSString *selectedTireSpec;



- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbSourcesData;

- (NSDictionary *)processObjectToDBData;

- (void)processDataToObjectWithDto:(UserAutosInfoDTO *)userDto;

@end
