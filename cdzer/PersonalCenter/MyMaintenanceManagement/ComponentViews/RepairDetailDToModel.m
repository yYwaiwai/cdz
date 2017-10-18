//
//  RepairDetailDToModel.m
//  cdzer
//
//  Created by KEns0n on 6/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairDetailDToModel.h"

@interface RepairDetailDToModel ()
{
    /* 维修商 */
    NSString *_repairNmuber, *_shopName , *_shopAddress , *_shopTel , *_appointmentTime , *_technician;
    
    /* 客户 */
    NSString *_repairType, *_autosAppearance, *_autosBrandName, *_autosDealershipName, *_autosSeries, *_autosModel, *_autosColor, *_autosEngineCode;
    NSString *_autosBodyCode, *_licensePlateNumber, *_userName, *_contactName, *_handlerName, *_remarkString, *_handleTime, *_insuranceTime, *_autosOwnerName;
    NSNumber *_contactsNumber, *_mileageCounts, *_oilReadingData;
    
    /* 详细费用 */
    NSNumber *_diagnoseAmount, *_estimatedManagementCost, *_estimatedMaterialCost, *_estimatedTotalAmount, *_discount, *_workingHour, *_totalWorkingHour, *_workingHourPrice;
    
            /* 维修项目 */          /* 维修材料 */
    NSMutableArray *_repairmentNComponentList;
    
    BOOL _isHavePriceDetail;
    CDZMaintenanceStatusType _statusType;
}
@property (nonatomic, strong) NSDictionary *shopDetail;

@property (nonatomic, strong) NSDictionary *userDetail;

@property (nonatomic, strong) NSDictionary *userAutosDetail;

@end

@implementation RepairDetailDToModel

+ (instancetype)createModelWithStatus:(CDZMaintenanceStatusType)statusType andData:(NSDictionary *)data {
    RepairDetailDToModel *detailObject = [RepairDetailDToModel new];
    if (detailObject) {
        detailObject.statusType = statusType;
        [detailObject updateObjectWithData:data];
    }
    return detailObject;
}

- (void)setStatusType:(CDZMaintenanceStatusType)statusType {
    _statusType = statusType;
}

- (void)updateObjectWithData:(NSDictionary *)data {
    NSDictionary *shopDetail = data[@"shop"];
    
    NSDictionary *userDetail = data[@"user"];
    
    NSDictionary *userAutosDetail = data[@"detail"];
    
    NSArray *repairmentItemsList = data[@"wxxm"];
    
    NSArray *componentReplaceList = data[@"wxcl"];
    
    
    if (shopDetail) {
        _repairNmuber = shopDetail[@"make_number"];
        _shopName = shopDetail[@"wxs_name"];
        _shopAddress = shopDetail[@"wxs_address"];
        _technician = shopDetail[@"make_technician"];
        _appointmentTime = shopDetail[@"addtime"];
        
        _shopTel = shopDetail[@"wxs_telphone"];
        if (!_shopTel) {
            _shopTel = shopDetail[@"wxs_telephone"];
        }
    }
    
    if (userDetail) {
        _autosAppearance = userDetail[@"face"];
        _autosBrandName = userDetail[@"brand_name"];
        _autosDealershipName = userDetail[@"factory_name"];
        _autosSeries = userDetail[@"fct_name"];
        _autosModel = userDetail[@"speci_name"];
        _autosColor = userDetail[@"color"];
        _autosEngineCode = userDetail[@"engine_code"];
        _autosBodyCode = userDetail[@"frame_num"];
        _userName = userDetail[@"user_name"];
        _autosOwnerName = userDetail[@"real_name"];
        _insuranceTime = userDetail[@"insure_time"];
        _mileageCounts = userDetail[@"mileage"];
        _contactsNumber = userDetail[@"contact_number"];
        
        _contactName = userDetail[@"contacts"];
        _handlerName = userDetail[@"caozuo"];
        _remarkString = userDetail[@"remark"];
        _handleTime = userDetail[@"current_time"];
        _oilReadingData = userDetail[@"oil"];
        _repairType = userDetail[@"service_project"];
        _licensePlateNumber = userDetail[@"car_number"];
        self.userDetail = userDetail;
    }
    
    _isHavePriceDetail = NO;
    if (userAutosDetail) {
        _isHavePriceDetail = YES;
        
        _diagnoseAmount = userAutosDetail[@"fjianchaprice"];
        if ([userAutosDetail[@"fjianchaprice"] isKindOfClass:NSString.class]) {
            _diagnoseAmount = @([userAutosDetail[@"fjianchaprice"] floatValue]);
        }
        
        _estimatedManagementCost = userAutosDetail[@"flpjprice"];
        if ([userAutosDetail[@"flpjprice"] isKindOfClass:NSString.class]) {
            _estimatedManagementCost = @([userAutosDetail[@"flpjprice"] floatValue]);
        }
        
        _estimatedMaterialCost = userAutosDetail[@"wcailiaofei"];
        if ([userAutosDetail[@"wcailiaofei"] isKindOfClass:NSString.class]) {
            _estimatedMaterialCost = @([userAutosDetail[@"wcailiaofei"] floatValue]);
        }
        
        _estimatedTotalAmount = userAutosDetail[@"wallcost"];
        if ([userAutosDetail[@"wallcost"] isKindOfClass:NSString.class]) {
            _estimatedTotalAmount = @([userAutosDetail[@"wallcost"] floatValue]);
        }
        
        _discount = userAutosDetail[@"discount"];
        if ([userAutosDetail[@"discount"] isKindOfClass:NSString.class]) {
            _discount = @([userAutosDetail[@"discount"] floatValue]);
        }
        
        _workingHour = userAutosDetail[@"whour"];
        if ([userAutosDetail[@"whour"] isKindOfClass:NSString.class]) {
            _workingHour = @([userAutosDetail[@"whour"] floatValue]);
        }
        
        _totalWorkingHour = userAutosDetail[@"wcost"];
        if ([userAutosDetail[@"wcost"] isKindOfClass:NSString.class]) {
            _totalWorkingHour = @([userAutosDetail[@"wcost"] floatValue]);
        }
        
        _workingHourPrice = userAutosDetail[@"wprice"];
        if ([userAutosDetail[@"wprice"] isKindOfClass:NSString.class]) {
            _workingHourPrice = @([userAutosDetail[@"wprice"] floatValue]);
        }
        
        _userCredits = [SupportingClass verifyAndConvertDataToString:userAutosDetail[@"credits"]];
        
        self.userAutosDetail = userAutosDetail;
    }
    _repairmentNComponentList = [NSMutableArray array];
    if (repairmentItemsList) {
        [_repairmentNComponentList addObject:repairmentItemsList];
    }
    
    if (componentReplaceList) {
        [_repairmentNComponentList addObject:componentReplaceList];
    }
    

}

@end
