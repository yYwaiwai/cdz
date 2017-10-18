//
//  RepairMainVC.m
//  cdzer
//
//  Created by KEns0n on 3/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairMainVC.h"
#import "AutosSelectedView.h"
#import "RepairSectionBtnsView.h"
#import "VehicleSelectionPickerVC.h"

#import "SelfDiagnosisVC.h"
#import "SelfRepairVC.h"
#import "RepairShopVC.h"
//#import "RepairCasesNVC.h"
#import "SelfDiagnosisVC.h"
#import "RepairExpressVC.h"
@interface RepairMainVC ()

@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) RepairSectionBtnsView *rsbView;

@end

@implementation RepairMainVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"iRepair")];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializationUI {
    @autoreleasepool {
//        UIImage *rmpImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
//                                                                                fileName:@"repair_mp_image"
//                                                                                    type:FMImageTypeOfPNG
//                                                                         scaleWithPhone4:NO
//                                                                            needToUpdate:YES];
//        UIImageView *rmpimageView = [[UIImageView alloc]initWithImage:rmpImage];
//        [rmpimageView setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), rmpImage.size.height)];
//        [self.contentView addSubview:rmpimageView];
        
        UIImage *bgImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                               fileName:@"repair_bgimg"
                                                                                   type:FMImageTypeOfJPEG
                                                                        scaleWithPhone4:NO
                                                                            offsetRatioForP4:1.0f
                                                                           needToUpdate:YES];
        [self.view setBackgroundImageByCALayerWithImage:bgImage];
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
        [self.contentView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
        [_ASView setBorderWithColor:nil borderWidth:0.0f];
        
        [self setRsbView:[[RepairSectionBtnsView alloc] initWithOrigin:CGPointMake(0.0f, CGRectGetMaxY(_ASView.frame))]];
        [self.contentView addSubview:_rsbView];
        [_rsbView setAllButtonTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];;
        [_rsbView setBorderWithColor:nil borderWidth:0.0f];
        
        _ASView.backgroundColor = CDZColorOfClearColor;
        _rsbView.backgroundColor = CDZColorOfClearColor;
        self.contentView.backgroundColor = CDZColorOfClearColor;
    }
    
}

- (void)buttonAction:(UIButton *)button {
    @autoreleasepool {
        BaseViewController *vc = nil;
        if ([_rsbView.searchBtn isEqual:button]) {
            vc = [RepairShopVC new];
        }
        if ([_rsbView.careServiceBtn isEqual:button]) {
            vc = [SelfRepairVC new];
        }
        if ([_rsbView.diagnosisBtn isEqual:button]) {
            vc = [SelfDiagnosisVC new];
        }
//        if ([_rsbView.casesBtn isEqual:button]) {
//            vc = [RepairCasesNVC new];
//        }
        if ([_rsbView.quickServiceBtn isEqual:button]) {
            vc = [RepairExpressVC new];
        }
//        if ([_rsbView.encyclopediaBtn isEqual:button]) {
//            vc = [RepairExpressVC new];
//        }
        
        if (vc) {
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


- (void)pushToVehicleSelectedVC {
    @autoreleasepool {
        VehicleSelectionPickerVC *vc = [VehicleSelectionPickerVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
#pragma mark- Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
