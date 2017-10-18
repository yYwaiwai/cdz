//
//  APIsConnection.h
//  cdzer
//
//  Created by KEns0n on 4/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "NSURLSessionTask+ExtUserInfo.h"
#import "APIsDefine.h"
#import "APIsErrorHandler.h"
#import "EServiceConfig.h"


typedef NS_ENUM(NSInteger, CDZAPIsHTTPMethod) {
    CDZAPIsHTTPMethodTypeOfGET,
    CDZAPIsHTTPMethodTypeOfPOST,
    CDZAPIsHTTPMethodTypeOfPUT,
    CDZAPIsHTTPMethodTypeOfPATCH,
    CDZAPIsHTTPMethodTypeOfDELETE,
};

typedef NS_ENUM(NSInteger, ConnectionImageType) {
    ConnectionImageTypeOfPNG = 1,
    ConnectionImageTypeOfJPEG = 2,
};

typedef NS_ENUM(NSInteger, SelfDiagnosisSelectionStep) {
    SelfDiagnosisStepOne = 0,
    SelfDiagnosisStepTwo = 1,
    SelfDiagnosisStepThree = 2,
    SelfDiagnosisStepFour = 3,
    SelfDiagnosisStepFive = 4,
};

typedef NS_ENUM(NSInteger, TERankingType) {
    TERankingTypeOfDailyRankingList = 1,
    TERankingTypeOfWeeklyRankingList = 2,
    TERankingTypeOfMonthlyRankingList = 3,
};

typedef NS_ENUM(NSInteger, CDZEREDRShareFetchType) {
    CDZEREDRShareFetchTypeOfNewFetch = 0,
    CDZEREDRShareFetchTypeOfRecommendFetch,
    CDZEREDRShareFetchTypeOfFollowedFetch,
    CDZEREDRShareFetchTypeOfSelfFetch,
    CDZEREDRShareFetchTypeOfOtherUserFetch,
    CDZEREDRShareFetchTypeOfNotRequest = -1,
};

typedef NS_ENUM(NSInteger, CDZEREDRShareFetchTopicType) {
    CDZEREDRShareFetchTopicTypeOfRoadShow = 0,
    CDZEREDRShareFetchTopicTypeOfCityAppearance,
    CDZEREDRShareFetchTopicTypeOfFunnyJokes,
    CDZEREDRShareFetchTopicTypeOfPersonalStyle,
    CDZEREDRShareFetchTopicTypeOfNotRequest = -1,
};

typedef NS_ENUM(NSUInteger, SNSSLVFItemBrandType) {
    SNSSLVFItemBrandTypeOfNone = 0,
    SNSSLVFItemBrandTypeOfTire,
    SNSSLVFItemBrandTypeOfWindshield,
    SNSSLVFItemBrandTypeOfStorageBattery,
};


typedef void (^APIsConnectionSuccessBlock)(NSURLSessionDataTask *operation, id responseObject);
typedef void (^APIsConnectionFailureBlock)(NSURLSessionDataTask *operation, NSError *error);

@class AFHTTPRequestOperation;
@interface APIsConnection : NSObject

+ (APIsConnection *)shareConnection;


#pragma mark - /////////////////////////////////////////////////////Personal Center APIs（个人中心接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////用户/////##########/////
/* 个人基本资料 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPersonalInformationWithAccessToken:(NSString *)token
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 用户注册 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserRegisterWithUserPhone:(NSString *)userPhone
                                                                  validCode:(NSString *)validCode
                                                                   password:(NSString *)password
                                                                 repassword:(NSString *)repassword
                                                             invitationCode:(NSString *)invitationCode
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 用户注册验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserRegisterValidCodeWithUserPhone:(NSString *)userPhone
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 用户忘记密码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserForgetPasswordWithUserPhone:(NSString *)userPhone
                                                                        validCode:(NSString *)validCode
                                                                         password:(NSString *)password
                                                                       repassword:(NSString *)repassword
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;
/* 用户忘记密码验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserForgetPWValidCodeWithUserPhone:(NSString *)userPhone
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 用户登录 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserLoginWithUserPhone:(NSString *)userPhone
                                                                password:(NSString *)password
                                                               channelID:(NSString *)channelID
                                                             deviceToken:(NSString *)deviceToken
                                                              apnsUserID:(NSString *)apnsUserID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 验证Token期限 */
- (NSURLSessionDataTask *)personalCenterAPIsPostValidUserTokenWithAccessToken:(NSString *)token
                                                                         userID:(NSString *)userID
                                                                      channelID:(NSString *)channelID
                                                                    deviceToken:(NSString *)deviceToken
                                                                     apnsUserID:(NSString *)apnsUserID
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 用户修改密码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserChangePasswordWithAccessToken:(NSString *)token
                                                                        oldPassword:(NSString *)oldPW
                                                                        newPassword:(NSString *)newPW
                                                                   newPasswordAgain:(NSString *)newPWAgain
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 用户基本资料修改 */
- (NSURLSessionDataTask *)personalCenterAPIsPatchUserPersonalInformationWithAccessToken:(NSString *)token
                                                                           byPortraitPath:(NSString *)portraitPath
                                                                             mobileNumber:(NSNumber *)mobileNumber
                                                                                 realName:(NSString *)realName
                                                                                 nickName:(NSString *)nickName
                                                                                   sexual:(NSNumber *)sexual
                                                                                      bod:(NSString *)bod
                                                                                 qqNumber:(NSNumber *)qqNumber
                                                                                    email:(NSString *)email
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 用户个人头像修改 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUseryPortraitImage:(UIImage *)portraitImage
                                                           imageName:(NSString *)imageName
                                                           imageType:(ConnectionImageType)imageType
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure;

- (NSURLSessionDataTask *)personalCenterAPIsPostUserCreditValidCodeWithAccessToken:(NSString *)token
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////车辆管理/////##########/////
/* 车辆列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoListWithAccessToken:(NSString *)token
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 车辆修改 */
- (NSURLSessionDataTask *)personalCenterAPIsPatchMyAutoWithAccessToken:(NSString *)token
                                                                myAutoID:(NSString *)myAutoID
                                                            myAutoNumber:(NSString *)myAutoNumber
                                                         myAutoBodyColor:(NSString *)myAutoBodyColor
                                                           myAutoMileage:(NSString *)myAutoMileage
                                                          myAutoFrameNum:(NSString *)myAutoFrameNum
                                                         myAutoEngineNum:(NSString *)myAutoEngineNum
                                                           insuranceDate:(NSString *)insuranceDate
                                                         annualCheckDate:(NSString *)annualCheckDate
                                                         maintenanceDate:(NSString *)maintenanceDate
                                                             registrDate:(NSString *)registrDate
                                                                 brandID:(NSString *)brandID
                                                       brandDealershipID:(NSString *)brandDealershipID
                                                                seriesID:(NSString *)seriesID
                                                                 modelID:(NSString *)modelID
                                                            insuranceNum:(NSString *)insuranceNum
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;


