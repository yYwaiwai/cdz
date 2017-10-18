//
//  MaintenanceItemObjectComponent.m
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceItemObjectComponent.h"

@implementation MaintenanceProductItemDTO

- (instancetype)init {
    if (self=[super init]) {
        self.productID = @"";
        self.productName = @"";
        self.productLogo = @"";
        self.productPrice = @"";
        self.autopartInfoID = @"";
        self.productStockCount = 0;
        self.productStandard = @"";
        self.productCenter = @"";
    }
    return self;
}

- (void)setProductID:(NSString *)productID {
    _productID = productID;
}

- (void)setProductName:(NSString *)productName {
    _productName = productName;
}

- (void)setProductLogo:(NSString *)productLogo {
    _productLogo = productLogo;
}

- (void)setProductPrice:(NSString *)productPrice {
    _productPrice = productPrice;
}

- (void)setAutopartInfoID:(NSString *)autopartInfoID {
    _autopartInfoID = autopartInfoID;
}

- (void)setProductStockCount:(NSUInteger)productStockCount {
    _productStockCount = productStockCount;
    if (self.currentSelectedCount>productStockCount) self.currentSelectedCount = productStockCount;
}

- (void)setCurrentSelectedCount:(NSUInteger)currentSelectedCount {
    if (currentSelectedCount==0) currentSelectedCount = 1;
    if (currentSelectedCount>self.productStockCount) currentSelectedCount = self.productStockCount;
    _currentSelectedCount = currentSelectedCount;
}

- (void)setProductStandard:(NSString *)productStandard {
    _productStandard = productStandard;
}

- (void)setProductCenter:(NSString *)productCenter {
    _productCenter = productCenter;
}

- (void)dtoValueAssignmentBySourceData:(NSDictionary *)sourceData {
//"id": "16062314441625012288",
//"product_name": "壳牌机油",
//"product_img": "http://he.bccar.net:80/imgUpload/demo/common/product/160623144204HMGFeLkuMM.png",
//"product_price": "120",
//"autopart_info": "14112514503342225446",
//"stocknum": "99",
//"number": "1",
//"standard": "4",
//"ctenter_name": "长沙采购中心"
    self.productID = [SupportingClass verifyAndConvertDataToString:sourceData[@"id"]];
    self.productName = sourceData[@"product_name"];
    self.productLogo = sourceData[@"product_img"];
    self.productPrice = [SupportingClass verifyAndConvertDataToString:sourceData[@"product_price"]];
    self.autopartInfoID = [SupportingClass verifyAndConvertDataToString:sourceData[@"autopart_info"]];
    self.productStockCount = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"autopart_info"]].unsignedIntegerValue;
    self.currentSelectedCount = 1;
    self.productStandard = [SupportingClass verifyAndConvertDataToString:sourceData[@"standard"]];
    if (sourceData[@"ctenter_name"]) {
        self.productCenter = [SupportingClass verifyAndConvertDataToString:sourceData[@"SupportingClass"]];
    }
    
}

- (void)productItemReplacementBySourceData:(NSDictionary *)sourceData {
    NSString *productID = [SupportingClass verifyAndConvertDataToString:sourceData[@"id"]];
    NSString *productName = [SupportingClass verifyAndConvertDataToString:sourceData[@"product_name"]];
    NSString *productLogo = [SupportingClass verifyAndConvertDataToString:sourceData[@"product_img"]];
    NSString *productPrice = [SupportingClass verifyAndConvertDataToString:sourceData[@"product_price"]];
    NSUInteger productStockCount = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"stocknum"]].unsignedIntegerValue;
    if (productID&&![productID isEqualToString:@""]&&productName&&![productName isEqualToString:@""]&&
        productLogo&&![productLogo isEqualToString:@""]&&productPrice&&![productPrice isEqualToString:@""]&&
        productStockCount>0) {
        self.productID = productID;
        self.productName = productName;
        self.productLogo = productLogo;
        self.productPrice = productPrice;
        self.productStockCount = productStockCount;
    }
}

@end

@interface MaintenanceTypeDTO ()

@property (nonatomic, strong) NSMutableArray <MaintenanceProductItemDTO *> *maintenanceProductItemInnerList;

@end

@implementation MaintenanceTypeDTO

- (void)setMaintenanceTypeID:(NSString *)maintenanceTypeID {
    _maintenanceTypeID = maintenanceTypeID;
}

