//
//  APIsConnection.m
//  cdzer
//
//  Created by KEns0n on 4/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef void (^APIsConnectionFormData)(id <AFMultipartFormData> formData);

#import "APIsConnection.h"
#import <CocoaSecurity/CocoaSecurity.h>

#define kParameterOfToken @"token"
#define kParameterOfID @"id"
@interface APIsConnection ()
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) NSMutableSet *normalResponseFilterSet;

@end

@implementation APIsConnection

static APIsConnection *connectionInstance = nil;
static NSString * const FirstRelativePath = @"b2bweb-portal/";
static AFHTTPSessionManager *operationManager = nil;
static AFHTTPSessionManager *imgOperationManager = nil;

+ (APIsConnection *)shareConnection {
    
    if (!connectionInstance) {
        connectionInstance = APIsConnection.new;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        config.URLCache = cache;
        
        connectionInstance.jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        connectionInstance.jsonResponseSerializer.acceptableContentTypes = [connectionInstance.jsonResponseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        
        operationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]
                                                    sessionConfiguration:config];
        //AFHTTPRequestOperationManager responseSerializer configs
        connectionInstance.normalResponseFilterSet = [NSMutableSet set];
        [operationManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        operationManager.requestSerializer.timeoutInterval = 10.0f;
        [operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [operationManager.operationQueue setMaxConcurrentOperationCount:2];
        operationManager.responseSerializer = connectionInstance.jsonResponseSerializer;
        
        imgOperationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]
                                                       sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [imgOperationManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        imgOperationManager.requestSerializer.timeoutInterval = 30.0f;
        [imgOperationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [imgOperationManager.operationQueue setMaxConcurrentOperationCount:2];
        //AFHTTPRequestOperationManager responseSerializer configs
        imgOperationManager.responseSerializer = connectionInstance.jsonResponseSerializer;
    }
    
    return connectionInstance;
}

- (NSURLSessionDataTask *)createRequestWithHTTPMethod:(CDZAPIsHTTPMethod)methodType
                                withFirstRelativePath:(BOOL)withFirstRelativePath
                                         relativePath:(NSString *)pathString
                                           parameters:(id)parameters
                                             progress:(void (^)(NSProgress * downloadProgress))downloadProgress
                        constructingPOSTBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))POSTBodyBlock
                                              success:(APIsConnectionSuccessBlock)success
                                              failure:(APIsConnectionFailureBlock)failure {
    
    //    void (^blockSEL)(NSURLSessionDataTask *operation, id responseObject);
    //
    //    blockSEL = ^(NSURLSessionDataTask *operation, id responseObject){
    //
    //    };
    NSURLSessionDataTask *operation = nil;
    if (!pathString) {
        return operation;
    }
    
    operationManager.responseSerializer = self.jsonResponseSerializer;
    if ([self.normalResponseFilterSet containsObject:pathString]) {
        operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    if (withFirstRelativePath) {
        pathString = [FirstRelativePath stringByAppendingPathComponent:pathString];
    }
    
    
    @autoreleasepool {
        switch (methodType) {
            case CDZAPIsHTTPMethodTypeOfGET:{
                operation = [operationManager GET:pathString parameters:parameters progress:downloadProgress success:success failure:failure];
            }
                
                break;
            case CDZAPIsHTTPMethodTypeOfPOST:{
                if (POSTBodyBlock) {
                    operation = [operationManager POST:pathString parameters:parameters constructingBodyWithBlock:POSTBodyBlock progress:downloadProgress success:success failure:failure];
                }else {
                    operation = [operationManager POST:pathString parameters:parameters progress:downloadProgress success:success failure:failure];
                }
            }
                
                break;
            case CDZAPIsHTTPMethodTypeOfPUT:{
                operation = [operationManager PUT:pathString parameters:parameters success:success failure:failure];
            }
                
                break;
            case CDZAPIsHTTPMethodTypeOfPATCH:{
                operation = [operationManager PATCH:pathString parameters:parameters success:success failure:failure];
            }
                
                break;
            case CDZAPIsHTTPMethodTypeOfDELETE:{
                operation = [operationManager DELETE:pathString parameters:parameters success:success failure:failure];
            }
                
                break;
                
            default:
                NSLog(@"request a error method!!");
                break;
        }
        
        return operation;
    }
}


- (NSURLSessionDataTask *)createImgUploadPostRequestWithRelativePath:(NSString *)pathString
                                                          parameters:(id)parameters
                                                            progress:(void (^)(NSProgress * downloadProgress))downloadProgress
                                       constructingPOSTBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))POSTBodyBlock
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    NSURLSessionDataTask *operation = nil;
    if (!pathString) {
        return operation;
    }
    operation = [imgOperationManager POST:pathString parameters:parameters constructingBodyWithBlock:POSTBodyBlock progress:downloadProgress success:success failure:failure];
    return operation;
}




#pragma mark- /////////////////////////////////////////////////////Personal Center APIs（个人中心接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////用户/////##########/////
/* 个人基本资料 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPersonalInformationWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalInfoDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户注册 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserRegisterWithUserPhone:(NSString *)userPhone
                                                                validCode:(NSString *)validCode
                                                                 password:(NSString *)password
                                                               repassword:(NSString *)repassword
                                                           invitationCode:(NSString *)invitationCode
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!invitationCode) {
            invitationCode = @"";
        }
        NSDictionary *parameters = @{@"telephone":userPhone,
                                     @"code":validCode,
                                     @"pass_word":password,
                                     @"password_again":repassword,
                                     @"recommend_code":invitationCode};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRegister
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户注册验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserRegisterValidCodeWithUserPhone:(NSString *)userPhone
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        CocoaSecurityResult *result = [CocoaSecurity md5:[userPhone stringByAppendingString:@"eq~!000583"]];
        NSString *signature = result.hex;
        NSDictionary *parameters = @{@"telephone":userPhone,
                                     @"signature":signature};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRegisterValidCode
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户忘记密码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserForgetPasswordWithUserPhone:(NSString *)userPhone
                                                                      validCode:(NSString *)validCode
                                                                       password:(NSString *)password
                                                                     repassword:(NSString *)repassword
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"telephone":userPhone, @"code":validCode, @"pass_word":password, @"password_again":repassword};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalForgotPassword
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 用户忘记密码验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserForgetPWValidCodeWithUserPhone:(NSString *)userPhone
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        CocoaSecurityResult *result = [CocoaSecurity md5:[userPhone stringByAppendingString:@"eq~!000583"]];
        NSString *signature = result.hex;
        NSDictionary *parameters = @{@"telephone":userPhone,
                                     @"signature":signature};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalForgotPasswordValidCode
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 用户登录 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserLoginWithUserPhone:(NSString *)userPhone
                                                              password:(NSString *)password
                                                             channelID:(NSString *)channelID
                                                           deviceToken:(NSString *)deviceToken
                                                            apnsUserID:(NSString *)apnsUserID
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!channelID) {
            channelID = @"";
        }
        if (!deviceToken) {
            deviceToken = @"";
        }
        if (!apnsUserID) {
            apnsUserID = @"";
        }
        NSDictionary *parameters = @{@"user_name":userPhone,
                                     @"pass_word":password,
                                     @"channelId":channelID,
                                     @"deviceToken":deviceToken,
                                     @"userId":apnsUserID,
                                     @"deviceCode":@""};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalLogin
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 验证Token期限 */
- (NSURLSessionDataTask *)personalCenterAPIsPostValidUserTokenWithAccessToken:(NSString *)token
                                                                       userID:(NSString *)userID
                                                                    channelID:(NSString *)channelID
                                                                  deviceToken:(NSString *)deviceToken
                                                                   apnsUserID:(NSString *)apnsUserID
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!channelID) {
            channelID = @"";
        }
        if (!deviceToken) {
            deviceToken = @"";
        }
        if (!apnsUserID) {
            apnsUserID = @"";
        }
        
        NSDictionary *parameters = @{@"token":token,
                                     @"userId":userID,
                                     @"channelId":channelID,
                                     @"deviceToken":deviceToken,
                                     @"userId":apnsUserID,
                                     @"deviceCode":@""};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalTokenValid
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户修改密码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserChangePasswordWithAccessToken:(NSString *)token
                                                                      oldPassword:(NSString *)oldPW
                                                                      newPassword:(NSString *)newPW
                                                                 newPasswordAgain:(NSString *)newPWAgain
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"old_pass_word":oldPW,
                                     @"new_pass_word":newPW,
                                     @"again_pass_word":newPWAgain};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalChangePW
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:token forKey:kParameterOfToken];
        if (!nickName&&
            !sexual&&
            !bod&&
            !qqNumber&&
            !email&&
            !realName&&
            !portraitPath) {
            [ProgressHUDHandler dismissHUDWithCompletion:^{
                
            }];
            return nil;
        }
        if (nickName) {
            [parameters setObject:nickName forKey:@"nichen"];
        }
        if (realName){
            [parameters setObject:realName forKey:@"realname"];
        }
        if (sexual) {
            [parameters setObject:sexual forKey:@"sex"];
        }
        
        if (portraitPath) {
            [parameters setObject:portraitPath forKey:@"faceImg"];
        }
        
        if (bod) {
            [parameters setObject:bod forKey:@"birthday"];
        }
        if (qqNumber) {
            [parameters setObject:qqNumber forKey:@"qq"];
        }
        if (email) {
            [parameters setObject:email forKey:@"email"];
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalInfoUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户个人头像修改 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUseryPortraitImage:(UIImage *)portraitImage
                                                         imageName:(NSString *)imageName
                                                         imageType:(ConnectionImageType)imageType
                                                           success:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *imageTypeString = @"image/jpeg";
        NSString *imageExt = @"jpg";
        NSData *data = UIImageJPEGRepresentation(portraitImage, 0.8);
        if (ConnectionImageTypeOfPNG==imageType) {
            imageTypeString = @"image/png";
            imageExt = @"png";
            data = UIImagePNGRepresentation(portraitImage);
        }
        if (!imageName){
            imageName = @"userPortraitImage";
        }
        
        APIsConnectionFormData formData = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:[imageName stringByAppendingPathExtension:imageExt] mimeType:imageTypeString];
        };
        
        NSDictionary *parameters = @{@"root":@"demo/basic/faceImg"};
        NSURLSessionDataTask *operation = nil;
        operation = [self createImgUploadPostRequestWithRelativePath:kCDZPersonalImageUpload
                                                          parameters:parameters
                                                            progress:nil
                                       constructingPOSTBodyWithBlock:formData
                                                             success:success
                                                             failure:failure];
        return operation;
    }
}



