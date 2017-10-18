//
//  ShopMechanicDetailDTO.h
//  cdzer
//
//  Created by KEns0n on 29/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopMechanicCommentDetailDTO : NSObject

@property (nonatomic, readonly) NSString *userPortrait;

@property (nonatomic, readonly) NSString *userName;

@property (nonatomic, readonly) NSString *commentDatetime;

@property (nonatomic, readonly) NSString *commentContent;

@property (nonatomic, readonly) NSString *commentMarking;

+ (ShopMechanicCommentDetailDTO *)createMechanicCommentDetailFromSourceData:(NSDictionary *)sourceData;

+ (NSArray <ShopMechanicCommentDetailDTO *>*)createMechanicCommentDetailListWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList;

@end

@interface ShopMechanicDetailDTO : NSObject

@property (nonatomic, readonly) NSString *mechanicName;

@property (nonatomic, readonly) NSString *mechanicPortrait;

@property (nonatomic, readonly) NSString *repairShopID;

@property (nonatomic, readonly) NSString *repairShopName;

@property (nonatomic, readonly) NSString *repairShopType;

@property (nonatomic, readonly) NSString *specialism;

@property (nonatomic, readonly) NSString *workingYrs;

@property (nonatomic, readonly) NSString *workingGrade;

@property (nonatomic, readonly) NSString *currentScore;

@property (nonatomic, readonly) NSString *totalScore;

@property (nonatomic, readonly) NSString *scorePercentage;

@property (nonatomic, readonly) NSString *totalCommentAvgValue;

@property (nonatomic, readonly) NSString *totalCommentCount;

@property (nonatomic, assign) BOOL mechanicWasCollected;

@property (nonatomic, readonly) NSArray <ShopMechanicCommentDetailDTO *> *commentDetailList;


+ (ShopMechanicDetailDTO *)createMechanicDetailFromSourceData:(NSDictionary *)sourceData;



@end
