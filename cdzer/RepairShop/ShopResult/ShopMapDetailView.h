//
//  ShopMapDetailView.h
//  iCars
//
//  Created by KEns0n on 6/1/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsLabel.h"
@interface ShopMapDetailView : UIView

@property (strong ,nonatomic) IBOutlet InsetsLabel *shopName;
@property (strong ,nonatomic) IBOutlet InsetsLabel *address;
@property (strong ,nonatomic) IBOutlet UILabel *distance;

#pragma mark -设置维修商信息
- (void)setShopDetailWithData:(NSDictionary *)detail ;

@end