/* 用户积分验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserCreditValidCodeWithAccessToken:(NSString *)token
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalCreditValidCode
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////车辆管理/////##########/////
/* 车辆列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoListWithAccessToken:(NSString *)token
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyAutoList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token} mutableCopy];
        if (!brandID && !brandDealershipID && !seriesID&&!modelID &&! registrDate&&
            !myAutoNumber && !myAutoBodyColor && !myAutoMileage &&! myAutoFrameNum&&
            !myAutoEngineNum && !insuranceDate && !annualCheckDate) {// && !maintenanceDate &&!insuranceNum) {
            [ProgressHUDHandler dismissHUDWithCompletion:^{
                
            }];
            return nil;
        }
        
        if (brandID&&![brandID isEqualToString:@""]&&![brandID isEqualToString:@"--"]&&
            brandDealershipID&&![brandDealershipID isEqualToString:@""]&&![brandDealershipID isEqualToString:@"--"]&&
            seriesID&&![seriesID isEqualToString:@""]&&![seriesID isEqualToString:@"--"]&&
            modelID&&![modelID isEqualToString:@""]&&![modelID isEqualToString:@"--"]) {
            [parameters addEntriesFromDictionary: @{@"brand":brandID,
                                                    @"factory":brandDealershipID,
                                                    @"fct":seriesID,
                                                    @"speci":modelID}];
        }
        if (myAutoNumber&&![myAutoNumber isEqualToString:@""]&&
            ![myAutoNumber isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"car_number":myAutoNumber}];
        }
        if (registrDate&&![registrDate isEqualToString:@""]&&
            ![registrDate isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"registr_time":registrDate}];
        }
        if (myAutoBodyColor&&![myAutoBodyColor isEqualToString:@""]&&
            ![myAutoBodyColor isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"color":myAutoBodyColor}];
        }
        if (myAutoMileage&&![myAutoMileage isEqualToString:@""]&&
            ![myAutoMileage isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"mileage":myAutoMileage}];
        }
        if (myAutoFrameNum&&![myAutoFrameNum isEqualToString:@""]&&
            ![myAutoFrameNum isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"frame_no":myAutoFrameNum}];
        }
        if (myAutoEngineNum&&![myAutoEngineNum isEqualToString:@""]&&
            ![myAutoEngineNum isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"engine_code":myAutoEngineNum}];
        }
        if (insuranceDate&&![insuranceDate isEqualToString:@""]&&
            ![insuranceDate isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"insure_time":insuranceDate}];
        }
        if (annualCheckDate&&![annualCheckDate isEqualToString:@""]&&
            ![annualCheckDate isEqualToString:@"--"]){
            [parameters addEntriesFromDictionary: @{@"annual_time":annualCheckDate}];
        }
        //        if (maintenanceDate){
        //            [parameters addEntriesFromDictionary: @{@"maintain_time":maintenanceDate}];
        //        }
        //        if (insuranceNum){
        //            [parameters addEntriesFromDictionary: @{@"insuranceNum":insuranceNum}];
        //        }
        //
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyAutoUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 车辆颜色 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoColorListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyAutosColorList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 车辆省列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoProvincesListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyAutosProvincesList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 车辆市列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyAutoCityListWithAutoProvincesID:(NSString *)autoProvincesID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:autoProvincesID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyAutosCityList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////收藏/////##########/////
/* 收藏的商品列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetProductsCollectionListWithAccessToken:(NSString *)token
                                                                            pageNums:(NSNumber *)pageNums
                                                                           pageSizes:(NSNumber *)pageSizes
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @1;
        if (!pageSizes) pageSizes = @10;
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZProductsCollectionList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 收藏的店铺列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShopsCollectionListWithAccessToken:(NSString *)token
                                                                         pageNums:(NSNumber *)pageNums
                                                                        pageSizes:(NSNumber *)pageSizes
                                                                       coordinate:(CLLocationCoordinate2D)coordinate
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @1;
        if (!pageSizes) pageSizes = @10;
        if (coordinate.latitude==0) coordinate.latitude = 28.224610;
        if (coordinate.longitude==0) coordinate.longitude = 112.893959;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"longitude":@(coordinate.longitude),
                                     @"latitude":@(coordinate.latitude)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZShopsCollectionList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 收藏的技师列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMechanicCollectionListWithAccessToken:(NSString *)token
                                                                            pageNums:(NSNumber *)pageNums
                                                                           pageSizes:(NSNumber *)pageSizes
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @1;
        if (!pageSizes) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicCollectionList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



/* 添加收藏的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertProductCollectionWithAccessToken:(NSString *)token
                                                                         productIDList:(NSArray *)productIDList
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *productIDListStr = [productIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:productIDListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZProductsCollectionAdd
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 添加收藏的店铺 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertShopCollectionWithAccessToken:(NSString *)token
                                                                         shopIDList:(NSArray *)shopIDList
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *shopIDListStr = [shopIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:shopIDListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShopsCollectionAdd
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除收藏的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteProductsCollectionWithAccessToken:(NSString *)token
                                                                       collectionIDList:(NSArray *)collectionIDList
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *collectionIDListStr = [collectionIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:collectionIDListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZProductsCollectionDelete
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除收藏的店铺 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteShopCollectionWithAccessToken:(NSString *)token
                                                                   collectionIDList:(NSArray *)collectionIDList
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *collectionIDListStr = [collectionIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,kParameterOfID:collectionIDListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShopsCollectionDelete
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 检测商品是否已收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsGetProductiWasCollectedWithAccessToken:(NSString *)token
                                                                      collectionID:(NSString *)collectionID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,kParameterOfID:collectionID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZProductWasCollected
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 检测店铺是否已收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShopWasCollectedWithAccessToken:(NSString *)token
                                                                        shopID:(NSString *)shopID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,kParameterOfID:shopID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShopsWasCollected
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////订单/////##########/////
/* 订单列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseOrderListWithAccessToken:(NSString *)token
                                                                       pageNums:(NSString *)pageNums
                                                                      pageSizes:(NSString *)pageSizes
                                                                      stateName:(NSString *)stateName
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @"1";
        if (!pageSizes) pageSizes = @"10";
        
        if (!stateName||[stateName isEqualToString:getLocalizationString(@"all_order_list")]) {
            stateName = @"";
        }
        
        NSDictionary *parameters = @{@"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"state_name":stateName,
                                     kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 订单详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseOrderDetailWithAccessToken:(NSString *)token
                                                                      orderMainID:(NSString *)orderMainID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 提交订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostOrderSubmitWithAccessToken:(NSString *)token
                                                             productIDList:(NSArray *)productIDList
                                                          productCountList:(NSArray *)productCountList
                                                                 addressID:(NSString *)addressID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *productIDListStr = [productIDList componentsJoinedByString:@"-"];
        NSString *productCountListStr = [productCountList componentsJoinedByString:@"-"];
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"buy_count":productCountListStr,
                                     @"product_id":productIDListStr,
                                     @"address_id":addressID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 免加入购物车提交订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostOrderExpressSubmitWithAccessToken:(NSString *)token
                                                                    productIDList:(NSArray *)productIDList
                                                                 productCountList:(NSArray *)productCountList
                                                                          brandID:(NSString *)brandID
                                                                brandDealershipID:(NSString *)brandDealershipID
                                                                         seriesID:(NSString *)seriesID
                                                                          modelID:(NSString *)modelID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *productIDListStr = [productIDList componentsJoinedByString:@","];
        NSString *productCountListStr = [productCountList componentsJoinedByString:@","];
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:productIDListStr,
                                     @"count":productCountListStr,
                                     @"brand":brandID, //(车品牌id)
                                     @"factory":brandDealershipID, //(车厂商id)
                                     @"fct":seriesID, //(车系名id)
                                     @"speci":modelID, //(车型名id)
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderExpressSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *productIDListStr = [productIDList componentsJoinedByString:@"-"];
        NSString *invoicePayeeNameListStr = [invoicePayeeNameList componentsJoinedByString:@"-"];
        
        NSMutableArray *resetUserRemarkList = [userRemarkList mutableCopy];
        [userRemarkList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * _stop) {
            if ([obj isEqualToString:@""]) {
                [resetUserRemarkList replaceObjectAtIndex:idx withObject:@"暂无"];
            }
        }];
        NSString *userRemarkListStr = [resetUserRemarkList componentsJoinedByString:@"--"];
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"address_id":addressID,
                                             @"product_id":productIDListStr,
                                             @"sum_price":totalPrice,
                                             @"android_ios":@"",
                                             @"remark":userRemarkListStr,
                                             @"invoice_head":invoicePayeeNameListStr,
                                             @"mark":@(formCart)} mutableCopy];
        
        if (creditTotalConsumed&&![creditTotalConsumed isEqualToString:@""]&&
            verifyCode&&![verifyCode isEqualToString:@""]){
            [parameters addEntriesFromDictionary:@{@"credit":creditTotalConsumed,
                                                   @"valid_code":verifyCode}];
        }
        
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchasesOrderConfirm
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!costType) {
            costType = @"";
        }
        if (!costTypeName) {
            costTypeName = @"";
        }
        if (!state) {
            state = @"";
        }
        if (!stateName) {
            stateName = @"";
        }
        if (!payType) {
            payType = @"";
        }
        if (!payTypeName) {
            payTypeName = @"";
        }
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"finished":@(!isPayAfterDelivery),
                                             @"main_id":orderMainID} mutableCopy];
        
        [parameters addEntriesFromDictionary:@{@"cost_type":costType,
                                               @"cost_type_name":costTypeName,
                                               @"paytype":payType,
                                               @"paytype_name":payTypeName,
                                               @"state":state,
                                               @"state_name":stateName,}];
        
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPaymentMethodByCashOnDelivery
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 订单付款方法－银联 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodByUnionPayWithAccessToken:(NSString *)token
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalLogin
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 订单付款方法－支付宝 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodByAlipayWithAccessToken:(NSString *)token
                                                                     orderMainID:(NSString *)orderMainID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainOrderId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPaymentMethodByAlipay
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 订单付款方法－微信 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentMethodChangeByWXWithAccessToken:(NSString *)token
                                                                       orderMainID:(NSString *)orderMainID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainOrderId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPaymentMethodChangeToWX
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 更新支付状态 */
- (NSURLSessionDataTask *)personalCenterAPIsPaymentStatusUpdateWithAccessToken:(NSString *)token
                                                                   orderMainID:(NSString *)orderMainID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPaymentStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 订单完成发表评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:(NSString *)token
                                                                                             orderMainID:(NSString *)orderMainID
                                                                                              itemNumber:(NSString *)itemNumber
                                                                                                 content:(NSString *)content
                                                                                                  rating:(NSString *)rating
                                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID,
                                     @"number":itemNumber,
                                     @"content":content,
                                     @"rate":rating};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 订单完成查看评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCommentForPurchaseOrderStateOfOrderFinsihWithAccessToken:(NSString *)token
                                                                                            orderMainID:(NSString *)orderMainID
                                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderCommentView
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCancelPurchaseOrderWithAccessToken:(NSString *)token
                                                                       orderMainID:(NSString *)orderMainID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderCancel
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 订单删除 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeletePurchaseOrderWithAccessToken:(NSString *)token
                                                                       orderMainID:(NSString *)orderMainID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderDelete
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 确定收货 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmPurchaseOrderStateOfHasBeenArrivedWithAccessToken:(NSString *)token
                                                                                             orderMainID:(NSString *)orderMainID
                                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderGoodsArrivedConfirm
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户申请退货 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserApplyReturnedPurchaseWithAccessToken:(NSString *)token
                                                                             orderMainID:(NSString *)orderMainID
                                                                                  reason:(NSString *)reason
                                                                                 content:(NSString *)content
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID,
                                     @"reason":reason,
                                     @"content":content};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderReturnOfGoods
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 确定退货完成 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmGoodsHasBeenReturnAccessToken:(NSString *)token
                                                                         orderMainID:(NSString *)orderMainID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"mainId":orderMainID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderGoodsReturnConfirm
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////保险/////##########/////
/* 检测用户保险信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceInfoCheckWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"sign":@true};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserInsuranceInfoCheck
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户已预约&购买保险列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAppointmentAndPurchasedListWasPurchasedList:(BOOL)isPurchasedList
                                                                                            accessToken:(NSString *)token
                                                                                               pageNums:(NSNumber *)pageNums
                                                                                              pageSizes:(NSNumber *)pageSizes
                                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"state_name":isPurchasedList?@"已购买":@"已预约"};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:isPurchasedList?kCDZUserInsurancePurchasedList:kCDZUserInsuranceAppointmentList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户已登记的保险车辆 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosListWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserInsuranceAutosList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户已登记的保险车辆保费详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosInsurancePremiumDetailWithAccessToken:(NSString *)token
                                                                                       autosLicenseNum:(NSString *)autosLicenseNum
                                                                                               success:(APIsConnectionSuccessBlock)success
                                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"car_number":autosLicenseNum};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserInsuranceAutosPremiumDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户保险详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceAutosInsuranceDetailWithAccessToken:(NSString *)token
                                                                                      premiumID:(NSString *)premiumID
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"premiumId":premiumID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserInsuranceDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"brand":brandID, //(车品牌id)
                                     @"brandName":brandName, //(车品牌)
                                     @"factory":brandDealershipID, //(车厂商id)
                                     @"factoryName":brandDealershipName, //(车厂商)
                                     @"fct":seriesID, //(车系名id)
                                     @"fctName":seriesIName, //(车系名)
                                     @"speci":modelID, //(车型名id)
                                     @"speciName":modelName, //(车型名)
                                     
                                     @"carUserName":userName, //(车主名称),
                                     @"phoneNo":phoneNumber, //(联系方式)
                                     
                                     @"c_city":cityID, //(投保城市)
                                     @"carNumber":autosNumber, //(车牌号)
                                     @"frameNo":autosFrameNum, //(车架号)
                                     @"engineCode":autosEngineNum, //(发动机号)
                                     @"carPrice":autosPrice, //(汽车价格)
                                     @"ncd":acTypeStr, //(出险次数)
                                     @"registTime":autosRegisterDate, //(注册时间)
                                     
                                     @"useType":autosUsageType, //(使用性质)
                                     @"seatNumber":autosNumOfSeats, //(座位号)
                                     @"isAssigned":autosWasSHand?@"是":@"否", //(汽车是否过户)
                                     @"assignedTime":autosAssignmentDate, //(过户时间)
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"carId":carId,
                                     @"company":insuranceCompany,  //保险公司
                                     @"saliTime":autosTALCInsuranceActiveDate,  //交钱险生效时间
                                     @"taxPrice":vehicleAndVesselTax,  //车船税
                                     @"saliPrice":autosTALCInsurance,  //交强险
                                     @"saliAllPrice":@(autosTALCInsurance.doubleValue+vehicleAndVesselTax.doubleValue),  //交强险 总价
                                     
                                     @"businessTime":commerceInsuranceActiveDate,  //商业险生效日期
                                     @"lossPrice":autosDamageInsurance,  //车辆损失险保费
                                     @"thirdType":thirdPartyLiabilityInsuranceCoverage,  //第三方责任险保额
                                     @"thirdPrice":thirdPartyLiabilityInsurance,  //第三方责任险保费
                                     @"theftPrice":robberyAndTheftInsurance,  //全车盗抢险保费
                                     
                                     @"driverType":driverLiabilityInsuranceCoverage,  //司机座位责任险保额
                                     @"driverPrice":driverLiabilityInsurance,  //司机座位责任险保费
                                     @"passengerType":passengerLiabilityInsuranceCoverage,  //乘客座位责任险保额
                                     @"passengerPrice":passengerLiabilityInsurance,  //乘客座位责任险保费
                                     
                                     @"glassType":windshieldDamageInsuranceType,  //玻璃单独损失险（玻璃进口还是国产）
                                     @"glassPrice":windshieldDamageInsurance,  //玻璃单独损失险保费
                                     @"fire":fireInsurance,  //自燃损失险
                                     @"bodyPrice":scratchDamageInsuranceCoverage,  //车身划痕保额
                                     @"body":scratchDamageInsurance,  //车身划痕保费
                                     @"repair":specifyServiceFactoryInsurance,  //指定专修厂特约险
                                     @"light_type":sideMirrorAndHeadlightDamageInsuranceType,  //倒车镜与车灯 国产还是进口
                                     @"light":sideMirrorAndHeadlightDamageInsurance,  //倒车镜与车灯单独损坏险
                                     @"water":wadingDrivingInsurance,  //涉水行驶损失险
                                     
                                     @"lsPrice":extraADInsurance,  //不计免赔特约险-车损
                                     @"thsPrice":extraRATInsurance,  //不计免赔特约险-盗抢
                                     @"tsPrice":extraTPLInsurance,  //不计免赔特约险-三者
                                     @"msPrice":extraDLNPLInsurance,  //不计免赔特约险-司机乘客
                                     @"anPrice":extraPlusInsurance,  //不计免赔特约险-附加险
                                     @"businessPrice":businessTotalPriceWithDiscount//商业险 折后总价
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppointment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////新的预约   保险/////##########/////
/* 点击首页的预约保险 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceMyInurancelistWithAccessToken:(NSString *)token
                                                                                                              success:(APIsConnectionSuccessBlock)success
                                                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceMyInurancelist
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

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
                                                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"phone_no":phoneNo,
                                     @"city":city,
                                     @"real_name":realname,
                                     @"speci":speci,
                                     @"frame_no":frameNo,
                                     @"engine_code":enginecode,
                                     @"register_time":registertime,
                                     @"car_number":carCumber};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppPremiumAddCar
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

/* 更换车辆 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceChangeCarNumberWithAccessToken:(NSString *)token
                                                                                                               success:(APIsConnectionSuccessBlock)success
                                                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceChangeCarNumber
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}
/*保险公司*/
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetCompanyWithsuccess:(APIsConnectionSuccessBlock)success
                                                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceGetCompany
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}
//身份证和行驶证 图片上传
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceGetTestPicWithImage:(UIImage *)portraitImage
                                                                                                  imageName:(NSString *)imageName
                                                                                                  imageType:(ConnectionImageType)imageType
                                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                                    failure:(APIsConnectionFailureBlock)failure  {
    @autoreleasepool {
        NSString *imageTypeString = @"image/jpeg";
        NSString *imageExt = @"jpg";
        NSData *data = UIImageJPEGRepresentation(portraitImage, 0.8);
        if (ConnectionImageTypeOfPNG==imageType) {
            imageTypeString = @"image/png";
            imageExt = @"png";
            data = UIImagePNGRepresentation(portraitImage);
        }
        if (!imageName){
            imageName = @"userPortraitImage";
        }
        
        APIsConnectionFormData formData = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:[imageName stringByAppendingPathExtension:imageExt] mimeType:imageTypeString];
        };
        
        NSDictionary *parameters = @{@"root":@"repair-basic-idCard"};
        NSURLSessionDataTask *operation = nil;
        operation = [self createImgUploadPostRequestWithRelativePath:kCDZCasesHistoryImageUploadCZD
                                                          parameters:parameters
                                                            progress:nil
                                       constructingPOSTBodyWithBlock:formData
                                                             success:success
                                                             failure:failure];
        return operation;
    }
}


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
                                                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,//
                                     @"company":company,//保险公司
                                     @"car_id":carId,//投保车辆id
                                     @"city":city,//投保城市
                                     @"license_img":licenseimg,//行驶证照片
                                     @"identity_img":identityImg,//身份证正面照
                                     @"s_time":sTime,//交强险生效时间
                                     @"b_time":bTime,//商业险生效时间
                                     @"premium_sali":premiumSali,//交强险
                                     @"b_damage":bDamage,//车辆损失险
                                     @"b_thief":bThief,//盗抢险
                                     @"b_liability":bLiability,//三责
                                     @"premium_glass":premiumGlass,//玻璃破碎险
                                     @"driver_seat":driverSeat,//司机座位责任险
                                     @"passenger_seat":passengerSeat,//乘客座位责任险
                                     @"premium_nature":premiumNature,//自燃险
                                     @"premium_body":premiumBody,//车身划痕
                                     @"premium_repair":premiumRepair,//指定专修厂特约险
                                     @"premium_water":premiumWater,//涉水行驶损失险
                                     @"loss_special":lossSpecial,//不计免赔——车损
                                     @"third_special":thirdSpecial,//不计免赔——三责
                                     @"theft_special":theftSpecial,//不计免赔——盗抢
                                     @"d_seat_special":dSeatSpecial,//不计免赔——司机
                                     @"p_seat_special":pSeatSpecial,//不计免赔——乘客
                                     @"fire_special":fireSpecial,//不计免赔——自燃险
                                     @"scratch_special":scratchSpecial,//不计免赔——划痕险
                                     @"water_special":waterSpecial,//不计免赔——涉水险
                                     };
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppAddPremiumList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

