//
//  SNSDCouponView.h
//  cdzer
//
//  Created by KEns0nLau on 8/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

typedef void(^SNSDCouponViewDataReloadBlock)();

#import <UIKit/UIKit.h>
@interface SNSDCouponView : UICollectionView

@property (nonatomic, strong) NSArray *couponList;

@property (nonatomic, copy) SNSDCouponViewDataReloadBlock reloadBlock;

@end
