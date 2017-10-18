//
//  MAIDConfigObject.h
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//


typedef NS_ENUM(NSInteger, CDZMAIDConfigType) {
    /* 保险公司列表 */
    CDZMAIDConfigTypeForComanyList,
    /* 第三者责任险 */
    CDZMAIDConfigTypeOfThirdPartyLiabilityInsurance,
    /* 司机座位责任险 */
    CDZMAIDConfigTypeOfDriverLiabilityInsurance,
    /* 乘客责任险 */
    CDZMAIDConfigTypeOfPassengerLiabilityInsurance,
    /* 玻璃单独破损险 */
    CDZMAIDConfigTypeOfVehicleWindshieldDamageInsurance,
    /* 车辆划痕损失险 */
    CDZMAIDConfigTypeOfVehicleScratchDamageInsurance,
    /* 倒车镜与车灯单独损坏险 */
    CDZMAIDConfigTypeOfSideMirrorAndHeadlightDamageInsurance,
    /* 自燃损失险 */
    CDZMAIDConfigTypeOfVehicleFireInsurance,
};

typedef NS_ENUM(NSInteger, CDZMAIDConfigMissType) {
    CDZMAIDConfigMissTypeOfNotingMiss,
    CDZMAIDConfigMissTypeOfCommerceInsuranceActiveDateDidNotSelected,
    CDZMAIDConfigMissTypeOfTALCIActiveDateDidNotSelected,
    CDZMAIDConfigMissTypeOfInsuranceDidNotSelected,
    CDZMAIDConfigMissTypeOfInsuranceCompanyDidNotSelected,
};


#import <Foundation/Foundation.h>

@interface MAIDConfigObjectDetail : NSObject
/* ID */
@property (nonatomic, strong) NSNumber *listID;
/* 保费 */
@property (nonatomic, strong) NSNumber *premiumCost;
/* 保额 */
@property (nonatomic, strong) NSString *coverageCost;
/* 保险名称 */
@property (nonatomic, strong) NSString *insuranceName;
/* 座位总数 */
@property (nonatomic, strong) NSNumber *seatNumber;
/* 保费费率 */
@property (nonatomic, strong) NSNumber *insuranceRatio;
/* 保险类型 */
@property (nonatomic, assign) CDZMAIDConfigType insuranceType;

@end


@interface MAIDConfigCompanyObject : NSObject
/* 保费公司列ID */
@property (nonatomic, strong) NSString *listID;
/* 时间 */
@property (nonatomic, strong) NSString *addTime;
/* 保险公司模块 */
@property (nonatomic, strong) NSString *companyModule;
/* 排序号码 */
@property (nonatomic, strong) NSNumber *sortNumber;
/* 保险公司名称 */
@property (nonatomic, strong) NSString *companyName;
/* 保险公司remark */
@property (nonatomic, strong) NSString *remark;
/* 保险公司目录类型 */
@property (nonatomic, strong) NSString *menuType;
/* 保险公司Logo */
@property (nonatomic, strong) NSString *companyImageURL;

@end


@interface MAIDConfigSubObject : NSObject
/* 保费详情列表 */
@property (nonatomic, strong) NSMutableArray *objectList;
/* 已选列ID */
@property (nonatomic, assign) NSInteger currentSelectionID;
/* 保险类型 */
@property (nonatomic, assign) CDZMAIDConfigType insuranceType;
/* 保险已选 */
@property (nonatomic, assign) BOOL isActive;

@property (nonatomic, readonly) id configDetail;

- (instancetype)initWithType:(CDZMAIDConfigType)insuranceType andList:(NSArray *)list;

@end


@interface MAIDConfigObject : NSObject

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

#pragma mark - Autos Info
@property (nonatomic, strong) NSString *carMAIID;

@property (nonatomic, strong) NSString *autosBrandImageURL;

@property (nonatomic, strong) NSString *licensePlate;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) NSString *wasSHandAutos;

@property (nonatomic, strong) NSString *autousOwnerName;

@property (nonatomic, strong) NSString *autosEngineNumber;

@property (nonatomic, strong) NSString *autosFrameNumber;

@property (nonatomic, strong) NSString *autosSeriesName;

@property (nonatomic, strong) NSString *autosModelName;

#pragma mark - Insurance Info
/* 车船税费用 */
@property (nonatomic, strong) NSNumber *vehicleAndVesselTax;
/* 交强险保费 Traffic Accident Liability Compulsory Insurance */
@property (nonatomic, strong) NSNumber *autosTALCInsurance;

