//
//  ReplacementOfGoodsVC.h
//  cdzer
//
//  Created by 车队长 on 16/10/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//
#import "MaintenanceItemObjectComponent.h"
#import "XIBBaseViewController.h"

typedef void(^ROGSelectedResultBlock)(MaintenanceProductItemDTO *productItemDTO);
@interface ReplacementOfGoodsVC : XIBBaseViewController

@property (nonatomic, strong) MaintenanceProductItemDTO *productItemDTO;

@property (nonatomic, strong) NSString *carModels;

@property (nonatomic, copy) ROGSelectedResultBlock selectedResultBlock;

@end