/* 我的保险列表 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppShowInsuranceAppWithAccessToken:(NSString *)token
                                                                                                                  pageNums:(NSNumber *)pageNums
                                                                                                                 pageSizes:(NSNumber *)pageSizes
                                                                                                                      type:(NSNumber *)type
                                                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"type":type};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppShowInsuranceApp
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 保险详情 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceAppBuyListWithAccessToken:(NSString *)token
                                                                                                                          pid:(NSString *)pid                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"pid":pid};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppInsuranceAppBuyList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

/* 点击重新预约 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceReAppointWithAccessToken:(NSString *)token
                                                                                                                         pid:(NSString *)pid                                                   success:(APIsConnectionSuccessBlock)success
                                                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"pid":pid};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceAppInsuranceReAppoint
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

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
                                                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,//
                                     @"pid":pid,
                                     @"company":company,//保险公司
                                     @"car_id":carId,//投保车辆id
                                     @"city":city,//投保城市
                                     @"license_img":licenseimg,//行驶证照片
                                     @"identity_img":identityImg,//身份证正面照
                                     @"s_time":sTime,//交强险生效时间
                                     @"b_time":bTime,//商业险生效时间
                                     @"premium_sali":premiumSali,//交强险
                                     @"b_damage":bDamage,//车辆损失险
                                     @"b_thief":bThief,//盗抢险
                                     @"b_liability":bLiability,//三责
                                     @"premium_glass":premiumGlass,//玻璃破碎险
                                     @"driver_seat":driverSeat,//司机座位责任险
                                     @"passenger_seat":passengerSeat,//乘客座位责任险
                                     @"premium_nature":premiumNature,//自燃险
                                     @"premium_body":premiumBody,//车身划痕
                                     @"premium_repair":premiumRepair,//指定专修厂特约险
                                     @"premium_water":premiumWater,//涉水行驶损失险
                                     @"loss_special":lossSpecial,//不计免赔——车损
                                     @"third_special":thirdSpecial,//不计免赔——三责
                                     @"theft_special":theftSpecial,//不计免赔——盗抢
                                     @"d_seat_special":dSeatSpecial,//不计免赔——司机
                                     @"p_seat_special":pSeatSpecial,//不计免赔——乘客
                                     @"fire_special":fireSpecial,//不计免赔——自燃险
                                     @"scratch_special":scratchSpecial,//不计免赔——划痕险
                                     @"water_special":waterSpecial,//不计免赔——涉水险
                                     };
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserAutosInsuranceConfirmReAppoint
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}




#pragma mark /////##########/////GPS购买/////##########/////
/* GPS购买 */
- (NSURLSessionDataTask *)personalCenterAPIsPostGPSPurchasesAppointmentWithAccessToken:(NSString *)token
                                                                               gpsType:(NSUInteger)gpsType
                                                                          dataCardType:(NSUInteger)dataCardType
                                                                      recognizanceType:(NSUInteger)recognizanceType
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *gpsTypeName = @"gps1";
        if (gpsType==1) gpsTypeName = @"gps2";
        if (gpsType==2) gpsTypeName = @"gps3";
        
        NSString *recognizanceTypeName = @"pay1";
        if (recognizanceType==1) recognizanceTypeName = @"pay2";
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"gpsType":gpsTypeName,
                                     @"payType":recognizanceTypeName,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSPurchasesAppointment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        
        return operation;
    }
}

#pragma mark /////##########/////优惠劵/////##########/////
/* 维修商优惠券列表 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopCouponAvailableListWithAccessToken:(NSString *)token
                                                                                 maintenanceShopID:(NSString *)maintenanceShopID
                                                                                           success:(APIsConnectionSuccessBlock)success
                                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxsId":maintenanceShopID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopCouponAvailableList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 个人领取维修商优惠券 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsPostUserCollectMaintenanceShopCouponWithAccessToken:(NSString *)token
                                                                                         couponID:(NSString *)couponID
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"preferId":couponID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopUserCollectCoupon
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 个人中心我的优惠券列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyCouponCollectedListWithAccessToken:(NSString *)token
                                                                           pageNums:(NSNumber *)pageNums
                                                                          pageSizes:(NSNumber *)pageSizes
                                                                             status:(NSNumber *)status
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"status":status};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyCouponUserCollectedCouponList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 使用优惠券选择列表 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserApplyCouponWithAccessToken:(NSString *)token
                                                                      repairID:(NSString *)repairID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"rid":repairID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyCouponAppleySelection
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////E-代修/////##########/////
/* E服务检测用户是否预约 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceVerifyUserWasMadeAppointmentWithAccessToken:(NSString *)token
                                                                                           theSign:(NSString *)theSign
                                                                                      eServiceType:(EServiceType)eServiceType
                                                                                           success:(APIsConnectionSuccessBlock)success
                                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSString *serviceType = @"e代修";
        switch (eServiceType) {
            case EServiceTypeOfERepair:
                serviceType = @"e代修";
                break;
            case EServiceTypeOfEInspect:
                serviceType = @"e代检";
                break;
            case EServiceTypeOfEInsurance:
                serviceType = @"e代赔";
                break;
                
            default:
                break;
        }
        if (!theSign) {
            theSign = @"";
        }
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"sign":theSign,
                                     @"type":serviceType};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceVerifyUserWasMadeAppointment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


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
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *serviceType = @"e代修";
        switch (eServiceType) {
            case EServiceTypeOfEInspect:
                serviceType = @"e代检";
                break;
                
            case EServiceTypeOfERepair:
                serviceType = @"e代修";
                break;
                
            case EServiceTypeOfEInsurance:
                serviceType = @"e代赔";
                break;
            default:
                break;
        }
        if (!appointmentTime||[appointmentTime isEqualToString:@""]) appointmentTime = @"暂无";
        if (!requestedConsultantID||[requestedConsultantID isEqualToString:@""]) requestedConsultantID = @"";
        if (!eRepairFree||[eRepairFree isEqualToString:@""]) eRepairFree = @"0.00";
        if (!longitude||[longitude isEqualToString:@""]) longitude = @"0";
        if (!latitude||[latitude isEqualToString:@""]) latitude = @"0";
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxsId":repairShopID,
                                     @"wxsName":repairShopName,
                                     @"name":registrant,
                                     @"phone":registrantPhone,
                                     @"address":address,
                                     @"carModel":autosModelName,
                                     @"addTime":appointmentTime,
                                     @"project":servieceItems,
                                     @"project_str":projectType,
                                     @"erepair_free":eRepairFree,
                                     @"lat":latitude,
                                     @"lon":longitude,
                                     @"e_type":serviceType,
                                     kParameterOfID:requestedConsultantID,
                                     @"order_state":@"未付款",
                                     @"order_type":orderWasAutoType?@"自动":@"用户指定",};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceMakeAppointment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceListWithAccessToken:(NSString *)token
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                                statusType:(NSString *)statusType
                                                               serviceType:(NSString *)serviceType
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"state_name":statusType,
                                     @"type_name":serviceType};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceDetailWithAccessToken:(NSString *)token
                                                                  eServiceID:(NSString *)eServiceID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"id_str":eServiceID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 取消E服务 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceCancelServiceWithAccessToken:(NSString *)token
                                                                          eServiceID:(NSString *)eServiceID
                                                                        isAutoCancel:(BOOL)isAutoCancel
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             kParameterOfID:eServiceID} mutableCopy];
        if (isAutoCancel) {
            [parameters setObject:@"自动取消" forKey:@"sing"];
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceServiceCancel
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务确认还车 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceConfirmVehicleWasReturnWithAccessToken:(NSString *)token
                                                                                    eServiceID:(NSString *)eServiceID
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"id_str":eServiceID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceConfirmVehicleReturn
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* E服务专员简单资讯 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantSimpleDetail4CommentWithAccessToken:(NSString *)token
                                                                                          eServiceID:(NSString *)eServiceID
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:eServiceID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceAssistantDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务提交评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceServiceCommentWithAccessToken:(NSString *)token
                                                                           eServiceID:(NSString *)eServiceID
                                                                           rateNumber:(NSNumber *)rateNumber
                                                                              comment:(NSString *)comment
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        rateNumber = @([SupportingClass roundToLastTwoFloatValue:rateNumber.doubleValue]);
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"id_str":eServiceID,
                                     @"rate":rateNumber,
                                     @"comment":comment};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceSubmitComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务查看评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceServiceCommentWithAccessToken:(NSString *)token
                                                                          eServiceID:(NSString *)eServiceID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"id_str":eServiceID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceReviewComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* E服务支付确认信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServicePaymentConfirmInfoWithAccessToken:(NSString *)token
                                                                              eServiceID:(NSString *)eServiceID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:eServiceID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServicePaymentConfirmInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* E服务支付确认信息 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServicePaymentInitInfoWithAccessToken:(NSString *)token
                                                                           eServiceID:(NSString *)eServiceID
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"e_id":eServiceID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServicePaymentInitInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* E服务地址检测 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceVerifyUserAddressResultWithAddress:(NSString *)address
                                                                            servieceItems:(NSString *)servieceItems
                                                                              projectType:(NSString *)projectType
                                                                             repairShopID:(NSString *)repairShopID
                                                                             eServiceType:(EServiceType)eServiceType
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *serviceType = @"e代修";
        switch (eServiceType) {
            case EServiceTypeOfEInspect:
                serviceType = @"e代检";
                break;
                
            case EServiceTypeOfERepair:
                serviceType = @"e代修";
                break;
                
            case EServiceTypeOfEInsurance:
                serviceType = @"e代赔";
                break;
            default:
                break;
        }
        
        
        NSDictionary *parameters = @{@"wxsId":repairShopID,
                                     @"address":address,
                                     @"project":servieceItems,
                                     @"project_str":projectType,
                                     @"e_type":serviceType,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceVerifyUserAddress
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 获取E服务专员列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantPostionListWithLongitude:(NSString *)longitude
                                                                                 latitude:(NSString *)latitude
                                                                             eServiceType:(EServiceType)eServiceType
                                                                       consultantPhoneNum:(NSString *)consultantPhoneNum
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *serviceType = @"e代修";
        switch (eServiceType) {
            case EServiceTypeOfEInspect:
                serviceType = @"e代检";
                break;
                
            case EServiceTypeOfERepair:
                serviceType = @"e代修";
                break;
                
            case EServiceTypeOfEInsurance:
                serviceType = @"e代赔";
                break;
            default:
                break;
        }
        if (!longitude||[longitude isEqualToString:@""]) longitude = @"0";
        if (!latitude||[latitude isEqualToString:@""]) latitude = @"0";
        if (!consultantPhoneNum||[consultantPhoneNum isEqualToString:@""]) consultantPhoneNum = @"";
        
        NSDictionary *parameters = @{@"lat":latitude,
                                     @"lon":longitude,
                                     @"type":serviceType,
                                     @"tel":consultantPhoneNum};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceConsultantPostionList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 获取E服务专员详情  */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantDetailWithAccessToken:(NSString *)token
                                                                            eServiceID:(NSString *)eServiceID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"id_str":eServiceID,};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceConsultantDeatil
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 获取E服务用户会员状态和服务价钱 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceUserMemberStatusNPriceWithAccessToken:(NSString *)token
                                                                                eServiceType:(EServiceType)eServiceType
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (eServiceType==0) {
            eServiceType = 1;
        }
        if (eServiceType>3) {
            eServiceType = 3;
        }
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"type":@(eServiceType),
                                     @"e_type":@(eServiceType-1),};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceUserMemberStatusNPrice
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 获取E服务专员详情和评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceConsultantDetailAndCommentListsWithAccessToken:(NSString *)token
                                                                                         consultantID:(NSString *)consultantID
                                                                                             pageNums:(NSNumber *)pageNums
                                                                                            pageSizes:(NSNumber *)pageSizes
                                                                                              success:(APIsConnectionSuccessBlock)success
                                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:consultantID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceConsultantDeatilWithComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 提交E服务积分支付 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEServiceCreditsPaymentWithAccessToken:(NSString *)token
                                                                           eServiceID:(NSString *)eServiceID
                                                                           verifyCode:(NSString *)verifyCode
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"e_id":eServiceID,
                                     @"verif":verifyCode};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceCreditsPayment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 请求E服务积分验证码 */
