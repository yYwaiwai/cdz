//
//  UserBehaviorHandler.m
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AddressDTO.h"
#import "BDPushConfigDTO.h"
#import "UserAutosInfoDTO.h"
#import "UserSelectedAutosInfoDTO.h"
#import "UserBehaviorHandler.h"
#import "MemberReviewNoticeView.h"
#import "UserMemberCenterConfig.h"
#import "EServiceAutoCancelApointmentObject.h"
@interface UserBehaviorHandler()
{
    NSString *_uid;
    NSString *_userToken;
    UserMemberType _userMemberType;
    CDZUserType _userType;
    NSString *_userTypeName;
    NSString *_csHotline;
}
@end

@implementation UserBehaviorHandler

static UserBehaviorHandler *_ubHandleInstance = nil;

- (NSString *)getUserToken {
    if (!_userToken) return nil;
    return [SecurityCryptor.shareInstance tokenDecryption:_userToken];
}

- (NSString *)getUserID {
    if (!_uid) return @"0";
    return _uid;
}

- (UserMemberType)getUserMemberType {
    return _userMemberType;
}

- (CDZUserType)getUserType {
    return _userType;
}

- (NSString *)getUserTypeName {
    if (!_userTypeName) return nil;
    return _userTypeName;
}

- (NSString *)getCSHotline {
//    if (!_csHotline) return @"073188865777";
    return _csHotline;
}

- (void)setPcIndicateInfo:(PersonalCenterIndicateInfoObject *)pcIndicateInfo {
    _pcIndicateInfo = pcIndicateInfo;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

+ (UserBehaviorHandler *)shareInstance {
    
    if (!_ubHandleInstance) {
        _ubHandleInstance = [UserBehaviorHandler new];
        [_ubHandleInstance updateUserIdentData];
        _ubHandleInstance.pcIndicateInfo = [PersonalCenterIndicateInfoObject new];
    }
    return _ubHandleInstance;
}

- (void)setShowLoginAlert:(BOOL)showLoginAlert {
    _wasShowLoginAlert = showLoginAlert;
}

- (void)updateUserIdentData {
    @autoreleasepool {
        NSDictionary *userIdentData = DBHandler.shareInstance.getUserIdentData;
        _uid = nil;
        _userToken = nil;
        _userType = CDZUserTypeOfUnknowUser;
        _userTypeName = nil;
        _csHotline = nil;
        if (userIdentData) {
            NSString *uid = userIdentData[@"uid"];
            if (uid&&![uid isEqualToString:@""]&&[[uid lowercaseString] rangeOfString:@"null"].location==NSNotFound) {
                _uid = uid;
            }
            NSString *userToken = userIdentData[@"token"];
            if (userToken&&![userToken isEqualToString:@""]&&[[userToken lowercaseString] rangeOfString:@"null"].location==NSNotFound) {
                _userToken = userToken;
            }
            NSNumber *userType = userIdentData[@"type"];
            if (userType&&userType.integerValue!=CDZUserTypeOfUnknowUser) {
                _userType = userType.integerValue;
            }
            
            NSString *userTypeName = userIdentData[@"typeName"];
            if (userTypeName&&![userTypeName isEqualToString:@""]&&[[userTypeName lowercaseString] rangeOfString:@"null"].location==NSNotFound) {
                _userTypeName = userTypeName;
            }
            
            NSString *csHotline = [SupportingClass verifyAndConvertDataToString:userIdentData[@"csHotline"]];
            if (csHotline) {
                _csHotline = csHotline;
            }
        }
    }
}

- (void)clearUserData {
    
    NSLog(@"Clear User Ident Data success::::::%d",[DBHandler.shareInstance clearUserIdentData]);
    NSLog(@"Clear User Autos Detail Data success::::::%d",[DBHandler.shareInstance clearUserAutosDetailData]);
}

- (void)userLogoutWasPopupDialog:(BOOL)showDialog andCompletionBlock:(UBLogoutCompletionBlock)completionBlock {
    if (showDialog) {
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"你是否确定注销账号？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                @strongify(self);
                [self executeLogoutWithCompletionBlock:completionBlock];
                
            }
        }];
    }else {
        [self executeLogoutWithCompletionBlock:completionBlock];
    }
}

