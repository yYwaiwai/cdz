//
//  RepairSectionBtnsView.h
//  cdzer
//
//  Created by KEns0n on 3/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairSectionBtnsView : UIView

- (instancetype)initWithOrigin:(CGPoint)origin;

- (void)setAllButtonTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic, strong) UIButton *quickServiceBtn;

@property (nonatomic, strong) UIButton *searchBtn;

@property (nonatomic, strong) UIButton *diagnosisBtn;

@property (nonatomic, strong) UIButton *careServiceBtn;

@property (nonatomic, strong) UIButton *casesBtn;

@property (nonatomic, strong) UIButton *encyclopediaBtn;
@end
