//
//  RepairShopSearchResultVC.h
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef void (^RSSResultBlock)(NSString *shopID, NSString *shopName);

@class KeyCityDTO;

#import "XIBBaseViewController.h"

@interface RepairShopSearchResultVC : XIBBaseViewController

@property (nonatomic, assign) BOOL wasSelectionMode;

@property (nonatomic, strong) NSString *keywordString;

@property (nonatomic, strong) NSString *shopTypeID;

@property (nonatomic, strong) NSString *shopServiceTypeID;

@property (nonatomic, assign) KeyCityDTO *selectedCity;

@property (nonatomic, strong) NSString *diagnosisResultReason;

@property (nonatomic, copy) RSSResultBlock resultBlock;

@end
