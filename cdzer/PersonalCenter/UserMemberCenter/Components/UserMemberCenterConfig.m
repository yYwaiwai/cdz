//
//  UserMemberCenterConfig.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UserMemberCenterConfig.h"

@implementation UserMemberCenterConfig

+ (UserMemberType)getMemberTypeByString:(NSString *)memberString {
    UserMemberType memberType = UserMemberTypeOfNone;
    if (memberString) {
        if ([memberString isContainsString:@"铜牌"]) {
            memberType = UserMemberTypeOfBronzeMedal;
        }else if ([memberString isContainsString:@"银牌"]) {
            memberType = UserMemberTypeOfSilverMedal;
        }else if ([memberString isContainsString:@"金牌"]) {
            memberType = UserMemberTypeOfGoldMedal;
        }else if ([memberString isContainsString:@"白金"]||[memberString isContainsString:@"铂金"]) {
            memberType = UserMemberTypeOfPlatinum;
            if ([memberString isContainsString:@"审核"]) {
                memberType = UserMemberTypeOfGoldMedal;
            }
        }else if ([memberString isContainsString:@"钻石"]) {
            memberType = UserMemberTypeOfDiamond;
            if ([memberString isContainsString:@"审核"]) {
                memberType = UserMemberTypeOfGoldMedal;
            }
        }
    }
    return memberType;
}

+ (NSString *)getMemberTypeNameByType:(UserMemberType)memberType {
    NSString *memberName = @"";
    switch (memberType) {
        case UserMemberTypeOfBronzeMedal:
            memberName = @"铜牌会员";
            break;
        case UserMemberTypeOfSilverMedal:
            memberName = @"银牌会员";
            break;
        case UserMemberTypeOfGoldMedal:
            memberName = @"金牌会员";
            break;
        case UserMemberTypeOfPlatinum:
            memberName = @"白金会员";
            break;
        case UserMemberTypeOfDiamond:
            memberName = @"钻石会员";
            break;
            
        default:
            break;
    }
    return memberName;
}


+ (UIImage *)getMemberStateImageByType:(UserMemberType)memberType wasInReview:(BOOL)inReview {
    UIImage *image = nil;
    if (memberType!=UserMemberTypeOfNone) {
        NSString *typeName = @"";
        NSString *reviewTypeName = inReview?@"member_in_review_state":@"member_state";
        switch (memberType) {
            case UserMemberTypeOfBronzeMedal:
                typeName = @"bronze_medal";
                break;
            case UserMemberTypeOfSilverMedal:
                typeName = @"silver_medal";
                break;
            case UserMemberTypeOfGoldMedal:
                typeName = @"gold_medal";
                break;
            case UserMemberTypeOfPlatinum:
                typeName = @"platinum";
                break;
            case UserMemberTypeOfDiamond:
                typeName = @"diamond";
                break;
                
            default:
                break;
        }
        NSString *imageName = [NSString stringWithFormat:@"umc_%@_%@_icon@3x",reviewTypeName, typeName];
        image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageName ofType:@"png"]];
    }
    return image;
}

@end

@implementation UMHDataModel

- (void)setContent:(NSString *)content {
    _content = content;
}

- (void)setDatatime:(NSString *)datatime {
    _datatime = datatime;
}

- (void)setCurrentGradeContent:(NSString *)currentGradeContent {
    _currentGradeContent = currentGradeContent;
}

- (void)setWasDowngrade:(BOOL)wasDowngrade {
    _wasDowngrade = wasDowngrade;
}

+ (UMHDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail {
    UMHDataModel *dataModel = nil;
    if (sourceDetail&&sourceDetail.count>0) {
        dataModel = [UMHDataModel new];
        dataModel.content = sourceDetail[@"reason"];
        dataModel.datatime = sourceDetail[@"update_date"];
        dataModel.currentGradeContent = sourceDetail[@"remark"];
//        dataModel.wasDowngrade = [sourceDetail[@""] boolValue];
    }
    return dataModel;
}

+ (NSMutableArray <UMHDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList {
    NSMutableArray <UMHDataModel *> *dataList = nil;
    if (sourceList&&[sourceList isKindOfClass:NSArray.class]&&sourceList.count>0) {
        dataList = [@[] mutableCopy];
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull sourceDetail, NSUInteger idx, BOOL * _Nonnull stop) {
            UMHDataModel *dataModel = [self createDataModelWithSourceDetail:sourceDetail];
            if (dataModel) {
                [dataList addObject:dataModel];
            }
        }];
    }
    return dataList;
}


@end


@implementation MDRDataModel

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setContent:(NSString *)content {
    _content = content;
}

- (void)setIconURL:(NSString *)iconURL {
    _iconURL = iconURL;
}

+ (MDRDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail {
    MDRDataModel *dataModel = nil;
    if (sourceDetail&&sourceDetail.count>0) {
        dataModel = [MDRDataModel new];
        dataModel.title = sourceDetail[@"right"];
        dataModel.content = sourceDetail[@"detail_info"];
        dataModel.iconURL = sourceDetail[@"img"];
    }
    return dataModel;
}

+ (NSMutableArray <MDRDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList {
    NSMutableArray <MDRDataModel *> *dataList = nil;
    if (sourceList&&[sourceList isKindOfClass:NSArray.class]&&sourceList.count>0) {
        dataList = [@[] mutableCopy];
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull sourceDetail, NSUInteger idx, BOOL * _Nonnull stop) {
            MDRDataModel *dataModel = [self createDataModelWithSourceDetail:sourceDetail];
            if (dataModel) {
                [dataList addObject:dataModel];
            }
        }];
    }
    return dataList;
}

@end

@implementation UMTDataModel

- (void)setMemberTypeID:(NSString *)memberTypeID {
    _memberTypeID = memberTypeID;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setContent:(NSString *)content {
    _content = content;
}

- (void)setIconURL:(NSString *)iconURL {
    _iconURL = iconURL;
}

+ (UMTDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail {
    UMTDataModel *dataModel = nil;
    if (sourceDetail&&sourceDetail.count>0) {
        dataModel = [UMTDataModel new];
        dataModel.memberTypeID = [SupportingClass verifyAndConvertDataToString:sourceDetail[@"id"]];
        dataModel.title = sourceDetail[@"name"];
        dataModel.content = sourceDetail[@"rights"];
        dataModel.iconURL = sourceDetail[@"img"];
    }
    return dataModel;
}


+ (NSMutableArray <UMTDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList {
    NSMutableArray <UMTDataModel *> *dataList = nil;
    if (sourceList&&[sourceList isKindOfClass:NSArray.class]&&sourceList.count>0) {
        dataList = [@[] mutableCopy];
        [sourceList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull sourceDetail, NSUInteger idx, BOOL * _Nonnull stop) {
            UMTDataModel *dataModel = [self createDataModelWithSourceDetail:sourceDetail];
            if (dataModel) {
                [dataList addObject:dataModel];
            }
        }];
    }
    return dataList;
}

@end