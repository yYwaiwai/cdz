//
//  EServicePaymentVC.h
//  cdzer
//
//  Created by KEns0n on 16/4/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "EServiceConfig.h"
@interface EServicePaymentVC : XIBBaseViewController

@property (nonatomic, assign) EServiceType serviceType;

@property (nonatomic, strong) NSString *eServiceID;

@property (nonatomic, strong) NSString *creditsRatio;

@property (nonatomic, assign) BOOL showPushBackLastView;

@end
