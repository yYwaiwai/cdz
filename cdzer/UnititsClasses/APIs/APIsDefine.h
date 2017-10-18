//
//  APIsDefine.h
//  cdzer
//
//  Created by KEns0n on 2/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, CDZMaintenanceStatusType) {
    CDZMaintenanceStatusTypeOfAppointment = 1,
    CDZMaintenanceStatusTypeOfDiagnosis = 2,
    CDZMaintenanceStatusTypeOfUserAuthorized = 3,
    CDZMaintenanceStatusTypeOfHasBeenClearing = 4,
};

static NSString *const CDZKeyOfErrorCodeKey = @"msg_code";
static NSString *const CDZKeyOfMessageKey = @"reason";
static NSString *const CDZKeyOfResultKey = @"result";
static NSString *const CDZKeyOfPageNumsKey = @"page_no";
static NSString *const CDZKeyOfPageSizesKey = @"page_size";
static NSString *const CDZKeyOfTotalPageSizesKey = @"total_size";











#pragma mark- /////////////////////////////////////////////////////APIs Base Define（接口配置）/////////////////////////////////////////////////////
#define kCDZSubPathTypeOfConnect @"connect"
#define kCDZSubPathTypeOfIntercept @"intercept"
#define kCDZSubPathTypeOfPeiConnect @"peiConnect"
#define kCDZSubPathTypeOfPersonalConnect @"personalConnect"
#define kCDZSubPathTypeOfGPS @"gps"
#define kCDZSubPathTypeOfImageUpload @"imgUpload"
#define kCDZSubPathTypeOfRapidRepair @"rapidRepair"
#define kCDZSubPathTypeOfMaintain @"maintain"
#define kCDZSubPathTypeOfOrder @"order"
#define kCDZSubPathTypeOfProduct @"product"
#define kCDZSubPathTypeOfMember @"member"
#define kCDZSubPathAppendingPathComponent(basePath,appendingPath) [basePath stringByAppendingPathComponent:appendingPath]


#pragma mark- /////////////////////////////////////////////////////Personal Center APIs（个人中心接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////用户/////##########/////
/* 个人基本资料 */
#define kCDZPersonalInfoDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"basicInformation")                         //个人基本资料
/* 用户注册 */
#define kCDZPersonalRegister kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appRegister")                                        //用户注册
/* 用户注册验证码 */
#define kCDZPersonalRegisterValidCode kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appRegisterUser")                           //用户注册
/* 用户忘记密码 */
#define kCDZPersonalForgotPassword kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appPassword")                                  //用户注册
/* 用户忘记密码验证码 */
#define kCDZPersonalForgotPasswordValidCode kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appPasswordUser")                           //用户注册

/* 用户登录 */
#define kCDZPersonalLogin kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"login")                                                 //用户登录
/* 验证Token期限 */
#define kCDZPersonalTokenValid kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appUserTokencheck")                                //验证Token期限
/* 用户修改密码 */
#define kCDZPersonalChangePW kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"updatePassWord")                           //用户修改密码
/* 用户基本资料修改 */
#define kCDZPersonalInfoUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"updateBasicInformation")                 //用户更新个人资料
/* 用户个人头像修改 */
#define kCDZPersonalImageUpload kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfImageUpload, @"imgUpload")                                 //用户个人头像修改

/* 用户积分验证码 */
#define kCDZPersonalCreditValidCode kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appcheckCredtis")                             //用户积分验证码

#pragma mark /////##########/////车辆管理/////##########/////
/* 车辆列表 */
#define kCDZMyAutoList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"carList")                                                //车辆列表
/* 车辆修改 */
#define kCDZMyAutoUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"confrimUpdateCardet")                                  //车辆修改
/* 车辆颜色 */
#define kCDZMyAutosColorList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"carColor")                                   //车辆颜色
/* 车牌省列表 */
#define kCDZMyAutosProvincesList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"carNumber")                              //车牌省列表
/* 车牌市列表 */
#define kCDZMyAutosCityList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"addCarNumberTwo")                        //车牌市列表


#pragma mark /////##########/////收藏/////##########/////
/* 收藏的商品列表 */
#define kCDZProductsCollectionList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"myColGoods")                            

/* 收藏的店铺列表 */
#define kCDZShopsCollectionList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"myColStore")

/* 收藏的技师列表 */
#define kCDZMechanicCollectionList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"colTechnicianList")


/* 添加收藏的商品 */
#define kCDZProductsCollectionAdd kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appColGoods")                               //添加收藏的商品
/* 删除收藏的商品 */
#define kCDZProductsCollectionDelete kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"delMyColGoods")                          //删除收藏的商品
/* 删除收藏的店铺 */
#define kCDZShopsCollectionDelete kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"delShop")                                   //删除收藏的店铺
/* 检测商品是否已收藏 */
#define kCDZProductWasCollected kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"peiShopCollect")                                  //检测商品是否已收藏
/* 检测店铺是否已收藏 */
#define kCDZShopsWasCollected kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"colStoreCollect")                               //检测店铺是否已收藏


