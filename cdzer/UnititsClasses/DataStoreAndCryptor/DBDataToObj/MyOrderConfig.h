//
//  MyOrderConfig.h
//  cdzer
//
//  Created by KEns0n on 6/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#ifndef cdzer_MyOrderConfig_h
#define cdzer_MyOrderConfig_h

typedef NS_ENUM(NSInteger, MyOrderStatus) {
    MyOrderStatusOfOrderUnknowState = -1,
    MyOrderStatusOfOrderCancel = 0,
    MyOrderStatusOfOrderWait4Payment,
    MyOrderStatusOfOrderWasPaidNWait4Delivery,
    MyOrderStatusOfOrderPayOnDeliveryNWait4Delivery,
    MyOrderStatusOfOrderDelivering,
    MyOrderStatusOfOrderApplingReturnPurchase,
    MyOrderStatusOfOrderAcceptApplingReturnPurchase,
    MyOrderStatusOfOrderReturnPurchaseRejected,
    MyOrderStatusOfOrderFinishWithoutComment,
    MyOrderStatusOfOrderFinish,
};


#endif


#define kOrderDetailKey @"order_details"
#define kAddressDetailKey @"address_details"
#define kCenterDetailKey @"center_details"