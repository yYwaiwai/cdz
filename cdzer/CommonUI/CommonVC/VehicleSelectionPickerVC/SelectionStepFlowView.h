//
//  SelectionStepFlowView.h
//  cdzer
//
//  Created by KEns0n on 3/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
@class UserSelectedAutosInfoDTO;
#import <UIKit/UIKit.h>

@interface SelectionStepFlowView : UIView

@property (nonatomic, readonly) UIButton *arrowBtn1;

@property (nonatomic, readonly) UIButton *arrowBtn2;

@property (nonatomic, readonly) UIButton *arrowBtn3;

@property (nonatomic, readonly) UIButton *arrowBtn4;

@property (nonatomic, strong, readonly) NSNumber *isReady;

@property (nonatomic, strong, readonly) NSNumber *isSelected;

@property (nonatomic, strong, readonly) UserSelectedAutosInfoDTO *autoData;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, assign) BOOL onlyForSelection;

- (void)initializationUI;

- (void)setupUIInfoData;

- (void)deselectedSelf;

- (void)addKeyboardObserve;

- (void)removeKeyboardObserve;

@end
