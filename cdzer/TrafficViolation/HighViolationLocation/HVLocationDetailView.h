//
//  HVLocationDetailView.h
//  iCars
//
//  Created by KEns0n on 6/1/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsLabel.h"
@interface HVLocationDetailView : UIView

@property (strong ,nonatomic) IBOutlet InsetsLabel *vlNumLabel;
@property (strong ,nonatomic) IBOutlet InsetsLabel *address;

@property (weak, nonatomic) IBOutlet UIButton *remarkBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;


@property (nonatomic, strong) NSString *addressStr;

@property (nonatomic, assign) NSNumber *longi;

@property (nonatomic, assign) NSNumber *latit;

@property (nonatomic,strong) UIViewController *owner;

#pragma mark -设置维修商信息
- (void)setShopDetailWithData:(NSDictionary *)detail;

@end
