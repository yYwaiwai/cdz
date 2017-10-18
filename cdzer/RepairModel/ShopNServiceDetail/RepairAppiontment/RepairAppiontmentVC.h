//
//  RepairAppiontmentVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
@class SMSLResultDTO;
@interface RepairAppiontmentVC : XIBBaseViewController

@property (nonatomic) BOOL isSpecServiceShop;

@property (nonatomic, strong) SMSLResultDTO *selectedMechanicDetail;

@property (nonatomic, strong) NSDictionary *shopDetail;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *repairSelectedIndexPath;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *maintainSelectedIndexPath;

@end
