//
//  MyCaseResultDTO.m
//  cdzer
//
//  Created by KEns0n on 03/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//
#import "MyCaseResultDTO.h"


@implementation MyCasePartDetailDTO

- (instancetype)init {
    if (self=[super init]) {
        self.partName = @"";
        self.counting = @"";
        self.partPrice = @"";
    }
    return self;
}

+ (NSArray <MyCasePartDetailDTO*> *)createPartsDataObjectWithPartSourceList:(NSArray <NSDictionary*> *)partSourceList {
    NSMutableArray *partList = [@[] mutableCopy];
    if (partSourceList.count>0&&partSourceList) {
        [partSourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.count>0) {
                MyCasePartDetailDTO *dto = [MyCasePartDetailDTO new];
                dto->_partName = [dto verifyAndConvertDataToString:detail[@"name"]];
                dto->_counting = [dto verifyAndConvertDataToString:detail[@"num"]];
                dto->_partPrice = [dto verifyAndConvertDataToString:detail[@"price"]];
                [partList addObject:dto];
            }
        }];
    }
    
    return [NSArray arrayWithArray:partList];
}

@end

@implementation MyCaseAutosInfoDTO

+ (MyCaseAutosInfoDTO *)createAutoDataObjectWithCaseSourceData:(NSDictionary *)sourceData {
    MyCaseAutosInfoDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [MyCaseAutosInfoDTO new];
        dto->_brandID = [dto verifyAndConvertDataToString:sourceData[@"brand"]];
        dto->_brandName = [dto verifyAndConvertDataToString:sourceData[@"brand_name"]];
        dto->_brandImgURL = [dto verifyAndConvertDataToString:sourceData[@"brand_img"]];
        dto->_dealershipID = [dto verifyAndConvertDataToString:sourceData[@"factory"]];
        dto->_dealershipName = [dto verifyAndConvertDataToString:sourceData[@"factory_name"]];
        dto->_seriesID = [dto verifyAndConvertDataToString:sourceData[@"fct"]];
        dto->_seriesName = [dto verifyAndConvertDataToString:sourceData[@"fct_name"]];
        dto->_modelID = [dto verifyAndConvertDataToString:sourceData[@"speci"]];
        dto->_modelName = [dto verifyAndConvertDataToString:sourceData[@"speci_name"]];
    }
    return dto;
}

+ (MyCaseAutosInfoDTO *)createAutoDataObjectFromUserSelectedAutosInfoDTO:(UserSelectedAutosInfoDTO *)autosData {
    MyCaseAutosInfoDTO *dto = nil;
    if (autosData) {
        dto = [MyCaseAutosInfoDTO new];
        dto->_brandID = autosData.brandID;
        dto->_brandName = autosData.brandName;
        dto->_brandImgURL = autosData.brandImgURL;
        dto->_dealershipID = autosData.dealershipID;
        dto->_dealershipName = autosData.dealershipName;
        dto->_seriesID = autosData.seriesID;
        dto->_seriesName = autosData.seriesName;
        dto->_modelID = autosData.modelID;
        dto->_modelName = autosData.modelName;
    }
    return dto;
}

@end


@implementation MyCaseResultDTO

+ (MyCaseResultDTO *)createCaseDataObjectWithCaseSourceData:(NSDictionary *)sourceData {
    MyCaseResultDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [MyCaseResultDTO new];
        dto->_theCaseID = [dto verifyAndConvertDataToString:sourceData[@"id"]];
        dto->_licensePlate = [dto verifyAndConvertDataToString:sourceData[@"car_number"]];
        dto->_stateName = [dto verifyAndConvertDataToString:sourceData[@"state_name"]];
        
        NSString *brandID = [dto verifyAndConvertDataToString:sourceData[@"brand"]];
        NSString *dealershipID = [dto verifyAndConvertDataToString:sourceData[@"factory"]];
        NSString *seriesID = [dto verifyAndConvertDataToString:sourceData[@"fct"]];
        NSString *modelID = [dto verifyAndConvertDataToString:sourceData[@"speci"]];
        
        if (brandID&&![brandID isEqualToString:@""]&&dealershipID&&![dealershipID isEqualToString:@""]&&
            seriesID&&![seriesID isEqualToString:@""]&&modelID&&![modelID isEqualToString:@""]) {
            dto->_autosInfo = [MyCaseAutosInfoDTO createAutoDataObjectWithCaseSourceData:sourceData];
        }
        
        dto->_createDatetime = [dto verifyAndConvertDataToString:sourceData[@"create_time"]];
        dto->_theCaseReason = [dto verifyAndConvertDataToString:sourceData[@"project"]];
        dto->_workingPrice = [dto verifyAndConvertDataToString:sourceData[@"man_fee"]];
        dto->_workingHrs = [dto verifyAndConvertDataToString:sourceData[@"man_hour"]];
        dto->_repairDateTime = [dto verifyAndConvertDataToString:sourceData[@"add_time"]];
        dto->_totalPrice = [dto verifyAndConvertDataToString:sourceData[@"fee"]];
        dto->_repairShopID = [dto verifyAndConvertDataToString:sourceData[@"wxs_id"]];
        dto->_repairShopName = [dto verifyAndConvertDataToString:sourceData[@"wxs_name"]];
        dto->_repairShopPhone = [dto verifyAndConvertDataToString:sourceData[@"wxs_tel"]];
        dto->_repairShopAddress = [dto verifyAndConvertDataToString:sourceData[@"address"]];
        dto->_repairPartsList = [MyCasePartDetailDTO createPartsDataObjectWithPartSourceList:sourceData[@"part_info"]];
        
        dto.isExpandPriceDetail = NO;
        dto.isExpandRepairReceiptsDetail = NO;
        dto->_caseRepairReceiptsImg = [dto verifyAndConvertDataToString:sourceData[@"img"]];
        dto->_haveReceiptsDetailRecord = [dto.caseRepairReceiptsImg isContainsString:@"http"];
    }
    return dto;
}

+ (NSArray <MyCaseResultDTO *>*)createCaseDataObjectWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList {
    NSMutableArray *caseList = [@[] mutableCopy];
    if (sourceList.count>0&&sourceList) {
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.count>0) {
                MyCaseResultDTO *dto = [MyCaseResultDTO createCaseDataObjectWithCaseSourceData:detail];
                if (dto) {
                    [caseList addObject:dto];
                }
            }
        }];
    }
    
    return [NSArray arrayWithArray:caseList];
}

@end
