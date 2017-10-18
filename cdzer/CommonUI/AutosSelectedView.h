//
//  AutosSelectedView.h
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "UserSelectedAutosInfoDTO.h"
#import <UIKit/UIKit.h>

@interface AutosSelectedView : UIControl

- (instancetype)initWithOrigin:(CGPoint)origin showMoreDeatil:(BOOL)moreDetail onlyForSelection:(BOOL)onlyForSelection;

- (void)reloadUIData;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autoData;

@end
