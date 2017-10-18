//
//  ValidCodeButton.h
//  cdzer
//
//  Created by KEns0n on 7/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef NS_ENUM(NSInteger, VCBType) {
    VCBTypeOfRegisterValid,
    VCBTypeOfPWForgetValid,
    VCBTypeOfOrderCreditValid,
};

#import <UIKit/UIKit.h>

@interface ValidCodeButton : UIButton

@property (readonly, getter=isRequested) BOOL requestedValidCode;

@property (nonatomic, assign) BOOL isReady;

@property (nonatomic, assign) BOOL shouldChangBGColor;

@property (nonatomic, strong) NSNumber *userPhone;

- (void)buttonSettingWithType:(VCBType)buttonType;

@end
