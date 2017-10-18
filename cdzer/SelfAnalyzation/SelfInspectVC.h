//
//  SelfInspectVC.h
//  cdzer
//
//  Created by KEns0n on 16/4/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

static NSString *const CDZNotiKeyOfSDVCResetSelection = @"CDZNotiKeyOfSDVCResetSelection";


#import "XIBBaseViewController.h"

@interface SelfInspectVC : XIBBaseViewController

@property (nonatomic, strong) NSDictionary *repairGuideDetail;

@property (nonatomic, strong) NSString *procedureDetailID;

@property (nonatomic, strong) NSString *titleName;

@property (nonatomic, strong) NSString *reapairItem;

@end
