//
//  ShopMechanicDetailDTO.m
//  cdzer
//
//  Created by KEns0n on 29/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicDetailDTO.h"

@implementation ShopMechanicCommentDetailDTO

+ (ShopMechanicCommentDetailDTO *)createMechanicCommentDetailFromSourceData:(NSDictionary *)sourceData {
    ShopMechanicCommentDetailDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [ShopMechanicCommentDetailDTO new];
        dto->_userName = [SupportingClass verifyAndConvertDataToString:sourceData[@"user_name"]];
        dto->_userPortrait = [SupportingClass verifyAndConvertDataToString:sourceData[@"face_img"]];
        dto->_commentDatetime = [SupportingClass verifyAndConvertDataToString:sourceData[@"addtime"]];
        dto->_commentContent = [SupportingClass verifyAndConvertDataToString:sourceData[@"content"]];
        dto->_commentMarking = [SupportingClass verifyAndConvertDataToString:sourceData[@"star"]];
    }
    return dto;
}

+ (NSArray <ShopMechanicCommentDetailDTO *>*)createMechanicCommentDetailListWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList {
    NSMutableArray <ShopMechanicCommentDetailDTO *> *dtoList = [@[] mutableCopy];
    if (sourceList.count>0&&sourceList) {
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            ShopMechanicCommentDetailDTO *dto = [ShopMechanicCommentDetailDTO createMechanicCommentDetailFromSourceData:detail];
            if (dto) {
                [dtoList addObject:dto];
            }
        }];
    }
    return [NSArray arrayWithArray:dtoList];
}
@end

@implementation ShopMechanicDetailDTO
+ (ShopMechanicDetailDTO *)createMechanicDetailFromSourceData:(NSDictionary *)sourceData {
    ShopMechanicDetailDTO *dto = nil;
    if (sourceData.count>0&&sourceData) {
        dto = [ShopMechanicDetailDTO new];
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
        dto->_totalCommentAvgValue = [SupportingClass verifyAndConvertDataToString:sourceData[@"avg_star"]];
        dto->_totalCommentCount = [SupportingClass verifyAndConvertDataToString:sourceData[@"c_size"]];
        dto->_commentDetailList = [ShopMechanicCommentDetailDTO createMechanicCommentDetailListWithCaseSourceList:sourceData[@"comment_info"]];
        dto->_mechanicWasCollected = [[SupportingClass verifyAndConvertDataToString:sourceData[@"is_col"]] isEqualToString:@"yes"];
    }
    return dto;
}

@end
