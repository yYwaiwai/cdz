//
//  MyShopingCartProductComponents.m
//  cdzer
//
//  Created by KEns0nLau on 10/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MyShopingCartProductComponents.h"

@implementation MSCProductDetail

- (void)setProductUID:(NSString *)productUID {
    _productUID = productUID;
}

- (void)setProductID:(NSString *)productID {
   _productID = productID;
}

- (void)setProductName:(NSString *)productName {
    _productName = productName;
}

- (void)setProductImgURL:(NSURL *)productImgURL {
    _productImgURL = productImgURL;
}

- (void)setIsGPSDevice:(BOOL)isGPSDevice {
    _isGPSDevice = isGPSDevice;
}

- (void)setRetailPrice:(NSString *)retailPrice {
    if (!retailPrice||[retailPrice isEqualToString:@""]||retailPrice.floatValue<0) {
     retailPrice = @"0.00";
    }
    _retailPrice = retailPrice;
}

- (void)setStockCount:(NSUInteger)stockCount {
    _stockCount = stockCount;
}

- (CGFloat)totalPrice {
    CGFloat totalPrice = self.retailPrice.floatValue*self.purchaseCount;
    return totalPrice;
}

- (void)setPurchaseCount:(NSUInteger)purchaseCount {
    if (purchaseCount<=0) purchaseCount = 1;
    if (purchaseCount>self.stockCount) purchaseCount = self.stockCount;
    if (purchaseCount>30) purchaseCount = 30;
    _purchaseCount = purchaseCount;
}

@end


@implementation MSCProductCenter

+ (NSMutableArray <MSCProductCenter *> *)createDataObjectListWithCenterSourceDataList:(NSArray <NSDictionary *> *)sourceDataList {
    NSMutableArray <MSCProductCenter *> *productCenterList = [@[] mutableCopy];
    if (sourceDataList.count!=0) {
        @weakify(self);
        [sourceDataList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull sourceData, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            MSCProductCenter *productCenter = [self createDataObjectWithCenterSourceData:sourceData];
            if (productCenter) {
                [productCenterList addObject:productCenter];
            }
        }];
    }
    return productCenterList;
}

+ (MSCProductCenter *)createDataObjectWithCenterSourceData:(NSDictionary *)sourceData {
    MSCProductCenter *productCenterObj = nil;
    NSArray <NSDictionary *> *productList = sourceData[@"product_info"];
    if (productList&&[productList isKindOfClass:NSArray.class]&&productList.count>0) {
        productCenterObj = MSCProductCenter.new;
        productCenterObj.centerName = sourceData[@"center_name"];
        productCenterObj.productList = [@[] mutableCopy];
        [productList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull productDetailSource, NSUInteger idx, BOOL * _Nonnull stop) {
            if (productDetailSource>0) {
                MSCProductDetail *productDetail = MSCProductDetail.new;
                productDetail.productUID = [SupportingClass verifyAndConvertDataToString:productDetailSource[@"id"]];
                productDetail.productID = [SupportingClass verifyAndConvertDataToString:productDetailSource[@"productId"]];
                productDetail.productName = [SupportingClass verifyAndConvertDataToString:productDetailSource[@"productName"]];
                NSString *urlString = productDetailSource[@"productImg"];
                if (!urlString) urlString = @"";
                productDetail.productImgURL = [NSURL URLWithString:urlString];
                productDetail.retailPrice = [SupportingClass verifyAndConvertDataToString:productDetailSource[@"tprice"]];
                productDetail.stockCount = [SupportingClass verifyAndConvertDataToNumber:productDetailSource[@"stocknum"]].unsignedIntegerValue;
                productDetail.purchaseCount = [SupportingClass verifyAndConvertDataToNumber:productDetailSource[@"buyCount"]].unsignedIntegerValue;
                if ([productDetail.productID isContainsString:@"PD141120094853302030"]||
                    [productDetail.productID isContainsString:@"PD141120094853302029"]) {
                    productDetail.isGPSDevice = YES;
                }
                [productCenterObj.productList addObject:productDetail];
            }
        }];
        if (productCenterObj.productList.count==0) productCenterObj = nil;
    }
    return productCenterObj;
}

- (void)setCenterName:(NSString *)centerName {
    _centerName = centerName;
}

- (void)setProductList:(NSMutableArray <MSCProductDetail *> *)productList {
    _productList = productList;
}

@end