//
//  SMSLResultDTO.m
//  cdzer
//
//  Created by KEns0n on 29/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMSLResultDTO.h"

@implementation SMSLResultDTO

+ (SMSLResultDTO *)createSMSLResultDataObjectFromSourceData:(NSDictionary *)sourceData {
    SMSLResultDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [SMSLResultDTO new];
        dto->_collectionID = @"";
        dto->_mechanicID = [SupportingClass verifyAndConvertDataToString:sourceData[@"id"]];
        NSString *colMecID = [SupportingClass verifyAndConvertDataToString:sourceData[@"tid"]];
        if (colMecID&&colMecID.length>0&&![colMecID isEqualToString:@""]) {
            dto->_collectionID = dto.mechanicID;
            dto->_mechanicID = colMecID;
        }
        dto->_mechanicName = [SupportingClass verifyAndConvertDataToString:sourceData[@"real_name"]];
        dto->_mechanicPortrait = [SupportingClass verifyAndConvertDataToString:sourceData[@"face_img"]];
        dto->_repairShopID = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_id"]];
        dto->_repairShopName = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_name"]];
        dto->_repairShopType = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_kind"]];
        dto->_specialism = [SupportingClass verifyAndConvertDataToString:sourceData[@"speciality"]];
        dto->_workingYrs = [SupportingClass verifyAndConvertDataToString:sourceData[@"work_age"]];
        dto->_workingGrade = [SupportingClass verifyAndConvertDataToString:sourceData[@"position"]];
        dto->_currentScore = [SupportingClass verifyAndConvertDataToString:sourceData[@"get_score"]];
        dto->_totalScore = [SupportingClass verifyAndConvertDataToString:sourceData[@"total_score"]];
        dto->_scorePercentage = [NSString stringWithFormat:@"%0.2f", dto.currentScore.floatValue/dto.totalScore.floatValue];
    }
    return dto;
}

+ (NSArray <SMSLResultDTO *>*)createSMSLResultDataObjectFromSourceList:(NSArray<NSDictionary *> *)sourceList {
    NSMutableArray *caseList = [@[] mutableCopy];
    if (sourceList.count>0&&sourceList) {
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.count>0) {
                SMSLResultDTO *dto = [SMSLResultDTO createSMSLResultDataObjectFromSourceData:detail];
                if (dto) {
                    [caseList addObject:dto];
                }
            }
        }];
    }
    
    return [NSArray arrayWithArray:caseList];
}


@end
