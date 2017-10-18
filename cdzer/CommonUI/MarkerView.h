//
//  MarkerView.h
//  cdzer
//
//  Created by KEns0n on 1/8/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerView : UIView

@property (nonatomic, strong) NSString *title;

- (instancetype)initWithTitle:(NSString *)title withFrame:(CGRect)frame;

- (void)showFailWarningView;

- (void)showFailWarningRedView;

- (void)showSuccessWarningView;

- (void)showSuccessWarningSkyGreenView;

- (void)showNormalView;

- (void)showNormalViewWithColor:(UIColor *)color;

- (void)showSelected;

@end