- (void)executeLogoutWithCompletionBlock:(UBLogoutCompletionBlock)completionBlock  {
    @autoreleasepool {
        if (self.getUserToken) {
            [APIsConnection.shareConnection personalCenterAPNSSettingAlertListWithAccessToken:self.getUserToken messageON:NO channelID:@"" deviceToken:@"" apnsUserID:@"" success:^(NSURLSessionDataTask *operation, id responseObject) {
                NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                NSLog(@"%@",message);
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {}];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOnPush"];
        self.pcIndicateInfo.userCreditRemainCount = nil;
        self.pcIndicateInfo.orderUnpayCount = nil;
        self.pcIndicateInfo.orderDeliveringCount = nil;
        self.pcIndicateInfo.orderNotInstallCount = nil;
        self.pcIndicateInfo.orderUncommentCount = nil;
        self.pcIndicateInfo.joinedMemberShopCount = nil;;
        self.pcIndicateInfo.UnMessageCount = nil;
        
        [DBHandler.shareInstance clearSelectedAutoData];
        BOOL isDone = [[DBHandler shareInstance] clearUserIdentData];
        [DBHandler.shareInstance clearUserAutosDetailData];
        [DBHandler.shareInstance clearUserInfo];
        UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
        [EServiceAutoCancelApointmentObject stopService];
        if (isDone) {
            [self updateUserIdentData];
            if (completionBlock) {
                completionBlock();
            }
        }

    }
}

- (void)validUserTokenWithSuccessBlock:(UBLoginRegisterSuccessBlock)successBlock failureBlock:(UBLoginRegisterfailureBlock)failureBlock {
    NSString *token = self.getUserToken;
    NSString *userID = _uid;
    if (!token||!userID) {
        NSError *error = [NSError errorWithDomain:@"Token Or UserID Missing" code:CDZUserDataErrorTokenOrUserIDMssing userInfo:nil];
        failureBlock(@"", error);
    };
    
    BDPushConfigDTO *dto = DBHandler.shareInstance.getBDAPNSConfigData;
    
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPostValidUserTokenWithAccessToken:token userID:userID channelID:dto.channelID deviceToken:dto.deviceToken apnsUserID:dto.bdpUserID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"Fail Valid Token");
            [self clearUserData];
            failureBlock(message, nil);
            return;
        }
        BOOL isDone = [self handleUserLoginOrTokenValidResponseData:responseObject];
        if (isDone) {
            successBlock();
            [self updateUserAdderss];
            [self showMemberLvUpWithLoginDetail:responseObject[CDZKeyOfResultKey]];
        }else {
            NSLog(@"Fail Valid Token");
            [self clearUserData];
            NSError *error = [NSError errorWithDomain:@"Data Corruption" code:CDZUserDataErrorDataCorruption userInfo:nil];
            failureBlock(@"验证失败！", error);
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"登录失败，请稍后再试！", theError);
    }];

}

- (void)userLoginWithUserPhone:(NSString *)userPhone password:(NSString *)password success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    @weakify(self);
    
    BDPushConfigDTO *pushDTO = DBHandler.shareInstance.getBDAPNSConfigData;
    NSString *channelID = pushDTO.channelID;
    NSString *deviceToken = pushDTO.deviceToken;
    NSString *apnsUserID = pushDTO.bdpUserID;
    
    [[APIsConnection shareConnection] personalCenterAPIsPostUserLoginWithUserPhone:userPhone password:password  channelID:channelID deviceToken:deviceToken apnsUserID:apnsUserID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        @strongify(self);
        BOOL isDone = [self handleUserLoginOrTokenValidResponseData:responseObject];
        if (isDone) {
            [EServiceAutoCancelApointmentObject startService];
            successBlock();
            if (![channelID isEqualToString:@""]&&![deviceToken isEqualToString:@""]&&![apnsUserID isEqualToString:@""]) {
                [APIsConnection.shareConnection personalCenterAPNSSettingAlertListWithAccessToken:self.getUserToken messageON:YES channelID:channelID deviceToken:deviceToken apnsUserID:apnsUserID success:^(NSURLSessionDataTask *operation, id responseObject) {
                    NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                    NSLog(@"%@",message);
                    NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
                    if (errorCode==0) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOnPush"];
                    }
                } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                
                }];
            }
            [self updateUserAdderss];
            [self showMemberLvUpWithLoginDetail:responseObject[CDZKeyOfResultKey]];
        }else {
            NSLog(@"Login Fail");
            [self clearUserData];
            NSError *error = [NSError errorWithDomain:@"Data Corruption" code:CDZUserDataErrorDataCorruption userInfo:nil];
            failureBlock(@"验证失败！", error);
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"登录失败，请稍后再试！", theError);
    }];
}

- (void)userRegisterWithUserPhone:(NSString *)userPhone validCode:(NSString *)validCode password:(NSString *)password repassword:(NSString *)repassword invitationCode:(NSString *)invitationCode success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    [[APIsConnection shareConnection] personalCenterAPIsPostUserRegisterWithUserPhone:userPhone validCode:validCode password:password repassword:repassword invitationCode:invitationCode success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        successBlock();
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"注册失败，请稍后再试！", theError);
    }];
}

