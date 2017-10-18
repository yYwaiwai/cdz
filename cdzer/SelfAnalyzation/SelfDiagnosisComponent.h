//
//  SelfDiagnosisComponent.h
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
static NSString *const CDZNotiKeyOfRepairGuideResult = @"CDZNotiKeyOfRepairGuideResult";
static NSString *const CDZNotiKeyOfNextDiagnosisResult = @"CDZNotiKeyOfNextDiagnosisResult";

@interface InternalDiagnosisNav : UINavigationController
@property (nonatomic, strong) AutosSelectedView *ASView;
@property (nonatomic, strong) NSMutableArray *dataLists;
@end

@interface InternalDiagnosisVC : BaseViewController

@property (nonatomic, assign) SelfDiagnosisSelectionStep stepIndex;

@end

