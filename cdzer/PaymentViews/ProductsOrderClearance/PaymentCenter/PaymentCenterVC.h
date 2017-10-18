//
//  PaymentCenterVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/26/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "CDZOPCObjectComponents.h"

@interface PaymentCenterVC : XIBBaseViewController

@property (nonatomic, strong) NSDictionary *paymentDetail;

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;

@property (nonatomic, assign) BOOL isUseCredit;

@property (nonatomic, assign) BOOL pushFromDetail;

@end
