//
//  SMSLResultDTO.h
//  cdzer
//
//  Created by KEns0n on 29/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMSLResultDTO : NSObject
//work only on Colletion
@property (nonatomic, readonly) NSString *collectionID;

@property (nonatomic, readonly) NSString *mechanicID;

@property (nonatomic, readonly) NSString *mechanicName;

@property (nonatomic, readonly) NSString *mechanicPortrait;

@property (nonatomic, readonly) NSString *repairShopID;

@property (nonatomic, readonly) NSString *repairShopName;

@property (nonatomic, readonly) NSString *repairShopType;

@property (nonatomic, readonly) NSString *specialism;

@property (nonatomic, readonly) NSString *workingYrs;

@property (nonatomic, readonly) NSString *workingGrade;

@property (nonatomic, readonly) NSString *scorePercentage;

@property (nonatomic, readonly) NSString *currentScore;

@property (nonatomic, readonly) NSString *totalScore;


+ (SMSLResultDTO *)createSMSLResultDataObjectFromSourceData:(NSDictionary *)sourceData;

+ (NSArray <SMSLResultDTO *>*)createSMSLResultDataObjectFromSourceList:(NSArray <NSDictionary *>*)sourceList;

@end
