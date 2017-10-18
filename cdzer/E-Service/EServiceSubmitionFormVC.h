//
//  EServiceSubmitionFormVC.h
//  cdzer
//
//  Created by KEns0nLau on 6/6/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "EServiceConfig.h"

@interface EServiceSubmitionFormVC : XIBBaseViewController

@property (nonatomic, assign) EServiceType serviceType;

@property (nonatomic, assign) BOOL wasAppointment;

@property (nonatomic, assign) CLLocationCoordinate2D userLocatedAddressCoordinate;

@property (nonatomic, strong) NSString *userLocatedAddress;

@property (nonatomic, assign) BOOL wasSelectedConsultant;

@property (nonatomic, strong) NSString *consultantID;

@property (nonatomic, strong) NSString *consultantName;

@property (nonatomic, strong) NSString *consultantPhone;

@property (nonatomic, strong) NSDictionary *priceDetail;

@end
