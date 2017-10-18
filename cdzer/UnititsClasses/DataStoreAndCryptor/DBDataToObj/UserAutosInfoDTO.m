//
//  UserAutosInfoDTO.m
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "UserAutosInfoDTO.h"
//UserAutosInfoDTO 用户汽车消息 详细的试验目的
@interface UserAutosInfoDTO ()
{
    NSNumber *_dbUID;
    NSString *_uid;
    NSString *_autosUID;
}
@end

@implementation UserAutosInfoDTO
- (instancetype)init {
    self = [super init];
    if (self) {
        _dbUID = @0;
        _uid = @"";
        _autosUID = @"";
        self.licensePlate = @"";
        self.brandName = @"";
        self.brandImgURL = @"";
        self.dealershipName = @"";
        self.seriesName = @"";
        self.modelName = @"";
        self.brandID = @"";
        self.dealershipID = @"";
        self.seriesID = @"";
        self.modelID = @"";
        self.gpsID = @"";
        self.bodyColor = @"";
        self.insureTime = @"";
        self.annualTime = @"";
        self.maintainTime = @"";
        self.registrTime = @"";
        self.frameNumber = @"";
        self.engineCode = @"";
        self.tireDefaultSpec = @"";
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

//process 处理；加工 数据库
- (void)processDBDataToObjectWithDBData:(NSDictionary *)dbSourcesData {
    if (dbSourcesData) {
        NSString *dbUID = dbSourcesData[@"db_uid"];
        if (!dbUID ||[dbUID  isKindOfClass:NSNull.class]) {
            _dbUID = @0;
        }else {
            _dbUID = @(dbUID.longLongValue) ;
        }
        
        NSString *uid = dbSourcesData[@"uid"];
        if (!uid||[uid isKindOfClass:NSNull.class]) {
            _uid = @"";
        }else {
            _uid = uid;
        }
        
        NSString *autosUID = dbSourcesData[@"id"];
        if (!autosUID||[autosUID isKindOfClass:NSNull.class]) {
            _autosUID = @"";
        }else {
            _autosUID = autosUID;
        }
        
        NSString *licensePlate = dbSourcesData[@"car_number"];
        if (!licensePlate||[licensePlate isKindOfClass:NSNull.class]) {
            self.licensePlate = @"";
        }else {
            self.licensePlate = licensePlate;
        }
        
        NSString *brandName = dbSourcesData[@"brand_name"];
        if (!brandName||[brandName isKindOfClass:NSNull.class]) {
            self.brandName = @"";
        }else {
            self.brandName = brandName;
        }
        
        NSString *brandImgURL = dbSourcesData[@"brand_img"];
        if (!brandImgURL||[brandImgURL isKindOfClass:NSNull.class]) {
            self.brandImgURL = @"";
        }else {
            self.brandImgURL = brandImgURL;
        }
        
        NSString *dealershipName = dbSourcesData[@"factory_name"];
        if (!dealershipName||[dealershipName isKindOfClass:NSNull.class]) {
            self.dealershipName = @"";
        }else {
            self.dealershipName = dealershipName;
        }
        
        NSString *seriesName = dbSourcesData[@"fct_name"];
        if (!seriesName||[seriesName isKindOfClass:NSNull.class]) {
            self.seriesName = @"";
        }else {
            self.seriesName = seriesName;
        }
        
        NSString *modelName = dbSourcesData[@"spec_name"];
        if (!modelName||[modelName isKindOfClass:NSNull.class]) {
            self.modelName = @"";
        }else {
            self.modelName = modelName;
        }
        
        NSString *brandID = dbSourcesData[@"brandId"];
        if (!brandID||[brandID isKindOfClass:NSNull.class]||[brandID isEqualToString:@""]) {
            self.brandID = @"";
        }else {
            self.brandID = [self verifyAndConvertDataToString:brandID];
        }
        
        NSString *dealershipID = dbSourcesData[@"factoryId"];
        if (!dealershipID||[dealershipID isKindOfClass:NSNull.class]||[dealershipID isEqualToString:@""]) {
            self.dealershipID = @"";
        }else {
            self.dealershipID = [self verifyAndConvertDataToString:dealershipID];
        }
        
        NSString *seriesID = dbSourcesData[@"fctId"];
        if (!seriesID||[seriesID isKindOfClass:NSNull.class]||[seriesID isEqualToString:@""]) {
            self.seriesID = @"";
        }else {
            self.seriesID = [self verifyAndConvertDataToString:seriesID];
        }
        
        NSString *modelID = dbSourcesData[@"specId"];
        if (!modelID||[modelID isKindOfClass:NSNull.class]||[modelID isEqualToString:@""]) {
            self.modelID = @"";
        }else {
            self.modelID = [self verifyAndConvertDataToString:modelID];
        }
        
        NSString *gpsID = dbSourcesData[@"imei"];
        if (!gpsID||[gpsID isKindOfClass:NSNull.class]) {
            self.gpsID = @"";
        }else {
            self.gpsID = gpsID;
        }
        
        NSString *bodyColor = dbSourcesData[@"color"];
        if (!bodyColor||[bodyColor isKindOfClass:NSNull.class]) {
            self.bodyColor = @"";
        }else {
            self.bodyColor = bodyColor;
        }
        
        NSString *mileage = dbSourcesData[@"mileage"];
        if (!mileage||[mileage isKindOfClass:NSNull.class]) {
            self.mileage = @"";
        }else {
            self.mileage = mileage;
        }
        
        NSString *insureTime = dbSourcesData[@"insure_time"];
        if (!insureTime||[insureTime isKindOfClass:NSNull.class]) {
            self.insureTime = @"";
        }else {
            self.insureTime = insureTime;
        }
        
        NSString *annualTime = dbSourcesData[@"annual_time"];
        if (!annualTime||[annualTime isKindOfClass:NSNull.class]) {
            self.annualTime = @"";
        }else {
            self.annualTime = annualTime;
        }
        
        NSString *maintainTime = dbSourcesData[@"maintain_time"];
        if (!maintainTime||[maintainTime isKindOfClass:NSNull.class]) {
            self.maintainTime = @"";
        }else {
            self.maintainTime = maintainTime;
        }
        
        NSString *registrTime = dbSourcesData[@"registr_time"];
        if (!registrTime||[registrTime isKindOfClass:NSNull.class]) {
            self.registrTime = @"";
        }else {
            self.registrTime = registrTime;
        }
        
        NSString *frameNumber = dbSourcesData[@"frame_no"];
        if (!frameNumber||[frameNumber isKindOfClass:NSNull.class]) {
            self.frameNumber = @"";
        }else {
            self.frameNumber = frameNumber;
        }
        
        NSString *engineCode = dbSourcesData[@"engine_code"];
        if (!engineCode||[engineCode isKindOfClass:NSNull.class]) {
            self.engineCode = @"";
        }else {
            self.engineCode = engineCode;
        }
        
        NSString *tireDefaultSpec = dbSourcesData[@"tire_default_spec"];
        if (!tireDefaultSpec||[tireDefaultSpec isKindOfClass:NSNull.class]) {
            self.tireDefaultSpec = @"";
        }else {
            self.tireDefaultSpec = tireDefaultSpec;
        }
    }
}

- (NSDictionary *)processObjectToDBData {
    if (!_uid||[_uid isEqualToString:@""]) {
        return nil;
    }
    
    NSDictionary *dataDetil = @{@"db_uid":_dbUID,
                                @"uid":_uid,
                                @"id":_autosUID,
                                @"car_number":_licensePlate,
                                @"brand_name":_brandName,
                                
                                @"brand_img":_brandImgURL,
                                @"factory_name":_dealershipName,
                                @"fct_name":_seriesName,
                                @"spec_name":_modelName,
                                
                                @"brandId":_brandID,
                                @"factoryId":_dealershipID,
                                @"fctId":_seriesID,
                                @"specId":_modelID,
                                
                                @"imei":_gpsID,
                                @"color":_bodyColor,
                                @"mileage":_mileage,
                                @"insure_time":_insureTime,
                                
                                @"annual_time":_annualTime,
                                @"maintain_time":_maintainTime,
                                @"registr_time":_registrTime,
                                @"frame_no":_frameNumber,
                                @"engine_code":_engineCode,
                                @"tire_default_spec":_tireDefaultSpec};
    return dataDetil;
}

- (void)processDataToObject:(NSDictionary *)sourcesData optionWithUID:(NSString *)uid{
    //    id: "15070310173398838082",
    //    car_number: "",
    //    brand_name: "",
    //    brand_img: "",
    
    //    factory_name: "",
    //    fct_name: "",
    //    spec_name: "",
    //    brandId: "",
    
    //    factoryId: "",
    //    fctId: "",
    //    specId: "",
    //    imei: "",
    
    //    color: "",
    //    mileage: "",
    //    insure_time: "",
    //    annual_time: "",
    
    //    maintain_time: "",
    //    registr_time: "",
    //    frame_no: "",
    //    engine_code: "",
    //    default_model: ""
    
    if (sourcesData&&uid&&![uid isEqualToString:@""]) {
        
        NSString *dbUID = sourcesData[@"id"];
        if (!dbUID ||[dbUID  isKindOfClass:NSNull.class]) {
            _dbUID = @0;
        }else {
            _dbUID = @(dbUID.longLongValue) ;
        }
        
        if (!uid||[uid isKindOfClass:NSNull.class]) {
            _uid = @"";
        }else {
            _uid = uid;
        }
        
        NSString *autosUID = [SupportingClass verifyAndConvertDataToString:sourcesData[@"id"]];
        if (!autosUID||[autosUID isKindOfClass:NSNull.class]) {
            _autosUID = @"";
        }else {
            _autosUID = autosUID;
        }
        
        NSString *licensePlate = sourcesData[@"car_number"];
        if (!licensePlate||[licensePlate isKindOfClass:NSNull.class]) {
            self.licensePlate = @"";
        }else {
            self.licensePlate = licensePlate;
        }
        
        NSString *brandName = sourcesData[@"brand_name"];
        if (!brandName||[brandName isKindOfClass:NSNull.class]) {
            self.brandName = @"";
        }else {
            self.brandName = brandName;
        }
        
        NSString *brandImgURL = sourcesData[@"brand_img"];
        if (!brandImgURL||[brandImgURL isKindOfClass:NSNull.class]) {
            self.brandImgURL = @"";
        }else {
            self.brandImgURL = brandImgURL;
        }
        
        NSString *dealershipName = sourcesData[@"factory_name"];
        if (!dealershipName||[dealershipName isKindOfClass:NSNull.class]) {
            self.dealershipName = @"";
        }else {
            self.dealershipName = dealershipName;
        }
        
        NSString *seriesName = sourcesData[@"fct_name"];
        if (!seriesName||[seriesName isKindOfClass:NSNull.class]) {
            self.seriesName = @"";
        }else {
            self.seriesName = seriesName;
        }
        
        NSString *modelName = sourcesData[@"spec_name"];
        if (!modelName||[modelName isKindOfClass:NSNull.class]) {
            self.modelName = @"";
        }else {
            self.modelName = modelName;
        }
        
        NSString *brandID = [self verifyAndConvertDataToString:sourcesData[@"brandId"]];
        if (!brandID||[brandID isKindOfClass:NSNull.class]||[brandID isEqualToString:@""]) {
            self.brandID = @"";
        }else {
            self.brandID = [self verifyAndConvertDataToString:brandID];
        }
        
        NSString *dealershipID = [self verifyAndConvertDataToString:sourcesData[@"factoryId"]];
        if (!dealershipID||[dealershipID isKindOfClass:NSNull.class]||[dealershipID isEqualToString:@""]) {
            self.dealershipID = @"";
        }else {
            self.dealershipID = [self verifyAndConvertDataToString:dealershipID];
        }
        
        NSString *seriesID = [self verifyAndConvertDataToString:sourcesData[@"fctId"]];
        if (!seriesID||[seriesID isKindOfClass:NSNull.class]||[seriesID isEqualToString:@""]) {
            self.seriesID = @"";
        }else {
            self.seriesID = [self verifyAndConvertDataToString:seriesID];
        }
        
        NSString *modelID = [self verifyAndConvertDataToString:sourcesData[@"specId"]];
        if (!modelID||[modelID isKindOfClass:NSNull.class]||[modelID isEqualToString:@""]) {
            self.modelID = @"";
        }else {
            self.modelID = [self verifyAndConvertDataToString:modelID];
        }
        
        NSString *gpsID = [SupportingClass verifyAndConvertDataToString:sourcesData[@"imei"]];
        if (!gpsID||[gpsID isKindOfClass:NSNull.class]) {
            self.gpsID = @"";
        }else {
            self.gpsID = gpsID;
        }
        
        NSString *bodyColor = sourcesData[@"color"];
        if (!bodyColor||[bodyColor isKindOfClass:NSNull.class]) {
            self.bodyColor = @"";
        }else {
            self.bodyColor = bodyColor;
        }
        
        NSString *mileage = [SupportingClass verifyAndConvertDataToString:sourcesData[@"mileage"]];
        if (!mileage||[mileage isKindOfClass:NSNull.class]) {
            self.mileage = @"";
        }else {
            self.mileage = mileage;
        }
        
        NSString *insureTime = sourcesData[@"insure_time"];
        if (!insureTime||[insureTime isKindOfClass:NSNull.class]) {
            self.insureTime = @"";
        }else {
            self.insureTime = insureTime;
        }
        
        NSString *annualTime = sourcesData[@"annual_time"];
        if (!annualTime||[annualTime isKindOfClass:NSNull.class]) {
            self.annualTime = @"";
        }else {
            self.annualTime = annualTime;
        }
        
        NSString *maintainTime = sourcesData[@"maintain_time"];
        if (!maintainTime||[maintainTime isKindOfClass:NSNull.class]) {
            self.maintainTime = @"";
        }else {
            self.maintainTime = maintainTime;
        }
        
        NSString *registrTime = sourcesData[@"registr_time"];
        if (!registrTime||[registrTime isKindOfClass:NSNull.class]) {
            self.registrTime = @"";
        }else {
            self.registrTime = registrTime;
        }
        
        NSString *frameNumber = [SupportingClass verifyAndConvertDataToString:sourcesData[@"frame_no"]];
        if (!frameNumber||[frameNumber isKindOfClass:NSNull.class]) {
            self.frameNumber = @"";
        }else {
            self.frameNumber = frameNumber;
        }
        
        NSString *engineCode = [SupportingClass verifyAndConvertDataToString:sourcesData[@"engine_code"]];
        if (!engineCode||[engineCode isKindOfClass:NSNull.class]) {
            self.engineCode = @"";
        }else {
            self.engineCode = engineCode;
        }
        
        
        
        NSString *tireDefaultSpec = [SupportingClass verifyAndConvertDataToString:sourcesData[@"default_model"]];
        if (!tireDefaultSpec||[tireDefaultSpec isKindOfClass:NSNull.class]) {
            self.tireDefaultSpec = @"";
        }else {
            self.tireDefaultSpec = tireDefaultSpec;
        }

    }
    
    
    
}

@end
