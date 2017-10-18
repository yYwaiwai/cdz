//
//  RepairShopVC.m
//  cdzer
//
//  Created by KEns0n on 3/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairShopVC.h"
#import "AutosSelectedView.h"
#import "SimpleDisplayView.h"
#import "RetailDirecrtSelecion.h"
#import "RepairShopSearchResultVC.h"
#import "CitySelectionVC.h"
#import "KeyCityDTO.h"
#import "UserLocationHandler.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <GPXParser/GPXParser.h>
#import "AutoUserLocationView.h"

@interface RepairShopVC ()

@property (nonatomic, strong) KeyCityDTO *selectedCity;

@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) AutoUserLocationView *cityLocationView;

@property (nonatomic, strong) SimpleDisplayView *storeNameField;

@property (nonatomic, strong) SimpleDisplayView *shopTypeView;

@property (nonatomic, strong) RetailDirecrtSelecion *retailDirecrtSelectView;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) UIButton *myLocation;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation RepairShopVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = getLocalizationString(@"RepairStore");
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self componentSetting];
    [self initializationUI];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateLocation:) name:CDZNotiKeyOfUpdateLocation object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UserLocationHandler.shareInstance stopUserLocationService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resignTFFirstResponder {
    [_storeNameField textFieldResignFirstResponder];
    [_shopTypeView textFieldResignFirstResponder];
}

- (void)pushToTheAutoSelection {
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO andSelectionResultBlock:nil];
}

- (void)pushToCitySelection {
    [self pushToCitySelectionViewWithBackTitle:nil selectedCity:_selectedCity hiddenLocation:YES onlySelection:YES animated:YES];
}

- (void)componentSetting {
    
    self.selectedCity = UserLocationHandler.getKeyCity;
}

- (void)updateLocation:(NSNotification *)notif {
    KeyCityDTO *dto = (KeyCityDTO *)notif.object;
    if (dto&&[notif.object isKindOfClass:KeyCityDTO.class]) {
        self.selectedCity = dto;
        [_cityLocationView updateSelectedCity:_selectedCity];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        UIImage *rmpImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                fileName:@"retail_mp_image"
                                                                                    type:FMImageTypeOfPNG
                                                                         scaleWithPhone4:NO
                                                                             offsetRatioForP4:1.0f
                                                                            needToUpdate:YES];
        UIImageView *rmpimageView = [[UIImageView alloc]initWithImage:rmpImage];
        [rmpimageView setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), rmpImage.size.height)];
        [self.contentView addSubview:rmpimageView];
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, CGRectGetMaxY(rmpimageView.frame)) showMoreDeatil:NO onlyForSelection:NO];
        [self.contentView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToTheAutoSelection) forControlEvents:UIControlEventTouchUpInside];
        [_ASView addTarget:self action:@selector(resignTFFirstResponder) forControlEvents:UIControlEventTouchUpInside];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        self.toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [_toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(resignTFFirstResponder)];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [_toolBar setItems:buttonsArray];

        self.cityLocationView = [[AutoUserLocationView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_ASView.frame),
                                                                                       CGRectGetWidth(self.contentView.frame),
                                                                                       vAdjustByScreenRatio(46.0f))];
        [_cityLocationView buttonAddTarget:self action:@selector(pushToCitySelection) forControlEvents:UIControlEventTouchUpInside];
        [_cityLocationView updateSelectedCity:_selectedCity];
        [self.contentView addSubview:_cityLocationView];
    
        
        [self setStoreNameField:[SimpleDisplayView new]];
        [_storeNameField setFrame:CGRectMake(0.0f, CGRectGetMaxY(_cityLocationView.frame), CGRectGetWidth(self.contentView.frame), 0.0f)];
        [_storeNameField initializationUIWithType:SDVTypeTextField iConImage:@"store" imageType:FMImageTypeOfPNG placeHolder:@"store_name"];
        [_storeNameField setAccessibilityIdentifierByID:1];
        [self.contentView addSubview:_storeNameField];
        [_storeNameField setTFInputAccessoryView:_toolBar];
        
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        NSArray *typeList = [DBHandler.shareInstance.getRepairShopTypeList valueForKey:@"name"];
        [self setShopTypeView:[SimpleDisplayView new]];
        [_shopTypeView setPickerViewData:typeList];
        [_shopTypeView setFrame:CGRectMake(0.0f, CGRectGetMaxY(_storeNameField.frame), CGRectGetWidth(self.contentView.frame), 0.0f)];
        [_shopTypeView initializationUIWithType:SDVTypePickerView iConImage:@"type" imageType:FMImageTypeOfPNG placeHolder:@"store_type"];
        [_shopTypeView setTFInputAccessoryView:_toolBar];
        [self.contentView addSubview:_shopTypeView];
        
        
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [confirmBtn setBackgroundColor:CDZColorOfDefaultColor];
        [confirmBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [confirmBtn setFrame:CGRectMake(vAdjustByScreenRatio(28.0f),
                                        CGRectGetMaxY(_shopTypeView.frame)+vAdjustByScreenRatio(vO2OSpaceSpace),
                                        CGRectGetWidth(self.contentView.frame)-vAdjustByScreenRatio(28.0f)*2,
                                        vAdjustByScreenRatio(35.0f))];
        [confirmBtn setTitle:getLocalizationString(@"search") forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(resignTFFirstResponder) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn addTarget:self action:@selector(showSearchResult) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:confirmBtn];
        
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        CGFloat offsetY = CGRectGetMaxY(confirmBtn.frame)+vAdjustByScreenRatio(vO2OSpaceSpace);
        self.retailDirecrtSelectView = [[RetailDirecrtSelecion alloc] initWithFrame:CGRectMake(0.0f, offsetY, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-offsetY)];
        [_retailDirecrtSelectView initializationUIWithTarget:self action:@selector(quickSearch:)];
        [self.contentView addSubview:_retailDirecrtSelectView];
        
    }
    
}
- (void)quickSearch:(UIButton *)button {
    @autoreleasepool {
        
        NSArray *list = [DBHandler.shareInstance.getRepairShopServiceTypeList valueForKey:@"id"];
        RepairShopSearchResultVC *vc = [RepairShopSearchResultVC new];
        vc.selectedCity = _selectedCity;
        vc.shopServiceTypeID = list[button.tag];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showSearchResult{
    @autoreleasepool {
        NSString *keywordString = _storeNameField.textString;
        
        RepairShopSearchResultVC *vc = [RepairShopSearchResultVC new];
        vc.selectedCity = _selectedCity;
        vc.keywordString = keywordString;
        vc.shopTypeID = @"";
        if (_shopTypeView.selectedIndex>0) {
            NSArray *list = [DBHandler.shareInstance.getRepairShopTypeList valueForKey:@"id"];
            vc.shopTypeID = list[_shopTypeView.selectedIndex-1];
        }
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
