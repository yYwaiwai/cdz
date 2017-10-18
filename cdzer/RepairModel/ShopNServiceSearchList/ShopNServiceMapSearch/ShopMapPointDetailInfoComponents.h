//
//  ShopMapPointDetailInfoComponents.h
//  cdzer
//
//  Created by KEns0nLau on 9/28/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"
#import <BaiduMapAPI_Map/BMKActionPaopaoView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface ShopMapPointDetailInfoView : UIView

@property (nonatomic, assign) BOOL isTypeOfSpecShop;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *repairBrandLogoIV;

@property (weak, nonatomic) IBOutlet UILabel *mainRepairServiceLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingStarView;

@end


typedef void(^ShopDetailInfoPaopaoViewBtnAction)(NSUInteger objectIdx);
@interface ShopDetailInfoPaopaoView :BMKActionPaopaoView

- (instancetype)initWithSMPDIV;

@property (nonatomic, assign) NSUInteger objectIdx;

@property (nonatomic, readonly) ShopMapPointDetailInfoView *infoView;

@property (nonatomic, copy) ShopDetailInfoPaopaoViewBtnAction btnAction;

@end

@interface ShopInfoPointAnnotation :BMKPointAnnotation

@property (nonatomic, strong) NSString *shopName;

@property (nonatomic, strong) NSString *shopMajorService;

@property (nonatomic, assign) CGFloat starValue;

@property (nonatomic, assign) BOOL isTypeOfSpecShop;

@property (nonatomic, assign) NSUInteger objectIdx;
    
@end

