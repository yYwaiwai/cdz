//
//  UserSelectedAutosInfoDTO.m
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "UserAutosInfoDTO.h"
#import "UserSelectedAutosInfoDTO.h"
@interface UserSelectedAutosInfoDTO ()
{
    NSString *_dbUID;
    BOOL _isSelectFromOnline;
}
@end

@implementation UserSelectedAutosInfoDTO

- (instancetype)init {
    self = [super init];
    if (self) {
        _brandID = nil;
        _dealershipID = nil;
        _seriesID = nil;
        _modelID = nil;
        
        _brandName = @"";
        _brandImgURL = @"";
        _dealershipName = @"";
        _seriesName = @"";
        _modelName = @"";
        _tireDefaultSpec = @"";
        _selectedTireSpec = @"";
    }
    return self;
}

- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbSourcesData {
    if (dbSourcesData) {
        NSString *dbUID = dbSourcesData[@"id"];
        if (!dbUID ||[dbUID  isKindOfClass:NSNull.class]) {
            _dbUID = @"0";
        }else {
            _dbUID = dbUID ;
        }
        
        _isSelectFromOnline = NO;
        if (dbSourcesData[@"select_from_online"]) {
            _isSelectFromOnline = [dbSourcesData[@"select_from_online"] boolValue];
        }
        
        NSString *brandName = dbSourcesData[CDZAutosKeyOfBrandName];
        if (!brandName||[brandName isKindOfClass:NSNull.class]) {
            self.brandName = @"";
        }else {
            self.brandName = brandName;
        }
        
        NSString *brandImgURL = dbSourcesData[CDZAutosKeyOfBrandIcon];
        if (!brandImgURL||[brandImgURL isKindOfClass:NSNull.class]) {
            self.brandImgURL = @"";
        }else {
            self.brandImgURL = brandImgURL;
        }
        
        NSString *dealershipName = dbSourcesData[CDZAutosKeyOfDealershipName];
        if (!dealershipName||[dealershipName isKindOfClass:NSNull.class]) {
            self.dealershipName = @"";
        }else {
            self.dealershipName = dealershipName;
        }
        
        NSString *seriesName = dbSourcesData[CDZAutosKeyOfSeriesName];
        if (!seriesName||[seriesName isKindOfClass:NSNull.class]) {
            self.seriesName = @"";
        }else {
            self.seriesName = seriesName;
        }
        
        NSString *modelName = dbSourcesData[CDZAutosKeyOfModelName];
        if (!modelName||[modelName isKindOfClass:NSNull.class]) {
            self.modelName = @"";
        }else {
            self.modelName = modelName;
        }
        
        NSString *brandID = dbSourcesData[CDZAutosKeyOfBrandID];
        if (!brandID||[brandID isKindOfClass:NSNull.class]||[brandID isEqualToString:@""]) {
            self.brandID = @"";
        }else {
            self.brandID = [self verifyAndConvertDataToString:brandID];
        }
        
        NSString *dealershipID = dbSourcesData[CDZAutosKeyOfDealershipID];
        if (!dealershipID||[dealershipID isKindOfClass:NSNull.class]||[dealershipID isEqualToString:@""]) {
            self.dealershipID = @"";
        }else {
            self.dealershipID = [self verifyAndConvertDataToString:dealershipID];
        }
        
        NSString *seriesID = dbSourcesData[CDZAutosKeyOfSeriesID];
        if (!seriesID||[seriesID isKindOfClass:NSNull.class]||[seriesID isEqualToString:@""]) {
            self.seriesID = @"";
        }else {
            self.seriesID = [self verifyAndConvertDataToString:seriesID];
        }
        
        NSString *modelID = dbSourcesData[CDZAutosKeyOfModelID];
        if (!modelID||[modelID isKindOfClass:NSNull.class]||[modelID isEqualToString:@""]) {
            self.modelID = @"";
        }else {
            self.modelID = [self verifyAndConvertDataToString:modelID];
        }
        
        NSString *tireDefaultSpec = dbSourcesData[CDZAutosKeyOfTireDefaultName];
        if (!tireDefaultSpec||[tireDefaultSpec isKindOfClass:NSNull.class]||[tireDefaultSpec isEqualToString:@""]) {
            self.tireDefaultSpec = @"";
        }else {
            self.tireDefaultSpec = [self verifyAndConvertDataToString:tireDefaultSpec];
        }
        
        
        NSString *selectedTireSpec = dbSourcesData[CDZAutosKeyOfTireDidSelectedName];
        if (!selectedTireSpec||[selectedTireSpec isKindOfClass:NSNull.class]||[selectedTireSpec isEqualToString:@""]) {
            self.selectedTireSpec = @"";
        }else {
            self.selectedTireSpec = [self verifyAndConvertDataToString:selectedTireSpec];
        }
        
    }
}

- (NSDictionary *)processObjectToDBData {
    if (!_dbUID||[_dbUID isEqualToString:@""]) {
        return nil;
    }
    
    NSDictionary *dataDetil = @{@"id":_dbUID,
                                @"select_from_online":@(_isSelectFromOnline),
                                CDZAutosKeyOfBrandName:_brandName,
                                CDZAutosKeyOfBrandIcon:_brandImgURL,
                                CDZAutosKeyOfDealershipName:_dealershipName,
                                CDZAutosKeyOfSeriesName:_seriesName,
                                CDZAutosKeyOfModelName:_modelName,
                                
                                CDZAutosKeyOfBrandID:_brandID,
                                CDZAutosKeyOfDealershipID:_dealershipID,
                                CDZAutosKeyOfSeriesID:_seriesID,
                                CDZAutosKeyOfModelID:_modelID,
                                CDZAutosKeyOfTireDefaultName:_tireDefaultSpec,
                                CDZAutosKeyOfTireDidSelectedName:_selectedTireSpec};
    return dataDetil;
}

- (void)processDataToObjectWithDto:(UserAutosInfoDTO *)userDto {
    if (userDto) {
        _dbUID = userDto.uid;
        _isSelectFromOnline = YES;
        self.brandName = userDto.brandName;
        self.brandID = userDto.brandID;
        self.brandImgURL = userDto.brandImgURL;
        self.dealershipName = userDto.dealershipName;
        self.dealershipID = userDto.dealershipID;
        self.seriesName = userDto.seriesName;
        self.seriesID = userDto.seriesID;
        self.modelName = userDto.modelName;
        self.modelID = userDto.modelID;
        self.tireDefaultSpec = userDto.tireDefaultSpec;
        self.selectedTireSpec = @"";
        if (userDto.tireDefaultSpec&&![userDto.tireDefaultSpec isEqualToString:@""]) {
            self.selectedTireSpec = userDto.tireDefaultSpec;
        }
    }
}

@end
