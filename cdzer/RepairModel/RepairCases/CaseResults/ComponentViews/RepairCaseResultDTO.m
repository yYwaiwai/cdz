//
//  RepairCaseResultDTO.m
//  cdzer
//
//  Created by KEns0n on 23/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairCaseResultDTO.h"


@implementation RepairCaseResultPartDTO

+ (NSArray <RepairCaseResultPartDTO*> *)createPartsDataObjectWithPartSourceList:(NSArray <NSDictionary*> *)partSourceList {
    NSMutableArray *partList = [@[] mutableCopy];
    if (partSourceList.count>0&&partSourceList) {
        [partSourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.count>0) {
                RepairCaseResultPartDTO *dto = [RepairCaseResultPartDTO new];
                dto->_partName = [SupportingClass verifyAndConvertDataToString:detail[@"name"]];
                dto->_counting = [SupportingClass verifyAndConvertDataToNumber:detail[@"num"]].unsignedIntegerValue;
                dto->_partPrice = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
                [partList addObject:dto];
            }
        }];
    }
    
    return [NSArray arrayWithArray:partList];
}

@end

@implementation RepairCaseResultDTO

+ (RepairCaseResultDTO *)createCaseDataObjectWithCaseSourceData:(NSDictionary *)sourceData {
    RepairCaseResultDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [RepairCaseResultDTO new];
        dto->_theCaseID = [SupportingClass verifyAndConvertDataToString:sourceData[@"id"]];
        dto->_licensePlate = [SupportingClass verifyAndConvertDataToString:sourceData[@"car_number"]];
        dto->_wasCreateByUser = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"tag"]].boolValue;
        dto->_wasCommented = [[SupportingClass verifyAndConvertDataToString:sourceData[@"if_comment"]] isContainsString:@"yes"];
        dto->_seriesName = [SupportingClass verifyAndConvertDataToString:sourceData[@"fct_name"]];
        dto->_modelName = [SupportingClass verifyAndConvertDataToString:sourceData[@"speci_name"]];
        dto->_createDatetime = [SupportingClass verifyAndConvertDataToString:sourceData[@"create_time"]];
        dto->_theCaseReason = [SupportingClass verifyAndConvertDataToString:sourceData[@"project"]];
        dto->_workingPrice = [SupportingClass verifyAndConvertDataToString:sourceData[@"man_fee"]];
        dto->_workingHrs = [SupportingClass verifyAndConvertDataToString:sourceData[@"man_hour"]];
        dto->_repairDateTime = [SupportingClass verifyAndConvertDataToString:sourceData[@"add_time"]];
        dto->_totalPrice = [SupportingClass verifyAndConvertDataToString:sourceData[@"fee"]];
        dto->_repairShopID = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_id"]];
        dto->_repairShopName = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_name"]];
        dto->_repairShopPhone = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_tel"]];
        dto->_repairShopAddress = [SupportingClass verifyAndConvertDataToString:sourceData[@"address"]];
        dto->_repairPartsList = [RepairCaseResultPartDTO createPartsDataObjectWithPartSourceList:sourceData[@"part_info"]];
        //评论
        NSDictionary *commentInfo = sourceData[@"comment_info"];
        dto->_haveCommentRecord = NO;
        if (commentInfo&&commentInfo.count>0) {
            dto->_haveCommentRecord = YES;
            dto->_userPortrait = [SupportingClass verifyAndConvertDataToString:commentInfo[@"face_img"]];
            dto->_userName = [SupportingClass verifyAndConvertDataToString:commentInfo[@"user_name"]];
            dto->_commentDatetime = [SupportingClass verifyAndConvertDataToString:commentInfo[@"addtime"]];
            dto->_commentContent = [SupportingClass verifyAndConvertDataToString:commentInfo[@"content"]];
        }
        
        dto.isExpandPriceDetail = NO;
        dto.isExpandCommentDetail = NO;
    }
    return dto;
}

+ (NSArray <RepairCaseResultDTO *>*)createCaseDataObjectWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList {
    NSMutableArray *caseList = [@[] mutableCopy];
    if (sourceList.count>0&&sourceList) {
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.count>0) {
                RepairCaseResultDTO *dto = [RepairCaseResultDTO createCaseDataObjectWithCaseSourceData:detail];
                if (dto) {
                    [caseList addObject:dto];
                }
            }
        }];
    }
    
    return [NSArray arrayWithArray:caseList];
}

@end

