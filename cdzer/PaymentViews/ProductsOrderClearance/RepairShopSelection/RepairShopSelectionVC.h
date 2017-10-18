//
//  RepairShopSelectionVC.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void(^RepairShopSelectionBlock)(NSDictionary *selectedShopDetail);

@interface RepairShopSelectionVC : XIBBaseViewController

@property (nonatomic, assign) BOOL isSelectionOnly;

@property (nonatomic, strong) NSArray *selectedMaintainItemList;

@property (nonatomic, strong) NSDictionary *selectedShopDetail;

@property (nonatomic, copy) RepairShopSelectionBlock resultBlock;

@end