/* 车辆颜色 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoColorListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 车辆省列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoProvincesListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 车辆市列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoCityListWithAutoProvincesID:(NSString *)autoProvincesID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;


#pragma mark /////##########/////收藏/////##########/////
/* 收藏的商品列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetProductsCollectionListWithAccessToken:(NSString *)token
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

/* 收藏的店铺列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShopsCollectionListWithAccessToken:(NSString *)token
                                                                           pageNums:(NSNumber *)pageNums
                                                                          pageSizes:(NSNumber *)pageSizes
                                                                         coordinate:(CLLocationCoordinate2D)coordinate
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 收藏的技师列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMechanicCollectionListWithAccessToken:(NSString *)token
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;
/* 添加收藏的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertProductCollectionWithAccessToken:(NSString *)token
                                                                           productIDList:(NSArray *)productIDList
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 添加收藏的店铺 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertShopCollectionWithAccessToken:(NSString *)token
                                                                           shopIDList:(NSArray *)shopIDList
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

/* 删除收藏的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteProductsCollectionWithAccessToken:(NSString *)token
                                                                         collectionIDList:(NSArray *)collectionIDList
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 删除收藏的店铺 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteShopCollectionWithAccessToken:(NSString *)token
                                                                     collectionIDList:(NSArray *)collectionIDList
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

/* 检测商品是否已收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsGetProductiWasCollectedWithAccessToken:(NSString *)token
                                                                        collectionID:(NSString *)collectionID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;
/* 检测店铺是否已收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShopWasCollectedWithAccessToken:(NSString *)token
                                                                          shopID:(NSString *)shopID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////订单/////##########/////
/* 订单列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseOrderListWithAccessToken:(NSString *)token
                                                                         pageNums:(NSString *)pageNums
                                                                        pageSizes:(NSString *)pageSizes
                                                                        stateName:(NSString *)stateName
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 订单详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseOrderDetailWithAccessToken:(NSString *)token
                                                                        orderMainID:(NSString *)orderMainID
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 提交订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostOrderSubmitWithAccessToken:(NSString *)token
                                                               productIDList:(NSArray *)productIDList
                                                            productCountList:(NSArray *)productCountList
                                                                   addressID:(NSString *)addressID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;


/* 免加入购物车提交订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostOrderExpressSubmitWithAccessToken:(NSString *)token
                                                                      productIDList:(NSArray *)productIDList
                                                                   productCountList:(NSArray *)productCountList
                                                                            brandID:(NSString *)brandID
                                                                  brandDealershipID:(NSString *)brandDealershipID
                                                                           seriesID:(NSString *)seriesID
                                                                            modelID:(NSString *)modelID
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 订单确认 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmOrderAndPaymentWithAccessToken:(NSString *)token
                                                                          productIDList:(NSArray *)productIDList
                                                                              addressID:(NSString *)addressID
                                                                             totalPrice:(NSString *)totalPrice
                                                                    creditTotalConsumed:(NSString *)creditTotalConsumed
                                                                             verifyCode:(NSString *)verifyCode
                                                                   invoicePayeeNameList:(NSArray *)invoicePayeeNameList
                                                                         userRemarkList:(NSArray *)userRemarkList
                                                                             isFormCart:(BOOL)formCart
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 订单付款方法－货到付款/状态更变 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodByPayAfterDeliveryWithAccessToken:(NSString *)token
                                                                          isPayAfterDelivery:(BOOL)isPayAfterDelivery
                                                                                 orderMainID:(NSString *)orderMainID
                                                                                    costType:(NSString *)costType
                                                                                costTypeName:(NSString *)costTypeName
                                                                                     payType:(NSString *)payType
                                                                                 payTypeName:(NSString *)payTypeName
                                                                                       state:(NSString *)state
                                                                                   stateName:(NSString *)stateName
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 订单付款方法－银联 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodByUnionPayWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 订单付款方法－支付宝 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodByAlipayWithAccessToken:(NSString *)token
                                                                       orderMainID:(NSString *)orderMainID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 订单付款方法－微信 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodChangeByWXWithAccessToken:(NSString *)token
                                                                         orderMainID:(NSString *)orderMainID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 更新支付状态 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentStatusUpdateWithAccessToken:(NSString *)token
                                                                     orderMainID:(NSString *)orderMainID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 订单完成发表评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:(NSString *)token
                                                                                               orderMainID:(NSString *)orderMainID
                                                                                                itemNumber:(NSString *)itemNumber
                                                                                                   content:(NSString *)content
                                                                                                    rating:(NSString *)rating
                                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 订单完成查看评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:(NSString *)token
                                                                                              orderMainID:(NSString *)orderMainID
                                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCancelPurchaseOrderWithAccessToken:(NSString *)token
                                                                         orderMainID:(NSString *)orderMainID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 订单删除 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeletePurchaseOrderWithAccessToken:(NSString *)token
                                                                         orderMainID:(NSString *)orderMainID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 确定收货 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmPurchaseOrderStateOfHasBeenArrivedWithAccessToken:(NSString *)token
                                                                                               orderMainID:(NSString *)orderMainID
                                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 用户申请退货 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserApplyReturnedPurchaseWithAccessToken:(NSString *)token
                                                                               orderMainID:(NSString *)orderMainID
                                                                                    reason:(NSString *)reason
                                                                                   content:(NSString *)content
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 确定退货完成 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmGoodsHasBeenReturnAccessToken:(NSString *)token
                                                                           orderMainID:(NSString *)orderMainID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure ;

#pragma mark /////##########/////保险/////##########/////
/* 检测用户保险信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceInfoCheckWithAccessToken:(NSString *)token
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 用户已预约&购买保险列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAppointmentAndPurchasedListWasPurchasedList:(BOOL)isPurchasedList
                                                                                              accessToken:(NSString *)token
                                                                                                 pageNums:(NSNumber *)pageNums
                                                                                                pageSizes:(NSNumber *)pageSizes
                                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 用户已登记的保险车辆 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosListWithAccessToken:(NSString *)token
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

/* 用户已登记的保险车辆保费详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosInsurancePremiumDetailWithAccessToken:(NSString *)token
                                                                                         autosLicenseNum:(NSString *)autosLicenseNum
                                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 用户保险详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosInsuranceDetailWithAccessToken:(NSString *)token
                                                                                        premiumID:(NSString *)premiumID
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 添加保险车辆信息 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsuranceInfoWithAccessToken:(NSString *)token
                                                                                 brandID:(NSString *)brandID
                                                                               brandName:(NSString *)brandName
                                                                       brandDealershipID:(NSString *)brandDealershipID
                                                                     brandDealershipName:(NSString *)brandDealershipName
                                                                                seriesID:(NSString *)seriesID
                                                                              seriesName:(NSString *)seriesIName
                                                                                 modelID:(NSString *)modelID
                                                                               modelName:(NSString *)modelName

                                                                                userName:(NSString *)userName
                                                                             phoneNumber:(NSString *)phoneNumber

                                                                                  cityID:(NSString *)cityID
                                                                             autosNumber:(NSString *)autosNumber
                                                                           autosFrameNum:(NSString *)autosFrameNum
                                                                          autosEngineNum:(NSString *)autosEngineNum
                                                                              autosPrice:(NSString *)autosPrice
                                                                               acTypeStr:(NSString *)acTypeStr
                                                                       autosRegisterDate:(NSString *)autosRegisterDate

                                                                          autosUsageType:(NSString *)autosUsageType
                                                                         autosNumOfSeats:(NSNumber *)autosNumOfSeats
                                                                           autosWasSHand:(NSNumber *)autosWasSHand
                                                                     autosAssignmentDate:(NSString *)autosAssignmentDate
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 提交保险信息 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsuranceAppointmentWithAccessToken:(NSString *)token
                                                                                          carId:(NSString *)carId
                                                                               insuranceCompany:(NSString *)insuranceCompany
                                                                       VTALCInsuranceActiveDate:(NSString *)autosTALCInsuranceActiveDate
                                                                            vehicleAndVesselTax:(NSNumber *)vehicleAndVesselTax
                                                                             autosTALCInsurance:(NSNumber *)autosTALCInsurance

                                                                    commerceInsuranceActiveDate:(NSString *)commerceInsuranceActiveDate
                                                                           autosDamageInsurance:(NSNumber *)autosDamageInsurance
                                                           thirdPartyLiabilityInsuranceCoverage:(NSString *)thirdPartyLiabilityInsuranceCoverage
                                                                   thirdPartyLiabilityInsurance:(NSNumber *)thirdPartyLiabilityInsurance
                                                                       robberyAndTheftInsurance:(NSNumber *)robberyAndTheftInsurance


                                                               driverLiabilityInsuranceCoverage:(NSString *)driverLiabilityInsuranceCoverage
                                                                       driverLiabilityInsurance:(NSNumber *)driverLiabilityInsurance
                                                            passengerLiabilityInsuranceCoverage:(NSString *)passengerLiabilityInsuranceCoverage
                                                                    passengerLiabilityInsurance:(NSNumber *)passengerLiabilityInsurance

                                                                  windshieldDamageInsuranceType:(NSString *)windshieldDamageInsuranceType
                                                                      windshieldDamageInsurance:(NSNumber *)windshieldDamageInsurance
                                                                                  fireInsurance:(NSNumber *)fireInsurance
                                                                 scratchDamageInsuranceCoverage:(NSString *)scratchDamageInsuranceCoverage
                                                                         scratchDamageInsurance:(NSNumber *)scratchDamageInsurance
                                                                 specifyServiceFactoryInsurance:(NSNumber *)specifyServiceFactoryInsurance
                                                      sideMirrorAndHeadlightDamageInsuranceType:(NSString *)sideMirrorAndHeadlightDamageInsuranceType
                                                          sideMirrorAndHeadlightDamageInsurance:(NSNumber *)sideMirrorAndHeadlightDamageInsurance
                                                                         wadingDrivingInsurance:(NSNumber *)wadingDrivingInsurance

                                                                               extraADInsurance:(NSNumber *)extraADInsurance
                                                                              extraRATInsurance:(NSNumber *)extraRATInsurance
                                                                              extraTPLInsurance:(NSNumber *)extraTPLInsurance
                                                                            extraDLNPLInsurance:(NSNumber *)extraDLNPLInsurance
                                                                             extraPlusInsurance:(NSNumber *)extraPlusInsurance
                                                                 businessTotalPriceWithDiscount:(NSNumber *)businessTotalPriceWithDiscount
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////新的预约   保险/////##########/////
/* 点击首页的预约保险 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceMyInurancelistWithAccessToken:(NSString *)token
                                                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 添加保险车辆 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppPremiumAddCarWithAccessToken:(NSString *)token
                                                                                                                  phoneNo:(NSString *)phoneNo
                                                                                                                     city:(NSString *)city
                                                                                                                 realname:(NSString *)realname
                                                                                                                    speci:(NSString *)speci
                                                                                                                  frameNo:(NSString *)frameNo
                                                                                                               enginecode:(NSString *)enginecode
                                                                                                             registertime:(NSString *)registertime
                                                                                                                carCumber:(NSString *)carCumber
                                                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 更换车辆 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceChangeCarNumberWithAccessToken:(NSString *)token
                                                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                                                 failure:(APIsConnectionFailureBlock)failure;

/*保险公司*/
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetCompanyWithsuccess:(APIsConnectionSuccessBlock)success
                                                                                                        failure:(APIsConnectionFailureBlock)failure;
//身份证和行驶证 图片上传
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetTestPicWithImage:(UIImage *)portraitImage
                                                                                                    imageName:(NSString *)imageName
                                                                                                    imageType:(ConnectionImageType)imageType
                                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                                      failure:(APIsConnectionFailureBlock)failure;

/*预约保险*/
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppAddPremiumListWithAccessToken:(NSString *)token
                                                                                                                   company:(NSString *)company
                                                                                                                     carId:(NSString *)carId
                                                                                                                      city:(NSString *)city
                                                                                                                licenseimg:(NSString *)licenseimg
                                                                                                               identityImg:(NSString *)identityImg
                                                                                                                     sTime:(NSString *)sTime
                                                                                                                     bTime:(NSString *)bTime
                                                                                                               premiumSali:(NSString *)premiumSali
                                                                                                                   bDamage:(NSString *)bDamage
                                                                                                                    bThief:(NSString *)bThief
                                                                                                                bLiability:(NSString *)bLiability
                                                                                                              premiumGlass:(NSString *)premiumGlass
                                                                                                                driverSeat:(NSString *)driverSeat
                                                                                                             passengerSeat:(NSString *)passengerSeat
                                                                                                             premiumNature:(NSString *)premiumNature
                                                                                                               premiumBody:(NSString *)premiumBody
                                                                                                             premiumRepair:(NSString *)premiumRepair
                                                                                                              premiumWater:(NSString *)premiumWater
                                                                                                               lossSpecial:(NSString *)lossSpecial
                                                                                                              thirdSpecial:(NSString *)thirdSpecial
                                                                                                              theftSpecial:(NSString *)theftSpecial
                                                                                                              dSeatSpecial:(NSString *)dSeatSpecial
                                                                                                              pSeatSpecial:(NSString *)pSeatSpecial
                                                                                                               fireSpecial:(NSString *)fireSpecial
                                                                                                            scratchSpecial:(NSString *)scratchSpecial
                                                                                                              waterSpecial:(NSString *)waterSpecial
                                                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 我的保险列表 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppShowInsuranceAppWithAccessToken:(NSString *)token
                                                                                                                    pageNums:(NSNumber *)pageNums
                                                                                                                   pageSizes:(NSNumber *)pageSizes
                                                                                                                        type:(NSNumber *)type
                                                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                                                     failure:(APIsConnectionFailureBlock)failure;
