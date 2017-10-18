//
//  MAIDConfigObject.m
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "MAIDConfigObject.h"

@interface MAIDConfigObject ()

/* 特约险比率 */
@property (nonatomic, strong) NSNumber *extraInsuranceRatio;
/* 涉水行驶损失险比率 */
@property (nonatomic, strong) NSNumber *extraWDInsuranceRatio;

@end

@implementation MAIDConfigObject

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithInsuranceDetail:(NSDictionary *)insuranceDetail {
    self = [super init];
    if (self) {
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
        [self handleInsuranceDetail:insuranceDetail];
    }
    return self;
}

- (void)handleInsuranceDetail:(NSDictionary *)insuranceDetail {
    
    @autoreleasepool {
        if (insuranceDetail&&insuranceDetail.count>0) {
            NSDictionary *carInfo = insuranceDetail[@"carInfo"];
            if (carInfo&&carInfo.count>0) {
//        carInfo =     {
//            brandImg = "http://x.autoimg.cn/app/image/brand/37_3.png";
//            carId = 15101313355272339927;
//            carUserName = "\U5c0f\U8c22";
//            city = "\U957f\U6c99\U5e02";
//            engineCode = ssdfddd;
//            fctName = "\U5a01\U822a";
//            frameNo = "xknn*********3222";
//            isAssigned = "\U5426";
//            licenseNo = "\U65b0A12365";
//            speciName = "\U5e03\U52a0\U8fea 2008\U6b3e 16.4 8.0T";
//        };
                self.carMAIID = [SupportingClass verifyAndConvertDataToString:carInfo[@"carId"]];
                self.licensePlate = [SupportingClass verifyAndConvertDataToString:carInfo[@"licenseNo"]];
                self.cityName = [SupportingClass verifyAndConvertDataToString:carInfo[@"city"]];
                self.wasSHandAutos = [SupportingClass verifyAndConvertDataToString:carInfo[@"isAssigned"]];
                
                self.autosBrandImageURL = [SupportingClass verifyAndConvertDataToString:carInfo[@"brandImg"]];
                self.autousOwnerName = [SupportingClass verifyAndConvertDataToString:carInfo[@"carUserName"]];
                self.autosEngineNumber = [SupportingClass verifyAndConvertDataToString:carInfo[@"engineCode"]];
                self.autosFrameNumber = [SupportingClass verifyAndConvertDataToString:carInfo[@"frameNo"]];
                self.autosSeriesName = [SupportingClass verifyAndConvertDataToString:carInfo[@"fctName"]];
                self.autosModelName = [SupportingClass verifyAndConvertDataToString:carInfo[@"speciName"]];
            }
            
            
//        "ccs_price" = 4800;
//        clssx = "2690.00";
//        theftInfo = "735.0";
//        "jqx_price" = 950;
//        count = "0.8";
//        tyxRatio = "0.15"
            
            self.commerceInsuranceDiscount = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"count"]];
            if (_commerceInsuranceDiscount.doubleValue<=0) {
                self.commerceInsuranceDiscount = @1;
            }
            self.autosDamageInsurance = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"clssx"]];
            self.vehicleAndVesselTax = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"ccs_price"]];
            self.robberyAndTheftInsurance = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"theftInfo"]];
            self.autosTALCInsurance = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"jqx_price"]];
            
            if (insuranceDetail[@"tyxRatio"]) {
                self.extraInsuranceRatio = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"tyxRatio"]];
            }else {
                self.extraInsuranceRatio = @0.15f;
            }
            
            if (insuranceDetail[@"wdxRatio"]) {
                self.extraWDInsuranceRatio = [SupportingClass verifyAndConvertDataToNumber:insuranceDetail[@"wdxRatio"]];
            }else {
                self.extraWDInsuranceRatio = @0.05f;
            }


//            company
            NSArray *companyList = insuranceDetail[@"company"];
            if (companyList&&companyList.count>0) {
                self.insuranceCompanyList = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeForComanyList andList:companyList];
            }
            
