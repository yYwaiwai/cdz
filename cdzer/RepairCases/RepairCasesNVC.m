//
//  RepairCasesNVC.m
//  cdzer
//
//  Created by KEns0n on 6/19/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define stepViewBaseTag 700
#define numLogoBaseTag 600
#define labelBaseTag 500
#define cellHeight 40.0f
#define kObjNameKey @"name"
#define kObjIDKey @"id"
#define kObjDictionaryKey @"dictionary"
#define kObjNoteKey @"note"
#define kObjFirstKey @"first"

#import "RepairCasesNVC.h"
#import "RepairCasesComponent.h"
#import "InsetsLabel.h"
#import "RepairCasesResultVC.h"

@interface RepairCasesNVC ()

@property (nonatomic, strong) InternalCaseNav *navVC;

@end

@implementation RepairCasesNVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"get_cases")];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self componentSetting];
    [self setReactiveRules];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(confirmTheResult:) name:CDZNotiKeyOfSDCResult object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)componentSetting {
    
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
        
        InternalCaseVC *vc = InternalCaseVC.new;
        self.navVC = [[InternalCaseNav alloc] initWithRootViewController:vc];
        self.navVC.navigationBarHidden = YES;
        [self.contentView addSubview:_navVC.view];
        
        CGRect frame = self.contentView.bounds;
        self.navVC.view.frame = frame;
        
    }
}

- (void)pushToVehicleSelectedVC {
    [self pushToAutoSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO];
}

- (void)confirmTheResult:(NSNotification *)notifiObject {
    @autoreleasepool {
        if (!notifiObject.userInfo||notifiObject.userInfo.count<3) {
            return;
        }
        NSDictionary *resultDetail = notifiObject.userInfo[CDZKeyOfResultKey];
        NSArray *theIDsList = notifiObject.userInfo[@"theIDsList"];
        NSArray *theTextList = notifiObject.userInfo[@"theTextList"];
        RepairCasesResultVC *sdrVC = [[RepairCasesResultVC alloc] init];
        sdrVC.resultDetail = resultDetail;
        sdrVC.theIDsList = theIDsList;
        sdrVC.theTextList = theTextList;
        [self setNavBarBackButtonTitleOrImage:nil titleColor:nil];
        [self.navigationController pushViewController:sdrVC animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