/* 保险详情 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceAppBuyListWithAccessToken:(NSString *)token
                                                                                                                            pid:(NSString *)pid                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                        failure:(APIsConnectionFailureBlock)failure;
/* 点击重新预约 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceReAppointWithAccessToken:(NSString *)token
                                                                                                                           pid:(NSString *)pid                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                       failure:(APIsConnectionFailureBlock)failure;
/*确定重新预约*/
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceConfirmReAppointWithAccessToken:(NSString *)token
                                                                                                                      pid:(NSString *)pid
                                                                                                                  company:(NSString *)company
                                                                                                                    carId:(NSString *)carId
                                                                                                                     city:(NSString *)city
                                                                                                               licenseimg:(NSString *)licenseimg
                                                                                                              identityImg:(NSString *)identityImg
                                                                                                                    sTime:(NSString *)sTime
                                                                                                                    bTime:(NSString *)bTime
                                                                                                              premiumSali:(NSString *)premiumSali
                                                                                                                  bDamage:(NSString *)bDamage
                                                                                                                   bThief:(NSString *)bThief
                                                                                                               bLiability:(NSString *)bLiability
                                                                                                             premiumGlass:(NSString *)premiumGlass
                                                                                                               driverSeat:(NSString *)driverSeat
                                                                                                            passengerSeat:(NSString *)passengerSeat
                                                                                                            premiumNature:(NSString *)premiumNature
                                                                                                              premiumBody:(NSString *)premiumBody
                                                                                                            premiumRepair:(NSString *)premiumRepair
                                                                                                             premiumWater:(NSString *)premiumWater
                                                                                                              lossSpecial:(NSString *)lossSpecial
                                                                                                             thirdSpecial:(NSString *)thirdSpecial
                                                                                                             theftSpecial:(NSString *)theftSpecial
                                                                                                             dSeatSpecial:(NSString *)dSeatSpecial
                                                                                                             pSeatSpecial:(NSString *)pSeatSpecial
                                                                                                              fireSpecial:(NSString *)fireSpecial
                                                                                                           scratchSpecial:(NSString *)scratchSpecial
                                                                                                             waterSpecial:(NSString *)waterSpecial
                                                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                                                  failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////GPS购买/////##########/////
/* GPS购买 */
- (NSURLSessionDataTask *)personalCenterAPIsPostGPSPurchasesAppointmentWithAccessToken:(NSString *)token
                                                                                 gpsType:(NSUInteger)gpsType
                                                                            dataCardType:(NSUInteger)dataCardType
                                                                        recognizanceType:(NSUInteger)recognizanceType
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;


#pragma mark /////##########/////优惠劵/////##########/////
/* 维修商优惠券列表 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopCouponAvailableListWithAccessToken:(NSString *)token
                                                                                   maintenanceShopID:(NSString *)maintenanceShopID
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure;
/* 个人领取维修商优惠券 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsPostUserCollectMaintenanceShopCouponWithAccessToken:(NSString *)token
                                                                                           couponID:(NSString *)couponID
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure;
/* 个人中心我的优惠券列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyCouponCollectedListWithAccessToken:(NSString *)token
                                                                             pageNums:(NSNumber *)pageNums
                                                                            pageSizes:(NSNumber *)pageSizes
                                                                               status:(NSNumber *)status
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;
/* 使用优惠券选择列表 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserApplyCouponWithAccessToken:(NSString *)token
                                                                        repairID:(NSString *)repairID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////E-代修/////##########/////
/* E服务检测用户是否预约 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceVerifyUserWasMadeAppointmentWithAccessToken:(NSString *)token
                                                                                             theSign:(NSString *)theSign
                                                                                        eServiceType:(EServiceType)eServiceType
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure;
/* 提交预约E服务 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceMakeAppointmentWithAccessToken:(NSString *)token
                                                                            repairShopID:(NSString *)repairShopID
                                                                          repairShopName:(NSString *)repairShopName
                                                                              registrant:(NSString *)registrant
                                                                         registrantPhone:(NSString *)registrantPhone
                                                                                 address:(NSString *)address
                                                                          autosModelName:(NSString *)autosModelName
                                                                           servieceItems:(NSString *)servieceItems
                                                                             projectType:(NSString *)projectType
                                                                         appointmentTime:(NSString *)appointmentTime
                                                                               longitude:(NSString *)longitude
                                                                                latitude:(NSString *)latitude
                                                                   requestedConsultantID:(NSString *)requestedConsultantID
                                                                            eServiceType:(EServiceType)eServiceType
                                                                             eRepairFree:(NSString *)eRepairFree
                                                                        orderWasAutoType:(BOOL)orderWasAutoType
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* E服务列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceListWithAccessToken:(NSString *)token
                                                                    pageNums:(NSNumber *)pageNums
                                                                   pageSizes:(NSNumber *)pageSizes
                                                                  statusType:(NSString *)statusType
                                                                 serviceType:(NSString *)serviceType
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;
/* E服务详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceDetailWithAccessToken:(NSString *)token
                                                                    eServiceID:(NSString *)eServiceID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 取消E服务 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceCancelServiceWithAccessToken:(NSString *)token
                                                                            eServiceID:(NSString *)eServiceID
                                                                          isAutoCancel:(BOOL)isAutoCancel
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;
/* E服务确认还车 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceConfirmVehicleWasReturnWithAccessToken:(NSString *)token
                                                                                      eServiceID:(NSString *)eServiceID
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;
/* E服务专员简单资讯 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantSimpleDetail4CommentWithAccessToken:(NSString *)token
                                                                                            eServiceID:(NSString *)eServiceID
                                                                                               success:(APIsConnectionSuccessBlock)success
                                                                                               failure:(APIsConnectionFailureBlock)failure;
/* E服务提交评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceServiceCommentWithAccessToken:(NSString *)token
                                                                             eServiceID:(NSString *)eServiceID
                                                                             rateNumber:(NSNumber *)rateNumber
                                                                                comment:(NSString *)comment
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;
/* E服务查看评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceServiceCommentWithAccessToken:(NSString *)token
                                                                            eServiceID:(NSString *)eServiceID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;
/* E服务支付确认信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServicePaymentConfirmInfoWithAccessToken:(NSString *)token
                                                                                eServiceID:(NSString *)eServiceID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* E服务支付确认信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServicePaymentInitInfoWithAccessToken:(NSString *)token
                                                                             eServiceID:(NSString *)eServiceID
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;



/* E服务地址检测 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceVerifyUserAddressResultWithAddress:(NSString *)address
                                                                              servieceItems:(NSString *)servieceItems
                                                                                projectType:(NSString *)projectType
                                                                               repairShopID:(NSString *)repairShopID
                                                                               eServiceType:(EServiceType)eServiceType
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;
/* 获取E服务专员列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantPostionListWithLongitude:(NSString *)longitude
                                                                                   latitude:(NSString *)latitude
                                                                               eServiceType:(EServiceType)eServiceType
                                                                         consultantPhoneNum:(NSString *)consultantPhoneNum
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;
/* 获取E服务专员详情  */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantDetailWithAccessToken:(NSString *)token
                                                                              eServiceID:(NSString *)eServiceID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 获取E服务用户会员状态和服务价钱 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceUserMemberStatusNPriceWithAccessToken:(NSString *)token
                                                                                  eServiceType:(EServiceType)eServiceType
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;


/* 获取E服务专员详情和评论  */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantDetailAndCommentListsWithAccessToken:(NSString *)token
                                                                                           consultantID:(NSString *)consultantID
                                                                                               pageNums:(NSNumber *)pageNums
                                                                                              pageSizes:(NSNumber *)pageSizes
                                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                                failure:(APIsConnectionFailureBlock)failure;


/* 提交E服务积分支付 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceCreditsPaymentWithAccessToken:(NSString *)token
                                                                             eServiceID:(NSString *)eServiceID
                                                                             verifyCode:(NSString *)verifyCode
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 请求E服务积分验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceCreditsRequestVerifyCodeWithAccessToken:(NSString *)token
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////商家会员/////##########/////
/* 用户的商家列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopMemberListWithAccessToken:(NSString *)token
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 会员置顶 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserSetRepairShopMembershipToTopWithAccessToken:(NSString *)token
                                                                                     repairShopID:(NSString *)repairShopID
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure;
/* 取消会员 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserCancelRepairShopMembershipWithAccessToken:(NSString *)token
                                                                                   repairShopID:(NSString *)repairShopID
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure;
/* 加入会员 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserJoinRepairShopMembershipWithAccessToken:(NSString *)token
                                                                                 repairShopID:(NSString *)repairShopID
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;

/* 商家公告列表*/
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopAnnouncementListWithAccessToken:(NSString *)token
                                                                                      pageNums:(NSNumber *)pageNums
                                                                                     pageSizes:(NSNumber *)pageSizes
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 商家公告详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopAnnouncementDetailWithAccessToken:(NSString *)token
                                                                                    repairShopID:(NSString *)repairShopID
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////地址/////##########/////
/* 地址列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShippingAddressListWithAccessToken:(NSString *)token
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 添加地址 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertShippingAddressWithAccessToken:(NSString *)token
                                                                         consigneeName:(NSString *)consigneeName
                                                                          mobileNumber:(NSString *)mobileNumber
                                                                            provinceID:(NSString *)provinceID
                                                                                cityID:(NSString *)cityID
                                                                            districtID:(NSString *)districtID
                                                                         detailAddress:(NSString *)detailAddress
                                                                      isDefaultAddress:(BOOL)isDefault
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

/* 地址详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShippingAddressDetailWithAccessToken:(NSString *)token
                                                                            addressID:(NSString *)addressID
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

/* 删除地址 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteShippingAddressWithAccessToken:(NSString *)token
                                                                             addressID:(NSString *)addressID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;
/* 更新地址 */
- (NSURLSessionDataTask *)personalCenterAPIsPatchShippingAddressWithAccessToken:(NSString *)token
                                                                        addressID:(NSString *)addressID
                                                                    consigneeName:(NSString *)consigneeName
                                                                     mobileNumber:(NSString *)mobileNumber
                                                                       provinceID:(NSString *)provinceID
                                                                           cityID:(NSString *)cityID
                                                                       districtID:(NSString *)districtID
                                                                    detailAddress:(NSString *)detailAddress
                                                                 isDefaultAddress:(BOOL)isDefault
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;



