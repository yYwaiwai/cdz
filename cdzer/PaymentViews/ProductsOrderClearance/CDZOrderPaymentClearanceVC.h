//
//  CDZOrderPaymentClearanceVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/14/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "CDZOPCObjectComponents.h"

@interface CDZOrderPaymentClearanceVC : XIBBaseViewController

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;

//Regular Parts
@property (nonatomic) BOOL isBuyNow;

// Spec Repair
@property (nonatomic, strong) UIImage *shopLogoImage;

@property (nonatomic, strong) NSString *specProductID;

@property (nonatomic, strong) NSNumber *specProductPurchaseCount;



// Maintain Express
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) NSNumber *workingHours;

@property (nonatomic, strong) NSArray *maintainItemList;


// Maintain Express && Regular Parts
@property (nonatomic, strong) NSArray *productList;

@property (nonatomic, strong) NSArray *productCountList;


//Repair & Maintenance
@property (nonatomic, strong) NSString *repairOrderID;

@property (nonatomic, strong) NSString *repairShopName;
@end
