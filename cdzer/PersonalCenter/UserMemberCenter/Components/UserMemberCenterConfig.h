//
//  UserMemberCenterConfig.h
//  cdzer
//
//  Created by KEns0n on 27/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UserMemberType) {
    UserMemberTypeOfNone = 0,
    UserMemberTypeOfBronzeMedal,
    UserMemberTypeOfSilverMedal,
    UserMemberTypeOfGoldMedal,
    UserMemberTypeOfPlatinum,
    UserMemberTypeOfDiamond,
};

@interface UserMemberCenterConfig : NSObject

+ (UserMemberType)getMemberTypeByString:(NSString *)memberString;

+ (NSString *)getMemberTypeNameByType:(UserMemberType)memberType;

+ (UIImage *)getMemberStateImageByType:(UserMemberType)memberType wasInReview:(BOOL)inReview;

@end



@interface UMHDataModel : NSObject

@property (nonatomic, strong, readonly) NSString *content;

@property (nonatomic, strong, readonly) NSString *datatime;

@property (nonatomic, strong, readonly) NSString *currentGradeContent;

@property (nonatomic, assign, readonly) BOOL wasDowngrade;

@property (nonatomic) BOOL isLastRow;

+ (UMHDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail;

+ (NSMutableArray <UMHDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList;

@end


@interface MDRDataModel : NSObject

@property (nonatomic, strong, readonly) NSString *title;

@property (nonatomic, strong, readonly) NSString *content;

@property (nonatomic, strong, readonly) NSString *iconURL;

+ (MDRDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail;

+ (NSMutableArray <MDRDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList;

@end


@interface UMTDataModel : NSObject

@property (nonatomic, strong, readonly) NSString *memberTypeID;

@property (nonatomic, strong, readonly) NSString *title;

@property (nonatomic, strong, readonly) NSString *content;

@property (nonatomic, strong, readonly) NSString *iconURL;

+ (UMTDataModel *)createDataModelWithSourceDetail:(NSDictionary *)sourceDetail;

+ (NSMutableArray <UMTDataModel *> *)createDataModelWithSourceList:(NSArray *)sourceList;

@end