#pragma mark /////##########/////购物车/////##########/////
/* 购物车列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCartListWithAccessToken:(NSString *)token
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 添加商品到购物车 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertProductToTheCartWithAccessToken:(NSString *)token
                                                                              productID:(NSString *)productID
                                                                                brandID:(NSString *)brandID
                                                                      brandDealershipID:(NSString *)brandDealershipID
                                                                               seriesID:(NSString *)seriesID
                                                                                modelID:(NSString *)modelID
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 删除购物车的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteProductFormTheCartWithAccessToken:(NSString *)token
                                                                            productIDList:(NSArray *)productIDList
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////车辆维修/////##########/////
/* 查询维修列表由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceStatusListByStatusType:(CDZMaintenanceStatusType)statusType
                                                                       accessToken:(NSString *)token
                                                                          pageNums:(NSNumber *)pageNums
                                                                         pageSizes:(NSNumber *)pageSizes
                                                                   shopNameOrKeyID:(NSString *)shopNameOrKeyID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 查询维修详情由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceStatusDetailByStatusType:(CDZMaintenanceStatusType)statusType
                                                                         accessToken:(NSString *)token
                                                                               keyID:(NSString *)keyID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 确认委托维修授权 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmMaintenanceAuthorizationWithAccessToken:(NSString *)token
                                                                                           keyID:(NSString *)keyID
                                                                               repairItemsString:(NSString *)repairItemsString
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 结算信息准备 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceClearingPaymentInfoWithAccessToken:(NSString *)token
                                                                                         keyID:(NSString *)keyID
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;

/* 取消维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCancelMaintenanceWithAccessToken:(NSString *)token
                                                                             keyID:(NSString *)keyID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

////////////////////* 结算维修 *////////////////////
/* 优惠劵结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByCouponWithAccessToken:(NSString *)token
                                                                                    repairID:(NSString *)repairID
                                                                                    couponID:(NSString *)couponID
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;
/* 全积分结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByAllOfCreditsWithAccessToken:(NSString *)token
                                                                                          repairID:(NSString *)repairID
                                                                                        verifyCode:(NSString *)verifyCode
                                                                                           success:(APIsConnectionSuccessBlock)success
                                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 部分积分结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByPartOfCreditsWithAccessToken:(NSString *)token
                                                                                           repairID:(NSString *)repairID
                                                                                      surplusAmount:(NSString *)surplusAmount
                                                                                      creditConsume:(NSString *)creditConsume
                                                                                         verifyCode:(NSString *)verifyCode
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure;
/* 支付完成通知 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserPaymentFinishNotifyWithAccessToken:(NSString *)token
                                                                             outTradeNum:(NSString *)outTradeNum
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;


#pragma mark /////##########/////其他/////##########/////
/* 询价列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetSelfEnquireProductsPriceWithAccessToken:(NSString *)token
                                                                                pageNums:(NSString *)pageNums
                                                                               pageSizes:(NSString *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 询价 */
- (NSURLSessionDataTask *)personalCenterAPIsPostSelfEnquireProductsPriceWithAccessToken:(NSString *)token
                                                                                  brandID:(NSString *)brandID
                                                                        brandDealershipID:(NSString *)brandDealershipID
                                                                                 seriesID:(NSString *)seriesID
                                                                                  modelID:(NSString *)modelID
                                                                                 centerID:(NSString *)centerID
                                                                             mobileNumber:(NSString *)mobileNumber
                                                                                 userName:(NSString *)userName
                                                                             productionID:(NSString *)productionID
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 积分列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCreditPointsHistoryWithAccessToken:(NSString *)token
                                                                           pageNums:(NSNumber *)pageNums
                                                                          pageSizes:(NSNumber *)pageSizes
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 采购中心列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseCenterListWithCityID:(NSString *)cityID
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure;
/* 首页轮播接口 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMainPageAdvertisingInfoListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;

#pragma mark - /////////////////////////////////////////////////////Autos Parts APIs（配件接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////汽车配件选择/////##########/////
/* 配件第一级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsFirstLevelListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 配件第二级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsSecondLevelListWithFirstLevelID:(NSString *)firstLevelID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 配件第三级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsThirdLevelListWithSecondLevelID:(NSString *)secondLevelID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 配件第四级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsLastLevelListWithThirdLevelID:(NSString *)thirdLevelID
                                                                    autoModelID:(NSString *)autoModelID
                                                                     priceOrder:(NSString *)priceOrder
                                                               salesVolumeOrder:(NSString *)salesVolumeOrder
                                                                       pageNums:(NSString *)pageNums
                                                                      pageSizes:(NSString *)pageSizes
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 配件评论列表 */
- (NSURLSessionDataTask *)autosPartsAPIsGetAutosPartsCommnetListWithProductID:(NSString *)shopID
                                                                       pageNums:(NSNumber *)pageNums
                                                                      pageSizes:(NSNumber *)pageSizes
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 配件推荐列表 */
- (NSURLSessionDataTask *)autosPartsAPIsGetRecommendProductWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure;

/* 搜索配件 */
- (NSURLSessionDataTask *)autosPartsAPIsGetAutosPartsSearchListWithKeyword:(NSString *)keyword
                                                                 autoModelID:(NSString *)autoModelID
                                                                  priceOrder:(NSString *)priceOrder
                                                            salesVolumeOrder:(NSString *)salesVolumeOrder
                                                                    pageNums:(NSNumber *)pageNums
                                                                   pageSizes:(NSNumber *)pageSizes
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;

#pragma mark - /////////////////////////////////////////////////////Maintenance Shops APIs（维修商接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////查询维修商、维修商详情和附属接口/////##########/////
/* 查询维修商 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsListWithpageNums:(NSString *)pageNums
                                                                          pageSizes:(NSString *)pageSizes
                                                                            ranking:(NSString *)rankValue
                                                                          serviceID:(NSString *)serviceID
                                                                           shopType:(NSString *)shopType
                                                                           shopName:(NSString *)shopName
                                                                             cityID:(NSString *)cityID
                                                                            address:(NSString *)address
                                                                          autoBrand:(NSString *)autoBrand
                                                                          longitude:(NSString *)longitude
                                                                           latitude:(NSString *)latitude
                                                                        isCertified:(BOOL)isCertified
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 维修商详情 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:(NSString *)shopID
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 维修商种类 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 维修商评论列表 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsCommnetListWithShopID:(NSString *)shopID
                                                                                pageNums:(NSString *)pageNums
                                                                               pageSizes:(NSString *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 维修商公用设施 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsInfrastructureWithShopID:(NSString *)shopID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 预约维修商保养或者维修选择 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsPostAppointmentFromMaintenanceShopsWithShopID:(NSString *)shopID
                                                                                 workingPrice:(NSString *)workingPrice
                                                                                  serviceItem:(NSString *)serviceItem
                                                                              isRepairService:(BOOL)isRepairService
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;

/* 确认和提交预约信息 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsPostConfirmAppointmentMaintenanceServieWithAccessToken:(NSString *)token
                                                                                                shopID:(NSString *)shopID
                                                                                           serviceItem:(NSString *)serviceItem
                                                                                           contactName:(NSString *)contactName
                                                                                         contactNumber:(NSString *)contactNumber
                                                                                       approveToChange:(BOOL)approveToChange
                                                                                              dateTime:(NSString *)dateTime
                                                                                          technicianID:(NSString *)technicianID
                                                                                               brandID:(NSString *)brandID
                                                                                     brandDealershipID:(NSString *)brandDealershipID
                                                                                              seriesID:(NSString *)seriesID
                                                                                               modelID:(NSString *)modelID
                                                                                               success:(APIsConnectionSuccessBlock)success
                                                                                               failure:(APIsConnectionFailureBlock)failure;

/* 维修完成评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentForShopRepairFinishWithAccessToken:(NSString *)token
                                                                                 makeNumber:(NSString *)makeNumber
                                                                                    content:(NSString *)content
                                                                                     rating:(NSString *)rating
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 获取预约维修资讯  */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetAppointmentPrepareRepairInfoWithAccessToken:(NSString *)token
                                                                                        shopID:(NSString *)shopID
                                                                   repairServiceItemListString:(NSString *)repairServiceItemListString
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;

/* 获取预约保养资讯  */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetAppointmentPrepareMaintenanceInfoWithAccessToken:(NSString *)token
                                                                                             shopID:(NSString *)shopID
                                                                     maintenanceServiceIDListString:(NSString *)maintenanceServiceIDListString
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure;

