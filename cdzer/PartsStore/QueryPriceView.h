//
//  QueryPriceView.h
//  cdzer
//
//  Created by 车队长 on 16/9/14.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+ShareAction.h"

@interface QueryPriceView : UIView

@property (weak, nonatomic) IBOutlet UIView *xjBgView;

@property (weak, nonatomic) IBOutlet UIView *view1;

@property (weak, nonatomic) IBOutlet UIView *mView;

@property (weak, nonatomic) IBOutlet UIView *fView;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UITextField *cityTF;

@property (weak, nonatomic) IBOutlet UITextField *cgzxTF;

@property (weak, nonatomic) IBOutlet UIButton *cancalButton;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (void)showView;

- (IBAction)hiddenView;
@end