- (void)setMaintenanceType:(NSString *)maintenanceType {
    _maintenanceType = maintenanceType;
}

- (void)setMaintenanceTypeName:(NSString *)maintenanceTypeName {
    _maintenanceTypeName = maintenanceTypeName;
}

- (void)setMaintenanceManHour:(NSString *)maintenanceManHour {
    _maintenanceManHour = maintenanceManHour;
}

- (void)setMaintenanceTypeCheckIcon:(NSString *)maintenanceTypeCheckIcon {
    _maintenanceTypeCheckIcon = maintenanceTypeCheckIcon;
}

- (void)setMaintenanceTypeUncheckIcon:(NSString *)maintenanceTypeUncheckIcon {
    _maintenanceTypeUncheckIcon = maintenanceTypeUncheckIcon;
}

- (void)setRemarkInfo:(NSString *)remarkInfo {
    _remarkInfo = remarkInfo;
}

- (NSArray<MaintenanceProductItemDTO *> *)maintenanceProductItemList {
    return [NSArray arrayWithArray:_maintenanceProductItemInnerList];
}

- (void)setMaintenanceProductItemList:(NSArray<MaintenanceProductItemDTO *> *)maintenanceProductItemList {
    if (!maintenanceProductItemList) maintenanceProductItemList = @[];
    
}

- (BOOL)removeProductItemFormByIndex:(NSUInteger)itemIndex {
    BOOL removeSuccess = NO;
    if ((self.maintenanceProductItemList.count-1)>=itemIndex) {
        @try {
            [self.maintenanceProductItemInnerList removeObjectAtIndex:itemIndex];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        } @finally {
            removeSuccess = YES;
        }
    }
    return removeSuccess;
}

- (BOOL)replaceProductItemFormByIndex:(NSUInteger)itemIndex withProductItemDTO:(MaintenanceProductItemDTO *)productItemDTO {
    BOOL replaceSuccess = NO;
    if ((self.maintenanceProductItemList.count-1)>=itemIndex&&productItemDTO) {
        @try {
            [self.maintenanceProductItemInnerList replaceObjectAtIndex:itemIndex withObject:productItemDTO];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        } @finally {
            replaceSuccess = YES;
        }
    }
    return replaceSuccess;
}

+ (MaintenanceTypeDTO *)getMaintenanceTypeDTOBySourceData:(NSDictionary *)sourceData {
    MaintenanceTypeDTO *dto = nil;
    if (sourceData&&sourceData.count>0) {
        //"maintain_name": "更换火花塞",
        //"man_hour": "2",
        //"maintain_id": "15090210275873816283",
        //"maintain_type": "1",
        //"check_icon": "http://cdz.cdzer.net:80/imgUpload/uploads/201607211138526HxdOZEk8p.png",
        //"uncheck_icon": "http://cdz.cdzer.net:80/imgUpload/uploads/201607211138408sEdozFtBS.png",
        //"mark": "1",
        //"product_info": []
        
        dto = [MaintenanceTypeDTO new];
        dto.maintenanceTypeID = [SupportingClass verifyAndConvertDataToString:sourceData[@"maintain_id"]];
        dto.maintenanceType = [SupportingClass verifyAndConvertDataToString:sourceData[@"maintain_type"]];
        dto.maintenanceTypeName = sourceData[@"maintain_name"];
        dto.maintenanceManHour = [SupportingClass verifyAndConvertDataToString:sourceData[@"man_hour"]];
        dto.maintenanceTypeCheckIcon = sourceData[@"check_icon"];
        dto.maintenanceTypeUncheckIcon = sourceData[@"uncheck_icon"];
        dto.remarkInfo = [SupportingClass verifyAndConvertDataToString:sourceData[@"mark"]];
        NSArray<NSDictionary *> *productList = sourceData[@"product_info"];
        dto.maintenanceProductItemInnerList = [NSMutableArray array];
        dto.isSelectedItem = YES;
        @weakify(dto);
        [productList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(dto);
            MaintenanceProductItemDTO *itemDTO = [MaintenanceProductItemDTO new];
            [itemDTO dtoValueAssignmentBySourceData:detail];
            if (itemDTO) {
                [dto.maintenanceProductItemInnerList addObject:itemDTO];
            }
        }];
    }
    return dto;
}


@end