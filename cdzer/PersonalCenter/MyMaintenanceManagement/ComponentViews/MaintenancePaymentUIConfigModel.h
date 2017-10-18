//
//  MaintenancePaymentUIConfigModel.h
//  cdzer
//
//  Created by 车队长 on 16/9/3.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kCellTypeOfSpace @"spaceCell"
#define kCellTypeOfTitle @"titleCell"
#define kCellTypeOfNormalContent @"normalContentCell"
#define kCellTypeOfDetailContent @"detailContentCell"
#define kCellTypeOfPriceContent @"priceContentCell"

#define kCellTypeOfqweContent @"contentCell"



#import <Foundation/Foundation.h>

typedef void(^CouponSelectionPushingBlock)();

@interface MaintenancePaymentUIConfigModel : NSObject<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *contentDetail;

@property (nonatomic, readonly) NSString *selectedItemsString;

@property (nonatomic, strong) NSString *couponContent;

@property (nonatomic, copy) CouponSelectionPushingBlock pushingBlock;

@property (nonatomic, copy) NSDictionary *discountDic;

@property (nonatomic,assign) BOOL isInvoice;

@property (nonatomic,assign) BOOL isIntegral;

@property (nonatomic,strong) NSString *discountStr;//优惠券

@property (nonatomic,strong) NSString *discountID;//优惠券ID

@property(nonatomic,strong) NSString*invoiceTextStr;//发票

@property(nonatomic,strong) NSString*integralStr;//积分

@property(nonatomic,strong) NSString* VerificationCode;//验证码

@end
