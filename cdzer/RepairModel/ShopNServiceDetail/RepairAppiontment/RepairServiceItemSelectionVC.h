//
//  RepairServiceItemSelectionVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/19/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
@class SMSLResultDTO;
typedef void(^RepairServiceItemSelectionResultBlock)(NSMutableSet <NSIndexPath *> *repairSelectedIndexPath, NSMutableSet <NSIndexPath *> *maintainSelectedIndexPath);
@interface RepairServiceItemSelectionVC : XIBBaseViewController

@property (nonatomic) BOOL isSpecServiceShop;

@property (nonatomic, strong) NSDictionary *shopDetail;

@property (nonatomic, strong) SMSLResultDTO *selectedMechanicDetail;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *repairSelectedIndexPath;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *maintainSelectedIndexPath;

@property (nonatomic, copy) RepairServiceItemSelectionResultBlock resultBlock;

@end