- (NSURLSessionDataTask *)personalCenterAPIsGetEServiceCreditsRequestVerifyCodeWithAccessToken:(NSString *)token
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEServiceCreditsRequestVerifyCode
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////商家会员/////##########/////
/* 用户的商家列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopMemberListWithAccessToken:(NSString *)token
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserRepairShopMemberList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 会员置顶 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserSetRepairShopMembershipToTopWithAccessToken:(NSString *)token
                                                                                   repairShopID:(NSString *)repairShopID
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxs_id":repairShopID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserSetRepairShopMembershipToTop
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 取消会员 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserCancelRepairShopMembershipWithAccessToken:(NSString *)token
                                                                                 repairShopID:(NSString *)repairShopID
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxs_id":repairShopID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserCancelRepairShopMembership
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 加入会员 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserJoinRepairShopMembershipWithAccessToken:(NSString *)token
                                                                               repairShopID:(NSString *)repairShopID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxs_id":repairShopID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserJoinRepairShopMembership
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 商家公告列表*/
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopAnnouncementListWithAccessToken:(NSString *)token
                                                                                    pageNums:(NSNumber *)pageNums
                                                                                   pageSizes:(NSNumber *)pageSizes
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopAnnouncementList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 商家公告详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserRepairShopAnnouncementDetailWithAccessToken:(NSString *)token
                                                                                  repairShopID:(NSString *)repairShopID
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxs_id":repairShopID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserJoinRepairShopMembership
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////地址/////##########/////
/* 地址列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShippingAddressListWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShippingAddressList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kParameterOfToken:token,
                                                                                          @"state":@(!isDefault),
                                                                                          @"name":consigneeName,
                                                                                          @"tel":mobileNumber,
                                                                                          @"provinceId":provinceID,
                                                                                          @"cityId":cityID,
                                                                                          @"regionId":districtID,
                                                                                          @"address":detailAddress}];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShippingAddressAdd
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 地址详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShippingAddressDetailWithAccessToken:(NSString *)token
                                                                          addressID:(NSString *)addressID
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kParameterOfToken:token,
                                                                                          kParameterOfID:addressID}];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShippingEditDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除地址 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteShippingAddressWithAccessToken:(NSString *)token
                                                                           addressID:(NSString *)addressID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"address_id":addressID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZShippingAddressDelete
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
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
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kParameterOfToken:token,
                                                                                          @"state":@(!isDefault),
                                                                                          @"address_id":addressID,
                                                                                          @"name":consigneeName,
                                                                                          @"tel":mobileNumber,
                                                                                          @"provinceId":provinceID,
                                                                                          @"countryId":cityID,
                                                                                          @"regionId":districtID,
                                                                                          @"address":detailAddress}];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZShippingAddressUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////购物车/////##########/////
/* 购物车列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCartListWithAccessToken:(NSString *)token
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCartOfCartList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 添加商品到购物车 */
- (NSURLSessionDataTask *)personalCenterAPIsPostInsertProductToTheCartWithAccessToken:(NSString *)token
                                                                            productID:(NSString *)productID
                                                                              brandID:(NSString *)brandID
                                                                    brandDealershipID:(NSString *)brandDealershipID
                                                                             seriesID:(NSString *)seriesID
                                                                              modelID:(NSString *)modelID
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:productID,
                                     @"brand":brandID,
                                     @"factory":brandDealershipID,
                                     @"fct":seriesID,
                                     @"speci":modelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZCartOfAddCart
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除购物车的商品 */
- (NSURLSessionDataTask *)personalCenterAPIsPostDeleteProductFormTheCartWithAccessToken:(NSString *)token
                                                                          productIDList:(NSArray *)productIDList
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *productIDListStr = [productIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:productIDListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZCartOfDeleteCart
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////车辆维修/////##########/////
/* 查询维修列表由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceStatusListByStatusType:(CDZMaintenanceStatusType)statusType
                                                                     accessToken:(NSString *)token
                                                                        pageNums:(NSNumber *)pageNums
                                                                       pageSizes:(NSNumber *)pageSizes
                                                                 shopNameOrKeyID:(NSString *)shopNameOrKeyID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *relativePath = nil;
        switch (statusType) {
            case CDZMaintenanceStatusTypeOfAppointment:
                relativePath = kCDZAutosRepairStatusOfAppointment;
                break;
            case CDZMaintenanceStatusTypeOfDiagnosis:
                relativePath = kCDZAutosRepairStatusOfDiagnosis;
                break;
            case CDZMaintenanceStatusTypeOfUserAuthorized:
                relativePath = kCDZAutosRepairStatusOfUserAuthorized;
                break;
            case CDZMaintenanceStatusTypeOfHasBeenClearing:
                relativePath = kCDZAutosRepairStatusOfHasBeenClearing;
                break;
                
            default:
                break;
        }
        if (!relativePath) return nil;
        if (!shopNameOrKeyID) shopNameOrKeyID = @"";
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"makenumber_wxsname":shopNameOrKeyID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:relativePath
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 查询维修详情由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceStatusDetailByStatusType:(CDZMaintenanceStatusType)statusType
                                                                       accessToken:(NSString *)token
                                                                             keyID:(NSString *)keyID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *relativePath = nil;
        switch (statusType) {
            case CDZMaintenanceStatusTypeOfAppointment:
                relativePath = kCDZAutosRepairStatusOfAppointmentDetial;
                break;
            case CDZMaintenanceStatusTypeOfDiagnosis:
                relativePath = kCDZAutosRepairStatusOfDiagnosisDetial;
                break;
            case CDZMaintenanceStatusTypeOfUserAuthorized:
                relativePath = kCDZAutosRepairStatusOfUserAuthorizedDetial;
                break;
            case CDZMaintenanceStatusTypeOfHasBeenClearing:
                relativePath = kCDZAutosRepairStatusOfHasBeenClearingDetial;
                break;
                
            default:
                break;
        }
        if (!relativePath) return nil;
        NSDictionary *parameters = @{kParameterOfToken:token,kParameterOfID:keyID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:relativePath
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 确认委托维修授权 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmMaintenanceAuthorizationWithAccessToken:(NSString *)token
                                                                                         keyID:(NSString *)keyID
                                                                             repairItemsString:(NSString *)repairItemsString
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"repairName":repairItemsString};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairConfirm
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 结算信息准备 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceClearingPaymentInfoWithAccessToken:(NSString *)token
                                                                                       keyID:(NSString *)keyID
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairClearingReady
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 取消维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCancelMaintenanceWithAccessToken:(NSString *)token
                                                                           keyID:(NSString *)keyID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairCancelMaintenance
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

////////////////////* 结算维修 *////////////////////
/* 优惠劵结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByCouponWithAccessToken:(NSString *)token
                                                                                  repairID:(NSString *)repairID
                                                                                  couponID:(NSString *)couponID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"make_number":repairID,
                                     @"preferId":couponID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairClearingByCoupon
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 全积分结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByAllOfCreditsWithAccessToken:(NSString *)token
                                                                                        repairID:(NSString *)repairID
                                                                                      verifyCode:(NSString *)verifyCode
                                                                                         success:(APIsConnectionSuccessBlock)success
                                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"make_number":repairID,
                                     @"integral":verifyCode};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairClearingByAllOfCredits
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 部分积分结算维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAutosRepairClearingByPartOfCreditsWithAccessToken:(NSString *)token
                                                                                         repairID:(NSString *)repairID
                                                                                    surplusAmount:(NSString *)surplusAmount
                                                                                    creditConsume:(NSString *)creditConsume
                                                                                       verifyCode:(NSString *)verifyCode
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"make_number":repairID,
                                     @"sumMoney":surplusAmount,
                                     @"userCredtis":creditConsume,
                                     @"integral":verifyCode};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosRepairClearingByPartOfCredits
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 支付完成通知 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserPaymentFinishNotifyWithAccessToken:(NSString *)token
                                                                           outTradeNum:(NSString *)outTradeNum
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"out_trade_no":outTradeNum,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserPaymentFinishNotify
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////其他/////##########/////
/* 询价列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetSelfEnquireProductsPriceWithAccessToken:(NSString *)token
                                                                              pageNums:(NSString *)pageNums
                                                                             pageSizes:(NSString *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @"1";
        if (!pageSizes) pageSizes = @"10";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfEnquireProductsPrice
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"brand":brandID,
                                     @"factory":brandDealershipID,
                                     @"fct":seriesID,
                                     @"spec":modelID,
                                     @"centerId":centerID,
                                     @"telphone":mobileNumber,
                                     @"real_name":userName,
                                     @"product_id":productionID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsEnquirePrice
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



/* 积分列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCreditPointsHistoryWithAccessToken:(NSString *)token
                                                                         pageNums:(NSNumber *)pageNums
                                                                        pageSizes:(NSNumber *)pageSizes
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCreditPointsHistory
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 采购中心列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPurchaseCenterListWithCityID:(NSString *)cityID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"cityId":cityID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseCenterList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 首页轮播接口 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMainPageAdvertisingInfoListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = nil;
        if (vGetUserToken) {
            parameters = @{kParameterOfToken:vGetUserToken};
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMainPageAdvertisingInfoList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark- /////////////////////////////////////////////////////Autos Parts APIs（配件接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////汽车配件选择/////##########/////
/* 配件第一级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsFirstLevelListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsSearchStepOne
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件第二级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsSecondLevelListWithFirstLevelID:(NSString *)firstLevelID
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:firstLevelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsSearchStepTwo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件第三级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsThirdLevelListWithSecondLevelID:(NSString *)secondLevelID
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:secondLevelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsSearchStepThree
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件第四级分类 */
- (NSURLSessionDataTask *)autosPartsAPIsGetPartsLastLevelListWithThirdLevelID:(NSString *)thirdLevelID
                                                                  autoModelID:(NSString *)autoModelID
                                                                   priceOrder:(NSString *)priceOrder
                                                             salesVolumeOrder:(NSString *)salesVolumeOrder
                                                                     pageNums:(NSString *)pageNums
                                                                    pageSizes:(NSString *)pageSizes
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @"1";
        if (!pageSizes) pageSizes = @"10";
        
        switch (salesVolumeOrder.integerValue) {
            case 1:
                salesVolumeOrder = @"0";
                break;
            case 2:
                salesVolumeOrder = @"1";
                break;
                
            default:
                salesVolumeOrder = @"";
                break;
        }
        switch (priceOrder.integerValue) {
            case 1:
                priceOrder = @"0";
                break;
            case 2:
                priceOrder = @"1";
                break;
                
            default:
                priceOrder = @"";
                break;
        }
        
        NSDictionary *parameters = @{kParameterOfID:thirdLevelID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"price_high_low":priceOrder,
                                     @"sales_high_low":salesVolumeOrder,
                                     @"speci":autoModelID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsSearchStepFour
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件评论列表 */
- (NSURLSessionDataTask *)autosPartsAPIsGetAutosPartsCommnetListWithProductID:(NSString *)ProductID
                                                                     pageNums:(NSNumber *)pageNums
                                                                    pageSizes:(NSNumber *)pageSizes
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        NSDictionary *parameters = @{@"productId":ProductID,@"page_no":pageNums,@"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 配件推荐列表 */
- (NSURLSessionDataTask *)autosPartsAPIsGetRecommendProductWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsRecommendProduct
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 搜索配件 */
- (NSURLSessionDataTask *)autosPartsAPIsGetAutosPartsSearchListWithKeyword:(NSString *)keyword
                                                               autoModelID:(NSString *)autoModelID
                                                                priceOrder:(NSString *)priceOrder
                                                          salesVolumeOrder:(NSString *)salesVolumeOrder
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        switch (salesVolumeOrder.integerValue) {
            case 1:
                salesVolumeOrder = @"0";
                break;
            case 2:
                salesVolumeOrder = @"1";
                break;
                
            default:
                salesVolumeOrder = @"";
                break;
        }
        switch (priceOrder.integerValue) {
            case 1:
                priceOrder = @"0";
                break;
            case 2:
                priceOrder = @"1";
                break;
                
            default:
                priceOrder = @"";
                break;
        }
        
        NSDictionary *parameters = @{@"name":keyword,
                                     @"speci":autoModelID,
                                     @"price_high_low":priceOrder,
                                     @"sales_high_low":salesVolumeOrder,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosPartsKeywordSearch
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}
#pragma mark- /////////////////////////////////////////////////////Maintenance Shops APIs（维修商接口）/////////////////////////////////////////////////////
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
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @"1";
        if (!pageSizes) pageSizes = @"10";
        if (!rankValue) rankValue = @"";
        if (!serviceID||[serviceID isEqualToString:@"全部"]) serviceID = @"0";
        
        if (!shopType||[shopType isEqualToString:@"全部"]) shopType = @"0";
        if (!shopName) shopName = @"";
        
        if (!cityID) cityID = @"0";
        if (!address) address = @"";
        if (!autoBrand) autoBrand = @"0";
        
        if (!longitude||!latitude) {
            longitude = @"";//@"112.979353";
            latitude = @"";//@"28.213478";
        }
        
        
        
        NSDictionary *parameters = @{@"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"rank":rankValue,
                                     @"service_item":serviceID,
                                     
                                     @"user_kind_id":shopType,
                                     @"shop_name":shopName,
                                     
                                     @"city":cityID,
                                     @"address":address,
                                     @"brand":autoBrand,
                                     
                                     @"longitude":longitude,
                                     @"latitude":latitude,
                                     @"isTrue":(isCertified?@"YES":@"no")};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopSearch
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商详情 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:(NSString *)shopID
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"wxsId":shopID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopDetails
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商种类 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopType
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商评论列表 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsCommnetListWithShopID:(NSString *)shopID
                                                                              pageNums:(NSString *)pageNums
                                                                             pageSizes:(NSString *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @"1";
        if (!pageSizes) pageSizes = @"10";
        
        NSDictionary *parameters = @{kParameterOfID:shopID,@"page_no":pageNums,@"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 维修商公用设施 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsInfrastructureWithShopID:(NSString *)shopID
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"equipment":shopID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopEquipment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 预约维修商保养或者维修选择 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsPostAppointmentFromMaintenanceShopsWithShopID:(NSString *)shopID
                                                                               workingPrice:(NSString *)workingPrice
                                                                                serviceItem:(NSString *)serviceItem
                                                                            isRepairService:(BOOL)isRepairService
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalLogin
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxsId":shopID,
                                     @"item":serviceItem,
                                     @"contacts":contactName,
                                     @"contactNumber":contactNumber,
                                     @"android_ios":@"ios",
                                     @"brand":brandID,
                                     @"factory":brandDealershipID,
                                     @"fct":seriesID,
                                     @"speci":modelID,
                                     @"addtime":dateTime,
                                     @"is_change":@(approveToChange),
                                     @"technician":technicianID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopConfirmAppointment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修完成评论 */
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentForShopRepairFinishWithAccessToken:(NSString *)token
                                                                               makeNumber:(NSString *)makeNumber
                                                                                  content:(NSString *)content
                                                                                   rating:(NSString *)rating
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"make_number":makeNumber,
                                     @"content":content,
                                     @"rate":rating};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopRepairFinishComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 获取预约维修资讯  */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetAppointmentPrepareRepairInfoWithAccessToken:(NSString *)token
                                                                                      shopID:(NSString *)shopID
                                                                 repairServiceItemListString:(NSString *)repairServiceItemListString
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxsId":shopID,
                                     @"phenomenon":repairServiceItemListString};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopAppointmentRepairInfoPrepare
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 获取预约保养资讯  */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetAppointmentPrepareMaintenanceInfoWithAccessToken:(NSString *)token
                                                                                           shopID:(NSString *)shopID
                                                                   maintenanceServiceIDListString:(NSString *)maintenanceServiceIDListString
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"wxsId":shopID,
                                     kParameterOfID:maintenanceServiceIDListString};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopAppointmentMaintenanceInfoPrepare
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark- /////////////////////////////////////////////////////Self-Diagnosis APIs（自助诊断接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////自助诊断结果/////##########/////
/* 故障解决方案 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetSolutionPlanWithDiagnosisResultID:(NSString *)diagnosisResultID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"yyfxId":diagnosisResultID};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfDiagnosisSolutionPlan
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件更换建议 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetProposedReplacementPartsWithSolutionPlanID:(NSString *)solutionPlanID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"jjfaId":solutionPlanID};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfDiagnosisReplacementParts
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 获取维修商 */
- (NSURLSessionDataTask *)theSelfDiagnosisAPIsGetMaintenanceShopsSuggestListWithReplacementPartsName:(NSString *)replacementPartsName
                                                                                            seriesID:(NSString *)seriesID
                                                                                         autoModelID:(NSString *)autoModelID
                                                                                             address:(NSString *)address
                                                                                        isDescenting:(NSNumber *)isDescenting
                                                                                           longitude:(NSString *)longitude
                                                                                            latitude:(NSString *)latitude
                                                                                             success:(APIsConnectionSuccessBlock)success
                                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"serviceModel":replacementPartsName,
                                                                                          @"fctid":seriesID,
                                                                                          @"specid":autoModelID,
                                                                                          @"flag":isDescenting.stringValue}];
        if (address) {
            [parameters setObject:address forKey:@"address"];
        }
        if (longitude&&latitude) {
            [parameters setObject:longitude forKey:@"longitude"];
            [parameters setObject:latitude forKey:@"latitude"];
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfDiagnosisResult
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark- /////////////////////////////////////////////////////Get History Cases of Success APIs（获取案例接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////获取案例步骤/////##########/////

/* 获取案例第一级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfStepOneListWithAutosModelID:(NSString *)autosModelID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"speci":autosModelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryListStepOne
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 获取案例第二级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfStepTwoListWithStepOneID:(NSString *)stepOneID
                                                                  selectedTextTitle:(NSString *)selectedTextTitle
                                                                     isDescSymptoms:(BOOL)isDescSymptoms
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:stepOneID,
                                     @"flag":@(isDescSymptoms+1),
                                     @"selectText":selectedTextTitle};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryListStepTwo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!token) token = @"";
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"selectText":resultKeyword,
                                     @"brand":brandID,
                                     @"factory":brandDealershipID,
                                     @"fct":seriesID,
                                     @"speci":modelID,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryResultList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}



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
                                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalLogin
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 案例详情 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetHistoryCasesOfCaseDetailWithSubscribeID:(NSString *)subscribeID
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:subscribeID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfCaseDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark- /////////////////////////////////////////////////////Self-Maintenance APIs（自助保养接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////自助维修步骤和结果/////##########/////
/* 获取保养信息 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenanceInfoWithAutoModelID:(NSString *)autoModelID
                                                                 autoTotalMileage:(NSString *)autoTotalMileage
                                                                     purchaseDate:(NSString *)purchaseDate
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"speci":autoModelID,@"mileage":autoTotalMileage,@"buyDate":purchaseDate};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfMaintenanceGetInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 选择保养服务 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenanceServiceListWithPartsIDList:(NSArray *)partsIDList
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"isChecked":[partsIDList componentsJoinedByString:@","]};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfMaintenanceServiceList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 配件详情 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:(NSString *)token
                                                                       productID:(NSString *)productID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!token) token = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"productId":productID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfMaintenancePartsDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 保养项目配件需求列表 */
- (NSURLSessionDataTask *)theSelfMaintenanceAPIsGetMaintenancePartsRequestListWithPartsIDList:(NSArray *)partsIDList
                                                                                      modelID:(NSString *)modelID
                                                                                      success:(APIsConnectionSuccessBlock)success
                                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"isChecked":[partsIDList componentsJoinedByString:@","],
                                     @"speci":modelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfMaintenancePartsRequestList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark- /////////////////////////////////////////////////////Common APIs（公用接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////新自助诊断步骤/////##########/////
/* 新自助诊断1～5步 */

- (NSURLSessionDataTask *)commonAPIsGetAutoSelfDiagnosisStepListWithStep:(SelfDiagnosisSelectionStep)theStep
                                                              nextStepID:(NSString *)nextStepID
                                                                seriesID:(NSString *)seriesID
                                                                 modelID:(NSString *)modelID
                                                                  typeID:(NSNumber *)typeID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSString *relativePath = @"";
        NSDictionary *parameters = nil;
        if (!nextStepID) nextStepID = @"";
        if (theStep==SelfDiagnosisStepOne) {
            if (!seriesID||!modelID||[seriesID isEqualToString:@""]||[modelID isEqualToString:@""]) {
                relativePath = @"";
            }else {
                parameters = @{@"fct":seriesID,@"speci":modelID};
                relativePath = kCDZSelfDiagnoseFirstStepList;
            }
        }else if (theStep==SelfDiagnosisStepTwo) {
            if (!seriesID||!modelID||[seriesID isEqualToString:@""]||[modelID isEqualToString:@""]) {
                relativePath = @"";
            }else {
                parameters = @{@"fct":seriesID,@"speci":modelID,
                               kParameterOfID:nextStepID,
                               @"type":typeID};
                relativePath = kCDZSelfDiagnoseSecondStepList;
            }
        }else {
            if (theStep==SelfDiagnosisStepThree) {
                relativePath = kCDZSelfDiagnoseThirdStepList;
            }
            if (theStep==SelfDiagnosisStepFour) {
                relativePath = kCDZSelfDiagnoseFourthStepList;
            }
            if (theStep==SelfDiagnosisStepFive) {
                relativePath = kCDZSelfDiagnoseFifthStepList;
            }
            if (!nextStepID||[nextStepID isEqualToString:@""]) {
                relativePath = @"";
            }else {
                parameters = @{kParameterOfID:nextStepID,
                               @"type":typeID};
            }
        }
        
        if ([relativePath isEqualToString:@""]) {
            return nil;
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:relativePath
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


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
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!token) token = @"";
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (!serviceID) serviceID = @"";
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"city_name":cityName,
                                     @"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"brand_id":brandId,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"service_item":serviceID,
                                     @"select_item":filterOption,
                                     @"key_words":searchKeyword};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZSelfDiagnoseFinalResultList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////获取案例和自助诊断公用步骤/////##########////

