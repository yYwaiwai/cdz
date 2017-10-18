//
//  EServiceSelectLocationVC.h
//  cdzer
//
//  Created by KEns0nLau on 6/6/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
typedef void(^EServiceSelectLocationResponsBlock)(BMKPoiInfo *addressPoiInfo);
@interface EServiceSelectLocationVC : XIBBaseViewController

@property (nonatomic, copy) EServiceSelectLocationResponsBlock responsBlock;

@end