#pragma mark /////##########/////订单/////##########/////
/* 订单列表 */
#define kCDZPurchaseOrderList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appTradeListNo")                                //订单列表
/* 订单详情 */
#define kCDZPurchaseOrderDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"orderDetail")                                 //订单详情
/* 提交订单 */
#define kCDZPurchaseOrderSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"consignee")                                          //提交订单
/* 免加入购物车提交订单 */
#define kCDZPurchaseOrderExpressSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"quickConsignee")                              //免加入购物车提交订单

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 订单确认 */
#define kCDZPurchasesOrderConfirm kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"confirmOrder")                              //订单确认和付款
/* 订单付款方法－货到付款/状态更变 */
#define kCDZPaymentMethodByCashOnDelivery kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"finished")                          //订单付款方法－货到付款/状态更变
/* 订单付款方法－银联 */
#define kCDZPaymentMethodByUnionPay kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"wayofPay")                                //订单确认和付款
/* 订单付款方法－支付宝 */
#define kCDZPaymentMethodByAlipay kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appAlipay")
/* 订单付款方法－微信 */
#define kCDZPaymentMethodChangeToWX kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"wexinAlipay")
/* 更新支付状态 */
#define kCDZPaymentStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAccountRepair")
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 订单完成发表评论 */
#define kCDZPurchaseOrderComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"subComment")                                 //订单完成发表评论
/* 订单完成查看评论 */
#define kCDZPurchaseOrderCommentView kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appQueryComment")                    //订单完成查看评论
/* 取消订单 */
#define kCDZPurchaseOrderCancel kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appDelOrder")                          //取消订单
/* 订单删除 */
#define kCDZPurchaseOrderDelete kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appDeleteOrder")                        //订单删除
/* 确定收货 */
#define kCDZPurchaseOrderGoodsArrivedConfirm kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"confirmReceipt")                  //确定收货
/* 用户申请退货 */
#define kCDZPurchaseOrderReturnOfGoods kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"orderRetFm")                           //用户申请退货
/* 确定退货完成 */
#define kCDZPurchaseOrderGoodsReturnConfirm kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appConfirmReturn")                  //确定退货完成

#pragma mark /////##########/////保险/////##########/////
/* 检测用户保险信息 */
#define kCDZUserInsuranceInfoCheck kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"myInurancelist")                   //检测用户保险信息
/* 用户已预约保险列表 */
#define kCDZUserInsuranceAppointmentList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"AppShowInsuranceApp")        //用户已预约保险列表
/* 用户已购买保险列表 */
#define kCDZUserInsurancePurchasedList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appShowInsuranceInfo")         //用户已购买保险列表
/* 用户已登记的保险车辆 */
#define kCDZUserInsuranceAutosList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appUpdateCar")                     //用户已登记的保险车辆
/* 用户已登记的保险车辆保费详情 */
#define kCDZUserInsuranceAutosPremiumDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appPremiumDetail")        //用户已登记的保险车辆保费详情
/* 用户保险详情 */
#define kCDZUserInsuranceDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appInsuranceAppBuyList")              //用户保险详情
/* 添加保险车辆信息 */
#define kCDZUserAutosInsuranceInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appPremiumAddCar")                 //添加保险车辆信息
/* 提交保险信息 */
#define kCDZUserAutosInsuranceAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAddPremiumList")         //提交保险信息

#pragma mark /////##########/////新的预约   保险/////##########/////
/* 点击首页的预约保险 */
#define kCDZUserAutosInsuranceMyInurancelist kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"myInurancelist")         //点击首页的预约保险
/* 添加保险车辆 */
#define kCDZUserAutosInsuranceAppPremiumAddCar kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appPremiumAddCar")         //添加保险车辆
/* 更换车辆 */
#define kCDZUserAutosInsuranceChangeCarNumber kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"changeCarNumber")         //更换车辆
/*保险公司*/
#define kCDZUserAutosInsuranceGetCompany kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getCompany")         //保险公司
/* 上传身份证和行驶证 */
#define kCDZCasesHistoryImageUploadCZD kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfImageUpload, @"cdz")
/* 预约保险 */
#define kCDZUserAutosInsuranceAppAddPremiumList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAddPremiumList")         //预约保险

/* 我的保险列表 */
#define kCDZUserAutosInsuranceAppShowInsuranceApp kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"AppShowInsuranceApp")         //我的保险列表
/* 保险详情 */
#define kCDZUserAutosInsuranceAppInsuranceAppBuyList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appInsuranceAppBuyList")         //保险详情
/* 点击重新预约 */
#define kCDZUserAutosInsuranceAppInsuranceReAppoint kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"reAppoint")         //点击重新预约
/* 确定重新预约 */
#define kCDZUserAutosInsuranceConfirmReAppoint kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"confirmReAppoint")         //确定重新预约



#pragma mark /////##########/////GPS购买/////##########/////
/* GPS购买 */
#define kCDZGPSPurchasesAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getCarInfo")                               //GPS购买

#pragma mark /////##########/////优惠劵/////##########/////
/* 维修商优惠券列表 */
#define kCDZRepairShopCouponAvailableList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"shopPreferList")                    //维修商优惠券列表
/* 个人领取维修商优惠券 */
#define kCDZRepairShopUserCollectCoupon kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getShopPreference")                   //个人领取维修商优惠券
/* 个人中心我的优惠券列表 */
#define kCDZMyCouponUserCollectedCouponList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"preferList")              //个人中心我的优惠券列表
/* 使用优惠券选择列表 */
#define kCDZMyCouponAppleySelection kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"userPreference")                  //使用优惠券选择列表

