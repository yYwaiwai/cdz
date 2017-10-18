//
//  ShopMechanicDetailVC.h
//  cdzer
//
//  Created by KEns0n on 16/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "ShopMechanicDetailDTO.h"
@class SMSLResultDTO;
typedef void(^SMSLSelectedResultBlock)(SMSLResultDTO *selectedMechanicDetail);
@interface ShopMechanicDetailVC : XIBBaseViewController

@property (nonatomic, strong) NSString *mechanicID;

@property (nonatomic, strong) ShopMechanicDetailDTO *detailData;

@property (nonatomic, assign) BOOL onlyForSelection;

@property (nonatomic, strong) SMSLResultDTO *selectedMechanicDetail;

@property (nonatomic, copy) SMSLSelectedResultBlock resultBlock;

@end
