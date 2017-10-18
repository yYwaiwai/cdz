//
//  RepairCaseResultDTO.h
//  cdzer
//
//  Created by KEns0n on 23/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepairCaseResultPartDTO : NSObject

@property (nonatomic, readonly) NSString *partName;

@property (nonatomic, readonly) NSUInteger counting;

@property (nonatomic, readonly) NSString *partPrice;

@end


@interface RepairCaseResultDTO : NSObject

@property (nonatomic, readonly) NSString *theCaseID;

@property (nonatomic, readonly) NSString *licensePlate;

@property (nonatomic, readonly) BOOL wasCreateByUser;

@property (nonatomic, readonly) BOOL wasCommented;

@property (nonatomic, readonly) NSString *seriesName;

@property (nonatomic, readonly) NSString *modelName;

@property (nonatomic, readonly) NSString *createDatetime;

@property (nonatomic, readonly) NSString *theCaseReason;

@property (nonatomic, readonly) NSString *workingPrice;

@property (nonatomic, readonly) NSString *workingHrs;

@property (nonatomic, readonly) NSString *repairDateTime;

@property (nonatomic, readonly) NSString *totalPrice;

@property (nonatomic, readonly) NSString *repairShopID;

@property (nonatomic, readonly) NSString *repairShopName;

@property (nonatomic, readonly) NSString *repairShopPhone;

@property (nonatomic, readonly) NSString *repairShopAddress;

@property (nonatomic, readonly) NSArray <RepairCaseResultPartDTO *> *repairPartsList;

@property (nonatomic, readonly) NSString *userPortrait;

@property (nonatomic, readonly) NSString *userName;

@property (nonatomic, readonly) NSString *commentDatetime;

@property (nonatomic, readonly) NSString *commentContent;


@property (nonatomic, assign) BOOL isExpandPriceDetail;

@property (nonatomic, assign) BOOL isExpandCommentDetail;
//评论
@property (nonatomic, readonly) BOOL haveCommentRecord;


+ (RepairCaseResultDTO *)createCaseDataObjectWithCaseSourceData:(NSDictionary *)sourceData;

+ (NSArray <RepairCaseResultDTO *>*)createCaseDataObjectWithCaseSourceList:(NSArray <NSDictionary *>*)sourceList;

@end