//
//  WXPaymentObject.m
//  cdzer
//
//  Created by KEns0n on 2/1/16.
//  Copyright © 2016 CDZER. All rights reserved.
//



#import "WXPaymentObject.h"
#import "WXApiObject.h"
#import <AFNetworking/AFNetworking.h>
#import <CocoaSecurity/CocoaSecurity.h>
#import <XMLDictionary/XMLDictionary.h>

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@implementation WXPaymentObject


@end

@implementation WXPaymentManager
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (instancetype)defaultManager {
    static WXPaymentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)registerPaymentApp {
    [WXApi registerApp:WX_PAY_APP_ID];
    
}


#pragma mark - payment
- (void)payForType:(WXPaymentType)payType paymentObject:(WXPaymentObject *)object completion:(WXPaymentComletion)completion {
    switch (payType) {
        case WXPaymentTypeALiPay: {
            
            break;
        }
        case WXPaymentTypeWeChat: {
            [[WXPaymentManager defaultManager] payForWeChatWithOrderObject:object completion:completion];
            break;
        }
        default:
            break;
    }
}


- (void)payTestForWeChatWithOrderObject:(WXPaymentObject *)object completion:(WXPaymentComletion)completion {
    NSString *centPrice = [NSString stringWithFormat:@"%.f",object.orderPrice.floatValue*100];
    
    [self sendWeChatPrePayAndPaymentRequestWithOrderID:object.orderID orderTitle:object.orderTitle price:centPrice completion:^(NSError *error, id requestObject, id responseObject) {
        if (error != nil) {
            //            NSLog(@"Domain:%@\n Description:%@\n request:%@\n", error.domain, error.description, requestObject);
            if (completion != nil) {
                completion(error, requestObject, nil);
            }
        } else {
            
            if (centPrice.floatValue < 0) {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PRICE code:WXPaymentErrorCodeWeChatPriceLow userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"价格为负数！"]}];
                if (completion != nil) {
                    completion(error, nil, nil);
                }
            } else {
                if (responseObject != nil) {
                    NSString     *time_stamp, *nonce_str;
                    //设置支付参数
                    time_t now;
                    time(&now);
                    time_stamp  = [NSString stringWithFormat:@"%ld", now];
                    CocoaSecurityResult *result = [CocoaSecurity md5:time_stamp];
                    nonce_str    = result.hex;
                    //支付请求的参数一定要核对清楚
                    PayReq *payRequest             = [[PayReq alloc] init];
                    payRequest.openID              = WX_PAY_APP_ID;
                    payRequest.partnerId           = WX_PAY_PARTNER_ID;
                    payRequest.prepayId            = [responseObject objectForKey:@"prepayid"];//!!!!
                    payRequest.nonceStr            = nonce_str;
                    payRequest.timeStamp           = time_stamp.intValue;
                    payRequest.package             = WX_PAY_PACKAGE;//????
                    
                    //第二次签名参数列表
                    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                    [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
                    [signParams setObject: nonce_str    forKey:@"noncestr"];
                    [signParams setObject: WX_PAY_PACKAGE      forKey:@"package"];
                    [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
                    [signParams setObject: time_stamp   forKey:@"timestamp"];
                    [signParams setObject: [responseObject objectForKey:@"prepayid"]     forKey:@"prepayid"];
                    //[signParams setObject: @"MD5"       forKey:@"signType"];
                    //生成签名
                    NSString *sign  = [self createMd5Sign:signParams];
                    payRequest.sign                = sign;//????
                    BOOL status = [WXApi sendReq:payRequest];
                    if (!status) {
                        NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_REQUEST code:WXPaymentErrorCodeWeChatRequestError userInfo:@{NSLocalizedDescriptionKey:@"支付请求失败！"}];
                        if (completion != nil) {
                            completion(error, nil, nil);
                        }
                    } else {
                        if (completion != nil) {
                            completion(nil, nil, nil);
                        }
                    }
                    
                } else {
                    NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_RESPONSE code:WXPaymentErrorCodeWeChatResponseError userInfo:@{NSLocalizedDescriptionKey:@"服务器返回对象为空！"}];
                    if (completion != nil) {
                        completion(error, nil, nil);
                    }
                }
            }
            
            
        }
    }];
}

