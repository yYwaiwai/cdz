//
//  PersonalHistorySelectView.h
//  cdzer
//
//  Created by KEns0n on 5/8/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
@class UserAutosInfoDTO;
#import <UIKit/UIKit.h>


@interface PersonalHistorySelectView : UIControl

@property (nonatomic, strong, readonly) NSNumber *isReady;

@property (nonatomic, strong, readonly) NSNumber *isSelected;

@property (nonatomic, strong, readonly) UserSelectedAutosInfoDTO *autoData;


- (void)initializationUIWasHistoryView:(BOOL)isHistoryView;

- (void)setupUIInfoData;

- (void)deselectedSelf;

- (void)reloadData;
@end
