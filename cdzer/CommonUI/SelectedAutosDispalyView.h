//
//  SelectedAutosDispalyView.h
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserSelectedAutosInfoDTO;
@interface SelectedAutosDispalyView : UIControl

- (void)reloadUIData;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autoData;

@end