//            driverInfo
            NSArray *driverInsuranceList = insuranceDetail[@"driverInfo"];
            if (driverInsuranceList&&driverInsuranceList.count>0) {
                self.driverLiabilityInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfDriverLiabilityInsurance andList:driverInsuranceList];
            }
            
//            fire
            NSArray *fireInsuranceList= insuranceDetail[@"fire"];
            if (fireInsuranceList&&fireInsuranceList.count>0) {
                self.fireInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfVehicleFireInsurance andList:fireInsuranceList];
            }
            
//            glassInfo
            NSArray *windShieldInsuranceList = insuranceDetail[@"glassInfo"];
            if (windShieldInsuranceList&&windShieldInsuranceList.count>0) {
                self.windshieldDamageInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance andList:windShieldInsuranceList];
            }
            
//            light
            NSArray *lightInsuranceList = insuranceDetail[@"light"];
            if (lightInsuranceList&&lightInsuranceList.count>0) {
                self.sideMirrorAndHeadlightDamageInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance andList:lightInsuranceList];
            }
            
//            passengerInfo
            NSArray *passengerInsuranceList = insuranceDetail[@"passengerInfo"];
            if (passengerInsuranceList&&passengerInsuranceList.count>0) {
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
                passengerInsuranceList = [insuranceDetail[@"passengerInfo"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                self.passengerLiabilityInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfPassengerLiabilityInsurance andList:passengerInsuranceList];
            }
            
//            scratch
            NSArray *scratchInsuranceList = insuranceDetail[@"scratch"];
            if (scratchInsuranceList&&scratchInsuranceList.count>0) {
                self.scratchDamageInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfVehicleScratchDamageInsurance andList:scratchInsuranceList];
            }
            
//            thirdInfo
            NSArray *thirdInsuranceList = insuranceDetail[@"thirdInfo"];
            if (thirdInsuranceList&&thirdInsuranceList.count>0) {
                self.thirdPartyLiabilityInsurance = [[MAIDConfigSubObject alloc] initWithType:CDZMAIDConfigTypeOfThirdPartyLiabilityInsurance andList:thirdInsuranceList];
            }
        }
    }
}

- (CDZMAIDConfigMissType)wasAllInsuranceDataComplete {
    CDZMAIDConfigMissType wasAllInsuranceDataComplete = CDZMAIDConfigMissTypeOfNotingMiss;
    
    if (!_autosTALCInsuranceActive&&!(_autosDamageInsuranceActive||_robberyAndTheftInsuranceActive||
        _passengerLiabilityInsurance.isActive||_driverLiabilityInsurance.isActive||_thirdPartyLiabilityInsurance.isActive)) {
        return CDZMAIDConfigMissTypeOfInsuranceDidNotSelected;
    }
    
    if (!_insuranceCompanyList.isActive||
        _insuranceCompanyList.objectList.count==0||
        _insuranceCompanyList.currentSelectionID<=-1) {
        return CDZMAIDConfigMissTypeOfInsuranceCompanyDidNotSelected;
    }
    
    if (!_autosTALCInsuranceActiveDate&&_autosTALCInsuranceActive) {
        return CDZMAIDConfigMissTypeOfTALCIActiveDateDidNotSelected;
    }
    
    if (!_commerceInsuranceActiveDate&&(_autosDamageInsuranceActive||_robberyAndTheftInsuranceActive||_passengerLiabilityInsurance.isActive||
                                        _driverLiabilityInsurance.isActive||_thirdPartyLiabilityInsurance.isActive)) {
        return CDZMAIDConfigMissTypeOfCommerceInsuranceActiveDateDidNotSelected;
    }
    
    return wasAllInsuranceDataComplete;
}

