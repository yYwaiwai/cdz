//
//  PositionErrorCorrectionVC.h
//  cdzer
//
//  Created by 车队长 on 16/12/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface PositionErrorCorrectionVC : XIBBaseViewController


@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSNumber *latitude;

@property (nonatomic, strong) NSNumber *longitude;

//@property (nonatomic, strong) BMKReverseGeoCodeResult *reverseGeoCodeResult;

@end
