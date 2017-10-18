//
//  RepairShopSearchResultVC.h
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
@class KeyCityDTO;
#import <UIKit/UIKit.h>

@interface RepairShopSearchResultVC : BaseViewController

@property (nonatomic, strong) NSString *keywordString;

@property (nonatomic, strong) NSString *shopTypeID;

@property (nonatomic, strong) NSString *shopServiceTypeID;

@property (nonatomic, assign) KeyCityDTO *selectedCity;

@property (nonatomic, strong) NSString *diagnosisResultReason;

@end
