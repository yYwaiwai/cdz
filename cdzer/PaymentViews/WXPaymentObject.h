//
//  WXPaymentObject.h
//  cdzer
//
//  Created by KEns0n on 2/1/16.
//  Copyright © 2016 CDZER. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "NYXMLParser.h"
//#import "NYWXPayUtility.h"
#import "WXApi.h"
#define WX_PAY_APP_ID @"wxe6857404fd8ab525"                     /**< 微信开放应用APP ID ！重要：必须是和商户关联的APP ID  */
#define WX_PAY_APP_SECRET @"d4624c36b6795d1d99dcf0547af5443d"   /**< 微信开放应用APP SECRET */

#define WX_PAY_API_KEY @"lxnz3TEoZJ3L9gBTF57ZXbi1yrorp35h"      /**< API密钥*/
#define WX_PAY_PARTNER_ID @"1292639801"                         /**< 微信支付商户号 */
#define WX_PAY_DEVICE_INFO @"cdzer-ios-wxpay"              /**< 支付设备号或门店号 */
#define WX_PAY_BILL_CREATE_IP @"113.247.250.212"                   /**< 发器支付的机器ip */
#define WX_PAY_NOTIFY_URL [[kBaseURLString stringByAppendingString:@"b2bweb-portal/"] stringByAppendingString:@"connect/wpay"]  /**< 回调URL，接收异步通知 */
#define WX_PAY_UNIFIEDORDER_API @"https://api.mch.weixin.qq.com/pay/unifiedorder" /**< 统一订单接口，详见https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=9_1 */
#define WX_PAY_PACKAGE @"Sign=WXPay"



#define PAYMENT_ERROR_DOMAIN_WX_PAY_RESULT_SUCCESS    @"PAYMENT_ERROR_DOMAIN_WX_PAY_RESULT_SUCCESS"     //支付成功
#define PAYMENT_ERROR_DOMAIN_WX_PREPAYID    @"PAYMENT_ERROR_DOMAIN_WX_PREPAYID"     //获取prepayid失败
#define PAYMENT_ERROR_DOMAIN_WX_SIGN        @"PAYMENT_ERROR_DOMAIN_WX_SIGN"         //服务器返回签名验证错误
#define PAYMENT_ERROR_DOMAIN_WX_SERVER      @"PAYMENT_ERROR_DOMAIN_WX_SERVER"       //请求接口返回错误
#define PAYMENT_ERROR_DOMAIN_WX_PRICE      @"PAYMENT_ERROR_DOMAIN_WX_PRICE"         //价格为负数
#define PAYMENT_ERROR_DOMAIN_WX_RESPONSE      @"PAYMENT_ERROR_DOMAIN_WX_RESPONSE"   //服务器返回对象为空
#define PAYMENT_ERROR_DOMAIN_WX_REQUEST      @"PAYMENT_ERROR_DOMAIN_WX_REQUEST"     //支付请求失败
#define PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL      @"PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL"//返回失败
#define PAYMENT_ERROR_DOMAIN_WX_PAYFAILED      @"PAYMENT_ERROR_DOMAIN_WX_PAYFAILED"//可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
#define PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED @"PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED"
/**
 * 支付错误码类型
 **/
typedef NS_ENUM(NSInteger, WXPaymentErrorCode) {
    WXPaymentErrorCodeWeChatSignVerifyError,
    WXPaymentErrorCodeWeChatApiResponseError,
    WXPaymentErrorCodeWeChatGetPrePayIDFailed,
    WXPaymentErrorCodeWeChatPriceLow,
    WXPaymentErrorCodeWeChatResponseError,
    WXPaymentErrorCodeWeChatRequestError,
    WXPaymentErrorCodeWeChatResultCodeFail,
    WXPaymentErrorCodeWeChatPayFailed,
    WXPaymentErrorCodeWeChatPayCanceled,
    WXPaymentErrorCodeWeChatPaySuccess,//暂不用，最好后台请求获取，以服务器饭或为准
    WXPaymentErrorCodeALiPay,
};

/**
 * 支付类型
 **/
typedef NS_ENUM(NSInteger, WXPaymentType) {
    WXPaymentTypeWeChat,
    WXPaymentTypeALiPay,
};

/**
 * 回调
 * @param error             支付请求返回的错误
 * @param requestObject     支付请求发送的对象
 * @param responseObject    支付相应返回的对象
 **/
typedef void(^WXPaymentComletion)(NSError *error, id requestObject, id responseObject);

/**
 * 支付订单对象
 **/
@interface WXPaymentObject : NSObject
@property (strong, nonatomic) NSString *orderID;    /**< 商户订单ID，商户后台提供 */
@property (strong, nonatomic) NSString *orderTitle; /**< 商户订单标题，商户后台提供 */
@property (strong, nonatomic) NSString *orderPrice; /**< 订单价格，单位为元 */
@property (strong, nonatomic) NSString *wxPrePayID; /**< 微信预支付订单号,微信支付时必填！ */
@end
/**
 * 支付通用类
 **/
@interface WXPaymentManager : NSObject <WXApiDelegate>
@property (strong, nonatomic) WXPaymentComletion completion; /**< 回调 */

/**
 * 单例
 **/
+ (instancetype)defaultManager;
- (void)registerPaymentApp;
/**
 * 微信移动端独立发送统一订单请求方法
 * @param orderID       商户订单ID，商户后台提供
 * @param orderTitle    商户订单标题，商户后台提供
 * @param price         订单价格，单位为分
 * @param completion    业务回调
 * @brief 该方法用于没有后台请求统一下单接口的情况
 * @description 仅供测试用
 **/
- (void)sendWeChatPrePayAndPaymentRequestWithOrderID:(NSString *)orderID orderTitle:(NSString *)orderTitle price:(NSString *)price completion:(WXPaymentComletion)completion;
/**
 * 微信支付方法
 * @param object 支付的订单对象
 * @param completion 支付的回调方法
 **/
- (void)payForWeChatWithOrderObject:(WXPaymentObject *)object completion:(WXPaymentComletion)completion;
/**
 * 支付统一方法
 * @param payType 支付类型，阿里支付、微信支付
 * @param object 支付订单对象
 * @param completion 回调函数
 **/
- (void)payForType:(WXPaymentType)payType paymentObject:(WXPaymentObject *)object completion:(WXPaymentComletion)completion;
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
/**
 * 分享打开三方应用代理回调方法 (iOS9+)
 **/
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;

- (NSString *)createMd5Sign:(NSMutableDictionary*)dict;

- (NSString *)getIPAddress:(BOOL)preferIPv4;

- (NSDictionary *)getIPAddresses;

@end