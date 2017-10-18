//
//  ShopMechanicSearchListVC.h
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "ShopMechanicDetailVC.h"
@class SMSLResultDTO;
@interface ShopMechanicSearchListVC : XIBBaseViewController

@property (nonatomic, strong) NSString *repairShopID;

@property (nonatomic, assign) BOOL onlyForSelection;

@property (nonatomic, assign) BOOL showShopSearchBtn;

@property (nonatomic, strong) SMSLResultDTO *selectedMechanicDetail;

@property (nonatomic, copy) SMSLSelectedResultBlock resultBlock;

@property (nonatomic, strong) NSString *fromStr;

@end
