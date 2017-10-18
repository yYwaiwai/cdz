//
//  SelfDiagnosisVC.m
//  cdzer
//
//  Created by KEns0n on 6/19/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define stepViewBaseTag 700
#define numLogoBaseTag 600
#define labelBaseTag 500
#define cellHeight 40.0f
#define kTypeKey(typeID) (typeID==0)?@"live_describe":@"major_describe"
#define kObjNameKey @"name"
#define kObjIDKey @"id"
#define kObjParentIDKey @"parent_id"
#define kSelectedIdxKey @"idx"
#define kSelectedStringKey @"string"
#define kConfigTitleKey @"title"


#import "SelfDiagnosisVC.h"
#import "AutosSelectedView.h"
#import "InsetsLabel.h"
#import "SelfDiagnosisResultVC.h"
#import "SelfDiagnosisCell.h"
#import "SelfDiagnosisComponent.h"
#import "RepairGudieProcedureVC.h"
#import "SelfInspectVC.h"

@interface SelfDiagnosisVC ()
@property (nonatomic, strong) UIImageView *bannerView;

@property (nonatomic, strong) InternalDiagnosisNav *navVC;
@end

@implementation SelfDiagnosisVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"self_analyzation")];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resetAllSelection) name:CDZNotiKeyOfSDVCResetSelection object:nil];
    
    [self componentSetting];
    [self setReactiveRules];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(confirmTheResult:) name:CDZNotiKeyOfSDCResult object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(goToPepairGuide:) name:CDZNotiKeyOfRepairGuideResult object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(goToNextStep:) name:CDZNotiKeyOfNextDiagnosisResult object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:CDZNotiKeyOfSDCResult object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:CDZNotiKeyOfRepairGuideResult object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:CDZNotiKeyOfNextDiagnosisResult object:nil];
}

- (void)componentSetting {
    
}

- (void)resetAllSelection {
    [self.navVC popToRootViewControllerAnimated:YES];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, navVC.ASView) subscribeNext:^(AutosSelectedView *ASView) {
        @strongify(self);
        if (ASView) {
            [ASView removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
            [ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGRect bannerRect = CGRectZero;
        UIImage *bannerImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"self_test" type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                           offsetRatioForP4:1.0f needToUpdate:YES];
        bannerRect.origin.y = (IS_IPHONE_4_OR_LESS)?(-10.0f):0.0f;
        bannerRect.size = bannerImage.size;
        self.bannerView = [[UIImageView alloc] initWithFrame:bannerRect];
        [_bannerView setImage:bannerImage];
        [self.contentView addSubview:_bannerView];
        
        InternalDiagnosisVC *vc = InternalDiagnosisVC.new;
        vc.stepIndex = SelfDiagnosisStepOne;
        self.navVC = [[InternalDiagnosisNav alloc] initWithRootViewController:vc];
        self.navVC.navigationBarHidden = YES;
        [self.contentView addSubview:_navVC.view];
        
        CGRect frame = CGRectMake(0.0f, CGRectGetMaxY(_bannerView.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_bannerView.frame));
        self.navVC.view.frame = frame;
        
    }
}

- (void)pushToVehicleSelectedVC {
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO andSelectionResultBlock:nil];
}

- (void)confirmTheResult:(NSNotification *)notifiObject {
    @autoreleasepool {
        if (!notifiObject.userInfo||!notifiObject.userInfo[CDZKeyOfResultKey]) {
            return;
        }
        SelfDiagnosisResultVC *sdrVC = [[SelfDiagnosisResultVC alloc] init];
        sdrVC.resultData = notifiObject.userInfo[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:sdrVC animated:YES];
    }
}

- (void)goToPepairGuide:(NSNotification *)notifiObject {
    @autoreleasepool {
        if (!notifiObject.userInfo||!notifiObject.userInfo[CDZKeyOfResultKey]) {
            return;
        }
        NSDictionary *procedureDetail = notifiObject.userInfo[CDZKeyOfResultKey];
        NSString *title = notifiObject.userInfo[@"title"];
        RepairGudieProcedureVC *vc = [RepairGudieProcedureVC new];
        vc.procedureDetail = procedureDetail;
        vc.title = title;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goToNextStep:(NSNotification *)notifiObject {
    @autoreleasepool {
        if (!notifiObject.userInfo||!notifiObject.userInfo[CDZKeyOfResultKey]) {
            return;
        }
        NSDictionary *repairGuideDetail = notifiObject.userInfo[CDZKeyOfResultKey];
        NSString *procedureDetailID = notifiObject.userInfo[@"procedureID"];
        NSString *title = notifiObject.userInfo[@"title"];
        SelfInspectVC *vc = [SelfInspectVC new];
        vc.repairGuideDetail = repairGuideDetail;
        vc.procedureDetailID = procedureDetailID;
        vc.title = @"继续检查";
        vc.titleName = title;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end


