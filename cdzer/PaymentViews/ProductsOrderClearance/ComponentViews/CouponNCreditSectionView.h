//
//  CouponNCreditSectionView.h
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDZOPCObjectComponents.h"
@interface CouponNCreditSectionView : UIView

@property (nonatomic, readonly) BOOL isActiveAccumulatePoints;

@property (nonatomic, readonly) BOOL isActiveCoupon;

@property (nonatomic, readonly) NSInteger totalAccumulatePoints;

@property (nonatomic, readonly) NSInteger consumedPoints;

@property (nonatomic, readonly) CGFloat totalRemainPrice;

@property (nonatomic, readonly) NSString *verifyCode;

@property (nonatomic, readonly) NSString *selectedCouponAmount;

@property (nonatomic, readonly) NSString *selectedCouponID;

@property (nonatomic, readonly) NSString *selectedCouponDescription;

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;

- (void)updateUIData:(NSDictionary *)sourceData ;

@end