#pragma mark /////##########/////E-代修/////##########/////
/* E服务检测用户是否预约 */
#define kCDZEServiceVerifyUserWasMadeAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"showErepairYesNo")        //E服务检测用户是否预约
/* 提交预约E服务 */
#define kCDZEServiceMakeAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAddERepair")                        //提交预约E服务服务
/* E服务列表 */
#define kCDZEServiceList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"ShowErepairListone")                              //E服务列表
/* E服务详情 */
#define kCDZEServiceDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"erepairAppoint")                                //E服务详情
/* 取消E服务 */
#define kCDZEServiceServiceCancel kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appCancelERepair")                       //取消服务
/* E服务确认还车 */
#define kCDZEServiceConfirmVehicleReturn kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"ensureGetCar")                    //E服务确认还车
/* E服务专员简单资讯  */
#define kCDZEServiceAssistantDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"commissionerBasic")                    //E服务专员简单资讯
/* E服务提交评论 */
#define kCDZEServiceSubmitComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"subErepairComment")                      //E服务提交评论
/* E服务查看评论 */
#define kCDZEServiceReviewComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"showErepairComment")                     //E服务查看评论
/* E服务支付确认信息 */
#define kCDZEServicePaymentConfirmInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"ReadyPayMengt")                     //E服务支付确认信息
/* E服务支付初始化信息 */
#define kCDZEServicePaymentInitInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"eServerOrder")                                //E服务支付初始化信息
/* E服务地址检测 */
#define kCDZEServiceVerifyUserAddress kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"eServerFee")                        //E服务地址检测
/* 获取E服务专员列表  */
#define kCDZEServiceConsultantPostionList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"MapPostion")                    //获取E服务专员列表
/* 获取E服务专员详情 */
#define kCDZEServiceConsultantDeatil kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"commDetalis")                    //获取E服务专员详情
/* 获取E服务专员详情和评论 */
#define kCDZEServiceConsultantDeatilWithComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"commissionerDetail")                    //获取E服务专员详情和评论

/* 获取E服务用户会员状态和服务价钱 */
#define kCDZEServiceUserMemberStatusNPrice kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"memberGrade")

/* 提交E服务积分支付 */
#define kCDZEServiceCreditsPayment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"creditEServer")                    //提交E服务积分支付

/* 请求E服务积分验证码 */
#define kCDZEServiceCreditsRequestVerifyCode kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appEservceverify")                    //请求E服务积分验证码

#pragma mark /////##########/////商家会员/////##########/////
/* 用户的商家列表 */
#define kCDZUserRepairShopMemberList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"shopMerberList")                           //用户的商家列表
/* 会员置顶 */
#define kCDZUserSetRepairShopMembershipToTop kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"AboveMerber")                     //会员置顶
/* 取消会员 */
#define kCDZUserCancelRepairShopMembership kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"cancleMerber")                     //取消会员
/* 取消会员 */
#define kCDZUserJoinRepairShopMembership kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"addMerber")                          //取消会员
/* 商家公告列表*/
#define kCDZRepairShopAnnouncementList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"NoticeList")                       //更新地
/* 商家公告详情*/
#define kCDZRepairShopAnnouncementDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"NoticeList")                       //更新地


#pragma mark /////##########/////地址/////##########/////
/* 地址列表 */
#define kCDZShippingAddressList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"addressList")                                 //地址列表
/* 添加地址 */
#define kCDZShippingAddressAdd kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"addConsigneeList")                             //添加地址
/* 地址详情 */
#define kCDZShippingEditDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"editConsignee")
/* 删除地址 */
#define kCDZShippingAddressDelete kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"delConsigneeList")                           //删除地址
/* 更新地址 */
#define kCDZShippingAddressUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfIntercept, @"updateConsigneeTest")                       //更新地址


#pragma mark /////##########/////购物车/////##########/////
/* 购物车列表 */
#define kCDZCartOfCartList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"showCart")                                         //购物车列表
/* 添加商品到购物车 */
#define kCDZCartOfAddCart kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"addCart")                                           //加入购物车
/* 删除购物车的商品 */
#define kCDZCartOfDeleteCart kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"delCart")                                        //删除购物车


#pragma mark /////##########/////车辆维修/////##########/////
////////////////////* 查询维修列表由维修类型 *////////////////////
#define kCDZAutosRepairStatusOfAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appointList")                       //已预约
#define kCDZAutosRepairStatusOfDiagnosis kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appRepairList")                       //已诊断
#define kCDZAutosRepairStatusOfUserAuthorized kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appRepairEntrust")               //已授权
#define kCDZAutosRepairStatusOfHasBeenClearing kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appRepairAccounts")             //以结算

#define kCDZAutosRepairStatusOfAppointmentDetial kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAuditAppointment")         //已预约详情
#define kCDZAutosRepairStatusOfDiagnosisDetial kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appDiagnoseDetailOne")          //已诊断详情
#define kCDZAutosRepairStatusOfUserAuthorizedDetial kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"showEntrustSheetTwo")               //已授权详情
#define kCDZAutosRepairStatusOfHasBeenClearingDetial kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"showBalanceSheet1Three")             //以结算详情

