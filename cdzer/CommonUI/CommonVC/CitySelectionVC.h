//
//  CitySelectionVC.h
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseViewController.h"
@class KeyCityDTO;
@interface CitySelectionVC : BaseViewController

@property (nonatomic, strong) KeyCityDTO *selectedCity;

@property (nonatomic, assign) BOOL hiddenLocationView;

@property (nonatomic, assign) BOOL selectionWithoutSave;

@end
