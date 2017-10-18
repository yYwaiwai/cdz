//
//  HVLocationRemarkVC.h
//  cdzer
//
//  Created by KEns0n on 1/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "BaseViewController.h"
#import "UserLocationHandler.h"

@interface HVLocationRemarkVC : BaseViewController

@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSNumber *latitude;

@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) BMKReverseGeoCodeResult *reverseGeoCodeResult;
@end