/* 故障种类 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFailureTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFailureType
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 故障现象 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFaultSymptomListWithAutoFailureTypeID:(NSString *)failureTypeID
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"gzzlId":failureTypeID};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFaultSymptom
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 故障架构 */
- (NSURLSessionDataTask *)commonAPIsGetAutoFaultStructureListWithAutoFaultSymptomID:(NSString *)faultSymptomID
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"gzxxId":faultSymptomID};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFaultStructure
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 故障原因分析 */
- (NSURLSessionDataTask *)commonAPIsGetDiagnosisResultListWithAutoFaultStructureID:(NSString *)faultStructureID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"gzjgId":faultStructureID};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFaultDiagnosis
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////汽车型号选择/////##########/////
/* 车辆品牌 */
- (NSURLSessionDataTask *)commonAPIsGetAutoBrandListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutoBrandList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 车辆经销商 */
- (NSURLSessionDataTask *)commonAPIsGetAutoBrandDealershipListWithBrandID:(NSString *)brandID
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"brandId":brandID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFactoryName
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 车辆系列 */
- (NSURLSessionDataTask *)commonAPIsGetAutoSeriesListWithBrandDealershipID:(NSString *)brandDealershipID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"factoryId":brandDealershipID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosFctList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 车辆型号 */
- (NSURLSessionDataTask *)commonAPIsGetAutoModelListWithAutoSeriesID:(NSString *)seriesID
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"fctId":seriesID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutoSpecList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////##########/////维修指南/////##########/////
/* 维修指南 */
- (NSURLSessionDataTask *)repairGuideAPIsGetMainPageGuideDataWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairGuideMainPageData
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修指南二级列表 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideSubTypeListWithMainTypeName:(NSString *)mainTypeName
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"rname":mainTypeName};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairGuideSubTypeList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修指南三级列表 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideResultListWithSubTypeID:(NSString *)subTypeID
                                                                      pageNums:(NSNumber *)pageNums
                                                                     pageSizes:(NSNumber *)pageSizes
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        NSDictionary *parameters = @{@"type_id":subTypeID,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairGuideResultList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修指南详情 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:(NSString *)procedureDetailID
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"rid":procedureDetailID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairGuideProcedureDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修指南指导资讯 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairStepGuideDetailWithProcedureDetailID:(NSString *)procedureDetailID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"relateId":procedureDetailID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairStepGuideDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修指南指导结果 */
- (NSURLSessionDataTask *)repairGuideAPIsGetRepairStepGuideFinalResultWithProcedureDetailID:(NSString *)procedureDetailID
                                                                                   seriesID:(NSString *)seriesID
                                                                                autoModelID:(NSString *)autoModelID
                                                                                 repairName:(NSString *)repairName
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:procedureDetailID,
                                     @"fct":seriesID,
                                     @"specid":autoModelID,
                                     @"repair_name":repairName};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairStepGuideFinalResult
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////违章/////##########/////
/* 违章查询界面，车辆及违章次数界面 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserViolationEnquiryInfoWithAccessToken:(NSString *)token
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserViolationEnquiryInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 违章查询 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserViolationEnquiryRequestWithAccessToken:(NSString *)token
                                                                          myAutoEngineNum:(NSString *)myAutoEngineNum
                                                                             licensePlate:(NSString *)licensePlate
                                                                          isShowRequested:(BOOL)isShowRequested
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"engineNo":myAutoEngineNum,
                                     @"carNumber":licensePlate,
                                     @"type":@(isShowRequested+1),};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserViolationEnquiryRequest
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 高发地查询列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCityViolationEnquiryListWithCityName:(NSString *)cityName
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"city":cityName};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZViolationCityBlacksiteList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 违章排行榜列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetUserHighViolationListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserViolationLocationRank
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 高发地神坑排行榜列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetHighViolationLocationListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZViolationLocationRank
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 违章详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetViolationDetailWithBlacksiteAddress:(NSString *)siteAddress
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"violation_place":siteAddress};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZViolationPlaceDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 违章地点纠错 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUserCorrectViolationLocationRequestWithAccessToken:(NSString *)token
                                                                                  blacksiteAddress:(NSString *)siteAddress
                                                                                         longitude:(NSNumber *)longitude
                                                                                          latitude:(NSNumber *)latitude
                                                                                          cityName:(NSString *)cityName
                                                                                           success:(APIsConnectionSuccessBlock)success
                                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"violation_place":siteAddress,
                                     @"lat":latitude,
                                     @"lng":longitude,
                                     @"city":cityName,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserViolationPlaceCorrect
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}




#pragma mark /////##########/////车考题库/////##########/////
/* 榜上有名查询 */
- (NSURLSessionDataTask *)personalCenterAPIsGetTrafficExaminationRankingListWithListType:(TERankingType)listType
                                                                                pageNums:(NSNumber *)pageNums
                                                                               pageSizes:(NSNumber *)pageSizes
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (listType<TERankingTypeOfDailyRankingList||listType>TERankingTypeOfMonthlyRankingList) {
            listType = TERankingTypeOfDailyRankingList;
        }
        NSDictionary *parameters = @{@"type":@(listType),
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZTrafficExaminationRankingList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 易错题目列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetTrafficExaminationRankingListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZTrafficExaminationMostlyFailureList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 模拟考试提交 */
- (NSURLSessionDataTask *)personalCenterAPIsPostTrafficExaminationSubmitSimulateExamWithAccessToken:(NSString *)token
                                                                                         resultMark:(NSNumber *)resultMark
                                                                                        useExamTime:(NSString *)useExamTime
                                                                                     examFailIDList:(NSString *)examFailIDList
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"grade":resultMark,
                                     @"use_time":useExamTime,
                                     @"exam_id":examFailIDList,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZTrafficExaminationSubmitSimulateExam
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



#pragma mark /////##########/////其他/////##########/////

/* 省份列表 */
- (NSURLSessionDataTask *)commonAPIsGetProvinceListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZProvinceList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 城市列表 */
- (NSURLSessionDataTask *)commonAPIsGetCityListWithProvinceID:(NSString *)provinceID
                                                    isKeyCity:(BOOL)isKeyCity
                                                      success:(APIsConnectionSuccessBlock)success
                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!provinceID) {
            provinceID = @"";
        }
        NSDictionary *parameters = @{@"provinceId":provinceID,@"isKeyCity":@(isKeyCity)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCityListWithProvince
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 区列表 */
- (NSURLSessionDataTask *)commonAPIsGetDistrictListWithCityID:(NSString *)cityID
                                                      success:(APIsConnectionSuccessBlock)success
                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{@"cityId":cityID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZDistrictListWithCity
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商类型列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopType
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商保养服务类型列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopServiceTypeListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopServiceType
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商保养服务列表 */
- (NSURLSessionDataTask *)commonAPIsGetRepairShopServiceListWithShopID:(NSString *)shopID
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters  = nil;
        if (shopID&&![shopID isEqualToString:@""]) {
            parameters = @{@"wxs_id":shopID};
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRepairShopServiceList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 订单状态列表 */
- (NSURLSessionDataTask *)commonAPIsGetPurchaseOrderStatusListWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPurchaseOrderStatusList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark- /////##########/////GPS/////##########/////
#pragma mark /////##########/////GPS配置/////##########/////
/* 车辆实时位置信息 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoGPSRealtimeInfoWithAccessToken:(NSString *)token
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoRealtimeInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 查询GPS上传设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetUploadSettingStatusWithAccessToken:(NSString *)token
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSUploadSettingStauts
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改GPS上传设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostUpdateGPSUploadSettingWithAccessToken:(NSString *)token
                                                                   localinfoStatus:(NSNumber *)localinfoStatus
                                                                      remindStatus:(NSNumber *)remindStatus
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure{
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"locainfoStatus":localinfoStatus,
                                     @"remindStatus":remindStatus};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSUpdateUploadSetting
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////OBD&&车辆配置/////##########/////
/* 服务密码验证 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAuthorizeServerSecurityPWWithAccessToken:(NSString *)token
                                                                               serPwd:(NSString *)serPwd
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"password":serPwd};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAuthorizeServerSecurityPW
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 快速设防详情 */
- (NSURLSessionDataTask *)personalGPSAPIsGetFastPreventionDetailWithAccessToken:(NSString *)token
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSFastPreventionDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 开启快速设防 */
- (NSURLSessionDataTask *)personalGPSAPIsPostFastPreventionOfnWithAccessToken:(NSString *)token
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSFastPreventionOn
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 关闭快速设防 */
- (NSURLSessionDataTask *)personalGPSAPIsPostFastPreventionOffWithAccessToken:(NSString *)token
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSFastPreventionOff
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 省电设置详情 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoPowerSaveStatusWithAccessToken:(NSString *)token
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoPowerSaveStatus
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改省电设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoPowerSaveChangeStatusWithAccessToken:(NSString *)token
                                                                               status:(BOOL)status
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoPowerSaveChangeStatus
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 设备安装校正 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoDeviceCalibrationWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoDeviceCalibrate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 点火熄火校准 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoIgnitionSystemCalibrationWithAccessToken:(NSString *)token
                                                                                   status:(BOOL)status
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoIgnitionSystemCalibrate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}




/* 获取安全设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoAllAlertStatusListWithAccessToken:(NSString *)token
                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoAllAlertStatusList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改侧翻设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoRoleAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                               status:(BOOL)status
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoRoleAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改碰撞设置*/
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoImpactAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                 status:(BOOL)status
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoImpactAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改电瓶低电压设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoBatteryLowAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                     status:(BOOL)status
                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoBatteryLowAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改拖车设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoTrailingAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                   status:(BOOL)status
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoTrailingAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改设备移除（断电）设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoODBRemoveAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                    status:(BOOL)status
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoODBRemoveAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改防盗喇叭设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoSecurityAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                   status:(BOOL)status
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoSecurityAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改疲劳驾驶设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoFatigueDrivingAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                                         status:(BOOL)status
                                                                                        success:(APIsConnectionSuccessBlock)success
                                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoFatigueDrivingAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



/* 获取超速设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOverSpeedSettingWithAccessToken:(NSString *)token
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoOverSpeedSetting
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 修改超速设置 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoOverSpeedSettingUpdateWithAccessToken:(NSString *)token
                                                                           speedStatus:(BOOL)speedStatus
                                                                                 speed:(NSNumber *)speed
                                                                           voiceStatus:(BOOL)voiceStatus
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"ratedStatus":@(speedStatus),
                                     @"ratedSpeed":speed,
                                     @"voiceStatus":@(voiceStatus)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoOverSpeedSettingUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 获取断油断电设置 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoPowerAndOilControlStatusWithAccessToken:(NSString *)token
                                                                                success:(APIsConnectionSuccessBlock)success
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoPowerAndOilControlStatus
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 修改断油断电设置*/
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoPowerAndOilControlStatusUpdateWithAccessToken:(NSString *)token
                                                                                        status:(BOOL)status
                                                                                       success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,@"status":@(status)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoPowerAndOilControlStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 查询个人电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoElectricFencingDetialWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoElectricFencingDetial
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 增加电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoAddElectricFencingWithAccessToken:(NSString *)token
                                                                              type:(NSString *)type
                                                                            radius:(NSString *)radius
                                                                         longitude:(NSString *)longitude
                                                                          latitude:(NSString *)latitude
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"type":type,
                                     @"radius":radius,
                                     @"longitude":longitude,
                                     @"latitude":latitude};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoAddElectricFencing
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除电子围栏 */
- (NSURLSessionDataTask *)personalGPSAPIsPostAutoRemoveElectricFencingWithAccessToken:(NSString *)token
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoRemoveElectricFencing
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}





/* OBD主动查询 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOBDDataWithAccessToken:(NSString *)token
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoOBDData
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* OBD故障检测 */
- (NSURLSessionDataTask *)personalGPSAPIsGetAutoOBDDiagnosisWithAccessToken:(NSString *)token
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoOBDDiagnosis
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////GPS、汽车记录和数据/////##########/////
/* 行车轨迹 */
- (NSURLSessionDataTask *)personalGPSAPIsGetDrivingHistoryListWithAccessToken:(NSString *)token
                                                                startDateTime:(NSString *)startDateTime
                                                                  endDateTime:(NSString *)endDateTime
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"startTime":startDateTime,
                                     @"endTime":endDateTime};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSAutoDrivingHistoryList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 清除行车历史轨迹 */
- (NSURLSessionDataTask *)personalGPSAPIsPostEraseDrivingHistoryWithAccessToken:(NSString *)token
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZGPSEraseDrivingHistory
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////##########/////其他/////##########/////
/* 消息列表 */
- (NSURLSessionDataTask *)personalMessageAPIsGetMessageAlertListWithAccessToken:(NSString *)token
                                                                       pageNums:(NSNumber *)pageNums
                                                                      pageSizes:(NSNumber *)pageSizes
                                                                      plateName:(NSString *)plateName
                                                                       typeName:(NSString *)typeName
                                                                isMessWasReaded:(BOOL)isMessWasReaded
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (!plateName) plateName = @"";
        if (!typeName) typeName = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"plate_name":plateName,
                                     @"type_nam":typeName,
                                     @"state_name":@(isMessWasReaded)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMessageAlertList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        return operation;
    }
}

/* 消息列表 */
- (NSURLSessionDataTask *)personalMessageAPIsGetGPSMessageAlertListWithAccessToken:(NSString *)token
                                                                          pageNums:(NSNumber *)pageNums
                                                                         pageSizes:(NSNumber *)pageSizes
                                                                         plateName:(NSString *)plateName
                                                                          typeName:(NSString *)typeName
                                                                   isMessWasReaded:(BOOL)isMessWasReaded
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (!plateName) plateName = @"";
        if (!typeName) typeName = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"plate_name":plateName,
                                     @"type_nam":typeName,
                                     @"state_name":@(isMessWasReaded)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMessageAlertList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        return operation;
    }
}

/* 消息已读状态 */
- (NSURLSessionDataTask *)personalMessageAPIsGetMessageAlertWasReaderStatusWithAccessToken:(NSString *)token
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = nil;
        if (token) {
            parameters = @{kParameterOfToken:token};
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMessageWasReadedStatus
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        return operation;
    }
}

/* 消息删除 */
- (NSURLSessionDataTask *)personalMessageAPIsPostMessageAlertMessageDeleteWithAccessToken:(NSString *)token
                                                                                messageID:(NSString *)messageID
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:messageID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMessageAlertMessageDelete
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        return operation;
    }
}

/* 消息状态更新 */
- (NSURLSessionDataTask *)personalMessageAPIsPostMessageAlertStatusUpdateWithAccessToken:(NSString *)token
                                                                               messageID:(NSString *)messageID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:messageID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMessageAlertStatusUpdate
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        
        return operation;
    }
}