////////////////////* 查询维修详情由维修类型 *////////////////////
/* 确认委托维修授权 */
#define kCDZAutosRepairConfirm kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAgreeRepair")                              //确认委托维修授权
/* 结算信息准备 */
#define kCDZAutosRepairClearingReady kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appPayRepair")                          //结算信息准备
/* 取消维修 */
#define kCDZAutosRepairCancelMaintenance kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appCancleRepair")                   //取消维修

////////////////////* 结算维修 *////////////////////
/* 优惠劵结算维修 */
#define kCDZAutosRepairClearingByCoupon kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAccountRepairThree")               //优惠劵结算维修
/* 全积分结算维修 */
#define kCDZAutosRepairClearingByAllOfCredits kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAccountRepair")              //全积分结算维修
/* 部分积分结算维修 */
#define kCDZAutosRepairClearingByPartOfCredits kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAccountRepairCredtis")      //部分积分结算维修
/* 支付完成通知 */
#define kCDZUserPaymentFinishNotify kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appNotify")           //支付完成通知

#pragma mark /////##########/////其他/////##########/////
/* 询价 */
#define kCDZSelfEnquireProductsPrice kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"appAskPrice")                            //询价
/* 积分列表 */
#define kCDZCreditPointsHistory kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"creditsList")                                 //积分列表
/* 采购中心列表 */
#define kCDZPurchaseCenterList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"centerNameList")                               //采购中心列表



#pragma mark- /////////////////////////////////////////////////////Autos Parts APIs（配件接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////汽车配件选择/////##########/////
/* 配件第一级分类 */
#define kCDZAutosPartsSearchStepOne kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"autopartType")                              //配件第一级分类
/* 配件第二级分类 */
#define kCDZAutosPartsSearchStepTwo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"autopartList")                              //配件第二级分类
/* 配件第三级分类 */
#define kCDZAutosPartsSearchStepThree kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"autopartInfo")                            //配件第三级分类
/* 配件第四级分类 */
#define kCDZAutosPartsSearchStepFour kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"userProduct")                              //配件第四级分类
/* 配件询价 */
#define kCDZAutosPartsEnquirePrice kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"askPrice")                                   //配件询价
/* 配件推荐列表 */
#define kCDZAutosPartsRecommendProduct kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"recommendProduct")
/* 配件评论列表 */
#define kCDZAutosPartsComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"detailcomment")                                      //配件用户评论
/* 搜索配件 */
#define kCDZAutosPartsKeywordSearch kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPeiConnect, @"appSearchProduct")                                //搜索配件

#pragma mark- /////////////////////////////////////////////////////Maintenance Shops APIs（维修商接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////查询维修商、维修商详情和附属接口/////##########/////
/* 查询维修商 */
#define kCDZMaintenanceShopSearch kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"searchStore")                               //查找维修商
/* 维修商详情 */
#define kCDZMaintenanceShopDetails kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"shopDetails")                              //维修商详情
/* 维修商种类 */
#define kCDZMaintenanceShopType kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"wxsType")                                     //维修商类型
/* 维修商评论列表 */
#define kCDZMaintenanceShopComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"userComment")                              //维修商用户评论
/* 维修商公用设施 */
#define kCDZMaintenanceShopEquipment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"shopEquipment")                          //维修商公用设备
/* 预约维修商保养或者维修选择 */
#define kCDZMaintenanceShopAppointmentDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appointment")                    //预约保养或者维修
/* 确认和提交预约信息 */
#define kCDZMaintenanceShopConfirmAppointment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"confirmAppoint")                //确认和提交预约信息
/* 维修完成评论 */
#define kCDZMaintenanceShopRepairFinishComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"subCommentShop")                    //维修完成评论
/* 获取预约维修资讯 */
#define kCDZMaintenanceShopAppointmentRepairInfoPrepare kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"repairInfo")                    //获取预约维修资讯 
/* 获取预约保养资讯  */
#define kCDZMaintenanceShopAppointmentMaintenanceInfoPrepare kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"maintainStoreMessageUpkeep")                    //获取预约保养资讯



#pragma mark- /////////////////////////////////////////////////////Self-Diagnosis APIs（自助诊断接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////自助诊断结果/////##########/////
/* 故障解决方案 */
#define kCDZSelfDiagnosisSolutionPlan kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultScheme")                           //解决方案
/* 配件更换建议 */
#define kCDZSelfDiagnosisReplacementParts kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultParts")                        //更换配件
/* 获取维修商 */
#define kCDZSelfDiagnosisResult kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultResult")                                 //诊断结果


#pragma mark- /////////////////////////////////////////////////////Self-Maintenance APIs（自助保养接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////自助维修步骤和结果/////##########/////
/* 获取保养信息 */
#define kCDZSelfMaintenanceGetInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getMaintain")                              //保养信息
/* 选择保养服务 */
#define kCDZSelfMaintenanceServiceList  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"chooseMaintain")                      //保养服务
/* 配件详情 */
#define kCDZSelfMaintenancePartsDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"detail")                               //配件详情
/* 保养项目配件需求列表 */
#define kCDZSelfMaintenancePartsRequestList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"appMaintainResult")               //保养项目配件需求列表