- (NSNumber *)TALCIWithVAVTax {
    double vehicleAndVesselTax = _vehicleAndVesselTax.doubleValue;
    double autosTALCInsurance = _autosTALCInsurance.doubleValue;
    
    return @([self roundToLastTwoFloatValue:(autosTALCInsurance+vehicleAndVesselTax)]);
}

- (NSNumber *)wadingDrivingInsurance {
    double wadingDrivingInsurance = 0.0f;
    if (_autosDamageInsuranceActive&&_autosDamageInsurance.doubleValue>0.0f) {
        wadingDrivingInsurance = _autosDamageInsurance.doubleValue;
    }
    
    return @([self roundToLastTwoFloatValue:(wadingDrivingInsurance*_extraWDInsuranceRatio.doubleValue)]);
}

- (NSNumber *)specifyServiceFactoryInsurance {
    double specifyServiceFactoryInsurance = 0.0f;
    if (_autosDamageInsuranceActive&&_autosDamageInsurance.doubleValue>0.0f) {
        specifyServiceFactoryInsurance = _autosDamageInsurance.doubleValue;
    }
    return @([self roundToLastTwoFloatValue:(specifyServiceFactoryInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)extraADInsurance {
    double extraADInsurance = 0.0f;
    if (_autosDamageInsuranceActive&&_autosDamageInsurance.doubleValue>0.0f) {
        extraADInsurance = _autosDamageInsurance.doubleValue;
    }
    
    return @([self roundToLastTwoFloatValue:(extraADInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)extraRATInsurance {
    double extraRATInsurance = 0.0f;
    if (_robberyAndTheftInsuranceActive&&_robberyAndTheftInsurance.doubleValue>0.0f) {
        extraRATInsurance = _robberyAndTheftInsurance.doubleValue;
    }
    return @([self roundToLastTwoFloatValue:(extraRATInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)extraTPLInsurance {
    double extraTPLInsurance = 0.0f;
    if (_thirdPartyLiabilityInsurance.isActive&&
        _thirdPartyLiabilityInsurance.objectList.count>=1&&
        _thirdPartyLiabilityInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _thirdPartyLiabilityInsurance.configDetail;
        
        extraTPLInsurance = deatil.premiumCost.doubleValue;
    }
    return @([self roundToLastTwoFloatValue:(extraTPLInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)extraDLNPLInsurance {
    double extraDLNPLInsurance = 0.0f;
    if (_passengerLiabilityInsurance.isActive&&
        _passengerLiabilityInsurance.objectList.count>=1&&
        _passengerLiabilityInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _passengerLiabilityInsurance.configDetail;
        
        extraDLNPLInsurance += deatil.premiumCost.doubleValue;
    }
    
    if (_driverLiabilityInsurance.isActive&&
        _driverLiabilityInsurance.objectList.count>=1&&
        _driverLiabilityInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _driverLiabilityInsurance.configDetail;
        
        extraDLNPLInsurance += deatil.premiumCost.doubleValue;
    }
    
    return @([self roundToLastTwoFloatValue:(extraDLNPLInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)extraPlusInsurance {
    double extraPlusInsurance = 0.0f;

    if (_specifyServiceFactoryInsuranceActive&&self.specifyServiceFactoryInsurance.doubleValue>0.0f) {
        extraPlusInsurance += self.specifyServiceFactoryInsurance.doubleValue;
    }

    if (_wadingDrivingInsuranceActive&&self.wadingDrivingInsurance.doubleValue>0.0f) {
        extraPlusInsurance += self.wadingDrivingInsurance.doubleValue;
    }
    
    if (_windshieldDamageInsurance.isActive&&
        _windshieldDamageInsurance.objectList.count>=1&&
        _windshieldDamageInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _windshieldDamageInsurance.configDetail;
        
        extraPlusInsurance += deatil.premiumCost.doubleValue;
    }
    
    if (_scratchDamageInsurance.isActive&&
        _scratchDamageInsurance.objectList.count>=1&&
        _scratchDamageInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _scratchDamageInsurance.configDetail;
        
        extraPlusInsurance += deatil.premiumCost.doubleValue;
    }
    
    if (_sideMirrorAndHeadlightDamageInsurance.isActive&&
        _sideMirrorAndHeadlightDamageInsurance.objectList.count>=1&&
        _sideMirrorAndHeadlightDamageInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _sideMirrorAndHeadlightDamageInsurance.configDetail;
        
        extraPlusInsurance += deatil.premiumCost.doubleValue;
    }
    
    if (_fireInsurance.isActive&&
        _fireInsurance.objectList.count>=1&&
        _fireInsurance.currentSelectionID>=0) {
        MAIDConfigObjectDetail *deatil = _fireInsurance.configDetail;
        
        extraPlusInsurance += deatil.premiumCost.doubleValue;
    }
    
    return @([self roundToLastTwoFloatValue:(extraPlusInsurance*_extraInsuranceRatio.doubleValue)]);
}

- (NSNumber *)actualPrice {
    double actualPrice = 0.0f;
    
    if (_autosTALCInsuranceActive) {
        actualPrice += self.TALCIWithVAVTax.doubleValue;
    }
    
    if (_autosDamageInsuranceActive||_robberyAndTheftInsuranceActive||_thirdPartyLiabilityInsurance.isActive||
         _passengerLiabilityInsurance.isActive||_driverLiabilityInsurance.isActive) {
        
        if (_autosDamageInsuranceActive){
            actualPrice += _autosDamageInsurance.doubleValue;
            if (_extraADInsuranceActive){
                actualPrice += self.extraADInsurance.doubleValue;
            }
            
            if (_wadingDrivingInsuranceActive){
                actualPrice += self.wadingDrivingInsurance.doubleValue;
            }
            
            if (_specifyServiceFactoryInsuranceActive){
                actualPrice += self.specifyServiceFactoryInsurance.doubleValue;
            }
            
            if (_windshieldDamageInsurance.isActive&&
                _windshieldDamageInsurance.objectList.count>=1&&
                _windshieldDamageInsurance.currentSelectionID>=0) {
                MAIDConfigObjectDetail *deatil = _windshieldDamageInsurance.configDetail;
                actualPrice += deatil.premiumCost.doubleValue;
            }
        
            
            if (_fireInsurance.isActive&&
                _fireInsurance.objectList.count>=1&&
                _fireInsurance.currentSelectionID>=0) {
                MAIDConfigObjectDetail *deatil = _fireInsurance.configDetail;
                actualPrice += deatil.premiumCost.doubleValue;
            }
        
            
            if (_scratchDamageInsurance.isActive&&
                _scratchDamageInsurance.objectList.count>=1&&
                _scratchDamageInsurance.currentSelectionID>=0) {
                MAIDConfigObjectDetail *deatil = _scratchDamageInsurance.configDetail;
                actualPrice += deatil.premiumCost.doubleValue;
            }
        
            
            if (_sideMirrorAndHeadlightDamageInsurance.isActive&&
                _sideMirrorAndHeadlightDamageInsurance.objectList.count>=1&&
                _sideMirrorAndHeadlightDamageInsurance.currentSelectionID>=0) {
                MAIDConfigObjectDetail *deatil = _sideMirrorAndHeadlightDamageInsurance.configDetail;
                actualPrice += deatil.premiumCost.doubleValue;
            }
            
            if ((_windshieldDamageInsurance.isActive||_scratchDamageInsurance.isActive||
                 _sideMirrorAndHeadlightDamageInsurance.isActive||_fireInsurance.isActive||
                 _wadingDrivingInsuranceActive||_specifyServiceFactoryInsuranceActive)&&_extraPlusInsuranceActive){
                actualPrice += self.extraPlusInsurance.doubleValue;
            }
            
            
        }
        
        if (_robberyAndTheftInsuranceActive){
            actualPrice += _robberyAndTheftInsurance.doubleValue;
            if (_extraRATInsuranceActive){
                actualPrice += self.extraRATInsurance.doubleValue;
            }
        }
        
        if (_thirdPartyLiabilityInsurance.isActive&&
            _thirdPartyLiabilityInsurance.objectList.count>=1&&
            _thirdPartyLiabilityInsurance.currentSelectionID>=0) {
            MAIDConfigObjectDetail *deatil = _thirdPartyLiabilityInsurance.configDetail;
            actualPrice += deatil.premiumCost.doubleValue;
            if (_extraTPLInsuranceActive){
                actualPrice += self.extraTPLInsurance.doubleValue;
            }
            
        }
        
        if (_passengerLiabilityInsurance.isActive&&
            _passengerLiabilityInsurance.objectList.count>=1&&
            _passengerLiabilityInsurance.currentSelectionID>=0) {
            MAIDConfigObjectDetail *deatil = _passengerLiabilityInsurance.configDetail;
            actualPrice += deatil.premiumCost.doubleValue;
        }
        
        if (_driverLiabilityInsurance.isActive&&
            _driverLiabilityInsurance.objectList.count>=1&&
            _driverLiabilityInsurance.currentSelectionID>=0) {
            MAIDConfigObjectDetail *deatil = _driverLiabilityInsurance.configDetail;
            actualPrice += deatil.premiumCost.doubleValue;
        }
        
        if ((_passengerLiabilityInsurance.isActive||_driverLiabilityInsurance.isActive)&&_extraDLNPLInsuranceActive){
            actualPrice += self.extraDLNPLInsurance.doubleValue;
        }
        
    }
    return @([self roundToLastTwoFloatValue:actualPrice]);
}

- (NSNumber *)totalPrice {
    double totalPrice = 0.0f;
    double autosTALCInsurance = _autosTALCInsuranceActive?self.TALCIWithVAVTax.doubleValue:0.0f;
    NSNumber *actualPrice = self.actualPrice;
    totalPrice += ((actualPrice.doubleValue - autosTALCInsurance) * _commerceInsuranceDiscount.doubleValue);
    totalPrice += autosTALCInsurance;
    return @([self roundToLastTwoFloatValue:totalPrice]);
}

- (NSNumber *)discountPrice {
    double discountPrice = 0.0f;
    double autosTALCInsurance = _autosTALCInsuranceActive?self.TALCIWithVAVTax.doubleValue:0.0f;
    NSNumber *actualPrice = self.actualPrice;
    discountPrice += ((actualPrice.doubleValue - autosTALCInsurance) * (1.0f-_commerceInsuranceDiscount.doubleValue));
    return @([self roundToLastTwoFloatValue:discountPrice]);
}

- (float)roundToLastTwoFloatValue:(float)value {
    return [SupportingClass roundToLastTwoFloatValue:value];
}

@end

@implementation MAIDConfigSubObject

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithType:(CDZMAIDConfigType)insuranceType andList:(NSArray *)list {
    if (!list&&list.count==0) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.isActive = NO;
        self.currentSelectionID = -1;
        if (insuranceType==CDZMAIDConfigTypeForComanyList) {
            self.isActive = YES;
        }
        self.insuranceType = insuranceType;
        self.objectList = [@[] mutableCopy];
        [self handleListData:list];
    }
    return self;
}

- (void)handleListData:(NSArray *)theList {
    @weakify(self);
    
    if (_insuranceType==CDZMAIDConfigTypeForComanyList) {
//        company =     (
//                       {
//                           addtime = "2015-08-19 11:10:07";
//                           id = 15081911114694696638;
//                           imgurl = "";
//                           menuType = ssgs;
//                           module = all;
//                           name = "\U9633\U5149\U4fdd\U9669";
//                           remark = "\U6240\U5c5e\U516c\U53f8";
//                           sort = 0;
//                       },
        
        [theList enumerateObjectsUsingBlock:^(NSDictionary  * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            if (detail&&detail.count>0) {
                MAIDConfigCompanyObject *companyObject = [MAIDConfigCompanyObject new];
                companyObject.listID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
                companyObject.addTime = detail[@"addtime"];
                companyObject.companyModule = detail[@"module"];
                companyObject.sortNumber = [SupportingClass verifyAndConvertDataToNumber:detail[@"sort"]];
                companyObject.companyName = detail[@"name"];
                companyObject.remark = detail[@"remark"];
                companyObject.menuType = detail[@"menuType"];
                companyObject.companyImageURL = detail[@"imgurl"];
                [self.objectList addObject:companyObject];
            }
        }];
        return;
    }
    
    
    [theList enumerateObjectsUsingBlock:^(NSDictionary  * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (detail&&detail.count>0) {
            MAIDConfigObjectDetail *configObject = [MAIDConfigObjectDetail new];
            configObject.insuranceType = self.insuranceType;
            switch (self.insuranceType) {
                case CDZMAIDConfigTypeOfDriverLiabilityInsurance:
//        driverInfo =     (
//                          {
//                              "coverage_no" = "1\U4e07";
//                              price = 42;
//                              rate = "0.0042";
//                          },
                    configObject.coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"coverage_no"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
                    configObject.insuranceRatio = [SupportingClass verifyAndConvertDataToNumber:detail[@"rate"]];
                    break;
                    
                case CDZMAIDConfigTypeOfVehicleFireInsurance:
//        fire =     (
//                    {
//                        price = "180.00";
//                        type = 150000;
//                    }
//                    );
                    
                    configObject.coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"type"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
                    
                    break;
                    
                case CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance:
//        glassInfo =     (
//                         {
//                             "glass_name" = "\U56fd\U4ea7\U73bb\U7483";
//                             "glass_price" = "285.00";
//                         },
                    
                    
                    configObject.insuranceName = [SupportingClass verifyAndConvertDataToString:detail[@"glass_name"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"glass_price"]];
                    break;
                    
                case CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance:
//        light =     (
//                     {
//                         price = "150.00";
//                         type = "\U8fdb\U53e3";
//                     },
                    configObject.insuranceName = [SupportingClass verifyAndConvertDataToString:detail[@"type"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
                    break;
                    
                case CDZMAIDConfigTypeOfPassengerLiabilityInsurance:
//        passengerInfo =     (
//                             {
//                                 "coverage_no" = "2\U4e07";
//                                 price = 216;
//                                 seatNumber = 4;
//                             },
                    
                    configObject.coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"coverage_no"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
                    configObject.seatNumber = [SupportingClass verifyAndConvertDataToNumber:detail[@"seatNumber"]];
                    break;
                    
                case CDZMAIDConfigTypeOfVehicleScratchDamageInsurance:
//        scratch =     (
//                       {
//                           "coverage_type" = 2000;
//                           id = 1;
//                           price = "400.00";
//                       },
                    configObject.coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"coverage_type"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
                    configObject.listID = [SupportingClass verifyAndConvertDataToNumber:detail[@"id"]];
                    break;
                    
                case CDZMAIDConfigTypeOfThirdPartyLiabilityInsurance:
//        thirdInfo =     (
//                         {
//                             "coverage_no" = "5\U4e07";
//                             "premium_price" = 807;
//                         },
                    configObject.coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"coverage_no"]];
                    configObject.premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"premium_price"]];
                    break;
                    
                case CDZMAIDConfigTypeForComanyList:
                default:
                    break;
            }
            [self.objectList addObject:configObject];
        }
    }];
    
    
}

- (id)configDetail {
    id configDetail = NULL;
    if (_currentSelectionID>=0&&_objectList.count>=1) {
        configDetail = _objectList[_currentSelectionID];
    }
    
    return configDetail;
}

@end

@implementation MAIDConfigObjectDetail

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

@end

@implementation MAIDConfigCompanyObject

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

@end

