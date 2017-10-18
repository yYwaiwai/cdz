//
//  MyShopingCartProductComponents.h
//  cdzer
//
//  Created by KEns0nLau on 10/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCProductDetail : NSObject

@property (nonatomic, strong, readonly, nonnull) NSString *productUID;

@property (nonatomic, strong, readonly, nonnull) NSString *productID;

@property (nonatomic, strong, readonly, nonnull) NSString *productName;

@property (nonatomic, strong, readonly, nullable) NSURL *productImgURL;

@property (nonatomic, assign, readonly) BOOL isGPSDevice;

@property (nonatomic, strong, readonly, nonnull) NSString *retailPrice;

@property (nonatomic, assign, readonly) NSUInteger stockCount;

@property (nonatomic, assign, readonly) CGFloat totalPrice;

@property (nonatomic, assign) NSUInteger purchaseCount;

@end


@interface MSCProductCenter : NSObject

@property (nonatomic, strong, readonly, nonnull) NSString *centerName;

@property (nonatomic, strong, readonly, nonnull) NSMutableArray <MSCProductDetail *> *productList;

+ (NSMutableArray <MSCProductCenter *> * _Nonnull)createDataObjectListWithCenterSourceDataList:(NSArray <NSDictionary *> * _Nonnull)sourceDataList;

@end