/* 保险公司 */
@property (nonatomic, strong) MAIDConfigSubObject *insuranceCompanyList;

/* 是否资料填妥 */
@property (nonatomic, readonly) CDZMAIDConfigMissType wasAllInsuranceDataComplete;

//Traffic Accident Liability Compulsory Insurance
/* 交强险保费 + 车船税费用 */
@property (nonatomic, readonly) NSNumber *TALCIWithVAVTax;
/* 是否购买交强险 */
@property (nonatomic, assign) BOOL autosTALCInsuranceActive;
/* 交强险 生效日期 */
@property (nonatomic, strong) NSDate *autosTALCInsuranceActiveDate;


/* 商业险 打折比例 */
@property (nonatomic, strong) NSNumber *commerceInsuranceDiscount;

///* 是否购买商业险 */
//@property (nonatomic, assign) BOOL commerceInsuranceActive;
/* 商业险 生效日期 */
@property (nonatomic, strong) NSDate *commerceInsuranceActiveDate;


/* 是否购买车辆损失险 */
@property (nonatomic, assign) BOOL autosDamageInsuranceActive;
/* 车辆损失险 */
@property (nonatomic, strong) NSNumber *autosDamageInsurance;

/* 是否购买盗抢险 */
@property (nonatomic, assign) BOOL robberyAndTheftInsuranceActive;
/* 盗抢险保费 */
@property (nonatomic, strong) NSNumber *robberyAndTheftInsurance;

/* 是否购买指定专修厂特约险 */
@property (nonatomic, assign) BOOL specifyServiceFactoryInsuranceActive;
/* 指定专修厂特约险保费 */
@property (nonatomic, readonly) NSNumber *specifyServiceFactoryInsurance;


/* 是否购买涉水行驶损失险 */
@property (nonatomic, assign) BOOL wadingDrivingInsuranceActive;
/* 涉水行驶损失险保费 */
@property (nonatomic, readonly) NSNumber *wadingDrivingInsurance;

#pragma mark - 不计免赔特约险
/* 是否购买不计免赔特约险-车损险 */
@property (nonatomic, assign) BOOL extraADInsuranceActive;
/* 不计免赔特约险-车损险保费 */
@property (nonatomic, readonly) NSNumber *extraADInsurance;


/* 是否购买不计免赔特约险-盗抢险 */
@property (nonatomic, assign) BOOL extraRATInsuranceActive;
/* 不计免赔特约险-盗抢险保费 */
@property (nonatomic, readonly) NSNumber *extraRATInsurance;


/* 是否购买不计免赔特约险-第三责任险 */
@property (nonatomic, assign) BOOL extraTPLInsuranceActive;
/* 不计免赔特约险-第三责任险保费 */
@property (nonatomic, readonly) NSNumber *extraTPLInsurance;


/* 是否购买不计免赔特约险-司机乘客险 */
@property (nonatomic, assign) BOOL extraDLNPLInsuranceActive;
/* 不计免赔特约险-司机乘客险保费 */
@property (nonatomic, readonly) NSNumber *extraDLNPLInsurance;


/* 是否购买不计免赔特约险-附加险 */
@property (nonatomic, assign) BOOL extraPlusInsuranceActive;
/* 不计免赔特约险-附加险保费 */
@property (nonatomic, readonly) NSNumber *extraPlusInsurance;



/* 第三者责任险 */
@property (nonatomic, strong) MAIDConfigSubObject *thirdPartyLiabilityInsurance;
/* 司机座位责任险 */
@property (nonatomic, strong) MAIDConfigSubObject *driverLiabilityInsurance;
/* 乘客责任险 */
@property (nonatomic, strong) MAIDConfigSubObject *passengerLiabilityInsurance;
/* 玻璃单独破损险 */
@property (nonatomic, strong) MAIDConfigSubObject *windshieldDamageInsurance;
/* 车辆划痕损失险 */
@property (nonatomic, strong) MAIDConfigSubObject *scratchDamageInsurance;
/* 倒车镜与车灯单独损坏险 */
@property (nonatomic, strong) MAIDConfigSubObject *sideMirrorAndHeadlightDamageInsurance;
/* 自燃损失险 */
@property (nonatomic, strong) MAIDConfigSubObject *fireInsurance;

- (instancetype)initWithInsuranceDetail:(NSDictionary *)insuranceDetail;

/* 总价格 */
@property (nonatomic, readonly) NSNumber *totalPrice;
/* 实际总价格 */
@property (nonatomic, readonly) NSNumber *actualPrice;
/* 优惠价格 */
@property (nonatomic, readonly) NSNumber *discountPrice;


@end