#pragma mark- /////////////////////////////////////////////////////Get History Cases of Success APIs（获取案例接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////获取案例步骤/////##########/////
/* 获取案例第一级分类 */
#define kCDZCasesHistoryListStepOne kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"caseSecond")                                 //获取案例第一级分类
/* 获取案例第二级分类 */
#define kCDZCasesHistoryListStepTwo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"caseThird")                                 //获取案例第二级分类
/* 获取案例结果 */
#define kCDZCasesHistoryResultList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"caseSixth")                                 //获取案例结果

/* 获取案例 */
#define kCDZCasesHistoryOfCaseList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"gainCase")                                 //获取案例
/* 案例详情 */
#define kCDZCasesHistoryOfCaseDetail  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"displayCase")                        //案例详情



#pragma mark- /////////////////////////////////////////////////////Common APIs（公用接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////新自助诊断步骤/////##########/////
/* 新自助诊断第一步 */
#define kCDZSelfDiagnoseFirstStepList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"diagnoseSecond")                                       //新自助诊断第一步
/* 新自助诊断第二步 */
#define kCDZSelfDiagnoseSecondStepList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"diagnoseThird")                                       //新自助诊断第二步
/* 新自助诊断第三步 */
#define kCDZSelfDiagnoseThirdStepList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"diagnoseFourth")                                       //新自助诊断第三步
/* 新自助诊断第四步 */
#define kCDZSelfDiagnoseFourthStepList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"diagnoseFifth")                                       //新自助诊断第四步
/* 新自助诊断第五步 */
#define kCDZSelfDiagnoseFifthStepList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"diagnoseSixth")                                       //新自助诊断第五步
/* 新自助诊断结果 */
#define kCDZSelfDiagnoseFinalResultList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"searchQuote")                                       //新自助诊断结果



#pragma mark /////##########/////获取案例和自助诊断公用步骤/////##########/////
/* 故障种类 */
#define kCDZAutosFailureType kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultKind")                                       //故障种类
/* 故障现象 */
#define kCDZAutosFaultSymptom kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultPhenomenon")                                //故障现象
/* 故障架构 */
#define kCDZAutosFaultStructure kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultConstruction")                            //故障结构
/* 故障原因分析 */
#define kCDZAutosFaultDiagnosis kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"faultReason")                                  //故障原因


#pragma mark /////##########/////汽车型号选择/////##########/////
/* 车辆品牌 */
#define kCDZAutoBrandList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"brandList")                                         //车辆品牌
/* 车辆经销商 */
#define kCDZAutosFactoryName kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"factoryName")                                     //汽车厂商
/* 车辆系列 */
#define kCDZAutosFctList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"fctList")                                             //车辆系列
/* 车辆品牌 */
#define kCDZAutoSpecList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"specList")                                           //车型


#pragma mark /////##########/////维修指南/////##########/////
/* 维修指南 */
#define kCDZRepairGuideMainPageData kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"repairGuides")                            //维修指南
/* 维修指南二级列表 */
#define kCDZRepairGuideSubTypeList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"repairSort")                               //维修指南二级列表
/* 维修指南三级列表 */
#define kCDZRepairGuideResultList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"guideInfo")                            //维修指南三级列表
/* 维修指南详情 */
#define kCDZRepairGuideProcedureDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"repairTheGuides")                //维修指南详情
/* 维修指南指导资讯 */
#define kCDZRepairStepGuideDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"repairInspect")                 //维修指南指导资讯
/* 维修指南指导结果 */
#define kCDZRepairStepGuideFinalResult kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getInspectPrice")                 //维修指南指导结果

#pragma mark /////##########/////违章/////##########/////
/* 违章查询界面，车辆及违章次数界面 */
#define kCDZUserViolationEnquiryInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getUsercarInfo")
/* 违章查询 */
#define kCDZUserViolationEnquiryRequest kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getViolationInfo")
/* 高发地查询列表 */
#define kCDZViolationCityBlacksiteList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getViolationPoint")
/* 违章排行榜列表 */
#define kCDZUserViolationLocationRank kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getViolationRank1")
/* 高发地神坑排行榜列表 */
#define kCDZViolationLocationRank kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getViolationRank2")
/* 违章详情 */
#define kCDZViolationPlaceDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getViolationPlaceInfo")
/* 违章地点纠错 */
#define kCDZUserViolationPlaceCorrect kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"subCorrectInfo")


#pragma mark /////##########/////车考题库/////##########/////
/* 榜上有名查询 */
#define kCDZTrafficExaminationRankingList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"getRankList")
/* 易错题目列表 */
#define kCDZTrafficExaminationMostlyFailureList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getEasyWrongList")
/* 模拟考试提交 */
#define kCDZTrafficExaminationSubmitSimulateExam kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"subDriverExam")


#pragma mark /////##########/////其他/////##########/////
/* 省份列表 */
#define kCDZProvinceList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"provinceList")                                       //获取所有省份
/* 城市列表 */
#define kCDZCityListWithProvince kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"cityList")                                   //获取所有重点城市／部分城市由省份筛选
/* 区列表 */
#define kCDZDistrictListWithCity kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"areaList")                                   //获取地区由城市筛选
/* 维修商类型列表 */
#define kCDZRepairShopType kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"wxsType")                                          //获取维修商类型列表
/* 维修商保养服务类型列表 */
#define kCDZRepairShopServiceType kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"serviceItemName")                           //获取维修商保养服务类型列表
/* 维修商保养服务列表 */
#define kCDZRepairShopServiceList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"maintainItemList")                          //获取维修商保养服务列表
/* 订单状态列表 */
#define kCDZPurchaseOrderStatusList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"orderStateName")                          //订单状态列表
/* 首页轮播接口 */
#define kCDZMainPageAdvertisingInfoList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"getShuffling")                                 //首页轮播接口

