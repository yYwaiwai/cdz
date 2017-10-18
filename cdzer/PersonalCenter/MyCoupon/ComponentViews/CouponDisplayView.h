//
//  CouponDisplayView.h
//  cdzer
//
//  Created by KEns0n on 11/2/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

typedef NS_ENUM(NSInteger, CouponDisplayType) {
    CouponDisplayTypeOfColor,
    CouponDisplayTypeOfColorWithWasTookImg,
    CouponDisplayTypeOfBlackNWhite,
    CouponDisplayTypeOfBlackNWhiteWithWasTookImg,
    CouponDisplayTypeOfBlackNWhiteWithWasExpiredImg,
};

#import <UIKit/UIKit.h>

@interface CouponDisplayView : UIView

@property (nonatomic, assign) BOOL showCouponStrOnly;

@property (nonatomic, assign) CouponDisplayType displayType;

- (void)setPriceText:(NSString *)priceTxt andContentText:(NSString *)contentTxt;

@end