- (void)userRequestRegisterValidCodeWithUserPhone:(NSString *)userPhone success:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    [[APIsConnection shareConnection] personalCenterAPIsPostUserRegisterValidCodeWithUserPhone:userPhone success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        NSString *verifyCode = [SupportingClass verifyAndConvertDataToString:[responseObject[CDZKeyOfResultKey] objectForKey:@"verify"]];
//        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:verifyCode isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        successBlock(verifyCode);
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"请求验证码失败，请稍后再试！", theError);
    }];
}

- (void)userForgotPasswordWithUserPhone:(NSString *)userPhone validCode:(NSString *)validCode password:(NSString *)password repassword:(NSString *)repassword success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    [[APIsConnection shareConnection] personalCenterAPIsPostUserForgetPasswordWithUserPhone:userPhone validCode:validCode password:password repassword:repassword success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        successBlock();
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"密码更改失败，请稍后再试！", theError);
    }];
}

- (void)userRequestForgotPasswordValidCodeWithUserPhone:(NSString *)userPhone success:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    [[APIsConnection shareConnection] personalCenterAPIsPostUserForgetPWValidCodeWithUserPhone:userPhone success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        NSString *verifyCode = [SupportingClass verifyAndConvertDataToString:[responseObject[CDZKeyOfResultKey] objectForKey:@"verify"]];
//        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:verifyCode isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        successBlock(verifyCode);
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"请求验证码失败，请稍后再试！", theError);
    }];
}

- (BOOL)handleUserLoginOrTokenValidResponseData:(id)responseObject {
    NSDictionary *result = responseObject[CDZKeyOfResultKey];
    NSString *token = result[@"token"];
    NSString *uid = result[@"user_id"];
    NSNumber *typeID = @([result[@"type_id"] integerValue]);
    NSString *typeName = result[@"type_name"];
    NSString *csHotline = [SupportingClass verifyAndConvertDataToString:result[@"customer"]];
    
    self.pcIndicateInfo.userCreditRemainCount = [SupportingClass verifyAndConvertDataToString:result[@"credits"]];
    self.pcIndicateInfo.orderUnpayCount = [SupportingClass verifyAndConvertDataToString:result[@"no_pay"]];
    self.pcIndicateInfo.orderDeliveringCount = [SupportingClass verifyAndConvertDataToString:result[@"no_receive"]];
    self.pcIndicateInfo.orderNotInstallCount = [SupportingClass verifyAndConvertDataToString:result[@"no_install"]];
    self.pcIndicateInfo.orderUncommentCount = [SupportingClass verifyAndConvertDataToString:result[@"no_comment"]];
    self.pcIndicateInfo.joinedMemberShopCount = [SupportingClass verifyAndConvertDataToString:result[@"member_shop_num"]];
    self.pcIndicateInfo.UnMessageCount = [SupportingClass verifyAndConvertDataToString:result[@"message_num"]];
    
    
    UserAutosInfoDTO *dto = [UserAutosInfoDTO new];
    [dto processDataToObject:result[@"carInfo"] optionWithUID:uid];
    
    if([DBHandler.shareInstance updateUserToken:token userID:uid userType:typeID typeName:typeName csHotline:csHotline]) {
        [self updateUserIdentData];
        NSLog(@"success update token & uid");
        NSLog(@"success update user autos detail data::::::%d", [DBHandler.shareInstance updateUserAutosDetailData:[dto processObjectToDBData]]);
        
        if (dto.brandID.integerValue!=0&&dto.dealershipID.integerValue!=0&&
            dto.seriesID.integerValue!=0&&dto.modelID.integerValue!=0) {
            UserSelectedAutosInfoDTO *selectedAutoDto = [UserSelectedAutosInfoDTO new];
            [selectedAutoDto processDataToObjectWithDto:dto];
            NSLog(@"success update selected autos detail data::::::%d", [DBHandler.shareInstance updateSelectedAutoData:selectedAutoDto]);
        }
        
    }

    NSString *enToken = self.getUserToken;
    BOOL isDone = [enToken isEqual:token];
    NSLog(@"isTokenSaveSuccess:::%d",isDone);
    return isDone;
}