#pragma mark- /////##########/////GPS/////##########/////
#pragma mark /////##########/////GPS配置/////##########/////
/* 车辆实时位置信息 */
#define kCDZGPSAutoRealtimeInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"refreshCar")                                        //车辆实时位置信息

/* 查询GPS上传设置 */
#define kCDZGPSUploadSettingStauts kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getPersonalSetting")                             //查询个人设置
/* 修改GPS上传设置 */
#define kCDZGPSUpdateUploadSetting kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"updateCustLocainfo")                             //修改个人设置


#pragma mark /////##########/////OBD&&车辆配置/////##########/////
/* 服务密码验证 */
#define kCDZGPSAuthorizeServerSecurityPW kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"verSerPwd")                                //服务密码验证

/* 快速设防详情 */
#define kCDZGPSFastPreventionDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"defenceDetail")                                 //快速设防详情
/* 开启快速设防 */
#define kCDZGPSFastPreventionOn kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"defenceAdd")                                        //开启快速设防
/* 关闭快速设防 */
#define kCDZGPSFastPreventionOff kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"defencedelete")                                    //关闭快速设防

/* 省电设置详情 */
#define kCDZGPSAutoPowerSaveStatus kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getCarLocationState")                            //省电设置详情
/* 修改省电设置 */
#define kCDZGPSAutoPowerSaveChangeStatus kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"setCarLocationState")                      //修改省电设置

/* 设备安装校正 */
#define kCDZGPSAutoDeviceCalibrate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"setDeviceInstall")                               //设备安装校正
/* 点火熄火校准 */
#define kCDZGPSAutoIgnitionSystemCalibrate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"setCarAcc")                              //点火熄火校准

/* 获取安全设置 */
#define kCDZGPSAutoAllAlertStatusList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getSafetySet")                                //获取安全设置
/* 修改侧翻设置 */
#define kCDZGPSAutoRoleAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"cfSet")                                    //修改侧翻设置
/* 修改碰撞设置*/
#define kCDZGPSAutoImpactAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"pzSet")                                  //修改碰撞设置
/* 修改电瓶低电压设置 */
#define kCDZGPSAutoBatteryLowAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"dpddySet")                           //修改电瓶低电压设置
/* 修改拖车设置 */
#define kCDZGPSAutoTrailingAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"tcSet")                                //修改拖车设置
/* 修改设备移除（断电）设置 */
#define kCDZGPSAutoODBRemoveAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"ddSet")                               //修改设备移除(断电)设置
/* 修改防盗喇叭设置 */
#define kCDZGPSAutoSecurityAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"fdlbSet")                              //修改防盗喇叭设置
/* 修改疲劳驾驶设置 */
#define kCDZGPSAutoFatigueDrivingAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"pljsSet")                        //修改疲劳驾驶设置

/* 获取超速设置 */
#define kCDZGPSAutoOverSpeedSetting kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getOverSpeedSet")                               //获取超速设置
/* 修改超速设置 */
#define kCDZGPSAutoOverSpeedSettingUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"subOverSpeedSet")                         //修改超速设置

/* 获取断油断电设置 */
#define kCDZGPSAutoPowerAndOilControlStatus kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getDydd")                               //获取断油断电设置
/* 修改断油断电设置*/
#define kCDZGPSAutoPowerAndOilControlStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"setDydd")                         //设置断油断电


/* 查询个人电子围栏 */
#define kCDZGPSAutoElectricFencingDetial kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"getGeofenceSet")                           //查询个人电子围栏
/* 增加电子围栏 */
#define kCDZGPSAutoAddElectricFencing kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"setGeofence")                                 //增加电子围栏
/* 删除电子围栏 */
#define kCDZGPSAutoRemoveElectricFencing kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"delGeofence")                               //删除电子围栏


/* OBD主动查询 */
#define kCDZGPSAutoOBDData kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"obdCheck")                                               //OBD主动查询
/* OBD故障检测 */
#define kCDZGPSAutoOBDDiagnosis kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"checkFault")                                        //OBD故障检测


#pragma mark /////##########/////GPS、汽车记录和数据/////##########/////
/* 行车轨迹 */
#define kCDZGPSAutoDrivingHistoryList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"appQueryPoint")                               //行车轨迹
/* 清除行车历史轨迹 */
#define kCDZGPSEraseDrivingHistory kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"delCustHistory")                                 //清除行车历史轨迹


#pragma mark /////##########/////其他/////##########/////
/* 消息列表 */
#define kCDZMessageAlertList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfGPS, @"appUserCarMessageList")                                  //消息列表
/* 消息删除 */
#define kCDZMessageAlertMessageDelete kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfConnect, @"deleteMessage")                     //消息状态更新
/* 消息状态更新 */
#define kCDZMessageAlertStatusUpdate kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"updateMessageState")                     //消息状态更新
/* 消息已读状态 */
#define kCDZMessageWasReadedStatus kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"noReadMessage")                     //消息已读状态
/* 推送消息设置 */
#define kCDZAPNSPushSetting kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"yesOrNointernalMessages")

