//
//  OverSpeedSettingView.h
//  cdzer
//
//  Created by KEns0n on 6/5/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverSpeedSettingView : UIControl

- (void)showView;

- (void)setSpeedSwitchValue:(BOOL)value;

- (void)setVoiceSwitchValue:(BOOL)value;

- (void)setLimitSpeed:(NSString *)speedString;

@end