- (void)userRequestCreditValidCodeWithSuccessBlock:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock {
    if (!self.getUserToken) {
        [SupportingClass showAlertViewWithTitle:@"error" message:@"凭证失效！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    [[APIsConnection shareConnection] personalCenterAPIsPostUserCreditValidCodeWithAccessToken:self.getUserToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        NSString *verifyCode = [SupportingClass verifyAndConvertDataToString:[responseObject[CDZKeyOfResultKey] objectForKey:@"verify"]];
//        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:verifyCode isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        successBlock(verifyCode);
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"请求验证码失败，请稍后再试！", theError);
    }];
}

- (void)notifyUserWasPaymenFinishAndSucceeWithOutTradeNum:(NSString *)outTradeNum {
    if(outTradeNum.length==0||!self.getUserToken||self.getUserToken.length==0) return;
    [APIsConnection.shareConnection personalCenterAPIsPostUserPaymentFinishNotifyWithAccessToken:self.getUserToken outTradeNum:outTradeNum success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return ;
        }
        NSLog(@"通知成功:====>%@" ,message);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"error");
    }];
}

- (void)userRequestEserviceVerifyCodeWithSuccess:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock  {
    [[APIsConnection shareConnection] personalCenterAPIsGetEServiceCreditsRequestVerifyCodeWithAccessToken:self.getUserToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0) {
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            failureBlock(message, nil);
            return;
        }
        successBlock();
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSError *theError = [NSError errorWithDomain:@"UpdateAccessNetworkError" code:CDZUserDataNetworkUpdateAccessError userInfo:nil];
        failureBlock(@"请求验证码失败，请稍后再试！", theError);
    }];
}

- (void)updateUserAdderss {
    [APIsConnection.shareConnection personalCenterAPIsGetShippingAddressListWithAccessToken:self.getUserToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            NSLog(@"获取失败:====>%@" ,message);
            return ;
        }
        NSArray <AddressDTO *> *addressList = [AddressDTO handleDataListToDTOList:[responseObject objectForKey:CDZKeyOfResultKey]];
        NSLog(@"获取成功:====>%@" ,message);
        AddressDTO *selectedAddress = DBHandler.shareInstance.getUserDefaultAddress;
        if (selectedAddress) {
            if (addressList.count==0) {
                [DBHandler.shareInstance clearUserDefaultAddress];
            }else {
                AddressDTO *defaultAddress = addressList.firstObject;
                if ([defaultAddress.addressID isEqualToString:selectedAddress.addressID]) {
                    NSLog(@"地址不需更新！");
                }else {
                    [DBHandler.shareInstance clearUserDefaultAddress];
                    BOOL isDone = [DBHandler.shareInstance updateUserDefaultAddress:addressList.firstObject];
                    NSLog(@"Was Update Address====>:: %d At %@", isDone, NSStringFromClass([self class]));
                }
            }
        }else {
            if (addressList.count!=0){
                [DBHandler.shareInstance clearUserDefaultAddress];
                BOOL isDone = [DBHandler.shareInstance updateUserDefaultAddress:addressList.firstObject];
                NSLog(@"Was Update Address====>:: %d At %@", isDone, NSStringFromClass([self class]));
            }else {
                [DBHandler.shareInstance clearUserDefaultAddress];
            }
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"Did Not Access User Address List");
    }];
}

- (void)updateUserMemberType:(NSString *)memberName {
    
    _userMemberType = [UserMemberCenterConfig getMemberTypeByString:memberName];
}

- (void)showMemberLvUpWithLoginDetail:(NSDictionary *)loginDetail {
//    level_name										用户等级
//    audit_info{
//        level_name									会员等级
//        state											1成功，2失败
//        remark										审核失败
    
    NSString *currentLvName = loginDetail[@"level_name"];
    [self updateUserMemberType:currentLvName];
    NSDictionary *auditInfo = loginDetail[@"audit_info"];
//    auditInfo = @{@"level_name":@"",
//                  @"state":@"2",
//                  @"remark":@"test测试",};
    if (auditInfo&&auditInfo.count>0) {
        BOOL reviewSuccess = [[SupportingClass verifyAndConvertDataToString:auditInfo[@"state"]] isContainsString:@"1"];
        UserMemberType memberType = [UserMemberCenterConfig getMemberTypeByString:auditInfo[@"level_name"]];
        NSString *reviewRefuseReason = auditInfo[@"remark"];
        if (!reviewRefuseReason) reviewRefuseReason = @"";
        
        MemberReviewNoticeView *noticeView = [[UINib nibWithNibName:@"MemberReviewNoticeView" bundle:nil] instantiateWithOwner:nil options:nil].lastObject;
        [noticeView showReviewNoticeSuccess:reviewSuccess memberType:memberType withRejectReason:reviewRefuseReason];
    }
    
}

@end

@implementation PersonalCenterIndicateInfoObject



@end

