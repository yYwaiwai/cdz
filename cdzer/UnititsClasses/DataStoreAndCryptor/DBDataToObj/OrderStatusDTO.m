//
//  OrderStatusDTO.m
//  cdzer
//
//  Created by KEns0n on 9/22/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "OrderStatusDTO.h"

@implementation OrderStatusDTO

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stateName = @"";
        self.stateID = @"";
        self.orderStatusType = MyOrderStatusOfOrderUnknowState;
    }
    return self;
}

- (void)setOrderWasNotCommented:(BOOL)orderWasNotCommented {
    _orderWasNotCommented = orderWasNotCommented;
    if (orderWasNotCommented) {
        self.orderStatusType = MyOrderStatusOfOrderFinishWithoutComment;
    }
}

- (void)setStateID:(NSString *)stateID {
    _stateID = stateID;
}

- (void)setStateName:(NSString *)stateName {
    _stateName = stateName;
}

- (void)setOrderStatusType:(MyOrderStatus)orderStatusType {
    _orderStatusType = orderStatusType;
}

- (void)processDataToObjectWithData:(NSDictionary *)sourceData {
    
    self.stateName = nil;
    self.stateID = nil;
    
    NSString *stateID = sourceData[@"id"];
    if (!stateID||[stateID isKindOfClass:NSNull.class]) {
        self.stateID = @"0";
    }else {
        self.stateID = [SupportingClass verifyAndConvertDataToString:stateID];
    }
    
    NSString *stateName = sourceData[@"name"];
    if (!stateName||[stateName isKindOfClass:NSNull.class]) {
        self.stateName = @"0";
    }else {
        self.stateName = [SupportingClass verifyAndConvertDataToString:stateName];
    }
    if (sourceData[@"order_state"]) {
        
    }
    
    self.orderStatusType = [self getStateHandle:stateName];
    

}

- (NSDictionary *)processObjectToDBData {
    return @{@"id":_stateID,
             @"name":_stateName,
             @"order_state":@(_orderStatusType)};
}

- (MyOrderStatus)getStateHandle:(NSString *)stateName {
    MyOrderStatus orderState = MyOrderStatusOfOrderUnknowState;
    
    if (stateName&&[stateName isEqualToString:@"未付款"]) {
        orderState = MyOrderStatusOfOrderWait4Payment;
    }
    
    if (stateName&&[stateName isEqualToString:@"已付款"]) {
        orderState = MyOrderStatusOfOrderWasPaidNWait4Delivery;
    }
    
    if (stateName&&[stateName isEqualToString:@"货到付款"]) {
        orderState = MyOrderStatusOfOrderPayOnDeliveryNWait4Delivery;
    }
    
    if (stateName&&[stateName isEqualToString:@"申请退货中"]) {
        orderState = MyOrderStatusOfOrderApplingReturnPurchase;
    }
    
    if (stateName&&[stateName isEqualToString:@"退货完成"]) {
        orderState = MyOrderStatusOfOrderAcceptApplingReturnPurchase;
    }
    
    if (stateName&&[stateName isEqualToString:@"订单完成"]) {
        orderState = MyOrderStatusOfOrderFinish;
    }
    
    if (stateName&&[stateName isEqualToString:@"订单取消"]) {
        orderState = MyOrderStatusOfOrderCancel;
    }
    
    if (stateName&&[stateName isEqualToString:@"拒绝退款"]) {
        orderState = MyOrderStatusOfOrderReturnPurchaseRejected;
    }
    
    if (stateName&&[stateName isEqualToString:@"派送中"]) {
        orderState = MyOrderStatusOfOrderDelivering;
    }
    return orderState;
}


@end
