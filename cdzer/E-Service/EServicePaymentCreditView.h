//
//  EServicePaymentCreditView.h
//  cdzer
//
//  Created by KEns0nLau on 6/14/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ESPaymentCreditViewResponseBlock)();

@interface EServicePaymentCreditView : UIView

@property (nonatomic, readonly) NSString *getVerifyCode;

@property (nonatomic, copy) ESPaymentCreditViewResponseBlock responseBlock;

- (void)showView;

- (IBAction)dismissSelf;

@end