/* 推送消息设置 */
- (NSURLSessionDataTask *)personalCenterAPNSSettingAlertListWithAccessToken:(NSString *)token
                                                                  messageON:(BOOL)messageON
                                                                  channelID:(NSString *)channelID
                                                                deviceToken:(NSString *)deviceToken
                                                                 apnsUserID:(NSString *)apnsUserID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!channelID) {
            channelID = @"";
        }
        if (!deviceToken) {
            deviceToken = @"";
        }
        if (!apnsUserID) {
            apnsUserID = @"";
        }
        if ([deviceToken isEqualToString:@""]||[channelID isEqualToString:@""]||[apnsUserID isEqualToString:@""]) {
            messageON = NO;
        }
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"message":@(!messageON),
                                     @"channelId":channelID,
                                     @"deviceToken":deviceToken,
                                     @"userId":apnsUserID,
                                     @"deviceCode":channelID,
                                     @"iOSDevice":@YES};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAPNSPushSetting
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 问卷接口 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyPFeedbackToShowWithAccessToken:(NSString *)token
                                                               answerListString:(NSString *)answerListString
                                                          otherAdviceListString:(NSString *)otherAdviceList
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"name":answerListString,
                                     @"other":otherAdviceList,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:kCDZAppSurvey
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 设置- 意见反馈展示 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyPFeedbackToShowWithSuccessBlock:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyFeedbackToShowInfoList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 设置 - 用户反馈信息提交 */
- (NSURLSessionDataTask *)personalSettingsAPIsPostUserFeedback:(NSString *)name
                                                           tel:(NSString *)tel
                                                         token:(NSString *)token
                                                       content:(NSString *)content
                                                      imageUrl:(NSString *)imageUrl
                                                       success:(APIsConnectionSuccessBlock)success
                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!token) {
            token = @"";
        }
        if (!name) {
            name = @"";
        }
        if (!tel) {
            tel = @"";
        }
        if (!imageUrl) {
            imageUrl = @"";
        }
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"name":name,
                                     @"tel":tel,
                                     @"content":content,
                                     @"face":imageUrl
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMyPersonalSettingsUserFeedbackInfoList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 用户设置反馈信息照片的提交 */
- (NSURLSessionDataTask *)personalSettingsAPIsPostUseryPortraitImageFeedback:(UIImage *)portraitImage
                                                                   imageName:(NSString *)imageName
                                                                   imageType:(ConnectionImageType)imageType
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    
    return [self personalCenterAPIsPostUseryPortraitImage:portraitImage imageName:imageName imageType:imageType success:success failure:failure];
}

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
                                                                     failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (!otherUserID) otherUserID = @"";
        if (!searchString) searchString = @"";
        if (!token) token = @"";
        
        NSString *fetchString = @"";
        NSString *fetchTopicString = @"";
        
        
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"video":wasVideo?@"video":@"",
                                             @"serach":searchString,
                                             @"square_id":otherUserID,
                                             @"page_no":pageNums,
                                             @"page_size":pageSizes} mutableCopy];
        
        switch (fetchType) {
            case CDZEREDRShareFetchTypeOfNewFetch:
                fetchString = @"最新";
                if ([kParameterOfToken isEqualToString:@""]) {
                    [parameters removeObjectForKey:kParameterOfToken];
                }
                [parameters removeObjectForKey:@"video"];
                break;
                
            case CDZEREDRShareFetchTypeOfRecommendFetch:
                if ([kParameterOfToken isEqualToString:@""]) {
                    [parameters removeObjectForKey:kParameterOfToken];
                }
                [parameters removeObjectForKey:@"video"];
                fetchString = @"推荐";
                break;
                
            case CDZEREDRShareFetchTypeOfFollowedFetch:
                if ([kParameterOfToken isEqualToString:@""]) {
                    [parameters removeObjectForKey:kParameterOfToken];
                }
                [parameters removeObjectForKey:@"video"];
                fetchString = @"关注";
                break;
                
            case CDZEREDRShareFetchTypeOfSelfFetch:
                fetchString = @"自己";
                break;
                
            case CDZEREDRShareFetchTypeOfOtherUserFetch:
                if ([kParameterOfToken isEqualToString:@""]) {
                    [parameters removeObjectForKey:kParameterOfToken];
                }
                fetchString = @"好友";
                break;
                
            case CDZEREDRShareFetchTypeOfNotRequest:
                switch (topicType) {
                    case CDZEREDRShareFetchTopicTypeOfRoadShow:
                        fetchTopicString = @"路上风景";
                        break;
                        
                    case CDZEREDRShareFetchTopicTypeOfCityAppearance:
                        fetchTopicString = @"城市样貌";
                        break;
                        
                    case CDZEREDRShareFetchTopicTypeOfFunnyJokes:
                        fetchTopicString = @"趣闻段子";
                        break;
                        
                    case CDZEREDRShareFetchTopicTypeOfPersonalStyle:
                        fetchTopicString = @"个人风采";
                        break;
                        
                    case CDZEREDRShareFetchTopicTypeOfNotRequest:
                        fetchString = @"最新";
                        [parameters removeObjectForKey:kParameterOfToken];
                        [parameters removeObjectForKey:@"video"];
                        break;
                    default:
                        break;
                }
                [parameters setObject:fetchTopicString forKey:@"topic"];
                break;
            default:
                break;
        }
        [parameters setObject:fetchString forKey:@"type"];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRFetchList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 行车广场 或 我的动态 详情 */
- (NSURLSessionDataTask *)persnalEDRAPIsGetUserShareFetchDetailWithAccessToken:(NSString *)token
                                                                       fetchID:(NSString *)fetchID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!token) token = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:fetchID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRFetchDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 行车广场关注或取消关注 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostChangeUserFollowOtherUserStatusWithAccessToken:(NSString *)token
                                                                                 wasFollow:(BOOL)wasFollow
                                                                         wasFollowedUserID:(NSString *)wasFollowedUserID
                                                                                   success:(APIsConnectionSuccessBlock)success
                                                                                   failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"type":wasFollow?@"关注":@"取消关注",
                                     @"attention_id":wasFollowedUserID,};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRFollowAction
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 行车广场 点赞或 取消点赞 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostChangeUserLikeOtherUserStatusWithAccessToken:(NSString *)token
                                                                                 wasLike:(BOOL)wasLike
                                                                     followedUserFetchID:(NSString *)followedUserFetchID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"type":wasLike?@"点赞":@"取消点赞",
                                     @"square_id":followedUserFetchID,};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRLikeAction
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 行车广场 评论或回复 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostFetchFeedBackWithAccessToken:(NSString *)token
                                                           contentString:(NSString *)contentString
                                                                 fetchID:(NSString *)fetchID
                                                                wasReply:(BOOL)wasReply
                                                                 replyID:(NSString *)replyID
                                                         beReplyUserName:(NSString *)beReplyUserName
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"content":contentString,
                                             @"square_id":fetchID,
                                             @"type":wasReply?@"回复":@"评论"} mutableCopy];
        if (wasReply&&replyID&&beReplyUserName) {
            [parameters addEntriesFromDictionary:@{@"comment_id":replyID,
                                                   @"nichen_bei":beReplyUserName}];
        }
        if (wasReply&&(!replyID||!beReplyUserName)) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"missing replay parameters" code:-11000 userInfo:nil];
                failure (nil, error);
            }
            return nil;
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRCommentOrReply
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 行车广场 之发布动态 */
- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchListWithAccessToken:(NSString *)token
                                                                     wasVideo:(BOOL)wasVideo
                                                                contentString:(NSString *)contentString
                                                           topicTypeListSting:(NSString *)topicTypeListSting
                                                                shareImageURL:(NSString *)shareImageURL
                                                                shareMovieURL:(NSString *)shareMovieURL
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"file_type":wasVideo?@"视频":@"图片",
                                             @"content":contentString,
                                             @"type":topicTypeListSting,
                                             @"img_url":shareImageURL,} mutableCopy];
        if (!shareMovieURL) shareMovieURL = @"";
        if (wasVideo) {
            [parameters setObject:shareMovieURL forKey:@"video_url"];
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRSubmitShareFetch
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}
/* 行车广场 个人粉丝／关注列表 */
- (NSURLSessionDataTask *)persnalEDRAPIsGetUserFanOrFollowedListWithAccessToken:(NSString *)token
                                                                     wasFanList:(BOOL)wasFanList
                                                                       pageNums:(NSNumber *)pageNums
                                                                      pageSizes:(NSNumber *)pageSizes
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"type":wasFanList?@"粉丝":@"关注",
                                             @"page_no":pageNums,
                                             @"page_size":pageSizes} mutableCopy];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZEDRUserFanOrFollowedList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchImageWithImagePath:(NSURL *)imagePath
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!imagePath) return nil;
        NSString *imageName = imagePath.lastPathComponent;
        NSString *imageTypeString = @"image/jpeg";
        NSData *data = [NSData dataWithContentsOfURL:imagePath];
        if ([imageName.pathExtension isEqualToString:@"png"]) {
            imageTypeString = @"image/png";
        }
        
        APIsConnectionFormData formData = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:imageName mimeType:imageTypeString];
        };
        
        NSDictionary *parameters = @{@"root":@"demo/basic/faceImg"};
        NSURLSessionDataTask *operation = nil;
        operation = [self createImgUploadPostRequestWithRelativePath:kCDZPersonalImageUpload
                                                          parameters:parameters
                                                            progress:nil
                                       constructingPOSTBodyWithBlock:formData
                                                             success:success
                                                             failure:failure];
        return operation;
    }
}

- (NSURLSessionDataTask *)persnalEDRAPIsPostUserShareFetchMovieWithMoviePath:(NSURL *)moviePath
                                                              withUpoadBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!moviePath) return nil;
        NSString *movieName = moviePath.lastPathComponent;
        NSString *movieTypeString = @"video/mpeg4";
        NSData *data = [NSData dataWithContentsOfURL:moviePath];
        
        APIsConnectionFormData formData = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:movieName mimeType:movieTypeString];
        };
        
        NSDictionary *parameters = @{@"root":@"demo/basic/faceImg"};
        NSURLSessionDataTask *operation = nil;
        operation = [self createImgUploadPostRequestWithRelativePath:kCDZPersonalImageUpload
                                                          parameters:parameters
                                                            progress:^(NSProgress *downloadProgress) {
                                                                
                                                            }
                                       constructingPOSTBodyWithBlock:formData
                                                             success:success
                                                             failure:failure];
        return operation;
    }
}


#pragma mark- /////////////////////////////////////////////////////Rapid Repair APIs（快速维修接口）/////////////////////////////////////////////////////
#pragma mark /////##########/////快速维修/////##########/////
/* 首页的专业服务、维修商列表的专修服务项目 */
- (NSURLSessionDataTask *)rapidRepairSpecServiceListWithSuccess:(APIsConnectionSuccessBlock)success
                                                        failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairServiceItemList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 首页的专修服务品牌列表 */
- (NSURLSessionDataTask *)rapidRepairSpecServiceItemBrandListWithItemBrandType:(SNSSLVFItemBrandType)itemBrandType
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSString *itemBrandTypeString = @"轮胎";
        switch (itemBrandType) {
            case SNSSLVFItemBrandTypeOfWindshield:
                itemBrandTypeString = @"玻璃";
                break;
            case SNSSLVFItemBrandTypeOfStorageBattery:
                itemBrandTypeString = @"电瓶";
                break;
            case SNSSLVFItemBrandTypeOfTire:
            default :
                itemBrandTypeString = @"轮胎";
                break;
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairServiceItemBrandList
                                           parameters:@{@"service_item":itemBrandTypeString}
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

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
                                                                          failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!token) token = @"";
        if (!searchKeyword) searchKeyword = @"";
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        if (!cityName||[cityName isEqualToString:@""]) cityName = @"长沙市";
        if (!eSerProject) eSerProject = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"city_name":cityName,
                                     @"select_item":filterOption,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"key_words":searchKeyword,
                                     @"project":eSerProject};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairShopList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

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
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!token) token = @"";
        if (!searchKeyword) searchKeyword = @"";
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        if (!cityName||[cityName isEqualToString:@""]) cityName = @"长沙市";
        if (!brandOrServiceID) brandOrServiceID = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"city_name":cityName,
                                     @"service_id":brandOrServiceID,
                                     @"select_item":filterOption,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"key_words":searchKeyword};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairBrandNSpecServiceList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 维修商地图列表（显示周围10公里的维修商） */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairShopMapListWithCityName:(NSString *)cityName
                                                                       coordinate:(CLLocationCoordinate2D)coordinate                                                                              success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!cityName||[cityName isEqualToString:@""]) cityName = @"长沙市";
        if (coordinate.latitude==0) coordinate.latitude = 28.224610;
        if (coordinate.longitude==0) coordinate.longitude = 112.893959;
        NSDictionary *parameters = @{@"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"city_name":cityName,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairShopMapList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}


/* 专修店——电瓶、玻璃、轮胎 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairSpecItemServiceListWithItemBrandType:(SNSSLVFItemBrandType)itemBrandType
                                                                                 tireSpecModel:(NSString *)tireSpecModel
                                                                                      cityName:(NSString *)cityName
                                                                                    coordinate:(CLLocationCoordinate2D)coordinate
                                                                                      pageNums:(NSNumber *)pageNums
                                                                                     pageSizes:(NSNumber *)pageSizes
                                                                                  filterOption:(NSNumber *)filterOption
                                                                                       modelID:(NSString *)modelID                                                                                    success:(APIsConnectionSuccessBlock)success
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        NSString *itemBrandTypeString = @"";
        switch (itemBrandType) {
            case SNSSLVFItemBrandTypeOfWindshield:
                itemBrandTypeString = @"玻璃";
                break;
            case SNSSLVFItemBrandTypeOfStorageBattery:
                itemBrandTypeString = @"电瓶";
                break;
            case SNSSLVFItemBrandTypeOfTire:
                itemBrandTypeString = @"轮胎";
                break;
            default :
                itemBrandTypeString = @"";
                break;
        }
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        if (!cityName||[cityName isEqualToString:@""]) cityName = @"长沙市";
        if (!tireSpecModel) tireSpecModel = @"";
        if (!modelID) modelID = @"";
        NSDictionary *parameters = @{@"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"city_name":cityName,
                                     @"product_model":tireSpecModel,
                                     @"service_name":itemBrandTypeString,
                                     @"con":filterOption,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"speci":modelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairSpecItemServiceList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 轮胎规格 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairTireSpecListWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairTireSpecList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 选择轮胎【个人中心有车辆，但default_model为空时，访问此接口】 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairTireDefaultSpecWithAccessToken:(NSString *)token success:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairTireDefaultSpec
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}


/* 确定轮胎型号【点击推荐的轮胎型号，或者点击更换其他中的搜索轮胎时访问此接口】 */
- (NSURLSessionDataTask *)personalCenterAPIsPostUpdateRapidRepairTireSpecSelectionWithAccessToken:(NSString *)token tireSpecModel:(NSString *)tireSpecModel modelID:(NSString *)modelID success:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        
        if (!tireSpecModel) tireSpecModel = @"";
        if (!modelID) modelID = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"speci":modelID,
                                     @"default_model":tireSpecModel,};
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairTireSpecSelectionSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 维修商的详情页面 */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairShopOrServiceDetailWithAccessToken:(NSString *)token
                                                                             shopOrServiceID:(NSString *)shopOrServiceID
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!token) token = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:shopOrServiceID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairShopOrServiceDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}