#pragma mark - /////////////////////////////////////////////////////Self-Diagnosis APIs（自助诊断接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////自助诊断结果/////##########/////
/* 故障解决方案 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetSolutionPlanWithDiagnosisResultID:(NSString *)diagnosisResultID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 配件更换建议 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetProposedReplacementPartsWithSolutionPlanID:(NSString *)solutionPlanID
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;

/* 获取维修商 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetMaintenanceShopsSuggestListWithReplacementPartsName:(NSString *)replacementPartsName
                                                                                              seriesID:(NSString *)seriesID
                                                                                           autoModelID:(NSString *)autoModelID
                                                                                               address:(NSString *)address
                                                                                          isDescenting:(NSNumber *)isDescenting
                                                                                             longitude:(NSString *)longitude
                                                                                              latitude:(NSString *)latitude
                                                                                               success:(APIsConnectionSuccessBlock)success
                                                                                               failure:(APIsConnectionFailureBlock)failure;


#pragma mark - /////////////////////////////////////////////////////Get History Cases of Success APIs（获取案例接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////获取案例步骤/////##########/////

/* 获取案例第一级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfStepOneListWithAutosModelID:(NSString *)autosModelID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 获取案例第二级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfStepTwoListWithStepOneID:(NSString *)stepOneID
                                                                    selectedTextTitle:(NSString *)selectedTextTitle
                                                                       isDescSymptoms:(BOOL)isDescSymptoms
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;
/* 获取案例结果 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesResultListWithAccessToken:(NSString *)token
                                                                       resultKeyword:(NSString *)resultKeyword
                                                                             brandID:(NSString *)brandID
                                                                   brandDealershipID:(NSString *)brandDealershipID
                                                                            seriesID:(NSString *)seriesID
                                                                             modelID:(NSString *)modelID
                                                                            pageNums:(NSNumber *)pageNums
                                                                           pageSizes:(NSNumber *)pageSizes
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;


/* 获取案例 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfSuccessMaintenanceShopsListWithpageNums:(NSString *)pageNums
                                                                                           pageSizes:(NSString *)pageSizes
                                                                                   diagnosisResultID:(NSString *)diagnosisResultID
                                                                                            shopType:(NSString *)shopType
                                                                                   isPriceDescenting:(BOOL)isPriceDescenting
                                                                                isDistanceDescenting:(BOOL)isDistanceDescenting
                                                                                           longitude:(NSString *)longitude
                                                                                            latitude:(NSString *)latitude
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 案例详情 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfCaseDetailWithSubscribeID:(NSString *)subscribeID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;


#pragma mark - /////////////////////////////////////////////////////Self-Maintenance APIs（自助保养接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////新自助诊断步骤/////##########/////
/* 新自助诊断1～5步 */

- (NSURLSessionDataTask *)commonAPIsGetAutoSelfDiagnosisStepListWithStep:(SelfDiagnosisSelectionStep)theStep
                                                                nextStepID:(NSString *)nextStepID
                                                                  seriesID:(NSString *)seriesID
                                                                   modelID:(NSString *)modelID
                                                                    typeID:(NSNumber *)typeID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 新自助诊断结果 */
- (NSURLSessionDataTask *)selfDiagnoseAPIsGetDiagnoseResultListWithAccessToken:(NSString *)token
                                                                   brandId:(NSString *)brandId
                                                                 serviceID:(NSString *)serviceID
                                                              filterOption:(NSNumber *)filterOption
                                                                  cityName:(NSString *)cityName
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                             searchKeyword:(NSString *)searchKeyword
                                                                coordinate:(CLLocationCoordinate2D)coordinate
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;



#pragma mark /////##########/////自助维修步骤和结果/////##########/////
/* 获取保养信息 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenanceInfoWithAutoModelID:(NSString *)autoModelID
                                                                   autoTotalMileage:(NSString *)autoTotalMileage
                                                                       purchaseDate:(NSString *)purchaseDate
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 选择保养服务 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenanceServiceListWithPartsIDList:(NSArray *)partsIDList
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 配件详情 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:(NSString *)token
                                                                         productID:(NSString *)productID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;


/* 保养项目配件需求列表 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenancePartsRequestListWithPartsIDList:(NSArray *)partsIDList
                                                                                        modelID:(NSString *)modelID
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure;


#pragma mark - /////////////////////////////////////////////////////Common APIs（公用接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////获取案例和自助诊断公用步骤/////##########/////
/* 故障种类 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFailureTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 故障现象 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFaultSymptomListWithAutoFailureTypeID:(NSString *)failureTypeID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 故障架构 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFaultStructureListWithAutoFaultSymptomID:(NSString *)faultSymptomID
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

/* 故障原因分析 */
- (NSURLSessionDataTask *)commonAPIsGetDiagnosisResultListWithAutoFaultStructureID:(NSString *)faultStructureID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////汽车型号选择/////##########/////
/* 车辆品牌 */
- (NSURLSessionDataTask *)commonAPIsGetAutoBrandListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;

/* 车辆经销商 */
- (NSURLSessionDataTask *)commonAPIsGetAutoBrandDealershipListWithBrandID:(NSString *)brandID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 车辆系列 */
- (NSURLSessionDataTask *)commonAPIsGetAutoSeriesListWithBrandDealershipID:(NSString *)brandDealershipID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 车辆型号 */
- (NSURLSessionDataTask *)commonAPIsGetAutoModelListWithAutoSeriesID:(NSString *)seriesID
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;


#pragma mark /////##########/////维修指南/////##########/////
/* 维修指南 */
- (NSURLSessionDataTask *)repairGuideAPIsGetMainPageGuideDataWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;


/* 维修指南二级列表 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideSubTypeListWithMainTypeName:(NSString *)mainTypeName
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 维修指南三级列表 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideResultListWithSubTypeID:(NSString *)subTypeID
                                                                        pageNums:(NSNumber *)pageNums
                                                                       pageSizes:(NSNumber *)pageSizes
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;
/* 维修指南详情 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:(NSString *)procedureDetailID
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;

/* 维修指南指导资讯 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairStepGuideDetailWithProcedureDetailID:(NSString *)procedureDetailID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;



/* 维修指南指导结果 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairStepGuideFinalResultWithProcedureDetailID:(NSString *)procedureDetailID
                                                                                     seriesID:(NSString *)seriesID
                                                                                  autoModelID:(NSString *)autoModelID
                                                                                   repairName:(NSString *)repairName
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////违章/////##########/////
/* 违章查询界面，车辆及违章次数界面 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserViolationEnquiryInfoWithAccessToken:(NSString *)token
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 违章查询 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserViolationEnquiryRequestWithAccessToken:(NSString *)token
                                                                            myAutoEngineNum:(NSString *)myAutoEngineNum
                                                                               licensePlate:(NSString *)licensePlate
                                                                            isShowRequested:(BOOL)isShowRequested
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;
/* 高发地查询列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCityViolationEnquiryListWithCityName:(NSString *)cityName
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;
/* 违章排行榜列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserHighViolationListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;
/* 高发地神坑排行榜列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetHighViolationLocationListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 违章详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetViolationDetailWithBlacksiteAddress:(NSString *)siteAddress
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;
/* 违章地点纠错 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserCorrectViolationLocationRequestWithAccessToken:(NSString *)token
                                                                                    blacksiteAddress:(NSString *)siteAddress
                                                                                           longitude:(NSNumber *)longitude
                                                                                            latitude:(NSNumber *)latitude
                                                                                            cityName:(NSString *)cityName
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////车考题库/////##########/////
/* 榜上有名查询 */
- (NSURLSessionDataTask *)personalCenterAPIsGetTrafficExaminationRankingListWithListType:(TERankingType)listType
                                                                                  pageNums:(NSNumber *)pageNums
                                                                                 pageSizes:(NSNumber *)pageSizes
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 易错题目列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetTrafficExaminationRankingListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 模拟考试提交 */
- (NSURLSessionDataTask *)personalCenterAPIsPostTrafficExaminationSubmitSimulateExamWithAccessToken:(NSString *)token
                                                                                           resultMark:(NSNumber *)resultMark
                                                                                          useExamTime:(NSString *)useExamTime
                                                                                       examFailIDList:(NSString *)examFailIDList
                                                                                              success:(APIsConnectionSuccessBlock)success
                                                                                              failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////其他/////##########/////

/* 省份列表 */
- (NSURLSessionDataTask *)commonAPIsGetProvinceListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                              failure:(APIsConnectionFailureBlock)failure;

/* 城市列表 */
- (NSURLSessionDataTask *)commonAPIsGetCityListWithProvinceID:(NSString *)provinceID
                                                      isKeyCity:(BOOL)isKeyCity
                                                        success:(APIsConnectionSuccessBlock)success
                                                        failure:(APIsConnectionFailureBlock)failure;
/* 区列表 */
- (NSURLSessionDataTask *)commonAPIsGetDistrictListWithCityID:(NSString *)cityID
                                                        success:(APIsConnectionSuccessBlock)success
                                                        failure:(APIsConnectionFailureBlock)failure;

/* 维修商类型列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 维修商保养服务类型列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopServiceTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 维修商保养服务列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopServiceListWithShopID:(NSString *)shopID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 订单状态列表 */
- (NSURLSessionDataTask *)commonAPIsGetPurchaseOrderStatusListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;
#pragma mark- /////##########/////GPS接口/////##########/////
#pragma mark /////##########/////GPS配置/////##########/////
/* 车辆实时位置信息 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoGPSRealtimeInfoWithAccessToken:(NSString *)token
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 查询GPS上传设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetUploadSettingStatusWithAccessToken:(NSString *)token
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 修改GPS上传设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostUpdateGPSUploadSettingWithAccessToken:(NSString *)token
                                                                     localinfoStatus:(NSNumber *)localinfoStatus
                                                                        remindStatus:(NSNumber *)remindStatus
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;



#pragma mark /////##########/////OBD&&车辆配置/////##########/////
/* 服务密码验证 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAuthorizeServerSecurityPWWithAccessToken:(NSString *)token
                                                                                 serPwd:(NSString *)serPwd
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;
/* 快速设防详情 */
- (NSURLSessionDataTask *)personalGPSAPIsGetFastPreventionDetailWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;
/* 开启快速设防 */
- (NSURLSessionDataTask *)personalGPSAPIsPostFastPreventionOfnWithAccessToken:(NSString *)token
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;
/* 关闭快速设防 */
- (NSURLSessionDataTask *)personalGPSAPIsPostFastPreventionOffWithAccessToken:(NSString *)token
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;
/* 省电设置详情 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoPowerSaveStatusWithAccessToken:(NSString *)token
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 修改省电设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoPowerSaveChangeStatusWithAccessToken:(NSString *)token
                                                                                 status:(BOOL)status
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 设备安装校正 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoDeviceCalibrationWithAccessToken:(NSString *)token
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;
/* 点火熄火校准 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoIgnitionSystemCalibrationWithAccessToken:(NSString *)token
                                                                                     status:(BOOL)status
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;


/* 获取安全设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoAllAlertStatusListWithAccessToken:(NSString *)token
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 修改侧翻设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoRoleAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                 status:(BOOL)status
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;

/* 修改碰撞设置*/
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoImpactAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                   status:(BOOL)status
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 修改电瓶低电压设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoBatteryLowAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                       status:(BOOL)status
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure;
/* 修改拖车设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoTrailingAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                     status:(BOOL)status
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 修改设备移除（断电）设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoODBRemoveAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                      status:(BOOL)status
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 修改防盗喇叭设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoSecurityAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                     status:(BOOL)status
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 修改疲劳驾驶设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoFatigueDrivingAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                           status:(BOOL)status
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure;


/* 获取超速设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOverSpeedSettingWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 修改超速设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoOverSpeedSettingUpdateWithAccessToken:(NSString *)token
                                                                             speedStatus:(BOOL)speedStatus
                                                                                   speed:(NSNumber *)speed
                                                                             voiceStatus:(BOOL)voiceStatus
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 获取断油断电设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoPowerAndOilControlStatusWithAccessToken:(NSString *)token
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 修改断油断电设置*/
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoPowerAndOilControlStatusUpdateWithAccessToken:(NSString *)token
                                                                                          status:(BOOL)status
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;





