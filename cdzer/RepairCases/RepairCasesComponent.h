//
//  RepairCasesComponent.h
//  cdzer
//
//  Created by KEns0n on 11/27/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "BaseViewController.h"
#import "AutosSelectedView.h"
#import "InsetsLabel.h"
#import <UIKit/UIKit.h>

static NSString *const CDZNotiKeyOfSDCResult = @"CDZNotiKeyOfSDCResult";

@interface InternalCaseNav : UINavigationController
@property (nonatomic, strong) AutosSelectedView *ASView;
@property (nonatomic, strong) NSMutableArray *dataLists;
@property (nonatomic, strong) NSMutableArray *selectionStringList;
@property (nonatomic, strong) NSMutableArray *selectionIDList;
@end

@interface InternalCaseVC : BaseViewController

@property (nonatomic, assign) BOOL wasStepTwo;

@end