- (void)payForWeChatWithOrderObject:(WXPaymentObject *)object completion:(WXPaymentComletion)completion {
    if (object.wxPrePayID.length == 0) {
        NSError *error  = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PREPAYID code:WXPaymentErrorCodeWeChatGetPrePayIDFailed userInfo:@{NSLocalizedDescriptionKey:@"获取prepayid失败！\n"}];
        if (completion != nil) {
            completion(error, nil, nil);
        }
    } else {
        NSString     *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        CocoaSecurityResult *result = [CocoaSecurity md5:time_stamp];
        nonce_str    = result.hex;
        //支付请求的参数一定要核对清楚
        PayReq *payRequest             = [[PayReq alloc] init];
        payRequest.openID              = WX_PAY_APP_ID;
        payRequest.partnerId           = WX_PAY_PARTNER_ID;
        payRequest.prepayId            = object.wxPrePayID;//!!!!
        payRequest.nonceStr            = nonce_str;
        payRequest.timeStamp           = time_stamp.intValue;
        payRequest.package             = WX_PAY_PACKAGE;//????
        
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: WX_PAY_PACKAGE      forKey:@"package"];
        [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: object.wxPrePayID     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        payRequest.sign                = sign;//????
        BOOL status = [WXApi sendReq:payRequest];
        if (!status) {
            NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_REQUEST code:WXPaymentErrorCodeWeChatRequestError userInfo:@{NSLocalizedDescriptionKey:@"支付请求失败！"}];
            if (completion != nil) {
                completion(error, nil, nil);
            }
        } else {
            if (completion != nil) {
                completion(nil, nil, nil);
            }
        }
    }
}

- (void)startupWXPayRequest:(NSDictionary *)signParams {
    @autoreleasepool {
        //调起微信支付
        NSMutableString *stamp  = [signParams objectForKey:@"timestamp"];
        PayReq* req             = [PayReq new];
        req.partnerId           = [signParams objectForKey:@"partnerid"];
        req.prepayId            = [signParams objectForKey:@"prepayid"];
        req.nonceStr            = [signParams objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [signParams objectForKey:@"package"];
        req.sign                = [signParams objectForKey:@"sign"];
        [WXApi sendReq:req];
    }
}


- (void)sendWeChatPrePayAndPaymentRequestWithOrderID:(NSString *)orderID orderTitle:(NSString *)orderTitle price:(NSString *)price completion:(WXPaymentComletion)completion {
    
    [ProgressHUDHandler showHUD];
    if ([price rangeOfString:@"."].location!=NSNotFound) {
        price = @(price.doubleValue*100).stringValue;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.completion = completion;
        NSMutableDictionary *preOrder = [NSMutableDictionary dictionary];
        srand( (unsigned)time(0) );
        NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
        NSString *ipAdrress = [self getIPAddress:YES];
        if ([ipAdrress isContainsString:@"192"]||
            [ipAdrress isContainsString:@"10."]) {
            ipAdrress = WX_PAY_BILL_CREATE_IP;
        }
        [preOrder setObject: WX_PAY_APP_ID          forKey:@"appid"];       //开放平台appid
        [preOrder setObject: WX_PAY_PARTNER_ID      forKey:@"mch_id"];      //商户号
        [preOrder setObject: WX_PAY_DEVICE_INFO     forKey:@"device_info"]; //支付设备号或门店号
        [preOrder setObject: noncestr               forKey:@"nonce_str"];   //随机串
        [preOrder setObject: @"APP"                 forKey:@"trade_type"];  //支付类型，固定为APP
        [preOrder setObject: orderTitle             forKey:@"body"];        //订单描述，展示给用户
        [preOrder setObject: WX_PAY_NOTIFY_URL      forKey:@"notify_url"];  //支付结果异步通知
        [preOrder setObject: orderID                forKey:@"out_trade_no"];//商户订单号
        [preOrder setObject: ipAdrress  forKey:@"spbill_create_ip"];//发器支付的机器ip
        [preOrder setObject: price                  forKey:@"total_fee"];       //订单金额，单位为分
        
        [self getPrePayIDWithPrePayOrder:preOrder completion:^(NSError *error, id requestObject, id responseObject) {
            NSString *prePayID = responseObject;
            if (!error&&prePayID.length != 0) {
                NSString    *package, *time_stamp, *nonce_str;
                //设置支付参数
                time_t now;
                time(&now);
                time_stamp  = [NSString stringWithFormat:@"%ld", now];
                CocoaSecurityResult *result = [CocoaSecurity md5:time_stamp];
                nonce_str    = result.hex;
                //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
                //package       = [NSString stringWithFormat:@"Sign=%@",package];
                package         = WX_PAY_PACKAGE;
                //第二次签名参数列表
                NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
                [signParams setObject: nonce_str    forKey:@"noncestr"];
                [signParams setObject: package      forKey:@"package"];
                [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
                [signParams setObject: time_stamp   forKey:@"timestamp"];
                [signParams setObject: prePayID     forKey:@"prepayid"];
                //[signParams setObject: @"MD5"       forKey:@"signType"];
                //生成签名
                NSString *sign  = [self createMd5Sign:signParams];
                
                //添加签名
                [signParams setObject:sign forKey:@"sign"];
                [ProgressHUDHandler dismissHUD];
                [self startupWXPayRequest:signParams];
                
            } else {
                [ProgressHUDHandler dismissHUD];
                NSError *error  = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PREPAYID code:WXPaymentErrorCodeWeChatGetPrePayIDFailed userInfo:@{NSLocalizedDescriptionKey:@"获取prepayid失败！"}];
                if (self.completion != nil) {
                    self.completion(error, preOrder, nil);
                }
            }
            
        }];
    });
    
}

