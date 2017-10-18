//
//  EServiceServiceDetailVC.h
//  cdzer
//
//  Created by KEns0nLau on 6/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface EServiceServiceDetailVC : XIBBaseViewController

@property (nonatomic, assign) EServiceType serviceType;

@property (nonatomic, strong) NSString *eServiceID;

@property (nonatomic, strong) NSDictionary *serviceDetail;

@property (nonatomic, strong) NSString *creditsRatio;


@end