/* 问卷接口 */
#define kCDZAppSurvey kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"questionnaireSurveyTwo")                   //问卷接口


/* 意见反展示馈接口 */
#define kCDZMyFeedbackToShowInfoList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"suggestHistory")                   //意见反馈展示接口

/* 意见反馈提交接口 */
#define kCDZMyPersonalSettingsUserFeedbackInfoList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"addSuggestion")                   //意见反馈提交接口




#pragma mark- /////////////////////////////////////////////////////EDR APIs（行车记录仪接口）/////////////////////////////////////////////////////
/* 行车广场 或 我的动态 列表 */
#define kCDZEDRFetchList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"carSquare")                      //行车广场 或 我的动态 列表
/* 行车广场 或 我的动态 详情 */
#define kCDZEDRFetchDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"carSquareDetails")             //行车广场 或 我的动态 详情
/* 行车广场关注或取消关注 */
#define kCDZEDRFollowAction kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"SendSquareAttention")         //行车广场关注或取消关注
/* 行车广场 点赞或 取消点赞 */
#define kCDZEDRLikeAction kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"SendSquareZan")                 //行车广场 点赞或 取消点赞
/* 行车广场 评论或回复 */
#define kCDZEDRCommentOrReply kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"SendSquareComment")         //行车广场 评论或回复
/* 行车广场 之发布动态 */
#define kCDZEDRSubmitShareFetch kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"SendSquareState")         //行车广场 之发布动态
/* 行车广场 个人粉丝／关注列表 */
#define kCDZEDRUserFanOrFollowedList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"CarLookAfter")         //行车广场 个人粉丝／关注列表



#pragma mark- /////////////////////////////////////////////////////Rapid Repair APIs（快速维修接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////快速维修/////##########/////
/* 首页的专业服务、维修商列表的专修服务项目 */
#define kCDZRapidRepairServiceItemList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"serviceItem")

/* 首页的专修服务品牌列表 */
#define kCDZRapidRepairServiceItemBrandList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"productBrand")

/* 首页的快速维修列表 */
#define kCDZRapidRepairShopList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"wxsList")

/* 维修商地图列表（显示周围10公里的维修商） */
#define kCDZRapidRepairShopMapList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"wxsMapList")

/* 品牌或专修项目搜索列表 */
#define kCDZRapidRepairBrandNSpecServiceList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"serviceWxsList")

/* 专修店——电瓶、玻璃、轮胎 */
#define kCDZRapidRepairSpecItemServiceList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"productList")

/* 轮胎规格 */
#define kCDZRapidRepairTireSpecList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"tyreSize")

/* 选择轮胎【个人中心有车辆，但default_model为空时，访问此接口】 */
#define kCDZRapidRepairTireDefaultSpec kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"wheelModel")

/* 确定轮胎型号【点击推荐的轮胎型号，或者点击更换其他中的搜索轮胎时访问此接口】 */
#define kCDZRapidRepairTireSpecSelectionSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"selectWheelModel")

/* 车辆信息（选择轮胎时，个人中心没有车辆或者点击更换车辆访问此接口）*/
#define kCDZLiteUpdateUserAutosData kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"addCarInfo")

/* 维修商的详情页面 */
#define kCDZRapidRepairShopOrServiceDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"wxsDetail")

/* 维修商属下维修技师 */
#define kCDZMaintenanceShopTechnicianList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"technicianList")

/* 维修商属下维修技师详情 */
#define kCDZMaintenanceShopTechnicianDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"technicianDetail")

/* 维修商评论列表(商家评价) */
#define kCDZMaintenanceShopCommentList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"wxsShopCommentList")

/* 特殊（轮胎，玻璃，电瓶）产品详情 */
#define kCDZRapidRepairSpecPartsDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"productDetail")

/* 产品评价 */
#define kCDZAutosProductCommentList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"productCommentList")

/* 产品中心 */
#define kCDZAutosProductCenterList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"productCenter")

/* 立即购买（轮胎、电瓶、玻璃） */
#define kCDZRapidRepairSpecPartsBuyNow kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"buyNow")

/* 提交订单（轮胎、电瓶、玻璃） */
#define kCDZRapidRepairSpecPartsOrderSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"submitOrders")

/* 添加收藏的店铺 */
#define kCDZShopsCollectionAdd kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"colStore")

/* 取消收藏的店铺 */
#define kCDZShopsCollectionRemove kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"cancleCollectionShop")

/* 快捷保养列表 */
#define kCDZMaintenanceExpressList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"quickMaintain")

/* 快捷保养建议列表 */
#define kCDZMaintenanceExpressRecommendList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"getMaintain")

/* 快捷保养项目选择（点击快捷保养首页的修改）*/
#define kCDZMaintenanceExpressServiceItemList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"serviceItemList")

/* 快捷保养更换商品 */
#define kCDZPersonalChangeProduct kCDZSubPathAppendingPathComponent(@"maintain", @"changeProduct")

/* 快捷保养结算初始数据&确定安装门店 */
#define kCDZMaintenanceExpressClearanceInfoDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"consignee")

/* 选择安装门店 */
#define kCDZMaintenanceExpressClearanceSelectStores kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"selectStores")