/* 维修商属下维修技师 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTechnicianListWithShopID:(NSString *)shopID
                                                                                 pageNums:(NSNumber *)pageNums
                                                                                pageSizes:(NSNumber *)pageSizes
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:shopID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopTechnicianList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修商属下维修技师详情 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsTechnicianDetailWithTechnicianID:(NSString *)technicianID
                                                                                         pageNums:(NSNumber *)pageNums
                                                                                        pageSizes:(NSNumber *)pageSizes
                                                                                          success:(APIsConnectionSuccessBlock)success
                                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:technicianID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopTechnicianDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 维修商评论列表(商家评价) */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetMaintenanceShopsCommentListWithShopID:(NSString *)shopID
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:shopID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceShopCommentList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 产品评价 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetProductionCommentListWithProductionID:(NSString *)productionID
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:productionID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosProductCommentList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 产品中心 */
- (NSURLSessionDataTask *)maintenanceShopsAPIsGetSpecServiceShopsProductListWithShopID:(NSString *)shopID
                                                                               modelID:(NSString *)modelID
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                          filterOption:(NSNumber *)filterOption
                                                                      productBrandName:(NSString *)productBrandName
                                                                         tireSpecModel:(NSString *)tireSpecModel
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        if (!tireSpecModel) tireSpecModel = @"";
        if (!modelID) modelID = @"";
        if (!productBrandName) productBrandName = @"";
        NSDictionary *parameters = @{kParameterOfID:shopID,
                                     @"speci":modelID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"con":filterOption,
                                     @"product_brand":productBrandName,
                                     @"product_model":tireSpecModel,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZAutosProductCenterList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 立即购买（轮胎、电瓶、玻璃） */
- (NSURLSessionDataTask *)personalCenterAPIsGetRapidRepairSpecPartsBuyNowInfoWithAccessToken:(NSString *)token
                                                                                   productID:(NSString *)productID
                                                                               purchaseCount:(NSNumber *)purchaseCount
                                                                                     brandID:(NSString *)brandID
                                                                           brandDealershipID:(NSString *)brandDealershipID
                                                                                    seriesID:(NSString *)seriesID
                                                                                     modelID:(NSString *)modelID
                                                                                     success:(APIsConnectionSuccessBlock)success
                                                                                     failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        if (!token) token = @"";
        if (!purchaseCount||purchaseCount.integerValue<=0) purchaseCount = @(1);
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:productID,
                                     @"number":purchaseCount,
                                     @"brand":brandID, //(车品牌id)
                                     @"factory":brandDealershipID, //(车厂商id)
                                     @"fct":seriesID, //(车系名id)
                                     @"speci":modelID, //(车型名id)
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairSpecPartsBuyNow
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}


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
                                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!invoicePayeeName) invoicePayeeName=@"";
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"wxs_id":shopID,
                                             @"product_id":productID,
                                             @"number":purchaseCount,
                                             @"sum_price":totalPrice,
                                             @"android_ios":@"",
                                             @"invoice_head":invoicePayeeName} mutableCopy];
        if (couponID&&![couponID isEqualToString:@""]) {
            [parameters setObject:couponID forKey:@"prefer_id"];
        }else if (creditTotalConsumed&&![creditTotalConsumed isEqualToString:@""]&&
                  verifyCode&&![verifyCode isEqualToString:@""]){
            [parameters addEntriesFromDictionary:@{@"credit":creditTotalConsumed,
                                                   @"valid_code":verifyCode}];
        }
        
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairSpecPartsOrderSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 店铺添加／取消收藏 */
- (NSURLSessionDataTask *)personalCenterAPIsUpdateShopCollectionStatusWithAccessToken:(NSString *)token
                                                                               shopID:(NSString *)shopID
                                                                 cancelShopCollection:(BOOL)cancelShopCollection
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:shopID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfPOST
                                withFirstRelativePath:YES
                                         relativePath:(cancelShopCollection?kCDZShopsCollectionRemove:kCDZShopsCollectionAdd)
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 添加车辆信息并返回轮胎型号（选择轮胎时，个人中心没有车辆或者点击更换车辆访问此接口）*/
- (NSURLSessionDataTask *)personalCenterAPIsPostLiteUpdateUserAutosDataWithAccessToken:(NSString *)token
                                                                               brandID:(NSString *)brandID
                                                                     brandDealershipID:(NSString *)brandDealershipID
                                                                              seriesID:(NSString *)seriesID
                                                                               modelID:(NSString *)modelID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"brand":brandID, //(车品牌id)
                                     @"factory":brandDealershipID, //(车厂商id)
                                     @"fct":seriesID, //(车系名id)
                                     @"speci":modelID, //(车型名id)
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZLiteUpdateUserAutosData
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 快捷保养列表 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceListWithItemsList:(NSArray *)itemsList
                                                                       seriesID:(NSString *)seriesID
                                                                        modelID:(NSString *)modelID
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSMutableDictionary *parameters = [@{@"fct":seriesID, //(车系名id)
                                             @"speci":modelID, //(车型名id)
                                             } mutableCopy];
        if (itemsList.count>0) {
            NSString *theIDsListStr = [itemsList componentsJoinedByString:@"-"];
            [parameters addEntriesFromDictionary:@{@"ids":theIDsListStr}];
            
        }
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 快捷保养建议列表 */
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetMaintenanceRecommendListWithStartToDriveDateTime:(NSString *)start2DriveDateTime
                                                                                            mileage:(NSString *)mileage
                                                                                           seriesID:(NSString *)seriesID
                                                                                            modelID:(NSString *)modelID
                                                                                            success:(APIsConnectionSuccessBlock)success
                                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSMutableDictionary *parameters = [@{@"fct":seriesID, //(车系名id)
                                             @"speci":modelID, //(车型名id)
                                             @"drive_time":start2DriveDateTime,
                                             @"mileage":mileage} mutableCopy];
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressRecommendList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

/* 快捷保养项目选择（点击快捷保养首页的修改）*/
- (NSURLSessionDataTask *)maintenanceExpressAPIsGetmaintenanceExpressServiceItemListWithSuccess:(APIsConnectionSuccessBlock)success failure:(APIsConnectionFailureBlock)failure {
    
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressServiceItemList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
        
    }
}

/* 快捷保养更换商品 */
- (NSURLSessionDataTask *)personalCenterAPIsGetChangeProductByautopartInfo:(NSString *)autopartInfo
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                                    number:(NSString *)number
                                                                     speci:(NSString *)speci
                                                                      sort:(NSNumber *)sort
                                                                  standard:(NSString *)standard
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{@"autopart_info":autopartInfo,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"number":number,
                                     @"speci":speci,
                                     @"sort":sort,
                                     @"standard":standard};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalChangeProduct
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!cityName) cityName = @"";
        if (!workHours) workHours = @0;
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"brand":brandID,
                                             @"factory":dealershipID,
                                             @"fct":seriesID,
                                             @"speci":modelID,
                                             @"work_hour":workHours,
                                             @"latitude":@(coordinate.latitude),
                                             @"longitude":@(coordinate.longitude),
                                             @"city_name":cityName} mutableCopy];
        if (productList.count>0&&productCountList.count>0&&
            productCountList.count==productList.count) {
            NSString *theIDsListStr = [productList componentsJoinedByString:@","];
            NSString *theCountsListStr = [productCountList componentsJoinedByString:@","];
            [parameters addEntriesFromDictionary:@{@"ids":theIDsListStr}];
            [parameters addEntriesFromDictionary:@{@"buy_counts":theCountsListStr}];
            
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressClearanceInfoDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"brand":brandID,
                                             @"factory":dealershipID,
                                             @"fct":seriesID,
                                             @"speci":modelID,
                                             @"wxs_id":repairShopID,
                                             @"wxs_price":repairShopRepairPrice} mutableCopy];
        if (productList.count>0&&productCountList.count>0&&
            productCountList.count==productList.count) {
            NSString *theIDsListStr = [productList componentsJoinedByString:@","];
            NSString *theCountsListStr = [productCountList componentsJoinedByString:@","];
            [parameters addEntriesFromDictionary:@{@"ids":theIDsListStr}];
            [parameters addEntriesFromDictionary:@{@"buy_counts":theCountsListStr}];
            
        }
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressClearanceInfoDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


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
                                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!searchKeyword) searchKeyword = @"";
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        if (!mainFilterOption||mainFilterOption.integerValue<0) mainFilterOption = @0;
        if (!mainFilterOption||mainFilterOption.integerValue>2) mainFilterOption = @2;
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        if (!cityName||[cityName isEqualToString:@""]) cityName = @"长沙市";
        if (!brandID) brandID = @"";
        NSString *maintainIDs = [maintainItemList componentsJoinedByString:@"-"];
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"maintain_ids":maintainIDs,
                                     @"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude),
                                     @"city_name":cityName,
                                     @"select_item":filterOption,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"key_words":searchKeyword,
                                     @"kind_name":mainFilterOption,
                                     @"brand":brandID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressClearanceSelectStores
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


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
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *productIDListStr = [productIDList componentsJoinedByString:@"-"];
        NSString *invoicePayeeNameListStr = [invoicePayeeNameList componentsJoinedByString:@"-"];
        
        NSMutableArray *resetUserRemarkList = [userRemarkList mutableCopy];
        [userRemarkList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * _stop) {
            if ([obj isEqualToString:@""]) {
                [resetUserRemarkList replaceObjectAtIndex:idx withObject:@"暂无"];
            }
        }];
        NSString *userRemarkListStr = [resetUserRemarkList componentsJoinedByString:@"--"];
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"wxs_id":repairShopID,
                                             @"address_id":addressID,
                                             @"ids":productIDListStr,
                                             @"sum_price":totalPrice,
                                             @"android_ios":@"",
                                             @"remark":userRemarkListStr,
                                             @"invoice_head":invoicePayeeNameListStr} mutableCopy];
        
        if (creditTotalConsumed&&![creditTotalConsumed isEqualToString:@""]&&
            verifyCode&&![verifyCode isEqualToString:@""]){
            [parameters addEntriesFromDictionary:@{@"credit":creditTotalConsumed,
                                                   @"valid_code":verifyCode}];
        }
        
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceExpressOrderSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 保养记录列表 */
- (NSURLSessionDataTask *)maintenanceRecordAPIsGetMaintenanceRecordListWithAccessToken:(NSString *)token
                                                                               modelID:(NSString *)modelID
                                                                              pageNums:(NSNumber *)pageNums
                                                                             pageSizes:(NSNumber *)pageSizes
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!modelID) modelID = @"";
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"speci":modelID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceRecordList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSString *maintenanceItemListStr = [maintenanceItemIDList componentsJoinedByString:@"-"];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"brand":brandID,
                                     @"factory":dealershipID,
                                     @"fct":seriesID,
                                     @"speci":modelID,
                                     @"mileage":totalMileage,
                                     @"addtime":maintenanceDateTime,
                                     @"maintain_ids":maintenanceItemListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceRecordInsert
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
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
                                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSString *maintenanceItemListStr = [maintenanceItemIDList componentsJoinedByString:@"-"];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:recordID,
                                     @"brand":brandID,
                                     @"factory":dealershipID,
                                     @"fct":seriesID,
                                     @"speci":modelID,
                                     @"mileage":totalMileage,
                                     @"addtime":maintenanceDateTime,
                                     @"maintain_ids":maintenanceItemListStr};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMaintenanceSelfMaintainRecordEdit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////######### 改 改 改 改 改   #/////车辆维修/////##########/////
/* 维修管理列表 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMaintenanceListByStatusType:(CDZMaintenanceStatusType)statusType
                                                               accessToken:(NSString *)token
                                                                  pageNums:(NSNumber *)pageNums
                                                                 pageSizes:(NSNumber *)pageSizes
                                                           shopNameOrKeyID:(NSString *)shopNameOrKeyID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!shopNameOrKeyID) shopNameOrKeyID = @"";
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"type":@(statusType),
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRepairList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 查询维修详情由维修类型 */
- (NSURLSessionDataTask *)personalCenterAPIsGetrepairOrderDetailByStatusType:(CDZMaintenanceStatusType)statusType
                                                                 accessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"type":@(statusType)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRepairOrderDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 同意维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostAgreeRepairWithAccessToken:(NSString *)token
                                                                     keyID:(NSString *)keyID
                                                         repairItemsString:(NSString *)repairItemsString
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"repair_item":repairItemsString};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalAgreeRepair
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 取消维修 */
- (NSURLSessionDataTask *)personalCenterAPIsPostRefuseRepairWithAccessToken:(NSString *)token
                                                                      keyID:(NSString *)keyID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRefuseRepair
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 点击确认付款 */
- (NSURLSessionDataTask *)personalCenterAPIsPostConfirmPayWithAccessToken:(NSString *)token
                                                                    keyID:(NSString *)keyID
                                                                  success:(APIsConnectionSuccessBlock)success
                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalConfirmPay
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 维修点击确认付款 */
- (NSURLSessionDataTask *)personalCenterAPIsPostEnsurePayorderWithAccessToken:(NSString *)token
                                                                repairOrderID:(NSString *)repairOrderID
                                                                         mark:(NSNumber *)mark
                                                                      credits:(NSString *)credits
                                                                    validCode:(NSString *)validCode
                                                                     preferId:(NSString *)preferId
                                                                  invoiceHead:(NSString *)invoiceHead
                                                                      success:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!mark||mark.integerValue<=1||mark.integerValue>=6) {
            mark = @3;
        }
        if (!invoiceHead) invoiceHead = @"";
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             kParameterOfID:repairOrderID,
                                             @"invoice_head":invoiceHead,
                                             @"mark":mark,} mutableCopy];
        
        if (credits&&![credits isEqualToString:@""]&&
            validCode&&![validCode isEqualToString:@""]) {
            [parameters addEntriesFromDictionary:@{@"credits":credits, @"valid_code":validCode}];
        }
        if (preferId&&![preferId isEqualToString:@""]) {
            [parameters addEntriesFromDictionary:@{@"prefer_id":preferId}];
        }
        [parameters addEntriesFromDictionary:@{@"mark":mark}];
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalEnsurePayorder
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 点击评论——服务评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostCommentRepairWithAccessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID

                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalCommentRepair
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 提交评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubRepairCommentWithAccessToken:(NSString *)token
                                                                          keyID:(NSString *)keyID
                                                                      productID:(NSString *)productID
                                                                           star:(NSString *)star
                                                                        content:(NSString *)content
                                                                        success:(APIsConnectionSuccessBlock)success
                                                                        failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID,
                                     @"star":star,
                                     @"content":content,
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalSubRepairComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 查看评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostShowRepairGroupCommentInfoWithAccessToken:(NSString *)token
                                                                                    keyID:(NSString *)keyID
                                                                                productID:(NSString *)productID
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalShowCommentInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/////////////////////////////////////////////////////////////////////////////////////////
//订单列表（全部、待付款、待收货、待安装、待评价）
- (NSURLSessionDataTask *)personalCenterAPIsGetOrderListByStatusType:(NSNumber *)status
                                                         accessToken:(NSString *)token
                                                            pageNums:(NSNumber *)pageNums
                                                           pageSizes:(NSNumber *)pageSizes
                                                            keyWords:(NSString *)keyWords
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!keyWords) keyWords = @"";
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"status":status,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"key_words":keyWords};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalShowOrderList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/* 订单详情 */
- (NSURLSessionDataTask *)personalCenterAPIsGetOrderDetailByaccessToken:(NSString *)token
                                                                  keyID:(NSString *)keyID
                                                                success:(APIsConnectionSuccessBlock)success
                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalOrderDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 未付款——立即支付 */