/* 查询个人电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoElectricFencingDetialWithAccessToken:(NSString *)token
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

/* 增加电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoAddElectricFencingWithAccessToken:(NSString *)token
                                                                                type:(NSString *)type
                                                                              radius:(NSString *)radius
                                                                           longitude:(NSString *)longitude
                                                                            latitude:(NSString *)latitude
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

/* 删除电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoRemoveElectricFencingWithAccessToken:(NSString *)token
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;


/* OBD主动查询 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOBDDataWithAccessToken:(NSString *)token
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;

/* OBD故障检测 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOBDDiagnosisWithAccessToken:(NSString *)token
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure;





#pragma mark /////##########/////GPS、汽车记录和数据/////##########/////
/* 行车轨迹 */
- (NSURLSessionDataTask *)personalGPSAPIsGetDrivingHistoryListWithAccessToken:(NSString *)token
                                                                  startDateTime:(NSString *)startDateTime
                                                                    endDateTime:(NSString *)endDateTime
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 清除行车历史轨迹 */
- (NSURLSessionDataTask *)personalGPSAPIsPostEraseDrivingHistoryWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////##########/////其他/////##########/////
/* 消息列表 */
- (NSURLSessionDataTask *)personalMessageAPIsGetMessageAlertListWithAccessToken:(NSString *)token
                                                                         pageNums:(NSNumber *)pageNums
                                                                        pageSizes:(NSNumber *)pageSizes
                                                                        plateName:(NSString *)plateName
                                                                         typeName:(NSString *)typeName
                                                                  isMessWasReaded:(BOOL)isMessWasReaded
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;
/* 消息删除 */
- (NSURLSessionDataTask *)personalMessageAPIsPostMessageAlertMessageDeleteWithAccessToken:(NSString *)token
                                                                                  messageID:(NSString *)messageID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failur;

/* 消息已读状态 */
- (NSURLSessionDataTask *)personalMessageAPIsGetMessageAlertWasReaderStatusWithAccessToken:(NSString *)token
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 消息状态更新 */
- (NSURLSessionDataTask *)personalMessageAPIsPostMessageAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                 messageID:(NSString *)messageID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 推送消息设置 */
- (NSURLSessionDataTask *)personalCenterAPNSSettingAlertListWithAccessToken:(NSString *)token
                                                                    messageON:(BOOL)messageON
                                                                    channelID:(NSString *)channelID
                                                                  deviceToken:(NSString *)deviceToken
                                                                   apnsUserID:(NSString *)apnsUserID
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure;

/* 问卷接口 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyPFeedbackToShowWithAccessToken:(NSString *)token
                                                                 answerListString:(NSString *)answerListString
                                                            otherAdviceListString:(NSString *)otherAdviceList
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 设置- 意见反馈展示 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyPFeedbackToShowWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

/* 设置 - 用户反馈信息提交 */
- (NSURLSessionDataTask *)personalSettingsAPIsPostUserFeedback:(NSString *)name
                                                             tel:(NSString *)tel
                                                           token:(NSString *)token
                                                         content:(NSString *)content
                                                        imageUrl:(NSString *)imageUrl
                                                         success:(APIsConnectionSuccessBlock)success
                                                         failure:(APIsConnectionFailureBlock)failure;
/* 用户设置反馈信息照片的提交 */
- (NSURLSessionDataTask *)personalSettingsAPIsPostUseryPortraitImageFeedback:(UIImage *)portraitImage
                                                                     imageName:(NSString *)imageName
                                                                     imageType:(ConnectionImageType)imageType
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
#pragma mark- /////////////////////////////////////////////////////EDR APIs（行车记录仪接口）/////////////////////////////////////////////////////
/* 行车广场 或 我的动态 列表 */
- (NSURLSessionDataTask *)persnalEDRAPIsGetUserShareFetchListWithAccessToken:(NSString *)token
                                                                      wasVideo:(BOOL)wasVideo
                                                                     fetchType:(CDZEREDRShareFetchType)fetchType
                                                                     topicType:(CDZEREDRShareFetchTopicType)topicType
                                                                   otherUserID:(NSString *)otherUserID
                                                                  searchString:(NSString *)searchString
                                                                      pageNums:(NSNumber *)pageNums
                                                                     pageSizes:(NSNumber *)pageSizes
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 行车广场 或 我的动态 详情 */
- (NSURLSessionDataTask *)persnalEDRAPIsGetUserShareFetchDetailWithAccessToken:(NSString *)token
                                                                         fetchID:(NSString *)fetchID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;
/* 行车广场关注或取消关注 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostChangeUserFollowOtherUserStatusWithAccessToken:(NSString *)token
                                                                                   wasFollow:(BOOL)wasFollow
                                                                           wasFollowedUserID:(NSString *)wasFollowedUserID
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure;
/* 行车广场 点赞或 取消点赞 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostChangeUserLikeOtherUserStatusWithAccessToken:(NSString *)token
                                                                                   wasLike:(BOOL)wasLike
                                                                       followedUserFetchID:(NSString *)followedUserFetchID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 行车广场 评论或回复 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostFetchFeedBackWithAccessToken:(NSString *)token
                                                             contentString:(NSString *)contentString
                                                                   fetchID:(NSString *)fetchID
                                                                  wasReply:(BOOL)wasReply
                                                                   replyID:(NSString *)replyID
                                                           beReplyUserName:(NSString *)beReplyUserName
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 行车广场 之发布动态 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchListWithAccessToken:(NSString *)token
                                                                       wasVideo:(BOOL)wasVideo
                                                                  contentString:(NSString *)contentString
                                                             topicTypeListSting:(NSString *)topicTypeListSting
                                                                  shareImageURL:(NSString *)shareImageURL
                                                                  shareMovieURL:(NSString *)shareMovieURL
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

/* 行车广场 个人粉丝／关注列表 */
- (NSURLSessionDataTask *)persnalEDRAPIsGetUserFanOrFollowedListWithAccessToken:(NSString *)token
                                                                       wasFanList:(BOOL)wasFanList
                                                                         pageNums:(NSNumber *)pageNums
                                                                        pageSizes:(NSNumber *)pageSizes
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchImageWithImagePath:(NSURL *)imagePath
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;


- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchMovieWithMoviePath:(NSURL *)moviePath
                                                                withUpoadBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;

#pragma mark- /////////////////////////////////////////////////////Rapid Repair APIs（快速维修接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////快速维修/////##########/////
/* 首页的专业服务、维修商列表的专修服务项目 */
- (NSURLSessionDataTask *)rapidRepairSpecServiceListWithSuccess:(APIsConnectionSuccessBlock)success
                                                          failure:(APIsConnectionFailureBlock)failure;

/* 首页的专修服务品牌列表 */
- (NSURLSessionDataTask *)rapidRepairSpecServiceItemBrandListWithItemBrandType:(SNSSLVFItemBrandType)itemBrandType
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 首页的快速维修列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairShopListWithAccessToken:(NSString *)token
                                                                           cityName:(NSString *)cityName
                                                                         coordinate:(CLLocationCoordinate2D)coordinate
                                                                           pageNums:(NSNumber *)pageNums
                                                                          pageSizes:(NSNumber *)pageSizes
                                                                       filterOption:(NSNumber *)filterOption
                                                                        eSerProject:(NSString *)eSerProject
                                                                      searchKeyword:(NSString *)searchKeyword
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 品牌或专修项目搜索列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairBrandNSpecServiceListWithAccessToken:(NSString *)token
                                                                                        cityName:(NSString *)cityName
                                                                                      coordinate:(CLLocationCoordinate2D)coordinate
                                                                                        pageNums:(NSNumber *)pageNums
                                                                                       pageSizes:(NSNumber *)pageSizes
                                                                                brandOrServiceID:(NSString *)brandOrServiceID
                                                                                    filterOption:(NSNumber *)filterOption
                                                                                   searchKeyword:(NSString *)searchKeyword
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 维修商地图列表（显示周围10公里的维修商） */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairShopMapListWithCityName:(NSString *)cityName
                                                                         coordinate:(CLLocationCoordinate2D)coordinate                                                                              success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 专修店——电瓶、玻璃、轮胎 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairSpecItemServiceListWithItemBrandType:(SNSSLVFItemBrandType)itemBrandType
                                                                                   tireSpecModel:(NSString *)tireSpecModel
                                                                                        cityName:(NSString *)cityName
                                                                                      coordinate:(CLLocationCoordinate2D)coordinate
                                                                                        pageNums:(NSNumber *)pageNums
                                                                                       pageSizes:(NSNumber *)pageSizes
                                                                                    filterOption:(NSNumber *)filterOption
                                                                                         modelID:(NSString *)modelID                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 轮胎规格 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairTireSpecListWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure;

/* 选择轮胎【个人中心有车辆，但default_model为空时，访问此接口】 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairTireDefaultSpecWithAccessToken:(NSString *)token success:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure;

/* 确定轮胎型号【点击推荐的轮胎型号，或者点击更换其他中的搜索轮胎时访问此接口】 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUpdateRapidRepairTireSpecSelectionWithAccessToken:(NSString *)token tireSpecModel:(NSString *)tireSpecModel modelID:(NSString *)modelID success:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure;


/* 维修商的详情页面 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairShopOrServiceDetailWithAccessToken:(NSString *)token
                                                                               shopOrServiceID:(NSString *)shopOrServiceID
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;

/* 维修商属下维修技师 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTechnicianListWithShopID:(NSString *)shopID
                                                                                   pageNums:(NSNumber *)pageNums
                                                                                  pageSizes:(NSNumber *)pageSizes
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;
/* 维修商属下维修技师详情 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTechnicianDetailWithTechnicianID:(NSString *)technicianID
                                                                                           pageNums:(NSNumber *)pageNums
                                                                                          pageSizes:(NSNumber *)pageSizes
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 维修商评论列表(商家评价) */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsCommentListWithShopID:(NSString *)shopID
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 产品评价 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetProductionCommentListWithProductionID:(NSString *)productionID
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 产品中心 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetSpecServiceShopsProductListWithShopID:(NSString *)shopID
                                                                                 modelID:(NSString *)modelID
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                            filterOption:(NSNumber *)filterOption
                                                                        productBrandName:(NSString *)productBrandName
                                                                           tireSpecModel:(NSString *)tireSpecModel
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