/* 快捷保养提交订单 */
#define kCDZMaintenanceExpressOrderSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"confirmOrder")

/* 保养记录列表 */
#define kCDZMaintenanceRecordList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"miantainRecorsList")

/* 添加保养记录 */
#define kCDZMaintenanceRecordInsert kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"addMaintainRecords")

/* 自助保养记录的编辑 */
#define kCDZMaintenanceSelfMaintainRecordEdit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMaintain, @"editMaintainRecords")

//改改改   我的维修管理——维修预约、维修诊断、维修委托、维修结算列表
#define kCDZPersonalRepairList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"repairList")

//维修订单详情
#define kCDZPersonalRepairOrderDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"repairOrderDetail")

//同意维修
#define kCDZPersonalAgreeRepair kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"agreeRepair")
//取消维修
#define kCDZPersonalRefuseRepair kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"refuseRepair")
//点击确认付款
#define kCDZPersonalConfirmPay kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"confirmPay")
//点击确认
#define kCDZPersonalEnsurePayorder kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"ensurePayorder")
//点击评论——服务评论
#define kCDZPersonalCommentRepair kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"commentRepair")
//提交评论
#define kCDZPersonalSubRepairComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"subRepairComment")
//查看评论
#define kCDZPersonalShowCommentInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"showCommentInfo")


//订单列表（全部、待付款、待收货、待安装、待评价
#define kCDZPersonalShowOrderList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"orderList")
//2、订单详情
#define kCDZPersonalOrderDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"orderDetail")
//未付款——立即支付
#define kCDZPersonalPayNow kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"payNow")
//未付款、货到付款——取消订单
#define kCDZPersonalCancleOrder1 kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"cancleOrder1")
//交易关闭——删除订单
#define kCDZPersonalDelOrder kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"delOrder")
//已付款、待安装——取消订单
#define kCDZPersonalCancleOrder2 kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"cancleOrder2")
//派送中——确认收货
#define kCDZPersonalConfirmReceive kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"confirmReceive")
//产品评论列表
#define kCDZPersonalCommentOrderInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"commentOrderInfo")
//产品  提交评论
#define kCDZPersonalSubComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"subComment")
//产品  查看评论
#define kCDZPersonalShowCommentInfoByOrder kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"showCommentInfo")
//产品  点击申请退款
#define kCDZPersonalApplyRefundr kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"applyRefund")
//产品  提交退款申请
#define kCDZPersonalSubApplyRefund kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"subApplyRefund")

//退款进度——返修/退换
#define kCDZPersonalRefundSchedule kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfOrder, @"refundSchedule")




//查找配件
#define kCDZPartsDetailBuyNowInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"buyNow")
//查找配件
#define kCDZPersonalProductList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"productList")
//配件一级分类
#define kCDZPersonalAutopartType kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"autopartType")
//配件二级分类信息
#define kCDZPersonalAutopartList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"autopartList")
//配件三级分类信息
#define kCDZPersonalAutopartInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"autopartInfo")
//、询价省份、城市、采购中心信息
#define kCDZPersonalInquiryInfo kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"inquiryInfo")
//购物车移至收藏
#define kCDZCartListMoveCollection kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfProduct, @"removeAndCol")

#pragma mark /////#########/////会员中心/////##########/////
// 会员中心详情
#define kCDZUserMemberCenterDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"memberCenter")

// 会员详情简介
#define kCDZMemberTypeDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"levelDetail")

// 会员申请
#define kCDZMemberApplicationSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"applyNow")

// 会员订单确认
#define kCDZMemberPaymentOrderSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"confirmOrder")

// 会员权益详情
#define kCDZUserMemberRightsDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"myRights")

// 会员成长列表
#define kCDZUserMemberHistoryList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfMember, @"growthRecords")


#pragma mark /////#########/////技师模块/////##########/////
// 技师技能列表
#define kCDZMechanicSpecialList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"specialItem")

// 技师列表
#define kCDZMechanicList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"technicianList")

// 技师详情
#define kCDZMechanicDetail kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"technicianDetail")

// 培训及荣誉
#define kCDZMechanicExpNCertsList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"trainList")

// 技师评论列表
#define kCDZMechanicCommentList kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfRapidRepair, @"technicainComment")

// 更新技师收藏状态-收藏
#define kCDZMechanicUserCollected kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"colTechnician")

// 更新技师收藏状态-取消收藏
#define kCDZMechanicUserUncollected kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"cancleColTechnician")





/* 添加案例 */
#define kCDZCasesHistoryOfAddCase  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"addCase")
/* 我的案例 */
#define kCDZCasesHistoryOfMyCase  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"myCase")

/* 编辑案例 */
#define kCDZCasesHistoryOfEditCase  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"editCase")
/* 删除案例 */
#define kCDZCasesHistoryOfDelCase  kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"delCase")
/* 上传结算单 */
#define kCDZCasesHistoryImageUploadJSDcdz kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfImageUpload, @"cdz")
/* 查看案例评论 */
#define kCDZCasesHistoryOfShowCaseComment kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"showCaseComment")

// 提交案例评论
#define kCDZCasesCommentSubmit kCDZSubPathAppendingPathComponent(kCDZSubPathTypeOfPersonalConnect, @"addCaseComment")



