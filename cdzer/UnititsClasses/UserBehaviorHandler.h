//
//  UserBehaviorHandler.h
//  cdzer
//
//  Created by KEns0n on 7/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


typedef NS_ENUM(NSInteger, CDZUserType) {
    CDZUserTypeOfUnknowUser=0,
    CDZUserTypeOfNormalUser=1,
    CDZUserTypeOfGPSUser=6,
    CDZUserTypeOfGPSWithODBUser=7,
};

typedef NS_ENUM(NSInteger, CDZUserDataError) {
    CDZUserDataErrorTokenOrUserIDMssing=-100,
    CDZUserDataErrorDataCorruption=-101,
    CDZUserDataNetworkUpdateAccessError=-102,
};

typedef void (^UBValidCodeSuccessBlock)(NSString *code);
typedef void (^UBLogoutCompletionBlock)(void);
typedef void (^UBLoginRegisterSuccessBlock)(void);
typedef void (^UBLoginRegisterfailureBlock)(NSString *errorMessage, NSError *error);
#import <Foundation/Foundation.h>
#import "UserMemberCenterConfig.h"


@interface PersonalCenterIndicateInfoObject : NSObject

@property (nonatomic, strong) NSString *userCreditRemainCount;

@property (nonatomic, strong) NSString *orderUnpayCount;

@property (nonatomic, strong) NSString *orderDeliveringCount;

@property (nonatomic, strong) NSString *orderNotInstallCount;

@property (nonatomic, strong) NSString *orderUncommentCount;

@property (nonatomic, strong) NSString *joinedMemberShopCount;

@property (nonatomic, strong) NSString *UnMessageCount;

@end

@interface UserBehaviorHandler : NSObject

@property (nonatomic, readonly) NSString* getUserToken;

@property (nonatomic, readonly) NSString* getUserID;

@property (nonatomic, assign, readonly) UserMemberType getUserMemberType;

@property (nonatomic, assign, readonly) CDZUserType getUserType;

@property (nonatomic, readonly) NSString* getUserTypeName;

@property (nonatomic, readonly) NSString *getCSHotline;

@property (nonatomic, assign, readonly) BOOL wasShowLoginAlert;

@property (nonatomic, readonly) PersonalCenterIndicateInfoObject *pcIndicateInfo;


+ (UserBehaviorHandler *)shareInstance;

- (void)updateUserMemberType:(NSString *)memberName;

- (void)setShowLoginAlert:(BOOL)showLoginAlert;

- (void)updateUserIdentData;

- (void)userLogoutWasPopupDialog:(BOOL)showDialog andCompletionBlock:(UBLogoutCompletionBlock)completionBlock;

- (void)validUserTokenWithSuccessBlock:(UBLoginRegisterSuccessBlock)successBlock failureBlock:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userLoginWithUserPhone:(NSString *)userPhone password:(NSString *)password success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userRegisterWithUserPhone:(NSString *)userPhone validCode:(NSString *)validCode password:(NSString *)password repassword:(NSString *)repassword invitationCode:(NSString *)invitationCode success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userRequestRegisterValidCodeWithUserPhone:(NSString *)userPhone success:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userForgotPasswordWithUserPhone:(NSString *)userPhone validCode:(NSString *)validCode password:(NSString *)password repassword:(NSString *)repassword success:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userRequestForgotPasswordValidCodeWithUserPhone:(NSString *)userPhone success:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)userRequestCreditValidCodeWithSuccessBlock:(UBValidCodeSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

- (void)notifyUserWasPaymenFinishAndSucceeWithOutTradeNum:(NSString *)outTradeNum;

- (void)userRequestEserviceVerifyCodeWithSuccess:(UBLoginRegisterSuccessBlock)successBlock failure:(UBLoginRegisterfailureBlock)failureBlock;

@end