/* 立即购买（轮胎、电瓶、玻璃） */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairSpecPartsBuyNowInfoWithAccessToken:(NSString *)token
                                                                                     productID:(NSString *)productID
                                                                                 purchaseCount:(NSNumber *)purchaseCount
                                                                                       brandID:(NSString *)brandID
                                                                             brandDealershipID:(NSString *)brandDealershipID
                                                                                      seriesID:(NSString *)seriesID
                                                                                       modelID:(NSString *)modelID
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure;

/* 提交订单（轮胎、电瓶、玻璃） */
- (NSURLSessionDataTask *)personalCenterAPIsPostRapidRepairSpecPartsOrderSubmitWithAccessToken:(NSString *)token
                                                                                          shopID:(NSString *)shopID
                                                                                       productID:(NSString *)productID
                                                                                   purchaseCount:(NSNumber *)purchaseCount
                                                                                      totalPrice:(NSString *)totalPrice
                                                                             creditTotalConsumed:(NSString *)creditTotalConsumed
                                                                                      verifyCode:(NSString *)verifyCode
                                                                                        couponID:(NSString *)couponID
                                                                                invoicePayeeName:(NSString *)invoicePayeeName
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure;

/* 店铺添加／取消收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsUpdateShopCollectionStatusWithAccessToken:(NSString *)token
                                                                                 shopID:(NSString *)shopID
                                                                   cancelShopCollection:(BOOL)cancelShopCollection
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;


/* 添加车辆信息并返回轮胎型号（选择轮胎时，个人中心没有车辆或者点击更换车辆访问此接口）*/
- (NSURLSessionDataTask *)personalCenterAPIsPostLiteUpdateUserAutosDataWithAccessToken:(NSString *)token
                                                                                 brandID:(NSString *)brandID
                                                                       brandDealershipID:(NSString *)brandDealershipID
                                                                                seriesID:(NSString *)seriesID
                                                                                 modelID:(NSString *)modelID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 快捷保养列表 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceListWithItemsList:(NSArray *)itemsList
                                                                         seriesID:(NSString *)seriesID
                                                                          modelID:(NSString *)modelID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;
/* 快捷保养建议列表 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceRecommendListWithStartToDriveDateTime:(NSString *)start2DriveDateTime
                                                                                              mileage:(NSString *)mileage
                                                                                             seriesID:(NSString *)seriesID
                                                                                              modelID:(NSString *)modelID
                                                                                              success:(APIsConnectionSuccessBlock)success
                                                                                              failure:(APIsConnectionFailureBlock)failure;

/* 快捷保养项目选择（点击快捷保养首页的修改）*/
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetmaintenanceExpressServiceItemListWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure;

/* 快捷保养更换商品 */
- (NSURLSessionDataTask *)personalCenterAPIsGetChangeProductByautopartInfo:(NSString *)autopartInfo
                                                                    pageNums:(NSNumber *)pageNums
                                                                   pageSizes:(NSNumber *)pageSizes
                                                                      number:(NSString *)number
                                                                       speci:(NSString *)speci
                                                                        sort:(NSNumber *)sort
                                                                    standard:(NSString *)standard
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;

/* 快捷保养结算初始数据 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceClearanceDefaultInfoWithAccessToken:(NSString *)token
                                                                                        productList:(NSArray *)productList
                                                                                   productCountList:(NSArray *)productCountList
                                                                                          workHours:(NSNumber *)workHours
                                                                                            brandID:(NSString *)brandID
                                                                                       dealershipID:(NSString *)dealershipID
                                                                                           seriesID:(NSString *)seriesID
                                                                                            modelID:(NSString *)modelID
                                                                                         coordinate:(CLLocationCoordinate2D)coordinate
                                                                                           cityName:(NSString *)cityName
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure;
/* 快捷保养结算确定安装门店初始 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceClearanceInfoAndShopSelectedWithAccessToken:(NSString *)token
                                                                                                productList:(NSArray *)productList
                                                                                           productCountList:(NSArray *)productCountList
                                                                                                    brandID:(NSString *)brandID
                                                                                               dealershipID:(NSString *)dealershipID
                                                                                                   seriesID:(NSString *)seriesID
                                                                                                    modelID:(NSString *)modelID
                                                                                               repairShopID:(NSString *)repairShopID
                                                                                      repairShopRepairPrice:(NSString *)repairShopRepairPrice
                                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 选择安装门店 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceClearanceShopSelectionListWithAccessToken:(NSString *)token
                                                                                         maintainItemList:(NSArray *)maintainItemList
                                                                                               coordinate:(CLLocationCoordinate2D)coordinate
                                                                                                 cityName:(NSString *)cityName
                                                                                                 pageNums:(NSNumber *)pageNums
                                                                                                pageSizes:(NSNumber *)pageSizes
                                                                                         mainFilterOption:(NSNumber *)mainFilterOption
                                                                                             filterOption:(NSNumber *)filterOption
                                                                                            searchKeyword:(NSString *)searchKeyword
                                                                                                  brandID:(NSString *)brandID
                                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 快捷保养提交订单 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceOrderSubmitWithAccessToken:(NSString *)token
                                                                              repairShopID:(NSString *)repairShopID
                                                                             productIDList:(NSArray *)productIDList
                                                                                 addressID:(NSString *)addressID
                                                                                totalPrice:(NSString *)totalPrice
                                                                       creditTotalConsumed:(NSString *)creditTotalConsumed
                                                                                verifyCode:(NSString *)verifyCode
                                                                      invoicePayeeNameList:(NSArray *)invoicePayeeNameList
                                                                            userRemarkList:(NSArray *)userRemarkList
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 保养记录列表 */
- (NSURLSessionDataTask *)maintenanceRecordAPIsGetMaintenanceRecordListWithAccessToken:(NSString *)token
                                                                                 modelID:(NSString *)modelID
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 添加保养记录 */
- (NSURLSessionDataTask *)maintenanceRecordAPIsPostAddMaintenanceRecordWithAccessToken:(NSString *)token
                                                                                 brandID:(NSString *)brandID
                                                                            dealershipID:(NSString *)dealershipID
                                                                                seriesID:(NSString *)seriesID
                                                                                 modelID:(NSString *)modelID
                                                                             totalMileage:(NSString *)totalMileage
                                                                     maintenanceDateTime:(NSString *)maintenanceDateTime
                                                                   maintenanceItemIDList:(NSArray *)maintenanceItemIDList
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 自助保养记录的编辑 */
- (NSURLSessionDataTask *)maintenanceRecordAPIsPostEditMaintenanceRecordWithAccessToken:(NSString *)token
                                                                                 recordID:(NSString *)recordID
                                                                                  brandID:(NSString *)brandID
                                                                             dealershipID:(NSString *)dealershipID
                                                                                 seriesID:(NSString *)seriesID
                                                                                  modelID:(NSString *)modelID
                                                                             totalMileage:(NSString *)totalMileage
                                                                      maintenanceDateTime:(NSString *)maintenanceDateTime
                                                                    maintenanceItemIDList:(NSArray *)maintenanceItemIDList
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////######### 改 改 改 改 改   #/////车辆维修/////##########/////
/* 维修管理列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceListByStatusType:(CDZMaintenanceStatusType)statusType
                                                                 accessToken:(NSString *)token
                                                                    pageNums:(NSNumber *)pageNums
                                                                   pageSizes:(NSNumber *)pageSizes
                                                             shopNameOrKeyID:(NSString *)shopNameOrKeyID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;
/* 查询维修详情由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetrepairOrderDetailByStatusType:(CDZMaintenanceStatusType)statusType
                                                                   accessToken:(NSString *)token
                                                                         keyID:(NSString *)keyID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 同意维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAgreeRepairWithAccessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID
                                                           repairItemsString:(NSString *)repairItemsString
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;
//取消维修
- (NSURLSessionDataTask *)personalCenterAPIsPostRefuseRepairWithAccessToken:(NSString *)token
                                                                        keyID:(NSString *)keyID
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure;
/* 点击确认付款 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmPayWithAccessToken:(NSString *)token
                                                                      keyID:(NSString *)keyID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure;

/* 维修点击确认付款 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEnsurePayorderWithAccessToken:(NSString *)token
                                                                  repairOrderID:(NSString *)repairOrderID
                                                                           mark:(NSNumber *)mark
                                                                        credits:(NSString *)credits
                                                                      validCode:(NSString *)validCode
                                                                       preferId:(NSString *)preferId
                                                                    invoiceHead:(NSString *)invoiceHead
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;


/* 点击评论——服务评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentRepairWithAccessToken:(NSString *)token
                                                                         keyID:(NSString *)keyID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 提交评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubRepairCommentWithAccessToken:(NSString *)token
                                                                            keyID:(NSString *)keyID
                                                                        productID:(NSString *)productID
                                                                             star:(NSString *)star
                                                                          content:(NSString *)content
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure;

/* 查看评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostShowRepairGroupCommentInfoWithAccessToken:(NSString *)token
                                                                                      keyID:(NSString *)keyID
                                                                                  productID:(NSString *)productID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;


////////////////////////////////////////////////////////

//订单列表（全部、待付款、待收货、待安装、待评价）
- (NSURLSessionDataTask *)personalCenterAPIsGetOrderListByStatusType:(NSNumber *)status
                                                           accessToken:(NSString *)token
                                                              pageNums:(NSNumber *)pageNums
                                                             pageSizes:(NSNumber *)pageSizes
                                                              keyWords:(NSString *)keyWords
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;

/* 订单详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetOrderDetailByaccessToken:(NSString *)token
                                                                    keyID:(NSString *)keyID
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure;

/* 未付款——立即支付 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPayNowByaccessToken:(NSString *)token
                                                               keyID:(NSString *)keyID
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure;
/* 未付款、货到付款——取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCancleOrder1ByaccessToken:(NSString *)token
                                                                     keyID:(NSString *)keyID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 交易关闭——删除订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetDelOrderByaccessToken:(NSString *)token
                                                                 keyID:(NSString *)keyID
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;

/* 未付款、货到付款——取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCancleOrder2ByaccessToken:(NSString *)token
                                                                     keyID:(NSString *)keyID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 派送中——确认收货 */