- (NSURLSessionDataTask *)personalCenterAPIsGetPayNowByaccessToken:(NSString *)token
                                                             keyID:(NSString *)keyID
                                                           success:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalPayNow
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 未付款、货到付款——取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCancleOrder1ByaccessToken:(NSString *)token
                                                                   keyID:(NSString *)keyID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalCancleOrder1
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 交易关闭——删除订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetDelOrderByaccessToken:(NSString *)token
                                                               keyID:(NSString *)keyID
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalDelOrder
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 未付款、货到付款——取消订单 */
- (NSURLSessionDataTask *)personalCenterAPIsGetCancleOrder2ByaccessToken:(NSString *)token
                                                                   keyID:(NSString *)keyID
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalCancleOrder2
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 派送中——确认收货 */
- (NSURLSessionDataTask *)personalCenterAPIsGetConfirmReceiveByaccessToken:(NSString *)token
                                                                     keyID:(NSString *)keyID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalConfirmReceive
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/*产品评论列表*/
- (NSURLSessionDataTask *)personalCenterAPIsGetCommentOrderInfoByaccessToken:(NSString *)token
                                                                       keyID:(NSString *)keyID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalCommentOrderInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 我的订单中  提交评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubRepairCommentByorderWithAccessToken:(NSString *)token
                                                                                 keyID:(NSString *)keyID
                                                                             productID:(NSString *)productID
                                                                           productType:(NSString *)productType
                                                                                  star:(NSString *)star
                                                                               content:(NSString *)content
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID,
                                     @"product_type":productType,
                                     @"star":star,
                                     @"content":content,
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalSubComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 我的订单中  查看评论*/
- (NSURLSessionDataTask *)personalCenterAPIsPostShowOrderGroupCommentInfoWithAccessToken:(NSString *)token
                                                                                   keyID:(NSString *)keyID
                                                                               productID:(NSString *)productID
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID,
                                     
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalShowCommentInfoByOrder
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 点击申请退款*/
- (NSURLSessionDataTask *)personalCenterAPIsPostApplyRefundByorderWithAccessToken:(NSString *)token
                                                                            keyID:(NSString *)keyID
                                                                        productID:(NSString *)productID

                                                                          success:(APIsConnectionSuccessBlock)success
                                                                          failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID,
                                     
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalApplyRefundr
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 提交退款申请*/
- (NSURLSessionDataTask *)personalCenterAPIsPostSubApplyRefundByorderWithAccessToken:(NSString *)token
                                                                               keyID:(NSString *)keyID
                                                                           productID:(NSString *)productID
                                                                           refundNum:(NSString *)refundNum
                                                                         refundPrice:(NSString *)refundPrice
                                                                        refundReason:(NSString *)refundReason
                                                                           refundDes:(NSString *)refundDes

                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,
                                     @"product_id":productID,
                                     @"refund_num":refundNum,
                                     @"refund_price":refundPrice,
                                     @"refund_reason":refundReason,
                                     @"refund_des":refundDes,
                                     
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalSubApplyRefund
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/*退款进度——返修/退换*/
- (NSURLSessionDataTask *)personalCenterAPIsGetRefundScheduleByaccessToken:(NSString *)token
                                                                     keyID:(NSString *)keyID
                                                                   success:(APIsConnectionSuccessBlock)success
                                                                   failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalRefundSchedule
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//查找配件
- (NSURLSessionDataTask *)personalCenterAPIsGetProductListBysortType:(NSNumber *)sort
                                                        autopartInfo:(NSString *)autopartInfo
                                                            pageNums:(NSNumber *)pageNums
                                                           pageSizes:(NSNumber *)pageSizes
                                                            keyWords:(NSString *)keyWords
                                                               speci:(NSString *)speci
                                                             success:(APIsConnectionSuccessBlock)success
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!keyWords) keyWords = @"";
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        
        NSDictionary *parameters = @{@"autopart_info":autopartInfo,
                                     @"sort":sort,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes,
                                     @"key_words":keyWords,
                                     @"speci":speci};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalProductList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//查找配件
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartTypeSuccess:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalAutopartType
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSMutableDictionary *parameters = [@{kParameterOfToken:token,
                                             @"brand":brandID,
                                             @"factory":dealershipID,
                                             @"fct":seriesID,
                                             @"speci":modelID,
                                             @"product_id":productID,
                                             @"buy_count":purchaseCount,
                                             @"address_id":addressID,
                                             @"mark":@0} mutableCopy];
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPartsDetailBuyNowInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


/*配件二级分类信息*/
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartListBykeyID:(NSString *)keyID
                                                           success:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{@"type_id":keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalAutopartList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/*配件三级分类信息*/
- (NSURLSessionDataTask *)personalCenterAPIsGetAutopartInfoBykeyID:(NSString *)keyID
                                                           success:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{@"list_id":keyID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalAutopartInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//、询价省份、城市、采购中心信息
- (NSURLSessionDataTask *)personalCenterAPIsGetInquiryInfoByprovinceID:(NSString *)provinceID
                                                                cityID:(NSString *)cityID
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!provinceID) provinceID = @"";
        if (!cityID) cityID = @"";
        NSDictionary *parameters = @{@"province_id":provinceID,
                                     @"city_id":cityID,};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZPersonalInquiryInfo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//购物车移至收藏
- (NSURLSessionDataTask *)personalCenterAPIsPostCartListMoveCollectionWithAccessToken:(NSString *)token
                                                                        productIDList:(NSArray *)productIDList
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSString *productIDListStr = [productIDList componentsJoinedByString:@","];
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"product_id":productIDListStr};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCartListMoveCollection
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 特殊（轮胎，玻璃，电瓶）产品详情 */
- (NSURLSessionDataTask *)rapidRepairAPIsGetSpecProductDetailWithSpecProductID:(NSString *)specProductID
                                                                    coordinate:(CLLocationCoordinate2D)coordinate
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfID:specProductID,
                                     @"latitude":@(coordinate.latitude),
                                     @"longitude":@(coordinate.longitude)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZRapidRepairSpecPartsDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
    
}

#pragma mark /////#########/////会员中心/////##########/////
// 会员中心详情
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberCenterDetailWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserMemberCenterDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 会员详情简介
- (NSURLSessionDataTask *)personalCenterAPIsGetMemberTypeDetailWithAccessToken:(NSString *)token
                                                                  memberTypeID:(NSNumber *)memberTypeID
                                                                       success:(APIsConnectionSuccessBlock)success
                                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!memberTypeID||memberTypeID.integerValue==0) memberTypeID = @1;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:memberTypeID};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMemberTypeDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


// 会员申请
- (NSURLSessionDataTask *)personalCenterAPIsPostMemberApplicationSubmitWithAccessToken:(NSString *)token
                                                                     applyMemberTypeID:(NSNumber *)applyMemberTypeID
                                                                               success:(APIsConnectionSuccessBlock)success
                                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!applyMemberTypeID||applyMemberTypeID.integerValue==0) applyMemberTypeID = @1;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"level":applyMemberTypeID};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMemberApplicationSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 会员订单确认
- (NSURLSessionDataTask *)personalCenterAPIsPostMemberPaymentSubmitPaymentWithAccessToken:(NSString *)token
                                                                          memberProductID:(NSString *)memberProductID
                                                                         invoicePayeeName:(NSString *)invoicePayeeName
                                                                                  success:(APIsConnectionSuccessBlock)success
                                                                                  failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!memberProductID) {
            memberProductID = @"";
        }
        if (!invoicePayeeName) {
            invoicePayeeName = @"";
        }
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"product_id":memberProductID,
                                     @"invoice_head":invoicePayeeName,
                                     @"android_ios":@"ios"};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMemberPaymentOrderSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


// 会员权益详情
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberRightsDetailWithAccessToken:(NSString *)token
                                                                             success:(APIsConnectionSuccessBlock)success
                                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserMemberRightsDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 会员成长列表
- (NSURLSessionDataTask *)personalCenterAPIsGetUserMemberHistoryListWithAccessToken:(NSString *)token
                                                                           pageNums:(NSNumber *)pageNums
                                                                          pageSizes:(NSNumber *)pageSizes
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @1;
        if (!pageSizes) pageSizes = @10;
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums};
        
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserMemberHistoryList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


#pragma mark /////#########/////技师模块/////##########/////
// 技师技能列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicSpecialListWithSuccess:(APIsConnectionSuccessBlock)success
                                                                      failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicSpecialList
                                           parameters:nil
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


// 技师列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicListWithFilterOption:(NSNumber *)filterOption
                                                                   pageNums:(NSNumber *)pageNums
                                                                  pageSizes:(NSNumber *)pageSizes
                                                              searchKeyword:(NSString *)searchKeyword
                                                      mechanicSpecialfilter:(NSString *)mechanicSpecialfilter
                                                         listFromRepairShop:(BOOL)listFromRepairShop
                                                               repairShopID:(NSString *)repairShopID
                                                                    success:(APIsConnectionSuccessBlock)success
                                                                    failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @(10);
        if (!searchKeyword) searchKeyword = @"";
        if (!mechanicSpecialfilter) mechanicSpecialfilter = @"";
        if (!repairShopID) repairShopID = @"";
        if (listFromRepairShop&&[repairShopID isEqualToString:@""]) listFromRepairShop = NO;
        if (!filterOption||filterOption.integerValue<0) filterOption = @0;
        if (!filterOption||filterOption.integerValue>4) filterOption = @4;
        
        NSDictionary *parameters = @{@"sorts":filterOption,
                                     @"page_size":pageSizes,
                                     @"page_no":pageNums,
                                     @"key_words":searchKeyword,
                                     @"select_item":mechanicSpecialfilter,
                                     @"wxs_id":repairShopID,
                                     @"type":@(listFromRepairShop)};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 技师详情
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicDetailWithAccessToken:(NSString *)token
                                                                  mechanicID:(NSString *)mechanicID
                                                                     success:(APIsConnectionSuccessBlock)success
                                                                     failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!token) token = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:mechanicID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicDetail
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 培训及荣誉
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicExpNCertsListWithMechanicID:(NSString *)mechanicID
                                                                           success:(APIsConnectionSuccessBlock)success
                                                                           failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        NSDictionary *parameters = @{kParameterOfID:mechanicID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicExpNCertsList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 技师评论列表
- (NSURLSessionDataTask *)mechanicCenterAPIsGetMechanicCommentListWithMechanicID:(NSString *)mechanicID
                                                                        pageNums:(NSNumber *)pageNums
                                                                       pageSizes:(NSNumber *)pageSizes
                                                                         success:(APIsConnectionSuccessBlock)success
                                                                         failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:mechanicID,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZMechanicCommentList
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

// 更新技师收藏状态
- (NSURLSessionDataTask *)mechanicCenterAPIsPostMechanicCollectionStatustWithAccessToken:(NSString *)token
                                                                              mechanicID:(NSString *)mechanicID
                                                                            toCollection:(BOOL)toCollection
                                                                                 success:(APIsConnectionSuccessBlock)success
                                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!token) token = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:mechanicID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:toCollection?kCDZMechanicUserCollected:kCDZMechanicUserUncollected
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

#pragma mark /////#########/////案例模块/////##########/////
/* 点击获取案列*/
- (NSURLSessionDataTask *)casesHistoryAPIsGetcaseSecondsuccess:(APIsConnectionSuccessBlock)success
                                                       failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryListStepOne
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/* 点击某个部位 获取案例第一级分类 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetCaseThirdWithAutosModelID:(NSString *)autosModelID
                                                                 idStr:(NSString *)idStr
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfID:idStr,
                                     @"speci":autosModelID};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryListStepTwo
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
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
                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!img||![img isContainsString:@"http"]) img = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"brand":brand,
                                     @"factory":factory,
                                     @"fct":fct,
                                     @"speci":autosModelID,
                                     @"car_number":carNumber,
                                     @"wxs_name":wsxName,
                                     @"address":address,
                                     @"wxs_tel":wxsTel,
                                     @"add_time":addTime,
                                     @"project":project,
                                     @"hour":hour,
                                     @"fee":fee,
                                     @"parts_name":partsName,
                                     @"parts_num":partsNum,
                                     @"parts_price":partsPrice,
                                     @"img":img};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfAddCase
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



/* 我的案例 */
- (NSURLSessionDataTask *)personalCenterAPIsGetMyCaseListWithAccessToken:(NSString *)token
                                                                pageNums:(NSNumber *)pageNums
                                                               pageSizes:(NSNumber *)pageSizes
                                                                 success:(APIsConnectionSuccessBlock)success
                                                                 failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums||pageNums.integerValue<=1) pageNums = @1;
        if (!pageSizes||pageSizes.integerValue<=1) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfMyCase
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

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
                                                             failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:idStr,
                                     @"brand":brand,
                                     @"factory":factory,
                                     @"fct":fct,
                                     @"speci":autosModelID,
                                     @"car_number":carNumber,
                                     @"wxs_name":wsxName,
                                     @"address":address,
                                     @"wxs_tel":wxsTel,
                                     @"add_time":addTime,
                                     @"project":project,
                                     @"hour":hour,
                                     @"fee":fee,
                                     @"parts_name":partsName,
                                     @"parts_num":partsNum,
                                     @"parts_price":partsPrice,
                                     @"img":img};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfEditCase
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

/* 删除案例 */
- (NSURLSessionDataTask *)casesHistoryAPIsGetDelCaseWithAccessToken:(NSString *)token
                                                              idStr:(NSString *)idStr
                                                            success:(APIsConnectionSuccessBlock)success
                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:idStr,
                                     };
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfDelCase
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//结算单图片上传
- (NSURLSessionDataTask *)casesHistoryAPIsGetStatementPicWithImage:(UIImage *)portraitImage
                                                         imageName:(NSString *)imageName
                                                         imageType:(ConnectionImageType)imageType
                                                           success:(APIsConnectionSuccessBlock)success
                                                           failure:(APIsConnectionFailureBlock)failure  {
    @autoreleasepool {
        NSString *imageTypeString = @"image/jpeg";
        NSString *imageExt = @"jpg";
        NSData *data = UIImageJPEGRepresentation(portraitImage, 0.8);
        if (ConnectionImageTypeOfPNG==imageType) {
            imageTypeString = @"image/png";
            imageExt = @"png";
            data = UIImagePNGRepresentation(portraitImage);
        }
        if (!imageName){
            imageName = @"userPortraitImage";
        }
        
        APIsConnectionFormData formData = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:[imageName stringByAppendingPathExtension:imageExt] mimeType:imageTypeString];
        };
        
        NSDictionary *parameters = @{@"root":@"repair-common"};
        NSURLSessionDataTask *operation = nil;
        operation = [self createImgUploadPostRequestWithRelativePath:kCDZCasesHistoryImageUploadJSDcdz
                                                          parameters:parameters
                                                            progress:nil
                                       constructingPOSTBodyWithBlock:formData
                                                             success:success
                                                             failure:failure];
        return operation;
    }
}

/* 查看案例评论 */
- (NSURLSessionDataTask *)personalCenterAPIsGetShowCaseCommentWithIDStr:(NSString *)idStr
                                                               pageNums:(NSNumber *)pageNums
                                                              pageSizes:(NSNumber *)pageSizes
                                                                success:(APIsConnectionSuccessBlock)success
                                                                failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        if (!pageNums) pageNums = @(1);
        if (!pageSizes) pageSizes = @10;
        NSDictionary *parameters = @{kParameterOfID:idStr,
                                     @"page_no":pageNums,
                                     @"page_size":pageSizes};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesHistoryOfShowCaseComment
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}



// 提交案例评论
- (NSURLSessionDataTask *)repairCaseAPIsPostCaseCommentWithAccessToken:(NSString *)token
                                                                caseID:(NSString *)caseID
                                                        commentContent:(NSString *)commentContent
                                                               success:(APIsConnectionSuccessBlock)success
                                                               failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        if (!caseID) caseID = @"";
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     kParameterOfID:caseID,
                                     @"content":commentContent};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZCasesCommentSubmit
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}

//一键报案
/*旧*/
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceInfoCheckWithtAccessToken:(NSString *)token
                                                                              success:(APIsConnectionSuccessBlock)success
                                                                              failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token,
                                     @"sign":@true};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:kCDZUserInsuranceInfoCheck
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}
/*新*/
- (NSURLSessionDataTask *)personalCenterAPIsGetUserInsuranceHotlineWithtAccessToken:(NSString *)token
                                                                            success:(APIsConnectionSuccessBlock)success
                                                                            failure:(APIsConnectionFailureBlock)failure {
    @autoreleasepool {
        
        NSDictionary *parameters = @{kParameterOfToken:token};
        
        NSURLSessionDataTask *operation = nil;
        operation = [self createRequestWithHTTPMethod:CDZAPIsHTTPMethodTypeOfGET
                                withFirstRelativePath:YES
                                         relativePath:@"personalConnect/OneKeyCall"
                                           parameters:parameters
                                             progress:nil
                        constructingPOSTBodyWithBlock:nil
                                              success:success
                                              failure:failure];
        return operation;
    }
}


@end
