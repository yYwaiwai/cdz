//
//  CDZOPCObjectComponents.h
//  cdzer
//
//  Created by KEns0nLau on 9/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

static NSString *const PISCTextViewAdjustPositionNotification = @"PISCTextViewAdjustPositionNotification";
static NSString *const PISCTextViewDidEndNotification = @"PISCTextViewDidEndNotification";

typedef NS_ENUM(NSUInteger, CDZOrderPaymentClearanceType) {
    CDZOrderPaymentClearanceTypeOfRegularParts,
    CDZOrderPaymentClearanceTypeOfSpecRepair,
    CDZOrderPaymentClearanceTypeOfMaintainExpress,
    CDZOrderPaymentClearanceTypeOfRepairNMaintenance,
    CDZOrderPaymentClearanceTypeOfUserMember,
    CDZOrderPaymentClearanceTypeOfInsurance,
};

#import <Foundation/Foundation.h>

@interface PISCConfigObject : NSObject

@property (nonatomic) BOOL isMultiProduct;

@property (nonatomic) BOOL showExpressPriceInfoView;

@property (nonatomic) BOOL showPayeeNameLabel;

@property (nonatomic, strong) NSString *payeeNameString;

@property (nonatomic) BOOL showUserRemarkView;

@property (nonatomic, strong) NSString *userRemarkString;

@property (nonatomic) BOOL showTotalPriceView;

@property (nonatomic, assign) CDZOrderPaymentClearanceType orderClearanceType;

@property (nonatomic, strong) NSDictionary *dataConfigDetail;

@end