- (NSURLSessionDataTask *)personalCenterAPIsGetConfirmReceiveByaccessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;
/*产品评论列表*/
- (NSURLSessionDataTask *)personalCenterAPIsGetCommentOrderInfoByaccessToken:(NSString *)token
                                                                         keyID:(NSString *)keyID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;
/* 我的订单中  提交评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubRepairCommentByorderWithAccessToken:(NSString *)token
                                                                                   keyID:(NSString *)keyID
                                                                               productID:(NSString *)productID
                                                                             productType:(NSString *)productType
                                                                                    star:(NSString *)star
                                                                                 content:(NSString *)content
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 我的订单中  查看评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostShowOrderGroupCommentInfoWithAccessToken:(NSString *)token
                                                                                     keyID:(NSString *)keyID
                                                                                 productID:(NSString *)productID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;
/* 点击申请退款*/
- (NSURLSessionDataTask *)personalCenterAPIsPostApplyRefundByorderWithAccessToken:(NSString *)token
                                                                              keyID:(NSString *)keyID
                                                                          productID:(NSString *)productID

                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure;

/* 提交退款申请*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubApplyRefundByorderWithAccessToken:(NSString *)token
                                                                                 keyID:(NSString *)keyID
                                                                             productID:(NSString *)productID
                                                                             refundNum:(NSString *)refundNum
                                                                           refundPrice:(NSString *)refundPrice
                                                                          refundReason:(NSString *)refundReason
                                                                             refundDes:(NSString *)refundDes

                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;


/*退款进度——返修/退换*/
- (NSURLSessionDataTask *)personalCenterAPIsGetRefundScheduleByaccessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure;
//查找配件
- (NSURLSessionDataTask *)personalCenterAPIsGetProductListBysortType:(NSNumber *)sort
                                                          autopartInfo:(NSString *)autopartInfo
                                                              pageNums:(NSNumber *)pageNums
                                                             pageSizes:(NSNumber *)pageSizes
                                                              keyWords:(NSString *)keyWords
                                                                 speci:(NSString *)speci
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;
//查找配件
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartTypeSuccess:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure;

//快速购买配件
- (NSURLSessionDataTask *)productDetailAPIsGetProductBuyNowPaymentInfoWithAccessToken:(NSString *)token
                                                                              productID:(NSString *)productID
                                                                          purchaseCount:(NSString *)purchaseCount
                                                                                brandID:(NSString *)brandID
                                                                           dealershipID:(NSString *)dealershipID
                                                                               seriesID:(NSString *)seriesID
                                                                                modelID:(NSString *)modelID
                                                                              addressID:(NSString *)addressID
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;
/*配件二级分类信息*/
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartListBykeyID:(NSString *)keyID
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure;
/*配件三级分类信息*/
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartInfoBykeyID:(NSString *)keyID
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure;


//、询价省份、城市、采购中心信息
- (NSURLSessionDataTask *)personalCenterAPIsGetInquiryInfoByprovinceID:(NSString *)provinceID
                                                                  cityID:(NSString *)cityID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;
//购物车移至收藏
- (NSURLSessionDataTask *)personalCenterAPIsPostCartListMoveCollectionWithAccessToken:(NSString *)token
                                                                          productIDList:(NSArray *)productIDList
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;


/* 特殊（轮胎，玻璃，电瓶）产品详情 */
- (NSURLSessionDataTask *)rapidRepairAPIsGetSpecProductDetailWithSpecProductID:(NSString *)specProductID
                                                                      coordinate:(CLLocationCoordinate2D)coordinate
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////#########/////会员中心/////##########/////
// 会员中心详情
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberCenterDetailWithAccessToken:(NSString *)token
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

// 会员详情简介
- (NSURLSessionDataTask *)personalCenterAPIsGetMemberTypeDetailWithAccessToken:(NSString *)token
                                                                    memberTypeID:(NSNumber *)memberTypeID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure;
// 会员申请
- (NSURLSessionDataTask *)personalCenterAPIsPostMemberApplicationSubmitWithAccessToken:(NSString *)token
                                                                       applyMemberTypeID:(NSNumber *)applyMemberTypeID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure;

// 会员订单确认
- (NSURLSessionDataTask *)personalCenterAPIsPostMemberPaymentSubmitPaymentWithAccessToken:(NSString *)token
                                                                            memberProductID:(NSString *)memberProductID
                                                                           invoicePayeeName:(NSString *)invoicePayeeName
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure;


// 会员权益详情
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberRightsDetailWithAccessToken:(NSString *)token
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure;

// 会员成长列表
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberHistoryListWithAccessToken:(NSString *)token
                                                                             pageNums:(NSNumber *)pageNums
                                                                            pageSizes:(NSNumber *)pageSizes
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

#pragma mark /////#########/////技师模块/////##########/////
// 技师技能列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicSpecialListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure;

// 技师列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicListWithFilterOption:(NSNumber *)filterOption
                                                                     pageNums:(NSNumber *)pageNums
                                                                    pageSizes:(NSNumber *)pageSizes
                                                                searchKeyword:(NSString *)searchKeyword
                                                        mechanicSpecialfilter:(NSString *)mechanicSpecialfilter
                                                           listFromRepairShop:(BOOL)listFromRepairShop
                                                                 repairShopID:(NSString *)repairShopID
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure;


// 技师详情
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicDetailWithAccessToken:(NSString *)token
                                                                    mechanicID:(NSString *)mechanicID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure;



// 培训及荣誉
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicExpNCertsListWithMechanicID:(NSString *)mechanicID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure;

// 技师评论列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicCommentListWithMechanicID:(NSString *)mechanicID
                                                                          pageNums:(NSNumber *)pageNums
                                                                         pageSizes:(NSNumber *)pageSizes
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure;

// 更新技师收藏状态
- (NSURLSessionDataTask *)mechanicCenterAPIsPostMechanicCollectionStatustWithAccessToken:(NSString *)token
                                                                                mechanicID:(NSString *)mechanicID
                                                                              toCollection:(BOOL)toCollection
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure;


#pragma mark /////#########/////案例模块/////##########/////

/* 点击获取案列*/
- (NSURLSessionDataTask *)casesHistoryAPIsGetcaseSecondsuccess:(APIsConnectionSuccessBlock)success
                                                         failure:(APIsConnectionFailureBlock)failure;

/* 点击某个部位 获取案例第一级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetCaseThirdWithAutosModelID:(NSString *)autosModelID
                                                                   idStr:(NSString *)idStr
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;
/* 添加案例 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetAddCaseWithWithAccessToken:(NSString *)token
                                                                    brand:(NSString *)brand
                                                                  factory:(NSString *)factory
                                                                      fct:(NSString *)fct
                                                             autosModelID:(NSString *)autosModelID
                                                                carNumber:(NSString *)carNumber
                                                                  wsxName:(NSString *)wsxName
                                                                  address:(NSString *)address
                                                                   wxsTel:(NSString *)wxsTel
                                                                  addTime:(NSString *)addTime
                                                                  project:(NSString *)project
                                                                     hour:(NSString *)hour
                                                                      fee:(NSString *)fee
                                                                partsName:(NSString *)partsName
                                                                 partsNum:(NSString *)partsNum
                                                               partsPrice:(NSString *)partsPrice
                                                                      img:(NSString *)img
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure;


/* 我的案例 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyCaseListWithAccessToken:(NSString *)token
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure;

/* 编辑案例 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetEditCaseWithAccessToken:(NSString *)token
                                                                 idStr:(NSString *)idStr
                                                                 brand:(NSString *)brand
                                                               factory:(NSString *)factory
                                                                   fct:(NSString *)fct
                                                          autosModelID:(NSString *)autosModelID
                                                             carNumber:(NSString *)carNumber
                                                               wsxName:(NSString *)wsxName
                                                               address:(NSString *)address
                                                                wxsTel:(NSString *)wxsTel
                                                               addTime:(NSString *)addTime
                                                               project:(NSString *)project
                                                                  hour:(NSString *)hour
                                                                   fee:(NSString *)fee
                                                             partsName:(NSString *)partsName
                                                              partsNum:(NSString *)partsNum
                                                            partsPrice:(NSString *)partsPrice
                                                                   img:(NSString *)img
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure;

/* 删除案例 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetDelCaseWithAccessToken:(NSString *)token
                                                                idStr:(NSString *)idStr
                                                              success:(APIsConnectionSuccessBlock)success
                                                              failure:(APIsConnectionFailureBlock)failure;

//结算单图片上传
- (NSURLSessionDataTask *)casesHistoryAPIsGetStatementPicWithImage:(UIImage *)portraitImage
                                                           imageName:(NSString *)imageName
                                                           imageType:(ConnectionImageType)imageType
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure  ;



/*查看案例评论*/
- (NSURLSessionDataTask *)personalCenterAPIsGetShowCaseCommentWithIDStr:(NSString *)idStr
                                                                 pageNums:(NSNumber *)pageNums
                                                                pageSizes:(NSNumber *)pageSizes
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure;

// 提交案例评论
- (NSURLSessionDataTask *)repairCaseAPIsPostCaseCommentWithAccessToken:(NSString *)token
                                                                  caseID:(NSString *)caseID
                                                          commentContent:(NSString *)commentContent
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure;

//一键报案
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceInfoCheckWithtAccessToken:(NSString *)token
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure;
//一键报案
//新
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceHotlineWithtAccessToken:(NSString *)token
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure;

@end