//- (void)postSynchronousRequestWithURL:(NSString *)urlString httpBody:(NSString *)httpBody
//                          withSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
////    manager.responseSerializer = [[AFXMLParserResponseSerializer alloc] init];
////    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
//    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@(httpBody.length).stringValue forHTTPHeaderField:@"Content-Length"];
//    
//    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlString parameters:nil error:nil];
//    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
//    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:success failure:failure];
//    [manager.operationQueue addOperation:operation];
//}

#warning 等待修改

- (void)getPrePayIDWithPrePayOrder:(NSMutableDictionary *)preOrder completion:(WXPaymentComletion)completion {
    NSString *packageSign = [self packageSign:preOrder];
    
//    [self postSynchronousRequestWithURL:WX_PAY_UNIFIEDORDER_API httpBody:packageSign withSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
//        NSString *prePayID = nil;
//        NSMutableDictionary *dictionary = [[XMLDictionaryParser.sharedInstance dictionaryWithData:responseObject] mutableCopy];
//        [dictionary removeObjectForKey:@"__name"];
//        NSString *return_code = dictionary[@"return_code"];
//        NSString *return_msg = dictionary[@"return_msg"];
//        if ([return_code isEqualToString:@"SUCCESS"]) {
//            NSString *result_code = dictionary[@"result_code"];
//            NSString *err_code = dictionary[@"err_code"];
//            NSString *err_code_des = dictionary[@"err_code_des"];
//            //生成返回数据的签名
//            NSString *sign = [self createMd5Sign:dictionary];
//            NSString *send_sign = dictionary[@"sign"];
//            
//            //验证签名正确性
//            if( [sign isEqualToString:send_sign]){
//                if( [result_code isEqualToString:@"SUCCESS"]) {
//                    //验证业务处理状态
//                    prePayID = dictionary[@"prepay_id"];
//                    return_code = 0;
//                    if (completion != nil) {
//                        completion(nil, nil, prePayID);
//                    }
//                    NSLog(@"获取预支付交易标示成功！\n");
//                } else {
//                    NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL code:WXPaymentErrorCodeWeChatResultCodeFail userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"获得prepayid失败, %@, %@", err_code, err_code_des]}];
//                    if (completion != nil) {
//                        completion(error, nil, nil);
//                    }
//                }
//            } else {
//                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_SIGN code:WXPaymentErrorCodeWeChatSignVerifyError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat: @"服务器返回签名验证错误！！！\n返回信息：%@", return_msg]}];
//                if (completion != nil) {
//                    completion(error, send_sign, nil);
//                }
//                //            last_errcode = 1;
//                //            [debugInfo appendFormat:@"gen_sign=%@\n   _sign=%@\n",sign,send_sign];
//                //            [debugInfo appendFormat:@"服务器返回签名验证错误！！！\n"];
//                
//            }
//        } else {
//            NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_SERVER code:WXPaymentErrorCodeWeChatSignVerifyError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"请求接口返回错误！！！\n返回信息：%@", return_msg]}];
//            if (completion != nil) {
//                completion(error, packageSign, nil);
//            }
//            //        last_errcode = 2;
//            //        [debugInfo appendFormat:@"接口返回错误！！！\n"];
//        }
//        
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        NSError *theError = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_SERVER code:WXPaymentErrorCodeWeChatSignVerifyError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"请求接口返回错误！！！\n返回信息：%@", @"连接逾时！"]}];
//        if (completion != nil) {
//            completion(theError, packageSign, nil);
//        }
//    }];
}
//获取package带参数的签名包
- (NSString *)packageSign:(NSMutableDictionary *)packageParams {
    NSString *sign;
    NSMutableString *reqPars = [NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in sortedArray) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}
/**
 * 具体签名加密方法见 https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=4_3
 **/
- (NSString *)createMd5Sign:(NSMutableDictionary*)dict {
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", WX_PAY_API_KEY];
    //得到MD5 sign签名
    CocoaSecurityResult *result = [CocoaSecurity md5:contentString];
    NSString *md5Sign = result.hex;
    
    return md5Sign;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {

    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return result;}

#pragma mark - wechat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *paymentResponse = (PayResp *)resp;
        switch (paymentResponse.errCode) {
            case 0: {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PAY_RESULT_SUCCESS code:WXPaymentErrorCodeWeChatPaySuccess userInfo:@{NSLocalizedDescriptionKey:@"支付成功！"}];
                if (self.completion != nil) {
                    self.completion(error, nil, @"SUCCESS");
                }
                break;
            }
            case -1: {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PAYFAILED code:WXPaymentErrorCodeWeChatPayFailed userInfo:@{NSLocalizedDescriptionKey:@"支付失败，可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等"}];
                if (self.completion != nil) {
                    self.completion(error, nil, nil);
                }
                break;
            }
            case -2: {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED code:WXPaymentErrorCodeWeChatPayCanceled userInfo:@{NSLocalizedDescriptionKey:@"用户取消支付"}];
                if (self.completion != nil) {
                    self.completion(error, nil, nil);
                }
                break;
            }
            default:
                break;
        }
    }
}


@end
